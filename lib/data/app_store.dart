import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:intl/intl.dart';

import '../core/format.dart';
import 'models.dart';
import 'split.dart';

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
  static const _languageKey = 'paisaflow_language';

  /// UI languages: English and Nepali.
  static const languages = ['en', 'ne'];

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
  final List<Friend> friends = [];
  final List<SplitGroup> groups = [];
  final List<SplitBill> bills = [];

  /// Book that split bills and settle-ups were last recorded in.
  String? lastSplitBookId;
  String defaultCurrency = 'NPR';
  ThemeMode themeMode = ThemeMode.system;
  String language = 'en';
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
    final savedLanguage = preferences.getString(_languageKey);
    language = languages.contains(savedLanguage) ? savedLanguage! : 'en';
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
        // This is an existing user; don't send them through onboarding.
        onboarded = true;
        books.clear();
        transactions.clear();
        goals.clear();
        logs.clear();
        friends.clear();
        groups.clear();
        bills.clear();
        lastSplitBookId = null;
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
      List<Map<String, Object?>> list(String key) =>
          (data[key] as List? ?? const [])
              .cast<Map>()
              .map((m) => m.cast<String, Object?>())
              .toList();
      friends
        ..clear()
        ..addAll(list('friends').map(Friend.fromJson));
      groups
        ..clear()
        ..addAll(list('groups').map(SplitGroup.fromJson));
      bills
        ..clear()
        ..addAll(list('bills').map(SplitBill.fromJson));
      lastSplitBookId = data['lastSplitBookId'] as String?;
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
        'friends': friends.map((item) => item.toJson()).toList(),
        'groups': groups.map((item) => item.toJson()).toList(),
        'bills': bills.map((item) => item.toJson()).toList(),
        'lastSplitBookId': lastSplitBookId,
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

  Future<void> setLanguage(String code) async {
    if (!languages.contains(code)) return;
    language = code;
    notifyListeners();
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_languageKey, code);
  }

  Future<void> saveProfile(UserProfile value) async {
    profile = value;
    await _commit();
  }

  Future<void> completeOnboarding() async {
    onboarded = true;
    await _commit();
  }

  /// Last onboarding step: turns the untouched starter book into the user's
  /// first book (or adds one if they already have data), then finishes
  /// onboarding.
  Future<void> finishSetup({
    required String name,
    required String currency,
    double openingBalance = 0,
  }) async {
    if (books.length == 1 && entryCount(books.single.id) == 0) {
      books.clear();
    }
    defaultCurrency = currency;
    // Set before saving so the book and the flag land in the same write; a
    // kill in between can't send the user through setup twice.
    onboarded = true;
    await saveBook(
      name: name,
      currency: currency,
      openingBalance: openingBalance,
    );
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
        _addLog(opening.id, 'created', 'Entry created', code: 'created');
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
      _addLog(transaction.id, 'created', 'Entry created', code: 'created');
    } else {
      final before = transactions[index];
      transactions[index] = transaction.copyWith(updatedAt: DateTime.now());
      final currency = bookById(transaction.bookId)?.currency ?? 'NPR';
      for (final (details, code, args) in _describeChanges(
        before,
        transaction,
        currency,
      )) {
        _addLog(transaction.id, 'updated', details, code: code, args: args);
      }
    }
    _touchBook(transaction.bookId);
    _recalculateAll();
    await _commit();
  }

  /// Edit history lines: English text plus a code and values the UI
  /// words in the current language (e.g. `amount`, [Rs 3,200, Rs 3,460]).
  static List<(String, String, List<String>)> _describeChanges(
    LedgerTransaction a,
    LedgerTransaction b,
    String currency,
  ) {
    String amount(double value) => money(value, currency);
    final when = DateFormat('d MMM y, h:mm a').format(b.occurredAt);
    final toIn = b.type == TransactionType.cashIn;
    return [
      if (a.amount != b.amount)
        (
          'Amount ${amount(a.amount)} → ${amount(b.amount)}',
          'amount',
          [amount(a.amount), amount(b.amount)],
        ),
      if (a.title != b.title)
        ('Title changed to “${b.title}”', 'title', [b.title]),
      if (a.category != b.category)
        (
          'Category ${a.category} → ${b.category}',
          'category',
          [a.category, b.category],
        ),
      if (a.paymentMode != b.paymentMode)
        (
          'Payment mode ${a.paymentMode} → ${b.paymentMode}',
          'mode',
          [a.paymentMode, b.paymentMode],
        ),
      if (a.type != b.type)
        (
          'Type changed to ${toIn ? 'cash in' : 'cash out'}',
          toIn ? 'typeIn' : 'typeOut',
          const <String>[],
        ),
      if (!sameDay(a.occurredAt, b.occurredAt) ||
          a.occurredAt.hour != b.occurredAt.hour ||
          a.occurredAt.minute != b.occurredAt.minute)
        ('Date changed to $when', 'date', [when]),
      if (a.notes != b.notes) ('Notes updated', 'notes', const <String>[]),
      if ((a.goalId ?? '') != (b.goalId ?? ''))
        ('Goal link updated', 'goal', const <String>[]),
    ];
  }

  Future<void> deleteTransaction(String id) async {
    final transaction = transactionById(id);
    if (transaction == null) return;
    transactions.removeWhere((item) => item.id == id);
    _addLog(id, 'deleted', 'Entry deleted', code: 'deleted');
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
  // Split bills
  // ---------------------------------------------------------------------------

  Friend? friendById(String id) {
    for (final friend in friends) {
      if (friend.id == id) return friend;
    }
    return null;
  }

  /// Books a split in [currency] can be recorded in (default: home).
  List<LedgerBook> splitBooks([String? currency]) => booksByRecent
      .where((book) => book.currency == (currency ?? defaultCurrency))
      .toList();

  /// The last-used split book if it qualifies, else the most recent one.
  String? defaultSplitBookId([String? currency]) {
    final candidates = splitBooks(currency);
    for (final book in candidates) {
      if (book.id == lastSplitBookId) return book.id;
    }
    return candidates.firstOrNull?.id;
  }

  /// Friend id → net amount they owe you across groups and bills in the
  /// home currency (negative when you owe them). Other currencies are never
  /// mixed into these totals.
  Map<String, double> get friendBalances {
    final totals = <String, double>{};
    for (final balances in [
      for (final group in groups)
        if (group.currency == defaultCurrency) group.balances,
      for (final bill in bills)
        if (bill.currency == defaultCurrency) bill.balances,
    ]) {
      for (final e in balances.entries) {
        totals[e.key] = (totals[e.key] ?? 0) + e.value;
      }
    }
    return totals;
  }

  double get owedToYou =>
      friendBalances.values.where((v) => v > 0).fold(0, (sum, v) => sum + v);

  double get youOwe =>
      friendBalances.values.where((v) => v < 0).fold(0, (sum, v) => sum - v);

  Future<Friend> addFriend(String name) async {
    final trimmed = name.trim();
    final existing = friends
        .where((f) => f.name.toLowerCase() == trimmed.toLowerCase())
        .firstOrNull;
    if (existing != null) return existing;
    final friend = Friend(
      id: newId('friend'),
      name: trimmed,
      colorValue: friendColors[friends.length % friendColors.length],
    );
    friends.add(friend);
    await _commit();
    return friend;
  }

  Future<String> saveGroup({
    String? id,
    required String name,
    required List<String> memberIds,
  }) async {
    final index = id == null ? -1 : groups.indexWhere((g) => g.id == id);
    final trimmed = name.trim().isEmpty ? 'Untitled group' : name.trim();
    if (index == -1) {
      final group = SplitGroup(
        id: newId('group'),
        name: trimmed,
        memberIds: memberIds,
        createdAt: DateTime.now(),
        currency: defaultCurrency,
      );
      groups.add(group);
      await _commit();
      return group.id;
    }
    // Members with expenses or a balance can't be dropped.
    final current = groups[index];
    final involved = {
      for (final e in current.expenses) ...[e.paidBy, ...e.shares.keys],
      for (final s in current.settlements) s.friendId,
    };
    groups[index] = current.copyWith(
      name: trimmed,
      memberIds: {
        ...memberIds,
        ...current.memberIds.where(involved.contains),
      }.toList(),
    );
    await _commit();
    return current.id;
  }

  Future<void> deleteGroup(String id) async {
    groups.removeWhere((g) => g.id == id);
    await _commit();
  }

  /// Adds an expense; when you paid and [recordInBookId] is set, the full
  /// amount is also posted as cash out in that book.
  Future<void> addGroupExpense({
    required String groupId,
    required String title,
    required double amount,
    required String paidBy,
    required Shares shares,
    String? recordInBookId,
  }) async {
    final index = groups.indexWhere((g) => g.id == groupId);
    if (index == -1) return;
    final group = groups[index];
    amount = roundMoney(amount);
    String? entryId;
    if (paidBy == me && recordInBookId != null) {
      entryId = _postSplitEntry(
        bookId: recordInBookId,
        type: TransactionType.cashOut,
        amount: amount,
        title: '$title (${group.name})',
        category: _spendCategory,
        log: 'Created from ${group.name} split',
        logCode: 'splitGroup',
        logArgs: [group.name],
      );
    }
    groups[index] = group.copyWith(
      expenses: [
        GroupExpense(
          id: newId('expense'),
          title: title.trim().isEmpty ? 'Expense' : title.trim(),
          amount: amount,
          paidBy: paidBy,
          shares: shares,
          createdAt: DateTime.now(),
          transactionId: entryId,
        ),
        ...group.expenses,
      ],
    );
    await _afterSplitChange(bookId: paidBy == me ? recordInBookId : null);
  }

  Future<void> deleteGroupExpense(String groupId, String expenseId) async {
    final index = groups.indexWhere((g) => g.id == groupId);
    if (index == -1) return;
    final group = groups[index];
    groups[index] = group.copyWith(
      expenses: group.expenses.where((e) => e.id != expenseId).toList(),
    );
    await _commit();
  }

  /// Clears what [friendId] owes you in a group (or what you owe them) and
  /// records the payment in [bookId].
  Future<double> settleGroup({
    required String groupId,
    required String friendId,
    required String bookId,
  }) async {
    final index = groups.indexWhere((g) => g.id == groupId);
    if (index == -1) return 0;
    final group = groups[index];
    final amount = group.balances[friendId] ?? 0;
    if (amount.abs() < .005) return 0;
    final settlement = _settle(friendId, amount, bookId, group.name);
    groups[index] = group.copyWith(
      settlements: [...group.settlements, settlement],
    );
    await _afterSplitChange(bookId: bookId);
    return amount;
  }

  /// Saves a one-off bill you paid. When [recordInBookId] is set the full
  /// amount is posted as cash out; [linkedEntryId] links an existing entry
  /// (from "Split this bill") instead.
  Future<SplitBill> saveBill({
    required String title,
    required double amount,
    required Shares shares,
    String? recordInBookId,
    String? linkedEntryId,
  }) async {
    final name = title.trim().isEmpty ? 'Bill' : title.trim();
    amount = roundMoney(amount);
    final entryId =
        linkedEntryId ??
        (recordInBookId == null
            ? null
            : _postSplitEntry(
                bookId: recordInBookId,
                type: TransactionType.cashOut,
                amount: amount,
                title: '$name (split)',
                category: _spendCategory,
                log: 'Created from split bill',
                logCode: 'splitBill',
              ));
    final bill = SplitBill(
      id: newId('bill'),
      title: name,
      amount: amount,
      shares: shares,
      createdAt: DateTime.now(),
      currency: defaultCurrency,
      transactionId: entryId,
    );
    bills.insert(0, bill);
    await _afterSplitChange(bookId: recordInBookId);
    return bill;
  }

  Future<double> settleBill({
    required String billId,
    required String friendId,
    required String bookId,
  }) async {
    final index = bills.indexWhere((b) => b.id == billId);
    if (index == -1) return 0;
    final bill = bills[index];
    final amount = bill.balances[friendId] ?? 0;
    if (amount.abs() < .005) return 0;
    final settlement = _settle(friendId, amount, bookId, bill.title);
    bills[index] = bill.copyWith(
      settlements: [...bill.settlements, settlement],
    );
    await _afterSplitChange(bookId: bookId);
    return amount;
  }

  Future<void> deleteBill(String id) async {
    bills.removeWhere((b) => b.id == id);
    await _commit();
  }

  /// Category for split costs: Food if the user has it, else the first one.
  String get _spendCategory => categories.contains('Food')
      ? 'Food'
      : (categories.firstOrNull ?? 'General');

  /// The bill created by splitting [entryId], if any.
  SplitBill? billForEntry(String entryId) =>
      bills.where((b) => b.transactionId == entryId).firstOrNull;

  /// Whether [entryId] was posted by a split (expense or settlement), so it
  /// shouldn't be split again.
  bool isSplitEntry(String entryId) =>
      groups.any(
        (g) =>
            g.expenses.any((e) => e.transactionId == entryId) ||
            g.settlements.any((s) => s.transactionId == entryId),
      ) ||
      bills.any((b) => b.settlements.any((s) => s.transactionId == entryId));

  Settlement _settle(
    String friendId,
    double amount,
    String bookId,
    String source,
  ) {
    final friend = friendById(friendId)?.name ?? 'friend';
    if (!categories.contains('Settlement')) categories.add('Settlement');
    final entryId = _postSplitEntry(
      bookId: bookId,
      type: amount > 0 ? TransactionType.cashIn : TransactionType.cashOut,
      amount: amount.abs(),
      title: 'Settlement · $friend',
      category: 'Settlement',
      log: 'Settled from $source',
      logCode: 'settled',
      logArgs: [source],
    );
    return Settlement(
      id: newId('settle'),
      friendId: friendId,
      amount: amount,
      at: DateTime.now(),
      transactionId: entryId,
    );
  }

  String _postSplitEntry({
    required String bookId,
    required TransactionType type,
    required double amount,
    required String title,
    required String category,
    required String log,
    required String logCode,
    List<String> logArgs = const [],
  }) {
    final now = DateTime.now();
    final entry = LedgerTransaction(
      id: newId('txn'),
      bookId: bookId,
      title: title,
      amount: amount,
      type: type,
      occurredAt: now,
      createdAt: now,
      updatedAt: now,
      category: category,
      paymentMode: 'Cash',
      notes: '',
      goalId: null,
      runningBalance: 0,
      externalReference: '',
      statementBalance: null,
      sequence: 0,
      importSource: '',
    );
    transactions.add(entry);
    _addLog(entry.id, 'created', log, code: logCode, args: logArgs);
    _touchBook(bookId);
    return entry.id;
  }

  Future<void> _afterSplitChange({String? bookId}) async {
    if (bookId != null) lastSplitBookId = bookId;
    _recalculateAll();
    await _commit();
  }

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
      _addLog(
        transaction.id,
        'imported',
        'Imported from ${preview.source}',
        code: 'imported',
        args: [preview.source],
      );
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

  void _addLog(
    String transactionId,
    String action,
    String details, {
    String? code,
    List<String> args = const [],
  }) {
    logs.add(
      TransactionLog(
        id: newId('log'),
        transactionId: transactionId,
        action: action,
        details: details,
        timestamp: DateTime.now(),
        code: code,
        args: args,
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
