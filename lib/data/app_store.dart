import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:intl/intl.dart';

import '../core/format.dart';
import 'models.dart';

class AppScope extends InheritedNotifier<AppStore> {
  const AppScope({super.key, required AppStore store, required super.child})
    : super(notifier: store);

  static AppStore watch(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'AppScope missing');
    return scope!.notifier!;
  }

  static AppStore read(BuildContext context) {
    final element = context.getElementForInheritedWidgetOfExactType<AppScope>();
    final scope = element?.widget as AppScope?;
    assert(scope != null, 'AppScope missing');
    return scope!.notifier!;
  }
}

class AppStore extends ChangeNotifier {
  // Keys predate the Paisa Flow rename; changing them would orphan saved data.
  static const _storageKey = 'hissabkitab_data_v1';
  static const _themeKey = 'hissabkitab_theme_mode';

  static const defaultCategories = [
    'Salary',
    'Freelance',
    'Gift',
    'Groceries',
    'Food',
    'Rent',
    'Utilities',
    'Transport',
    'Shopping',
    'Health',
  ];
  static const defaultPaymentModes = [
    'Cash',
    'eSewa',
    'Khalti',
    'Bank transfer',
    'Card',
  ];

  final List<LedgerBook> books = [];
  final List<LedgerTransaction> transactions = [];
  final List<SavingsGoal> goals = [];
  final List<TransactionLog> logs = [];
  final List<String> categories = [...defaultCategories];
  final List<String> paymentModes = [...defaultPaymentModes];
  UserProfile profile = const UserProfile();
  String defaultCurrency = 'NPR';
  ThemeMode themeMode = ThemeMode.system;
  bool isLoaded = false;

  /// Set when saved data couldn't be parsed on launch.
  String? loadError;

  /// False until the user finishes onboarding (or for data saved before
  /// onboarding existed, which counts as onboarded).
  bool onboarded = false;

  Future<void> load() async {
    final preferences = await SharedPreferences.getInstance();
    themeMode = ThemeMode.values.firstWhere(
      (item) => item.name == preferences.getString(_themeKey),
      orElse: () => ThemeMode.system,
    );
    final raw = preferences.getString(_storageKey);
    if (raw == null) {
      _seed();
    } else {
      try {
        _decode(raw);
      } catch (error, stack) {
        // Never leave the app blank or overwrite data we couldn't read: keep
        // the raw copy aside so it can be recovered, then start fresh.
        final backupKey =
            '${_storageKey}_unreadable_${DateTime.now().millisecondsSinceEpoch}';
        await preferences.setString(backupKey, raw);
        FlutterError.reportError(
          FlutterErrorDetails(
            exception: error,
            stack: stack,
            library: 'paisa_flow',
            context: ErrorDescription(
              'loading saved data (kept as $backupKey)',
            ),
          ),
        );
        loadError = 'Some saved data couldn’t be read. A copy was kept.';
        books.clear();
        transactions.clear();
        goals.clear();
        logs.clear();
        _seed();
      }
    }
    _recalculateAll();
    isLoaded = true;
    notifyListeners();
  }

  void _decode(String raw) {
    {
      final data = jsonDecode(raw) as Map<String, Object?>;
      final rawBooks = (data['books'] as List).cast<Map>();
      books
        ..clear()
        ..addAll([
          for (var i = 0; i < rawBooks.length; i++)
            LedgerBook.fromJson(rawBooks[i].cast(), index: i),
        ]);
      transactions
        ..clear()
        ..addAll(
          (data['transactions'] as List).cast<Map>().map(
            (item) => LedgerTransaction.fromJson(item.cast()),
          ),
        );
      final rawGoals = (data['goals'] as List? ?? const []).cast<Map>();
      goals
        ..clear()
        ..addAll([
          for (var i = 0; i < rawGoals.length; i++)
            SavingsGoal.fromJson(rawGoals[i].cast(), index: i),
        ]);
      logs
        ..clear()
        ..addAll(
          (data['logs'] as List? ?? const []).cast<Map>().map(
            (item) => TransactionLog.fromJson(item.cast()),
          ),
        );
      _loadLists(data, rawBooks);
      profile = UserProfile.fromJson(
        (data['profile'] as Map? ?? const {}).cast(),
      );
      defaultCurrency = data['defaultCurrency'] as String? ?? 'NPR';
      onboarded = data['onboarded'] as bool? ?? true;
      if (books.isEmpty) _seed();
    }
  }

