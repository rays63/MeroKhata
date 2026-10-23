import 'dart:convert';
import 'dart:math';

import 'package:cryptography/cryptography.dart';
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
  static const _bookFiltersKey = 'paisaflow_book_filters';
  static const _typePromptLaterKey = 'paisaflow_type_prompt_later';
  static const _recentSearchesKey = 'paisaflow_recent_searches';
  static const _lastBackupKey = 'paisaflow_last_backup';
  static const _backupSnoozeKey = 'paisaflow_backup_snooze';
  static const _appLockKey = 'paisaflow_app_lock';
  static const _insightsLayoutKey = 'paisaflow_insights_layout';

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

  /// Entries the user saved with ★ to fill the form in one tap.
  final List<EntryTemplate> templates = [];

  /// Entries that come due on a schedule (never added without asking).
  final List<RecurringEntry> recurring = [];

  /// Second-level names under each category (Food → Lunch, Groceries…).
  final Map<String, List<String>> subcategories = {};

  /// Monthly spending limits.
  final List<Budget> budgets = [];

  /// Tags the user created, including ones no entry uses yet. Tags on entries
  /// are always listed too (see [allTags]).
  final List<String> tags = [];
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
    typePromptLater = preferences.getBool(_typePromptLaterKey) ?? false;
    recentSearches
      ..clear()
      ..addAll(preferences.getStringList(_recentSearchesKey) ?? const []);
    lastBackupAt = DateTime.tryParse(
      preferences.getString(_lastBackupKey) ?? '',
    );
    backupSnoozedUntil = DateTime.tryParse(
      preferences.getString(_backupSnoozeKey) ?? '',
    );
    _loadAppLock(preferences.getString(_appLockKey));
    _loadInsightsLayout(preferences.getString(_insightsLayoutKey));
    _bookFilters.clear();
    try {
      final saved = jsonDecode(preferences.getString(_bookFiltersKey) ?? '{}');
      for (final MapEntry(:key, :value) in (saved as Map).entries) {
        _bookFilters[key as String] = (value as Map).cast<String, String>();
      }
    } catch (_) {
      // Filters are a convenience; unreadable ones just reset.
    }
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
      templates
        ..clear()
        ..addAll(list('templates').map(EntryTemplate.fromJson));
      recurring
        ..clear()
        ..addAll(list('recurring').map(RecurringEntry.fromJson));
      budgets
        ..clear()
        ..addAll(list('budgets').map(Budget.fromJson));
      subcategories
        ..clear()
        ..addAll({
          for (final MapEntry(:key, :value)
              in (data['subcategories'] as Map? ?? const {}).entries)
            key as String: [for (final v in value as List) '$v'],
        });
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
    tags
      ..clear()
      ..addAll([
        for (final tag in data['tags'] as List? ?? const [])
          if (normalizeTag(tag.toString()) case final name when name.isNotEmpty)
            name,
      ]);
  }

  Future<void> persist() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_storageKey, jsonEncode(snapshot()));
  }

  /// Everything the app keeps about the user's money, as saved on the phone
  /// and in backups.
  Map<String, Object?> snapshot() => {
    'books': books.map((item) => item.toJson()).toList(),
    'transactions': transactions.map((item) => item.toJson()).toList(),
    'goals': goals.map((item) => item.toJson()).toList(),
    'logs': logs.map((item) => item.toJson()).toList(),
    'categories': categories,
    'paymentModes': paymentModes,
    'tags': tags,
    'templates': templates.map((item) => item.toJson()).toList(),
    'recurring': recurring.map((item) => item.toJson()).toList(),
    'subcategories': subcategories,
    'budgets': budgets.map((item) => item.toJson()).toList(),
    'profile': profile.toJson(),
    'defaultCurrency': defaultCurrency,
    'onboarded': onboarded,
    'friends': friends.map((item) => item.toJson()).toList(),
    'groups': groups.map((item) => item.toJson()).toList(),
    'bills': bills.map((item) => item.toJson()).toList(),
    'lastSplitBookId': lastSplitBookId,
  };

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

  // ---------------------------------------------------------------------------
  // Book filters (remembered per book, saved on the phone)
  // ---------------------------------------------------------------------------

  final Map<String, Map<String, String>> _bookFilters = {};

  /// The filters last used in [bookId]'s ledger: keys `range`, `category`,
  /// `mode` and `type`; missing keys mean "all".
  Map<String, String> bookFilters(String bookId) =>
      Map.unmodifiable(_bookFilters[bookId] ?? const {});

  Future<void> saveBookFilters(
    String bookId,
    Map<String, String> filters,
  ) async {
    if (filters.isEmpty) {
      _bookFilters.remove(bookId);
    } else {
      _bookFilters[bookId] = Map.of(filters);
    }
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_bookFiltersKey, jsonEncode(_bookFilters));
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
      type: AccountType.cash,
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

  /// Accounts made before types existed (still counted as Other).
  List<LedgerBook> get untypedBooks =>
      books.where((book) => book.type == null).toList();

  /// The user tapped "Later" on Home's set-a-type prompt.
  bool typePromptLater = false;

  Future<void> dismissTypePrompt() async {
    typePromptLater = true;
    notifyListeners();
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(_typePromptLaterKey, true);
  }

  /// Currencies in use, the default currency first.
  List<String> get accountCurrencies {
    final seen = <String>{};
    for (final book in books) {
      seen.add(book.currency);
    }
    return [
      if (seen.remove(defaultCurrency)) defaultCurrency,
      ...seen.toList()..sort(),
    ];
  }

  /// Assets, what is owed on Card and Loan accounts, and net worth for one
  /// currency. Never converted across currencies.
  AccountTotals totalsFor(String currency) {
    var assets = 0.0, owed = 0.0;
    for (final book in books) {
      if (book.currency != currency) continue;
      final balance = balanceFor(book.id);
      if (book.isLiability) {
        owed -= balance;
      } else {
        assets += balance;
      }
    }
    return AccountTotals(assets: assets, owed: owed);
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

  /// Searches the user ran, newest first (kept on this phone only).
  final List<String> recentSearches = [];

  Future<void> addRecentSearch(String query) async {
    final value = query.trim();
    if (value.isEmpty) return;
    recentSearches
      ..remove(value)
      ..insert(0, value);
    if (recentSearches.length > 6) recentSearches.removeLast();
    notifyListeners();
    final preferences = await SharedPreferences.getInstance();
    await preferences.setStringList(_recentSearchesKey, recentSearches);
  }

  Future<void> clearRecentSearches() async {
    recentSearches.clear();
    notifyListeners();
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_recentSearchesKey);
  }

  /// Entries across every account matching [query] in the title, notes,
  /// category, payment mode, reference, tags ("#wedding") or amount
  /// ("5000"), newest first. A transfer appears once.
  List<LedgerTransaction> search(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return const [];
    final tagQuery = q.startsWith('#') ? normalizeTag(q) : null;
    final number = double.tryParse(q.replaceAll(',', ''));
    bool matches(LedgerTransaction e) {
      if (tagQuery != null) return e.tags.any((t) => t.contains(tagQuery));
      if (number != null && e.amount == number) return true;
      return [
        e.title,
        e.notes,
        e.category,
        e.subcategory,
        e.paymentMode,
        e.externalReference,
        ...e.tags,
      ].any((field) => field.toLowerCase().contains(q));
    }

    return [
      for (final entry in entriesNewestFirst)
        if (!entry.isTransferMirror && matches(entry)) entry,
    ];
  }

  /// Every account's entries, newest first.
  List<LedgerTransaction> get entriesNewestFirst =>
      [...transactions]..sort((a, b) {
        final date = b.occurredAt.compareTo(a.occurredAt);
        return date == 0 ? b.createdAt.compareTo(a.createdAt) : date;
      });

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
    AccountType? type,
  }) async {
    final now = DateTime.now();
    final index = id == null ? -1 : books.indexWhere((book) => book.id == id);
    final trimmed = name.trim().isEmpty ? 'Untitled account' : name.trim();
    if (index == -1) {
      final book = LedgerBook(
        id: newId('book'),
        name: trimmed,
        description: description?.trim() ?? '',
        createdAt: now,
        updatedAt: now,
        currency: currency ?? defaultCurrency,
        colorValue: itemColors[books.length % itemColors.length],
        type: type ?? AccountType.other,
      );
      books.add(book);
      if (openingBalance > 0) {
        // On a Card or Loan the opening amount is what is already owed.
        final opening = LedgerTransaction(
          id: newId('txn'),
          bookId: book.id,
          title: 'Opening balance',
          amount: openingBalance,
          type: book.isLiability
              ? TransactionType.cashOut
              : TransactionType.cashIn,
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
      type: type,
    );
    await _commit();
    return existing.id;
  }

  Future<void> deleteBook(String id) async {
    books.removeWhere((book) => book.id == id);
    transactions.removeWhere((transaction) => transaction.bookId == id);
    templates.removeWhere((template) => template.bookId == id);
    budgets.removeWhere((b) => b.scope == 'account:$id');
    recurring.removeWhere((r) => r.bookId == id || r.toBookId == id);
    _recalculateGoalProgress();
    await _commit();
    if (_bookFilters.containsKey(id)) await saveBookFilters(id, const {});
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

  /// Removes an option from the picker. Entries that use it keep it.
  Future<void> removeCategory(String name) => _removeOption(categories, name);

  Future<void> removePaymentMode(String name) =>
      _removeOption(paymentModes, name);

  Future<void> _removeOption(List<String> list, String name) async {
    if (!list.remove(name)) return;
    await _commit();
  }

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
    if (category) {
      final subs = subcategories.remove(from);
      if (subs != null) {
        final into = subcategories[value] ??= [];
        into.addAll(subs.where((s) => !into.contains(s)));
      }
      for (var i = 0; i < budgets.length; i++) {
        if (budgets[i].category == from) {
          budgets[i] = Budget(
            id: budgets[i].id,
            scope: budgets[i].scope,
            amount: budgets[i].amount,
            category: value,
          );
        }
      }
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
    _rememberTags(transaction.tags);
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
      if (a.tags.join(',') != b.tags.join(','))
        ('Tags updated', 'tags', const <String>[]),
    ];
  }

  // ---------------------------------------------------------------------------
  // Insights layout
  // ---------------------------------------------------------------------------

  /// Insights cards in the default order.
  static const insightsCards = [
    'charts',
    'boxes',
    'places',
    'trends',
    'modes',
    'tags',
  ];

  /// The user's order of the Insights cards (kept on this phone).
  List<String> insightsOrder = [...insightsCards];
  final Set<String> insightsHidden = {};

  void _loadInsightsLayout(String? raw) {
    insightsOrder = [...insightsCards];
    insightsHidden.clear();
    if (raw == null) return;
    try {
      final json = (jsonDecode(raw) as Map).cast<String, Object?>();
      final order = [
        for (final id in json['order'] as List? ?? const [])
          if (insightsCards.contains(id)) id as String,
      ];
      // Cards added in a later version go at the end.
      insightsOrder = [
        ...order,
        for (final id in insightsCards)
          if (!order.contains(id)) id,
      ];
      insightsHidden.addAll([
        for (final id in json['hidden'] as List? ?? const [])
          if (insightsCards.contains(id)) id as String,
      ]);
    } catch (_) {}
  }

  Future<void> saveInsightsLayout(
    List<String> order,
    Set<String> hidden,
  ) async {
    insightsOrder = [...order];
    insightsHidden
      ..clear()
      ..addAll(hidden);
    notifyListeners();
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(
      _insightsLayoutKey,
      jsonEncode({
        'order': insightsOrder,
        'hidden': [...insightsHidden],
      }),
    );
  }

  // ---------------------------------------------------------------------------
  // App lock
  // ---------------------------------------------------------------------------

  /// Wrong PINs allowed before a 30-second wait.
  static const maxPinAttempts = 5;
  static const pinLockout = Duration(seconds: 30);

  String? _pinSalt;
  String? _pinHash;

  bool get appLockEnabled => _pinHash != null;

  /// Fingerprint or face unlock, on top of the PIN.
  bool lockBiometrics = false;

  /// How long the app may sit in the background before it locks again.
  Duration lockAfter = Duration.zero;

  int failedPinAttempts = 0;
  DateTime? pinLockedUntil;

  void _loadAppLock(String? raw) {
    _pinSalt = _pinHash = null;
    lockBiometrics = false;
    lockAfter = Duration.zero;
    failedPinAttempts = 0;
    pinLockedUntil = null;
    if (raw == null) return;
    try {
      final json = (jsonDecode(raw) as Map).cast<String, Object?>();
      _pinSalt = json['salt'] as String?;
      _pinHash = json['hash'] as String?;
      lockBiometrics = json['biometrics'] == true;
      lockAfter = Duration(seconds: json['after'] as int? ?? 0);
      failedPinAttempts = json['failed'] as int? ?? 0;
      pinLockedUntil = DateTime.tryParse(json['lockedUntil'] as String? ?? '');
    } catch (_) {
      // Unreadable settings: stay locked out of nothing, but don't crash.
    }
  }

  Future<void> _saveAppLock() async {
    notifyListeners();
    final preferences = await SharedPreferences.getInstance();
    if (_pinHash == null) {
      await preferences.remove(_appLockKey);
      return;
    }
    await preferences.setString(
      _appLockKey,
      jsonEncode({
        'salt': _pinSalt,
        'hash': _pinHash,
        'biometrics': lockBiometrics,
        'after': lockAfter.inSeconds,
        'failed': failedPinAttempts,
        if (pinLockedUntil != null)
          'lockedUntil': pinLockedUntil!.toIso8601String(),
      }),
    );
  }

  static Future<String> _hashPin(String pin, String salt) async {
    final hash = await Sha256().hash(utf8.encode('$salt:$pin'));
    return base64Encode(hash.bytes);
  }

  /// Turns the lock on (or changes the PIN). Only a salted hash is kept.
  Future<void> setPin(String pin) async {
    _pinSalt = base64Encode(SecretKeyData.random(length: 16).bytes);
    _pinHash = await _hashPin(pin, _pinSalt!);
    failedPinAttempts = 0;
    pinLockedUntil = null;
    await _saveAppLock();
  }

  /// Checks [pin], counting wrong tries; after [maxPinAttempts] the keypad
  /// waits [pinLockout]. The count survives restarts.
  Future<PinCheck> checkPin(String pin, {DateTime? now}) async {
    final at = now ?? DateTime.now();
    if (pinLockedUntil != null && at.isBefore(pinLockedUntil!)) {
      return PinCheck.lockedOut;
    }
    if (_pinHash != null && await _hashPin(pin, _pinSalt!) == _pinHash) {
      failedPinAttempts = 0;
      pinLockedUntil = null;
      await _saveAppLock();
      return PinCheck.ok;
    }
    failedPinAttempts++;
    if (failedPinAttempts >= maxPinAttempts) {
      failedPinAttempts = 0;
      pinLockedUntil = at.add(pinLockout);
      await _saveAppLock();
      return PinCheck.lockedOut;
    }
    await _saveAppLock();
    return PinCheck.wrong;
  }

  /// A successful fingerprint or face unlock also clears wrong PIN tries.
  Future<void> resetPinAttempts() async {
    failedPinAttempts = 0;
    pinLockedUntil = null;
    await _saveAppLock();
  }

  Future<void> disableAppLock() async {
    _pinSalt = _pinHash = null;
    lockBiometrics = false;
    lockAfter = Duration.zero;
    await _saveAppLock();
  }

  Future<void> setLockBiometrics(bool value) async {
    lockBiometrics = value;
    await _saveAppLock();
  }

  Future<void> setLockAfter(Duration value) async {
    lockAfter = value;
    await _saveAppLock();
  }

  // ---------------------------------------------------------------------------
  // Backup & restore
  // ---------------------------------------------------------------------------

  /// When the user last made a backup on this phone.
  DateTime? lastBackupAt;

  /// "Later" on the backup reminder hides it until then.
  DateTime? backupSnoozedUntil;

  Future<void> recordBackup({DateTime? at}) async {
    lastBackupAt = at ?? DateTime.now();
    notifyListeners();
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(
      _lastBackupKey,
      lastBackupAt!.toIso8601String(),
    );
  }

  Future<void> snoozeBackupReminder({DateTime? now}) async {
    backupSnoozedUntil = (now ?? DateTime.now()).add(const Duration(days: 7));
    notifyListeners();
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(
      _backupSnoozeKey,
      backupSnoozedUntil!.toIso8601String(),
    );
  }

  /// Days without a backup once that reaches 30 (counting from the oldest
  /// entry when there has never been one), or null when no reminder is due.
  int? backupReminderDays({DateTime? now}) {
    final today = now ?? DateTime.now();
    if (backupSnoozedUntil != null && today.isBefore(backupSnoozedUntil!)) {
      return null;
    }
    final since =
        lastBackupAt ??
        transactions
            .map((e) => e.createdAt)
            .fold<DateTime?>(
              null,
              (oldest, d) => oldest == null || d.isBefore(oldest) ? d : oldest,
            );
    if (since == null) return null;
    final days = today.difference(since).inDays;
    return days >= 30 ? days : null;
  }

  /// Reads backup [data] into a scratch store so a bad file can't leave this
  /// one half-restored. Throws if the data can't be read.
  static AppStore readBackupData(Map<String, Object?> data) =>
      AppStore().._decode(jsonEncode(data));

  /// What [other] would add to this phone when merged.
  ({int entries, int alreadyHere}) mergePreview(AppStore other) {
    final ids = {for (final e in transactions) e.id};
    final fresh = other.transactions.where((e) => !ids.contains(e.id)).length;
    return (entries: fresh, alreadyHere: other.transactions.length - fresh);
  }

  /// Replaces everything on this phone with [other] (a read backup).
  Future<void> restoreReplace(AppStore other) async {
    _decode(jsonEncode(other.snapshot()));
    onboarded = true;
    _recalculateAll();
    await _commit();
  }

  /// Adds what [other] has that this phone doesn't (matched by id); nothing
  /// here is changed or removed. Returns how many entries were added.
  Future<int> restoreMerge(AppStore other) async {
    void addMissing<T>(List<T> into, List<T> from, String Function(T) id) {
      final have = {for (final item in into) id(item)};
      into.addAll(from.where((item) => have.add(id(item))));
    }

    final before = transactions.length;
    addMissing(books, other.books, (b) => b.id);
    addMissing(transactions, other.transactions, (e) => e.id);
    addMissing(goals, other.goals, (g) => g.id);
    addMissing(logs, other.logs, (g) => g.id);
    addMissing(templates, other.templates, (t) => t.id);
    addMissing(recurring, other.recurring, (r) => r.id);
    addMissing(budgets, other.budgets, (b) => b.id);
    for (final MapEntry(:key, :value) in other.subcategories.entries) {
      final into = subcategories[key] ??= [];
      for (final name in value) {
        if (!into.contains(name)) into.add(name);
      }
    }
    addMissing(friends, other.friends, (f) => f.id);
    addMissing(groups, other.groups, (g) => g.id);
    addMissing(bills, other.bills, (b) => b.id);
    for (final (into, from) in [
      (categories, other.categories),
      (paymentModes, other.paymentModes),
      (tags, other.tags),
    ]) {
      for (final value in from) {
        if (!into.contains(value)) into.add(value);
      }
    }
    _recalculateAll();
    await _commit();
    return transactions.length - before;
  }

  // ---------------------------------------------------------------------------
  // Subcategories
  // ---------------------------------------------------------------------------

  List<String> subcategoriesOf(String category) =>
      List.unmodifiable(subcategories[category] ?? const []);

  Future<void> addSubcategory(String category, String name) async {
    final value = name.trim();
    final list = subcategories[category] ??= [];
    if (value.isEmpty || list.contains(value)) return;
    list.add(value);
    await _commit();
  }

  /// Renames a subcategory and every entry, template and repeat using it.
  Future<void> renameSubcategory(
    String category,
    String from,
    String to,
  ) async {
    final value = to.trim();
    final list = subcategories[category];
    final index = list?.indexOf(from) ?? -1;
    if (list == null || index == -1 || value.isEmpty || value == from) return;
    if (list.contains(value)) {
      list.removeAt(index);
    } else {
      list[index] = value;
    }
    _replaceSubcategory(category, from, value);
    await _commit();
  }

  /// Removes a subcategory; its entries move up to the parent category.
  Future<void> deleteSubcategory(String category, String name) async {
    subcategories[category]?.remove(name);
    _replaceSubcategory(category, name, '');
    await _commit();
  }

  Future<void> moveSubcategory(String category, int from, int to) async {
    final list = subcategories[category];
    if (list == null || to < 0 || to >= list.length) return;
    list.insert(to, list.removeAt(from));
    await _commit();
  }

  /// How many entries use [category] › [name].
  int subcategoryCount(String category, String name) => transactions
      .where((e) => e.category == category && e.subcategory == name)
      .length;

  void _replaceSubcategory(String category, String from, String to) {
    for (var i = 0; i < transactions.length; i++) {
      final e = transactions[i];
      if (e.category == category && e.subcategory == from) {
        transactions[i] = e.copyWith(subcategory: to);
      }
    }
    for (var i = 0; i < templates.length; i++) {
      final t = templates[i];
      if (t.category == category && t.subcategory == from) {
        templates[i] = EntryTemplate.fromJson({
          ...t.toJson(),
          'subcategory': to,
        });
      }
    }
    for (var i = 0; i < recurring.length; i++) {
      final r = recurring[i];
      if (r.category == category && r.subcategory == from) {
        recurring[i] = RecurringEntry.fromJson({
          ...r.toJson(),
          'subcategory': to,
        });
      }
    }
  }

  // ---------------------------------------------------------------------------
  // Budgets
  // ---------------------------------------------------------------------------

  /// Accounts a budget scope covers.
  Set<String> scopeAccounts(String scope) {
    if (scope.startsWith('account:')) {
      final id = scope.substring('account:'.length);
      return {if (bookById(id) != null) id};
    }
    final currency = scope.substring('currency:'.length);
    return {
      for (final b in books)
        if (b.currency == currency) b.id,
    };
  }

  String scopeCurrency(String scope) => scope.startsWith('account:')
      ? bookById(scope.substring('account:'.length))?.currency ??
            defaultCurrency
      : scope.substring('currency:'.length);

  List<Budget> budgetsFor(String scope) =>
      budgets.where((b) => b.scope == scope).toList();

  Budget? budgetFor(String scope, String? category) => budgets
      .where((b) => b.scope == scope && b.category == category)
      .firstOrNull;

  /// Spending against a budget in [month]: cash out in the scope's
  /// accounts, without transfers or opening balances.
  double budgetSpent(String scope, String? category, DateTime month) {
    final ids = scopeAccounts(scope);
    return transactions
        .where(
          (e) =>
              ids.contains(e.bookId) &&
              e.countsAsFlow &&
              e.type == TransactionType.cashOut &&
              (category == null || e.category == category) &&
              e.occurredAt.year == month.year &&
              e.occurredAt.month == month.month,
        )
        .fold(0.0, (s, e) => s + e.amount);
  }

  /// Average monthly spending over the 3 months before [month] (months with
  /// nothing spent count as zero), as a hint when setting a limit.
  double budgetHint(String scope, String? category, DateTime month) {
    var total = 0.0;
    for (var i = 1; i <= 3; i++) {
      total += budgetSpent(
        scope,
        category,
        DateTime(month.year, month.month - i),
      );
    }
    return total / 3;
  }

  /// Adds or updates the budget for [scope] + [category].
  Future<void> saveBudget({
    required String scope,
    String? category,
    required double amount,
    String? replacing,
  }) async {
    budgets.removeWhere(
      (b) => b.id == replacing || (b.scope == scope && b.category == category),
    );
    budgets.add(
      Budget(
        id: newId('bud'),
        scope: scope,
        amount: amount,
        category: category,
      ),
    );
    await _commit();
  }

  Future<void> deleteBudget(String id) async {
    budgets.removeWhere((b) => b.id == id);
    await _commit();
  }

  // ---------------------------------------------------------------------------
  // Repeating entries
  // ---------------------------------------------------------------------------

  /// "Ask me later" hides the due popup until the app is opened again.
  bool dueAskedLater = false;

  Future<RecurringEntry> addRecurring(RecurringEntry entry) async {
    final saved = RecurringEntry.fromJson({
      ...entry.toJson(),
      'id': newId('rec'),
    });
    recurring.add(saved);
    await _commit();
    return saved;
  }

  Future<void> deleteRecurring(String id) async {
    recurring.removeWhere((r) => r.id == id);
    await _commit();
  }

  /// Every due date not yet confirmed or skipped, oldest first.
  List<DueEntry> dueEntries({DateTime? now}) {
    final at = now ?? DateTime.now();
    return [
      for (final r in recurring)
        if (bookById(r.bookId) != null &&
            (r.toBookId == null || bookById(r.toBookId!) != null))
          for (final due in r.dueBy(at)) DueEntry(r, due),
    ]..sort((a, b) => a.due.compareTo(b.due));
  }

  /// Adds the [add] items as entries (dated when they were due) and moves
  /// every listed repeat past its last shown date; unticked ones are
  /// skipped and come back next cycle. Returns how many were added.
  Future<int> confirmDue({
    required List<DueEntry> shown,
    required List<DueEntry> add,
  }) async {
    for (final item in add) {
      await _addOccurrence(item);
    }
    final last = <String, DateTime>{};
    for (final item in shown) {
      final seen = last[item.recurring.id];
      if (seen == null || item.due.isAfter(seen)) {
        last[item.recurring.id] = item.due;
      }
    }
    for (var i = 0; i < recurring.length; i++) {
      final through = last[recurring[i].id];
      if (through != null) {
        recurring[i] = recurring[i].copyWith(
          nextDue: recurring[i].following(through),
        );
      }
    }
    await _commit();
    return add.length;
  }

  /// Marks one due date as handled (the user recorded it from the form).
  Future<void> markDueHandled(DueEntry item) =>
      confirmDue(shown: [item], add: const []);

  Future<void> _addOccurrence(DueEntry item) async {
    final r = item.recurring;
    if (r.isTransfer) {
      await saveTransfer(
        fromId: r.bookId,
        toId: r.toBookId!,
        amount: r.amount,
        when: item.due,
        notes: r.notes.isEmpty ? r.title : r.notes,
        tags: r.tags,
      );
      return;
    }
    final now = DateTime.now();
    final entry = LedgerTransaction(
      id: newId('txn'),
      bookId: r.bookId,
      title: r.title,
      amount: r.amount,
      type: r.type,
      occurredAt: item.due,
      createdAt: now,
      updatedAt: now,
      category: r.category,
      paymentMode: r.paymentMode,
      notes: r.notes,
      goalId: null,
      runningBalance: 0,
      externalReference: '',
      statementBalance: null,
      sequence: 0,
      importSource: '',
      tags: r.tags,
      subcategory: r.subcategory,
    );
    transactions.add(entry);
    _addLog(entry.id, 'created', 'Entry created', code: 'repeated');
    _touchBook(entry.bookId);
    _recalculateRunningBalance(entry.bookId);
  }

  // ---------------------------------------------------------------------------
  // Templates & suggestions
  // ---------------------------------------------------------------------------

  Future<EntryTemplate> addTemplate(EntryTemplate template) async {
    final saved = EntryTemplate(
      id: newId('tpl'),
      title: template.title.trim(),
      type: template.type,
      amount: template.amount,
      category: template.category,
      paymentMode: template.paymentMode,
      bookId: template.bookId,
      tags: template.tags,
    );
    templates.add(saved);
    await _commit();
    return saved;
  }

  Future<void> renameTemplate(String id, String title) async {
    final index = templates.indexWhere((t) => t.id == id);
    if (index == -1 || title.trim().isEmpty) return;
    templates[index] = templates[index].copyWith(title: title.trim());
    await _commit();
  }

  Future<void> deleteTemplate(String id) async {
    templates.removeWhere((t) => t.id == id);
    await _commit();
  }

  /// Past entries whose title contains [typed], newest first, one per title:
  /// picking one fills the form's category, payment mode and tags.
  List<LedgerTransaction> titleSuggestions(String typed, {int limit = 4}) {
    final q = typed.trim().toLowerCase();
    if (q.length < 2) return const [];
    final seen = <String>{};
    final found = <LedgerTransaction>[];
    for (final entry in entriesNewestFirst) {
      if (entry.transferId != null || !entry.countsAsFlow) continue;
      final title = entry.title.trim();
      final key = title.toLowerCase();
      if (!key.contains(q) || key == q || !seen.add(key)) continue;
      found.add(entry);
      if (found.length == limit) break;
    }
    return found;
  }

  // ---------------------------------------------------------------------------
  // Tags
  // ---------------------------------------------------------------------------

  /// Every tag, most used first, with how many entries use it. A transfer
  /// counts once.
  List<(String, int)> get allTags {
    final counts = <String, int>{for (final tag in tags) tag: 0};
    for (final entry in transactions) {
      if (entry.isTransferMirror) continue;
      for (final tag in entry.tags) {
        counts[tag] = (counts[tag] ?? 0) + 1;
      }
    }
    final list = counts.entries.map((e) => (e.key, e.value)).toList()
      ..sort((a, b) {
        final byCount = b.$2.compareTo(a.$2);
        return byCount != 0 ? byCount : a.$1.compareTo(b.$1);
      });
    return list;
  }

  /// Entries with [tag], newest first; a transfer appears once (its From
  /// side).
  List<LedgerTransaction> entriesTagged(String tag) => [
    for (final entry in entriesNewestFirst)
      if (entry.tags.contains(tag) && !entry.isTransferMirror) entry,
  ];

  /// Adds a tag to the list; returns its stored name ('' if blank).
  Future<String> addTag(String raw) async {
    final name = normalizeTag(raw);
    if (name.isEmpty || tags.contains(name)) return name;
    tags.add(name);
    await _commit();
    return name;
  }

  /// Renames [from] everywhere. If [to] already exists the two are merged.
  Future<void> renameTag(String from, String to) async {
    final name = normalizeTag(to);
    if (name.isEmpty || name == from) return;
    _replaceTag(from, name);
    await _commit();
  }

  /// Moves every entry tagged [from] to [into] and removes [from].
  Future<void> mergeTag(String from, String into) => renameTag(from, into);

  /// Removes [tag] from the list and from every entry; entries stay.
  Future<void> deleteTag(String tag) async {
    _replaceTag(tag, null);
    await _commit();
  }

  void _replaceTag(String from, String? to) {
    final index = tags.indexOf(from);
    tags.remove(from);
    if (to != null && !tags.contains(to)) {
      tags.insert(index == -1 ? tags.length : index, to);
    }
    for (var i = 0; i < transactions.length; i++) {
      final entry = transactions[i];
      if (!entry.tags.contains(from)) continue;
      transactions[i] = entry.copyWith(
        tags: {
          for (final tag in entry.tags) tag == from ? to : tag,
        }.nonNulls.toList(),
      );
    }
  }

  /// Remembers tags typed on an entry so they're suggested next time.
  void _rememberTags(Iterable<String> names) {
    for (final name in names) {
      if (!tags.contains(name)) tags.add(name);
    }
  }

  // ---------------------------------------------------------------------------
  // Transfers
  // ---------------------------------------------------------------------------

  /// The entries that make up a transfer, or null if it no longer exists.
  TransferLegs? transferLegs(String transferId) {
    LedgerTransaction? out, into, fee;
    for (final entry in transactions) {
      if (entry.transferId != transferId) continue;
      if (entry.transferFee) {
        fee = entry;
      } else if (entry.type == TransactionType.cashOut) {
        out = entry;
      } else {
        into = entry;
      }
    }
    if (out == null || into == null) return null;
    return TransferLegs(out: out, into: into, fee: fee);
  }

  /// Records (or updates) money moving between two of the user's accounts:
  /// cash out of [fromId], cash in to [toId] ([toAmount] when the currencies
  /// differ), and an optional [fee] as a real expense in [fromId].
  Future<String> saveTransfer({
    String? transferId,
    required String fromId,
    required String toId,
    required double amount,
    double? toAmount,
    double fee = 0,
    required DateTime when,
    String notes = '',
    List<String> tags = const [],
  }) async {
    final id = transferId ?? newId('xfer');
    final previous = transferId == null ? null : transferLegs(transferId);
    final now = DateTime.now();
    final from = bookById(fromId);
    final to = bookById(toId);
    LedgerTransaction leg(
      LedgerTransaction? old,
      String bookId,
      TransactionType type,
      double value,
    ) => LedgerTransaction(
      id: old?.id ?? newId('txn'),
      bookId: bookId,
      title: 'Transfer',
      amount: value,
      type: type,
      occurredAt: when,
      createdAt: old?.createdAt ?? now,
      updatedAt: now,
      category: 'Transfer',
      paymentMode: '',
      notes: notes.trim(),
      goalId: null,
      runningBalance: 0,
      externalReference: old?.externalReference ?? '',
      statementBalance: old?.statementBalance,
      sequence: old?.sequence ?? 0,
      importSource: old?.importSource ?? '',
      transferId: id,
      tags: tags,
    );
    final out = leg(previous?.out, fromId, TransactionType.cashOut, amount);
    final into = leg(
      previous?.into,
      toId,
      TransactionType.cashIn,
      toAmount ?? amount,
    );
    final touched = {
      fromId,
      toId,
      ?previous?.out.bookId,
      ?previous?.into.bookId,
      ?previous?.fee?.bookId,
    };
    transactions.removeWhere((entry) => entry.transferId == id);
    transactions.addAll([out, into]);
    _rememberTags(tags);
    if (fee > 0) {
      // A cash withdrawal's fee is the ATM's; anything else is the transfer's.
      final atm =
          from?.accountType == AccountType.bank &&
          to?.accountType == AccountType.cash;
      final old = previous?.fee;
      transactions.add(
        LedgerTransaction(
          id: old?.id ?? newId('txn'),
          bookId: fromId,
          title: atm ? 'ATM fee' : 'Transfer fee',
          amount: fee,
          type: TransactionType.cashOut,
          occurredAt: when,
          createdAt: old?.createdAt ?? now,
          updatedAt: now,
          category: 'Bank fees',
          paymentMode: '',
          notes: '',
          goalId: null,
          runningBalance: 0,
          externalReference: '',
          statementBalance: null,
          sequence: 0,
          importSource: '',
          transferId: id,
          transferFee: true,
        ),
      );
      if (!categories.contains('Bank fees')) categories.add('Bank fees');
    }
    for (final entry in [out, into]) {
      _addLog(
        entry.id,
        previous == null ? 'created' : 'updated',
        previous == null ? 'Transfer created' : 'Transfer updated',
        code: previous == null ? 'transferCreated' : 'transferUpdated',
      );
    }
    for (final bookId in touched) {
      _touchBook(bookId);
      _recalculateRunningBalance(bookId);
    }
    await _commit();
    return id;
  }

  /// Removes both sides of a transfer and its fee.
  Future<void> deleteTransfer(String transferId) async {
    final entries = transactions
        .where((entry) => entry.transferId == transferId)
        .toList();
    if (entries.isEmpty) return;
    transactions.removeWhere((entry) => entry.transferId == transferId);
    for (final entry in entries) {
      _addLog(entry.id, 'deleted', 'Entry deleted', code: 'deleted');
      _touchBook(entry.bookId);
    }
    _recalculateAll();
    await _commit();
  }

  Future<void> deleteTransaction(String id) async {
    final transaction = transactionById(id);
    if (transaction == null) return;
    if (transaction.isTransferLeg) {
      await deleteTransfer(transaction.transferId!);
      return;
    }
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
    required String? bookId,
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
    required String? bookId,
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

  /// Records a settle-up, plus a cash entry in [bookId] unless it is null
  /// (settled without recording it in a book).
  Settlement _settle(
    String friendId,
    double amount,
    String? bookId,
    String source,
  ) {
    final friend = friendById(friendId)?.name ?? 'friend';
    if (bookId != null && !categories.contains('Settlement')) {
      categories.add('Settlement');
    }
    final entryId = bookId == null
        ? null
        : _postSplitEntry(
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
    double? openingBalance,
    double? closingBalance,
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
      openingBalance: openingBalance,
      closingBalance: closingBalance,
    );
  }

  ImportPreview previewStatement(String bookId, ParsedStatement statement) =>
      previewImport(
        bookId: bookId,
        source: statement.format,
        parsed: statement.rows,
        ignored: statement.ignored,
        openingBalance: statement.openingBalance,
        closingBalance: statement.closingBalance,
      );

  /// Checks several statements against [bookId] in statement-period order.
  /// Rows one file will import count as existing for the files after it, so
  /// days where statements overlap are imported once.
  ImportBatch previewBatch(String bookId, List<ParsedStatement> statements) {
    final ordered = [...statements]
      ..sort((a, b) {
        final start = (a.periodStart ?? DateTime(9999)).compareTo(
          b.periodStart ?? DateTime(9999),
        );
        return start != 0 ? start : a.fileName.compareTo(b.fileName);
      });
    final existing = <String, int>{};
    for (final transaction in transactionsForBook(bookId)) {
      final key = _duplicateKey(transaction);
      existing[key] = (existing[key] ?? 0) + 1;
    }
    final files = <(ParsedStatement, ImportPreview)>[];
    for (final statement in ordered) {
      final importable = <LedgerTransaction>[];
      final duplicates = <LedgerTransaction>[];
      for (final transaction in statement.rows) {
        final key = _duplicateKey(transaction);
        final remaining = existing[key] ?? 0;
        if (remaining > 0) {
          existing[key] = remaining - 1;
          duplicates.add(transaction);
        } else {
          importable.add(transaction);
        }
      }
      for (final transaction in importable) {
        final key = _duplicateKey(transaction);
        existing[key] = (existing[key] ?? 0) + 1;
      }
      files.add((
        statement,
        ImportPreview(
          source: statement.format,
          importable: importable,
          duplicates: duplicates,
          ignored: statement.ignored,
          openingBalance: statement.openingBalance,
          closingBalance: statement.closingBalance,
        ),
      ));
    }

    // Consecutive statements of one account should continue each other's
    // balance. Only checked when both name the same source and account.
    final gaps = <ChainGap>[];
    final groups = <String, List<ParsedStatement>>{};
    for (final statement in ordered) {
      if (statement.source == null || statement.account == null) continue;
      groups
          .putIfAbsent('${statement.source}|${statement.account}', () => [])
          .add(statement);
    }
    for (final group in groups.values) {
      for (var i = 1; i < group.length; i++) {
        final previous = group[i - 1];
        final next = group[i];
        final closing = previous.closingBalance;
        final opening = next.openingBalance;
        if (closing == null || opening == null) continue;
        // Overlapping statements pass through the earlier closing balance.
        if (next.balanceKeys.contains(closing.toStringAsFixed(2))) continue;
        gaps.add(
          ChainGap(
            from: previous.fileName,
            to: next.fileName,
            closing: closing,
            opening: opening,
          ),
        );
      }
    }

    final first = ordered.where((s) => s.openingBalance != null).firstOrNull;
    final importable = [for (final (_, p) in files) ...p.importable];
    // What the book will hold after import. It equals the last statement's
    // closing balance when the files continue one account without gaps.
    final after = first == null
        ? null
        : roundMoney(
            importable.fold(
              first.openingBalance!,
              (total, entry) => total + entry.signedAmount,
            ),
          );
    return ImportBatch(
      files: files,
      combined: ImportPreview(
        source: ordered.map((s) => s.format).toSet().join('/'),
        importable: importable,
        duplicates: [for (final (_, p) in files) ...p.duplicates],
        ignored: [for (final (_, p) in files) ...p.ignored],
        openingBalance: first?.openingBalance,
        closingBalance: files.length == 1 ? first?.closingBalance : after,
      ),
      openingFrom: first?.fileName,
      sources: ordered.map((s) => s.source ?? s.format).toSet().toList(),
      chainGaps: gaps,
    );
  }

  /// Whether saving [preview] will add an "Opening balance" entry: only for a
  /// book with no entries, so a balance the user set is never changed.
  bool importSetsOpeningBalance(String bookId, ImportPreview preview) =>
      preview.openingBalance != null &&
      roundMoney(preview.openingBalance!) != 0 &&
      preview.importable.isNotEmpty &&
      transactionsForBook(bookId).isEmpty;

  /// Saves an import. [transfers] maps a row's id to the user's other account
  /// for rows the user turned into transfers in the preview.
  Future<void> commitImport(
    ImportPreview preview, {
    Map<String, String> transfers = const {},
    List<String> tags = const [],
  }) async {
    if (tags.isNotEmpty) {
      _rememberTags(tags);
      preview = ImportPreview(
        source: preview.source,
        importable: [
          for (final row in preview.importable)
            row.copyWith(tags: {...row.tags, ...tags}.toList()),
        ],
        duplicates: preview.duplicates,
        ignored: preview.ignored,
        openingBalance: preview.openingBalance,
        closingBalance: preview.closingBalance,
      );
    }
    if (preview.importable.isNotEmpty) {
      final bookId = preview.importable.first.bookId;
      if (importSetsOpeningBalance(bookId, preview)) {
        _addImportOpening(bookId, preview);
      }
    }
    final rows = <LedgerTransaction>[];
    for (final row in preview.importable) {
      final other = transfers[row.id];
      if (other == null || bookById(other) == null) {
        rows.add(row);
        continue;
      }
      // The statement row keeps its reference and balance, so a re-import
      // still finds it; the other account gets the matching side.
      final transferId = newId('xfer');
      rows.add(_asTransferLeg(row, transferId));
      transactions.add(
        _asTransferLeg(
          row,
          transferId,
          id: newId('txn'),
          bookId: other,
          type: row.type == TransactionType.cashOut
              ? TransactionType.cashIn
              : TransactionType.cashOut,
        ),
      );
      _addLog(
        transactions.last.id,
        'created',
        'Transfer created',
        code: 'transferCreated',
      );
      _touchBook(other);
    }
    transactions.addAll(rows);
    // Imported rows can name a payment mode (the statement's bank or
    // wallet) the user hasn't added yet; add it so filters can find them.
    for (final transaction in rows) {
      if (transaction.isTransferLeg) continue;
      final mode = transaction.paymentMode.trim();
      if (mode.isNotEmpty && !paymentModes.contains(mode)) {
        paymentModes.add(mode);
      }
      // Likewise a category suggested by a keyword rule ("Cellular topup").
      final category = transaction.category;
      if (category != 'Imported' && !categories.contains(category)) {
        categories.add(category);
      }
    }
    for (final transaction in rows) {
      _addLog(
        transaction.id,
        'imported',
        'Imported from ${transaction.importSource}',
        code: 'imported',
        args: [transaction.importSource],
      );
      _touchBook(transaction.bookId);
    }
    _recalculateAll();
    await persist();
    notifyListeners();
  }

  LedgerTransaction _asTransferLeg(
    LedgerTransaction row,
    String transferId, {
    String? id,
    String? bookId,
    TransactionType? type,
  }) {
    final mirror = bookId != null;
    return LedgerTransaction(
      id: id ?? row.id,
      bookId: bookId ?? row.bookId,
      title: 'Transfer',
      amount: row.amount,
      type: type ?? row.type,
      occurredAt: row.occurredAt,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      category: 'Transfer',
      paymentMode: mirror ? '' : row.paymentMode,
      // The bank's own wording stays on the statement side.
      notes: mirror ? '' : (row.notes.isEmpty ? row.title : row.notes),
      goalId: null,
      runningBalance: 0,
      externalReference: mirror ? '' : row.externalReference,
      statementBalance: mirror ? null : row.statementBalance,
      sequence: mirror ? 0 : row.sequence,
      importSource: mirror ? '' : row.importSource,
      transferId: transferId,
      tags: row.tags,
    );
  }

  /// The statement's opening balance as an "Opening balance" entry (which
  /// Insights leaves out), just before its first row, so the book balance
  /// ends at the statement's closing balance.
  void _addImportOpening(String bookId, ImportPreview preview) {
    final opening = roundMoney(preview.openingBalance!);
    final first = preview.importable
        .map((entry) => entry.occurredAt)
        .reduce((a, b) => a.isBefore(b) ? a : b);
    final now = DateTime.now();
    final entry = LedgerTransaction(
      id: newId('txn'),
      bookId: bookId,
      title: 'Opening balance',
      amount: opening.abs(),
      type: opening > 0 ? TransactionType.cashIn : TransactionType.cashOut,
      occurredAt: first.subtract(const Duration(seconds: 1)),
      createdAt: now,
      updatedAt: now,
      category: 'Opening balance',
      paymentMode: preview.importable.first.paymentMode,
      notes: '',
      goalId: null,
      runningBalance: 0,
      externalReference: '',
      statementBalance: null,
      sequence: 0,
      importSource: preview.source,
    );
    transactions.add(entry);
    _addLog(entry.id, 'created', 'Entry created', code: 'created');
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
        type: AccountType.cash,
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