  /// Categories and payment modes used to be stored per book. Older data is
  /// merged into the shared lists so nothing the user typed is lost.
  void _loadLists(Map<String, Object?> data, List<Map> rawBooks) {
    List<String> merge(String key, List<String> defaults) {
      final saved = (data[key] as List?)?.map((e) => e.toString()).toList();
      if (saved != null) return saved;
      final legacy = {
        for (final book in rawBooks)
          ...((book[key] as List?) ?? const []).map((e) => e.toString()),
      };
      return {...defaults, ...legacy}.toList();
    }

    categories
      ..clear()
      ..addAll(merge('categories', defaultCategories));
    paymentModes
      ..clear()
      ..addAll(merge('paymentModes', defaultPaymentModes));
  }

  Future<void> persist() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(
      _storageKey,
      jsonEncode({
        'books': books.map((item) => item.toJson()).toList(),
        'transactions': transactions.map((item) => item.toJson()).toList(),
        'goals': goals.map((item) => item.toJson()).toList(),
        'logs': logs.map((item) => item.toJson()).toList(),
        'categories': categories,
        'paymentModes': paymentModes,
        'profile': profile.toJson(),
        'defaultCurrency': defaultCurrency,
        'onboarded': onboarded,
      }),
    );
  }

  Future<void> _commit() async {
    await persist();
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    themeMode = mode;
    notifyListeners();
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_themeKey, mode.name);
  }

  Future<void> saveProfile(UserProfile value) async {
    profile = value;
    await _commit();
  }

  Future<void> completeOnboarding() async {
    onboarded = true;
    await _commit();
  }

  Future<void> setDefaultCurrency(String code) async {
    defaultCurrency = code;
    await _commit();
  }

  // ---------------------------------------------------------------------------
  // Books
  // ---------------------------------------------------------------------------

  LedgerBook? bookById(String id) {
    for (final book in books) {
      if (book.id == id) return book;
    }
    return null;
  }

  /// Books ordered by most recent activity, as shown on Home and Books.
  List<LedgerBook> get booksByRecent =>
      [...books]..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

  double balanceFor(String bookId) => transactions
      .where((transaction) => transaction.bookId == bookId)
      .fold(0, (total, transaction) => total + transaction.signedAmount);

  int entryCount(String bookId) =>
      transactions.where((transaction) => transaction.bookId == bookId).length;

  /// Newest first.
  List<LedgerTransaction> transactionsForBook(String bookId) {
    return transactions
        .where((transaction) => transaction.bookId == bookId)
        .toList()
      ..sort((a, b) {
        final date = b.occurredAt.compareTo(a.occurredAt);
        return date == 0 ? b.createdAt.compareTo(a.createdAt) : date;
      });
  }

  LedgerTransaction? transactionById(String id) {
    for (final transaction in transactions) {
      if (transaction.id == id) return transaction;
    }
    return null;
  }

  List<TransactionLog> logsFor(String transactionId) {
    return logs.where((log) => log.transactionId == transactionId).toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  /// Creates a book (with an optional opening balance entry) and returns its
  /// id, or renames an existing one. The currency only changes while the book
  /// has no entries.
  Future<String> saveBook({
    String? id,
    required String name,
    String? description,
    String? currency,
    double openingBalance = 0,
  }) async {
    final now = DateTime.now();
    final index = id == null ? -1 : books.indexWhere((book) => book.id == id);
    final trimmed = name.trim().isEmpty ? 'Untitled book' : name.trim();
    if (index == -1) {
      final book = LedgerBook(
        id: newId('book'),
        name: trimmed,
        description: description?.trim() ?? '',
        createdAt: now,
        updatedAt: now,
        currency: currency ?? defaultCurrency,
        colorValue: itemColors[books.length % itemColors.length],
      );
      books.add(book);
      if (openingBalance > 0) {
        final opening = LedgerTransaction(
          id: newId('txn'),
          bookId: book.id,
          title: 'Opening balance',
          amount: openingBalance,
          type: TransactionType.cashIn,
          occurredAt: now,
          createdAt: now,
          updatedAt: now,
          category: 'Opening balance',
          paymentMode: 'Cash',
          notes: '',
          goalId: null,
          runningBalance: 0,
          externalReference: '',
          statementBalance: null,
          sequence: 0,
          importSource: '',
        );
        transactions.add(opening);
        _addLog(opening.id, 'created', 'Entry created');
        _recalculateRunningBalance(book.id);
      }
      await _commit();
      return book.id;
    }
    final existing = books[index];
    books[index] = existing.copyWith(
      name: trimmed,
      description: description?.trim(),
      currency: entryCount(existing.id) == 0 ? currency : null,
      updatedAt: now,
    );
    await _commit();
    return existing.id;
  }

  Future<void> deleteBook(String id) async {
    books.removeWhere((book) => book.id == id);
    transactions.removeWhere((transaction) => transaction.bookId == id);
    _recalculateGoalProgress();
    await _commit();
  }

  // ---------------------------------------------------------------------------
  // Categories & payment modes
  // ---------------------------------------------------------------------------

  Future<void> addCategory(String name) => _addOption(categories, name);

  Future<void> addPaymentMode(String name) => _addOption(paymentModes, name);

  /// Renames an option and every entry that uses it.
  Future<void> renameCategory(String from, String to) =>
      _renameOption(categories, from, to, category: true);

  Future<void> renamePaymentMode(String from, String to) =>
      _renameOption(paymentModes, from, to, category: false);

  Future<void> _addOption(List<String> list, String name) async {
    final value = name.trim();
    if (value.isEmpty || list.contains(value)) return;
    list.add(value);
    await _commit();
  }

  Future<void> _renameOption(
    List<String> list,
    String from,
    String to, {
    required bool category,
  }) async {
    final value = to.trim();
    final index = list.indexOf(from);
    if (index == -1 || value.isEmpty || value == from) return;
    if (list.contains(value)) {
      list.removeAt(index);
    } else {
      list[index] = value;
    }
    for (var i = 0; i < transactions.length; i++) {
      final transaction = transactions[i];
      if (category && transaction.category == from) {
        transactions[i] = transaction.copyWith(category: value);
      } else if (!category && transaction.paymentMode == from) {
        transactions[i] = transaction.copyWith(paymentMode: value);
      }
    }
    await _commit();
  }

  // ---------------------------------------------------------------------------
  // Entries
  // ---------------------------------------------------------------------------

  Future<void> saveTransaction(LedgerTransaction transaction) async {
    final index = transactions.indexWhere((item) => item.id == transaction.id);
    if (index == -1) {
      transactions.add(transaction);
      _addLog(transaction.id, 'created', 'Entry created');
    } else {
      final before = transactions[index];
      transactions[index] = transaction.copyWith(updatedAt: DateTime.now());
      final currency = bookById(transaction.bookId)?.currency ?? 'NPR';
      for (final change in _describeChanges(before, transaction, currency)) {
        _addLog(transaction.id, 'updated', change);
      }
    }
    _touchBook(transaction.bookId);
    _recalculateAll();
    await _commit();
  }

  /// Human-readable edit history lines, e.g. "Amount Rs 3,200 → Rs 3,460".
  static List<String> _describeChanges(
    LedgerTransaction a,
    LedgerTransaction b,
    String currency,
  ) {
    String amount(double value) => money(value, currency);
    return [
      if (a.amount != b.amount)
        'Amount ${amount(a.amount)} → ${amount(b.amount)}',
      if (a.title != b.title) 'Title changed to “${b.title}”',
      if (a.category != b.category) 'Category ${a.category} → ${b.category}',
      if (a.paymentMode != b.paymentMode)
        'Payment mode ${a.paymentMode} → ${b.paymentMode}',
      if (a.type != b.type)
        'Type changed to ${b.type == TransactionType.cashIn ? 'cash in' : 'cash out'}',
      if (!sameDay(a.occurredAt, b.occurredAt) ||
          a.occurredAt.hour != b.occurredAt.hour ||
          a.occurredAt.minute != b.occurredAt.minute)
        'Date changed to ${DateFormat('d MMM y, h:mm a').format(b.occurredAt)}',
      if (a.notes != b.notes) 'Notes updated',
      if ((a.goalId ?? '') != (b.goalId ?? '')) 'Goal link updated',
    ];
  }

  Future<void> deleteTransaction(String id) async {
    final transaction = transactionById(id);
    if (transaction == null) return;
    transactions.removeWhere((item) => item.id == id);
    _addLog(id, 'deleted', 'Entry deleted');
    _touchBook(transaction.bookId);
    _recalculateAll();
    await _commit();
  }

  // ---------------------------------------------------------------------------
  // Goals
  // ---------------------------------------------------------------------------

  Future<void> saveGoal({
    String? id,
    required String name,
    required double targetAmount,
    required double manualSaved,
    DateTime? deadline,
  }) async {
    final index = id == null ? -1 : goals.indexWhere((goal) => goal.id == id);
    final goal = SavingsGoal(
      id: id ?? newId('goal'),
      name: name.trim(),
      targetAmount: targetAmount,
      manualSaved: manualSaved,
      savedAmount: manualSaved,
      deadline: deadline,
      colorValue: index == -1
          ? itemColors[goals.length % itemColors.length]
          : goals[index].colorValue,
    );
    if (index == -1) {
      goals.add(goal);
    } else {
      goals[index] = goal;
    }
    _recalculateGoalProgress();
    await _commit();
  }

  Future<void> deleteGoal(String id) async {
    goals.removeWhere((goal) => goal.id == id);
    for (var i = 0; i < transactions.length; i++) {
      if (transactions[i].goalId == id) {
        transactions[i] = transactions[i].copyWith(goalId: '');
      }
    }
    await _commit();
  }

  int linkedEntries(String goalId) =>
      transactions.where((transaction) => transaction.goalId == goalId).length;

  // ---------------------------------------------------------------------------
  // Import
  // ---------------------------------------------------------------------------

  ImportPreview previewImport({
    required String bookId,
    required String source,
    required List<LedgerTransaction> parsed,
    required List<String> ignored,
  }) {
    // Counted rather than a set: a statement can legitimately contain two
    // identical rows, and only as many as already exist are duplicates.
    final existing = <String, int>{};
    for (final transaction in transactionsForBook(bookId)) {
      final key = _duplicateKey(transaction);
      existing[key] = (existing[key] ?? 0) + 1;
    }
    final importable = <LedgerTransaction>[];
    final duplicates = <LedgerTransaction>[];
    for (final transaction in parsed) {
      final key = _duplicateKey(transaction);
      final remaining = existing[key] ?? 0;
      if (remaining > 0) {
        existing[key] = remaining - 1;
        duplicates.add(transaction);
      } else {
        importable.add(transaction);
      }
    }
    return ImportPreview(
      source: source,
      importable: importable,
      duplicates: duplicates,
      ignored: ignored,
    );
  }

  Future<void> commitImport(ImportPreview preview) async {
    transactions.addAll(preview.importable);
    for (final transaction in preview.importable) {
      _addLog(transaction.id, 'imported', 'Imported from ${preview.source}');
      _touchBook(transaction.bookId);
    }
    _recalculateAll();
    await persist();
    notifyListeners();
  }

  void _seed() {
    final now = DateTime.now();
    books.add(
      LedgerBook(
        id: 'book_default',
        name: 'Personal',
        description: '',
        createdAt: now,
        updatedAt: now,
      ),
    );
  }

  void _touchBook(String bookId) {
    final index = books.indexWhere((book) => book.id == bookId);
    if (index != -1) {
      books[index] = books[index].copyWith(updatedAt: DateTime.now());
    }
  }

  void _addLog(String transactionId, String action, String details) {
    logs.add(
      TransactionLog(
        id: newId('log'),
        transactionId: transactionId,
        action: action,
        details: details,
        timestamp: DateTime.now(),
      ),
    );
  }

  void _recalculateAll() {
    for (final book in books) {
      _recalculateRunningBalance(book.id);
    }
    _recalculateGoalProgress();
  }

  void _recalculateRunningBalance(String bookId) {
    final positions = <String, int>{};
    for (var i = 0; i < transactions.length; i++) {
      if (transactions[i].bookId == bookId) positions[transactions[i].id] = i;
    }
    final sorted = [for (final i in positions.values) transactions[i]]
      ..sort((a, b) {
        final date = a.occurredAt.compareTo(b.occurredAt);
        return date == 0 ? a.createdAt.compareTo(b.createdAt) : date;
      });
    var balance = 0.0;
    for (final transaction in sorted) {
      balance += transaction.signedAmount;
      transactions[positions[transaction.id]!] = transaction.copyWith(
        runningBalance: balance,
      );
    }
  }

  void _recalculateGoalProgress() {
    for (var i = 0; i < goals.length; i++) {
      final goal = goals[i];
      final linked = transactions
          .where(
            (transaction) =>
                transaction.goalId == goal.id &&
                transaction.type == TransactionType.cashIn,
          )
          .fold<double>(0, (total, transaction) => total + transaction.amount);
      goals[i] = goal.copyWith(savedAmount: goal.manualSaved + linked);
    }
  }

  /// Identifies the same real-world transaction across overlapping
  /// statements. The statement's running balance pins a row to one point in
  /// the account history, so the description (whose line wrapping can differ
  /// between exports) and the row position are deliberately left out.
  String _duplicateKey(LedgerTransaction transaction) {
    // References alone are not unique: eSewa reuses a transfer's code for
    // its fee row, so the amount and direction are part of the key.
    final reference = transaction.externalReference.trim().toLowerCase();
    if (reference.isNotEmpty) {
      return [
        'ref',
        transaction.bookId,
        reference,
        transaction.type.name,
        transaction.amount.toStringAsFixed(2),
      ].join('|');
    }
    final day = DateTime(
      transaction.occurredAt.year,
      transaction.occurredAt.month,
      transaction.occurredAt.day,
    ).toIso8601String();
    final balance = transaction.statementBalance;
    return [
      transaction.bookId,
      day,
      transaction.type.name,
      transaction.amount.toStringAsFixed(2),
      if (balance != null)
        'bal:${balance.toStringAsFixed(2)}'
      else
        transaction.title.trim().toLowerCase(),
    ].join('|');
  }

  static String newId(String prefix) {
    return '${prefix}_${DateTime.now().microsecondsSinceEpoch}_${Random().nextInt(99999)}';
  }
}
