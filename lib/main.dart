import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spreadsheet_decoder/spreadsheet_decoder.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart' as sfpdf;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const HissabKitabBootstrap());
}

class HissabKitabBootstrap extends StatefulWidget {
  const HissabKitabBootstrap({super.key});

  @override
  State<HissabKitabBootstrap> createState() => _HissabKitabBootstrapState();
}

class _HissabKitabBootstrapState extends State<HissabKitabBootstrap> {
  final store = AppStore();

  @override
  void initState() {
    super.initState();
    store.load();
  }

  @override
  Widget build(BuildContext context) {
    return AppScope(
      store: store,
      child: AnimatedBuilder(
        animation: store,
        builder: (context, _) => MaterialApp(
          title: AppText.name,
          debugShowCheckedModeBanner: false,
          themeMode: store.themeMode,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          home: const AppShell(),
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: const TextScaler.linear(0.78),
            ),
            child: child!,
          ),
        ),
      ),
    );
  }
}

class AppText {
  const AppText._();

  static const name = 'Mero Khata';
}

class AppTheme {
  const AppTheme._();

  static const emerald = Color(0xFF2ECC71);
  static const deepEmerald = Color(0xFF0F7A4A);
  static const ink = Color(0xFF101418);
  static const navy = Color(0xFF425672);
  static const marble = Color(0xFFF6F7F8);
  static const cloud = Color(0xFFF0F2F3);
  static const slate = Color(0xFF263238);
  static const mist = Color(0xFFEAF7EF);
  static const danger = Color(0xFFC31D1D);

  static final ThemeData light = _buildLight();
  static final ThemeData dark = _buildDark();

  static ThemeData _buildLight() {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: emerald,
        primary: deepEmerald,
        secondary: deepEmerald,
        surface: Colors.white,
      ),
    );
    final bt = base.textTheme;
    return base.copyWith(
      scaffoldBackgroundColor: marble,
      appBarTheme: AppBarTheme(
        centerTitle: false,
        backgroundColor: Colors.transparent,
        foregroundColor: ink,
        elevation: 0,
        titleTextStyle: GoogleFonts.plusJakartaSans(
          textStyle: bt.titleLarge,
          color: deepEmerald,
          fontSize: 20,
          fontWeight: FontWeight.w800,
        ),
      ),
      textTheme: GoogleFonts.manropeTextTheme(bt).copyWith(
        displaySmall: GoogleFonts.plusJakartaSans(
          textStyle: bt.displaySmall,
          color: ink,
          fontSize: 44,
          height: .98,
          fontWeight: FontWeight.w900,
          letterSpacing: -1.8,
        ),
        headlineMedium: GoogleFonts.plusJakartaSans(
          textStyle: bt.headlineMedium,
          color: ink,
          fontSize: 20,
          height: 1.02,
          fontWeight: FontWeight.w900,
          letterSpacing: -1.2,
        ),
        headlineSmall: GoogleFonts.plusJakartaSans(
          textStyle: bt.headlineSmall,
          color: ink,
          fontSize: 28,
          fontWeight: FontWeight.w900,
          letterSpacing: -.8,
        ),
        titleLarge: GoogleFonts.plusJakartaSans(
          textStyle: bt.titleLarge,
          color: ink,
          fontSize: 22,
          fontWeight: FontWeight.w800,
          letterSpacing: -.4,
        ),
        titleMedium: GoogleFonts.manrope(
          textStyle: bt.titleMedium,
          color: ink,
          fontSize: 17,
          fontWeight: FontWeight.w800,
        ),
        bodyLarge: GoogleFonts.manrope(
          textStyle: bt.bodyLarge,
          color: navy,
          fontSize: 17,
          height: 1.35,
        ),
        bodyMedium: GoogleFonts.manrope(
          textStyle: bt.bodyMedium,
          color: navy,
          fontSize: 14,
          height: 1.35,
        ),
        labelLarge: GoogleFonts.manrope(
          textStyle: bt.labelLarge,
          color: navy,
          fontSize: 13,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.4,
        ),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
          side: BorderSide(color: Colors.white.withValues(alpha: .72)),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: deepEmerald,
          foregroundColor: Colors.white,
          shape: const StadiumBorder(),
          minimumSize: const Size(48, 54),
          textStyle: const TextStyle(inherit: false, fontSize: 16, fontWeight: FontWeight.w900),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Color(0xFF10A65A),
        foregroundColor: Colors.white,
        elevation: 10,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        elevation: 0,
        height: 20,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        indicatorColor: mist,
        labelTextStyle: WidgetStateProperty.all(
          const TextStyle(
            inherit: false,
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: .4,
          ),
        ),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: cloud,
        border: OutlineInputBorder(borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderSide: BorderSide.none),
      ),
    );
  }

  static ThemeData _buildDark() {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: emerald,
        brightness: Brightness.dark,
      ),
    );
    return base.copyWith(
      textTheme: GoogleFonts.manropeTextTheme(base.textTheme),
      cardTheme: CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(shape: const StadiumBorder()),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(),
      ),
    );
  }
}

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

enum TransactionType {
  cashIn('Cash In'),
  cashOut('Cash Out');

  const TransactionType(this.label);
  final String label;
}

class LedgerBook {
  const LedgerBook({
    required this.id,
    required this.name,
    required this.description,
    required this.createdAt,
    required this.updatedAt,
    required this.categories,
    required this.paymentModes,
  });

  final String id;
  final String name;
  final String description;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<String> categories;
  final List<String> paymentModes;

  LedgerBook copyWith({
    String? name,
    String? description,
    DateTime? updatedAt,
    List<String>? categories,
    List<String>? paymentModes,
  }) {
    return LedgerBook(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      categories: categories ?? this.categories,
      paymentModes: paymentModes ?? this.paymentModes,
    );
  }

  Map<String, Object?> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'categories': categories,
    'paymentModes': paymentModes,
  };

  factory LedgerBook.fromJson(Map<String, Object?> json) => LedgerBook(
    id: json['id'] as String,
    name: json['name'] as String,
    description: json['description'] as String? ?? '',
    createdAt: DateTime.parse(json['createdAt'] as String),
    updatedAt: DateTime.parse(json['updatedAt'] as String),
    categories: (json['categories'] as List? ?? const [])
        .map((item) => item.toString())
        .toList(),
    paymentModes: (json['paymentModes'] as List? ?? const [])
        .map((item) => item.toString())
        .toList(),
  );
}

class LedgerTransaction {
  const LedgerTransaction({
    required this.id,
    required this.bookId,
    required this.title,
    required this.amount,
    required this.type,
    required this.occurredAt,
    required this.createdAt,
    required this.updatedAt,
    required this.category,
    required this.paymentMode,
    required this.notes,
    required this.goalId,
    required this.runningBalance,
    required this.externalReference,
    required this.statementBalance,
    required this.sequence,
    required this.importSource,
  });

  final String id;
  final String bookId;
  final String title;
  final double amount;
  final TransactionType type;
  final DateTime occurredAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String category;
  final String paymentMode;
  final String notes;
  final String? goalId;
  final double runningBalance;
  final String externalReference;
  final double? statementBalance;
  final int sequence;
  final String importSource;

  double get signedAmount => type == TransactionType.cashIn ? amount : -amount;

  LedgerTransaction copyWith({
    String? title,
    double? amount,
    TransactionType? type,
    DateTime? occurredAt,
    DateTime? updatedAt,
    String? category,
    String? paymentMode,
    String? notes,
    String? goalId,
    double? runningBalance,
    String? externalReference,
    double? statementBalance,
    int? sequence,
    String? importSource,
  }) {
    return LedgerTransaction(
      id: id,
      bookId: bookId,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      occurredAt: occurredAt ?? this.occurredAt,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      category: category ?? this.category,
      paymentMode: paymentMode ?? this.paymentMode,
      notes: notes ?? this.notes,
      goalId: goalId ?? this.goalId,
      runningBalance: runningBalance ?? this.runningBalance,
      externalReference: externalReference ?? this.externalReference,
      statementBalance: statementBalance ?? this.statementBalance,
      sequence: sequence ?? this.sequence,
      importSource: importSource ?? this.importSource,
    );
  }

  Map<String, Object?> toJson() => {
    'id': id,
    'bookId': bookId,
    'title': title,
    'amount': amount,
    'type': type.name,
    'occurredAt': occurredAt.toIso8601String(),
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'category': category,
    'paymentMode': paymentMode,
    'notes': notes,
    'goalId': goalId,
    'runningBalance': runningBalance,
    'externalReference': externalReference,
    'statementBalance': statementBalance,
    'sequence': sequence,
    'importSource': importSource,
  };

  factory LedgerTransaction.fromJson(Map<String, Object?> json) {
    return LedgerTransaction(
      id: json['id'] as String,
      bookId: json['bookId'] as String,
      title: json['title'] as String,
      amount: (json['amount'] as num).toDouble(),
      type: TransactionType.values.firstWhere(
        (item) => item.name == json['type'],
        orElse: () => TransactionType.cashOut,
      ),
      occurredAt: DateTime.parse(json['occurredAt'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      category: json['category'] as String? ?? '',
      paymentMode: json['paymentMode'] as String? ?? '',
      notes: json['notes'] as String? ?? '',
      goalId: json['goalId'] as String?,
      runningBalance: (json['runningBalance'] as num? ?? 0).toDouble(),
      externalReference: json['externalReference'] as String? ?? '',
      statementBalance: (json['statementBalance'] as num?)?.toDouble(),
      sequence: json['sequence'] as int? ?? 0,
      importSource: json['importSource'] as String? ?? '',
    );
  }
}

class SavingsGoal {
  const SavingsGoal({
    required this.id,
    required this.name,
    required this.targetAmount,
    required this.manualSaved,
    required this.savedAmount,
    required this.deadline,
  });

  final String id;
  final String name;
  final double targetAmount;
  final double manualSaved;
  final double savedAmount;
  final DateTime? deadline;

  double get remaining => max(0, targetAmount - savedAmount).toDouble();
  double get progress =>
      targetAmount <= 0 ? 0 : (savedAmount / targetAmount).clamp(0, 1);

  SavingsGoal copyWith({
    String? name,
    double? targetAmount,
    double? manualSaved,
    double? savedAmount,
    DateTime? deadline,
  }) {
    return SavingsGoal(
      id: id,
      name: name ?? this.name,
      targetAmount: targetAmount ?? this.targetAmount,
      manualSaved: manualSaved ?? this.manualSaved,
      savedAmount: savedAmount ?? this.savedAmount,
      deadline: deadline ?? this.deadline,
    );
  }

  Map<String, Object?> toJson() => {
    'id': id,
    'name': name,
    'targetAmount': targetAmount,
    'manualSaved': manualSaved,
    'savedAmount': savedAmount,
    'deadline': deadline?.toIso8601String(),
  };

  factory SavingsGoal.fromJson(Map<String, Object?> json) => SavingsGoal(
    id: json['id'] as String,
    name: json['name'] as String,
    targetAmount: (json['targetAmount'] as num).toDouble(),
    manualSaved: (json['manualSaved'] as num? ?? 0).toDouble(),
    savedAmount: (json['savedAmount'] as num? ?? 0).toDouble(),
    deadline: json['deadline'] == null
        ? null
        : DateTime.parse(json['deadline'] as String),
  );
}

class TransactionLog {
  const TransactionLog({
    required this.id,
    required this.transactionId,
    required this.action,
    required this.details,
    required this.timestamp,
  });

  final String id;
  final String transactionId;
  final String action;
  final String details;
  final DateTime timestamp;

  Map<String, Object?> toJson() => {
    'id': id,
    'transactionId': transactionId,
    'action': action,
    'details': details,
    'timestamp': timestamp.toIso8601String(),
  };

  factory TransactionLog.fromJson(Map<String, Object?> json) => TransactionLog(
    id: json['id'] as String,
    transactionId: json['transactionId'] as String,
    action: json['action'] as String,
    details: json['details'] as String,
    timestamp: DateTime.parse(json['timestamp'] as String),
  );
}

class ImportPreview {
  const ImportPreview({
    required this.source,
    required this.importable,
    required this.duplicates,
    required this.ignored,
  });

  final String source;
  final List<LedgerTransaction> importable;
  final List<LedgerTransaction> duplicates;
  final List<String> ignored;
}

class AppStore extends ChangeNotifier {
  static const _storageKey = 'hissabkitab_data_v1';
  static const _themeKey = 'hissabkitab_theme_mode';

  final List<LedgerBook> books = [];
  final List<LedgerTransaction> transactions = [];
  final List<SavingsGoal> goals = [];
  final List<TransactionLog> logs = [];
  ThemeMode themeMode = ThemeMode.system;
  bool isLoaded = false;

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
      final data = jsonDecode(raw) as Map<String, Object?>;
      books
        ..clear()
        ..addAll(
          (data['books'] as List).cast<Map>().map(
            (item) => LedgerBook.fromJson(item.cast()),
          ),
        );
      transactions
        ..clear()
        ..addAll(
          (data['transactions'] as List).cast<Map>().map(
            (item) => LedgerTransaction.fromJson(item.cast()),
          ),
        );
      goals
        ..clear()
        ..addAll(
          (data['goals'] as List? ?? const []).cast<Map>().map(
            (item) => SavingsGoal.fromJson(item.cast()),
          ),
        );
      logs
        ..clear()
        ..addAll(
          (data['logs'] as List? ?? const []).cast<Map>().map(
            (item) => TransactionLog.fromJson(item.cast()),
          ),
        );
      if (books.isEmpty) {
        _seed();
      }
    }
    _recalculateAll();
    isLoaded = true;
    notifyListeners();
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
      }),
    );
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    themeMode = mode;
    notifyListeners();
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_themeKey, mode.name);
  }

  LedgerBook? bookById(String id) {
    for (final book in books) {
      if (book.id == id) return book;
    }
    return null;
  }

  double balanceFor(String bookId) => transactionsForBook(
    bookId,
  ).fold(0, (total, transaction) => total + transaction.signedAmount);

  List<LedgerTransaction> transactionsForBook(String bookId) {
    return transactions
        .where((transaction) => transaction.bookId == bookId)
        .toList()
      ..sort((a, b) {
        final date = b.occurredAt.compareTo(a.occurredAt);
        return date == 0 ? b.createdAt.compareTo(a.createdAt) : date;
      });
  }

  List<TransactionLog> logsFor(String transactionId) {
    return logs.where((log) => log.transactionId == transactionId).toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  Future<void> saveBook({
    String? id,
    required String name,
    required String description,
  }) async {
    final now = DateTime.now();
    final index = id == null ? -1 : books.indexWhere((book) => book.id == id);
    if (index == -1) {
      books.add(
        LedgerBook(
          id: _id('book'),
          name: name.trim(),
          description: description.trim(),
          createdAt: now,
          updatedAt: now,
          categories: const ['General', 'Salary', 'Food', 'Bills', 'Transfer'],
          paymentModes: const ['Cash', 'Bank', 'Card', 'Wallet'],
        ),
      );
    } else {
      books[index] = books[index].copyWith(
        name: name.trim(),
        description: description.trim(),
        updatedAt: now,
      );
    }
    await persist();
    notifyListeners();
  }

  Future<void> deleteBook(String id) async {
    books.removeWhere((book) => book.id == id);
    transactions.removeWhere((transaction) => transaction.bookId == id);
    await persist();
    notifyListeners();
  }

  Future<void> addCategory(String bookId, String name) async {
    final index = books.indexWhere((book) => book.id == bookId);
    if (index == -1 || name.trim().isEmpty) return;
    final values = {...books[index].categories, name.trim()}.toList()..sort();
    books[index] = books[index].copyWith(categories: values);
    await persist();
    notifyListeners();
  }

  Future<void> addPaymentMode(String bookId, String name) async {
    final index = books.indexWhere((book) => book.id == bookId);
    if (index == -1 || name.trim().isEmpty) return;
    final values = {...books[index].paymentModes, name.trim()}.toList()..sort();
    books[index] = books[index].copyWith(paymentModes: values);
    await persist();
    notifyListeners();
  }

  Future<void> saveTransaction(LedgerTransaction transaction) async {
    final index = transactions.indexWhere((item) => item.id == transaction.id);
    if (index == -1) {
      transactions.add(transaction);
      _addLog(transaction.id, 'created', 'Transaction created');
    } else {
      transactions[index] = transaction.copyWith(updatedAt: DateTime.now());
      _addLog(transaction.id, 'updated', 'Transaction updated');
    }
    _touchBook(transaction.bookId);
    _recalculateAll();
    await persist();
    notifyListeners();
  }

  Future<void> deleteTransaction(String id) async {
    final transaction = transactions.where((item) => item.id == id).firstOrNull;
    if (transaction == null) return;
    transactions.removeWhere((item) => item.id == id);
    _addLog(id, 'deleted', 'Transaction deleted');
    _touchBook(transaction.bookId);
    _recalculateAll();
    await persist();
    notifyListeners();
  }

  Future<void> saveGoal({
    String? id,
    required String name,
    required double targetAmount,
    required double manualSaved,
    DateTime? deadline,
  }) async {
    final index = id == null ? -1 : goals.indexWhere((goal) => goal.id == id);
    final goal = SavingsGoal(
      id: id ?? _id('goal'),
      name: name.trim(),
      targetAmount: targetAmount,
      manualSaved: manualSaved,
      savedAmount: manualSaved,
      deadline: deadline,
    );
    if (index == -1) {
      goals.add(goal);
    } else {
      goals[index] = goal;
    }
    _recalculateGoalProgress();
    await persist();
    notifyListeners();
  }

  Future<void> deleteGoal(String id) async {
    goals.removeWhere((goal) => goal.id == id);
    for (var i = 0; i < transactions.length; i++) {
      if (transactions[i].goalId == id) {
        transactions[i] = transactions[i].copyWith(goalId: '');
      }
    }
    await persist();
    notifyListeners();
  }

  ImportPreview previewImport({
    required String bookId,
    required String source,
    required List<LedgerTransaction> parsed,
    required List<String> ignored,
  }) {
    final existing = transactionsForBook(bookId).map(_duplicateKey).toSet();
    final seen = <String>{};
    final importable = <LedgerTransaction>[];
    final duplicates = <LedgerTransaction>[];
    for (final transaction in parsed) {
      final key = _duplicateKey(transaction);
      if (existing.contains(key) || !seen.add(key)) {
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
        name: 'Main Book',
        description: 'Daily cash flow',
        createdAt: now,
        updatedAt: now,
        categories: const ['General', 'Salary', 'Food', 'Bills', 'Transfer'],
        paymentModes: const ['Cash', 'Bank', 'Card', 'Wallet'],
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
        id: _id('log'),
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
    final sorted =
        transactions
            .where((transaction) => transaction.bookId == bookId)
            .toList()
          ..sort((a, b) {
            final date = a.occurredAt.compareTo(b.occurredAt);
            return date == 0 ? a.createdAt.compareTo(b.createdAt) : date;
          });
    var balance = 0.0;
    for (final transaction in sorted) {
      balance += transaction.signedAmount;
      final index = transactions.indexWhere(
        (item) => item.id == transaction.id,
      );
      transactions[index] = transaction.copyWith(runningBalance: balance);
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

  String _duplicateKey(LedgerTransaction transaction) {
    if (transaction.externalReference.trim().isNotEmpty) {
      return 'ref:${transaction.bookId}:${transaction.externalReference.trim().toLowerCase()}';
    }
    final day = DateTime(
      transaction.occurredAt.year,
      transaction.occurredAt.month,
      transaction.occurredAt.day,
    ).toIso8601String();
    return [
      transaction.bookId,
      day,
      transaction.amount.toStringAsFixed(2),
      transaction.title.trim().toLowerCase(),
      transaction.statementBalance?.toStringAsFixed(2) ?? '',
      transaction.sequence,
    ].join('|');
  }

  static String _id(String prefix) {
    return '${prefix}_${DateTime.now().microsecondsSinceEpoch}_${Random().nextInt(99999)}';
  }
}

class ImportParser {
  static Future<ImportPreview> parsePdf({
    required AppStore store,
    required String bookId,
  }) async {
    final file = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['pdf'],
      withData: true,
    );
    final bytes = file?.files.single.bytes;
    if (bytes == null) {
      return const ImportPreview(
        source: 'PDF',
        importable: [],
        duplicates: [],
        ignored: [],
      );
    }
    sfpdf.PdfDocument? document;
    try {
      document = sfpdf.PdfDocument(inputBytes: bytes);
      final text = sfpdf.PdfTextExtractor(document).extractText();
      return _parseText(
        store: store,
        bookId: bookId,
        source: 'PDF',
        text: text,
      );
    } finally {
      document?.dispose();
    }
  }

  static Future<ImportPreview> parseXls({
    required AppStore store,
    required String bookId,
  }) async {
    final file = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['xls', 'xlsx', 'csv', 'tsv'],
      withData: true,
    );
    final bytes = file?.files.single.bytes;
    if (bytes == null) {
      return const ImportPreview(
        source: 'XLS',
        importable: [],
        duplicates: [],
        ignored: [],
      );
    }
    final parsed = <LedgerTransaction>[];
    final ignored = <String>[];
    try {
      final workbook = SpreadsheetDecoder.decodeBytes(bytes);
      var sequence = 0;
      for (final table in workbook.tables.values) {
        for (final row in table.rows.skip(1)) {
          sequence++;
          final cells = row
              .map((cell) => cell?.toString().trim() ?? '')
              .toList();
          final transaction = _fromCells(cells, bookId, 'XLS', sequence);
          if (transaction == null) {
            ignored.add(cells.join(' | '));
          } else {
            parsed.add(transaction);
          }
        }
      }
    } catch (_) {
      return _parseText(
        store: store,
        bookId: bookId,
        source: 'XLS',
        text: utf8.decode(bytes, allowMalformed: true),
      );
    }
    return store.previewImport(
      bookId: bookId,
      source: 'XLS',
      parsed: parsed,
      ignored: ignored,
    );
  }

  static ImportPreview _parseText({
    required AppStore store,
    required String bookId,
    required String source,
    required String text,
  }) {
    final parsed = <LedgerTransaction>[];
    final ignored = <String>[];
    var sequence = 0;
    for (final line in text.split(RegExp(r'\r?\n'))) {
      final clean = line.trim().replaceAll(RegExp(r'\s+'), ' ');
      if (clean.isEmpty || _isHeader(clean)) continue;
      sequence++;
      final transaction = _fromLine(clean, bookId, source, sequence);
      if (transaction == null) {
        ignored.add(clean);
      } else {
        parsed.add(transaction);
      }
    }
    return store.previewImport(
      bookId: bookId,
      source: source,
      parsed: parsed,
      ignored: ignored,
    );
  }

  static LedgerTransaction? _fromCells(
    List<String> cells,
    String bookId,
    String source,
    int sequence,
  ) {
    final date = cells.map(_parseDate).whereType<DateTime>().firstOrNull;
    final amounts = cells.map(_parseAmount).whereType<double>().toList();
    if (date == null || amounts.isEmpty) return null;
    final joined = cells.join(' ');
    final title = cells.firstWhere(
      (cell) =>
          cell.length > 2 &&
          _parseDate(cell) == null &&
          _parseAmount(cell) == null,
      orElse: () => 'Imported transaction',
    );
    final reference = cells.firstWhere(
      (cell) => RegExp(r'[A-Za-z]{2,}\d{2,}|\d{6,}').hasMatch(cell),
      orElse: () => '',
    );
    final amount = amounts.firstWhere((value) => value != 0, orElse: () => 0);
    final lower = joined.toLowerCase();
    final type =
        amount < 0 ||
            lower.contains('debit') ||
            lower.contains('withdrawal') ||
            lower.contains(' dr ')
        ? TransactionType.cashOut
        : TransactionType.cashIn;
    return _transaction(
      bookId: bookId,
      title: title,
      amount: amount.abs(),
      type: type,
      date: date,
      source: source,
      sequence: sequence,
      reference: reference,
    );
  }

  static LedgerTransaction? _fromLine(
    String line,
    String bookId,
    String source,
    int sequence,
  ) {
    final date = _firstDate(line);
    final amounts = RegExp(r'[-+]?\d[\d,]*(\.\d+)?')
        .allMatches(line)
        .map((match) => _parseAmount(match.group(0)!))
        .whereType<double>()
        .toList();
    if (date == null || amounts.isEmpty) return null;
    final amount = amounts.last;
    final balance = amounts.length > 1 ? amounts[amounts.length - 2] : null;
    final lower = line.toLowerCase();
    final type =
        amount < 0 ||
            lower.contains('debit') ||
            lower.contains('withdrawal') ||
            lower.contains(' cash out ') ||
            lower.contains(' dr ')
        ? TransactionType.cashOut
        : TransactionType.cashIn;
    final title = line
        .replaceAll(RegExp(r'\d{1,4}[-/]\d{1,2}[-/]\d{1,4}'), '')
        .replaceAll(RegExp(r'[-+]?\d[\d,]*(\.\d+)?'), '')
        .replaceAll(
          RegExp(r'\b(debit|credit|dr|cr)\b', caseSensitive: false),
          '',
        )
        .trim();
    return _transaction(
      bookId: bookId,
      title: title.isEmpty ? 'Imported transaction' : title,
      amount: amount.abs(),
      type: type,
      date: date,
      source: source,
      sequence: sequence,
      balance: balance,
    );
  }

  static LedgerTransaction _transaction({
    required String bookId,
    required String title,
    required double amount,
    required TransactionType type,
    required DateTime date,
    required String source,
    required int sequence,
    String reference = '',
    double? balance,
  }) {
    final now = DateTime.now();
    return LedgerTransaction(
      id: AppStore._id('txn'),
      bookId: bookId,
      title: title,
      amount: amount,
      type: type,
      occurredAt: date,
      createdAt: now,
      updatedAt: now,
      category: 'Imported',
      paymentMode: '',
      notes: '',
      goalId: null,
      runningBalance: 0,
      externalReference: reference,
      statementBalance: balance,
      sequence: sequence,
      importSource: source,
    );
  }

  static bool _isHeader(String line) {
    final lower = line.toLowerCase();
    return lower.contains('date') &&
        (lower.contains('description') ||
            lower.contains('particular') ||
            lower.contains('amount'));
  }

  static DateTime? _firstDate(String input) {
    final match = RegExp(
      r'\b(\d{4}[-/]\d{1,2}[-/]\d{1,2}|\d{1,2}[-/]\d{1,2}[-/]\d{2,4})\b',
    ).firstMatch(input);
    return match == null ? null : _parseDate(match.group(1)!);
  }

  static DateTime? _parseDate(String input) {
    for (final pattern in const [
      'yyyy-MM-dd',
      'yyyy/MM/dd',
      'dd-MM-yyyy',
      'dd/MM/yyyy',
      'MM-dd-yyyy',
      'MM/dd/yyyy',
    ]) {
      try {
        return DateFormat(pattern).parseStrict(input);
      } on FormatException {
        continue;
      }
    }
    return null;
  }

  static double? _parseAmount(String input) {
    return double.tryParse(
      input.replaceAll(',', '').replaceAll(RegExp(r'[^0-9.+-]'), ''),
    );
  }
}

class ExportService {
  static Future<void> exportPdf({
    required LedgerBook book,
    required List<LedgerTransaction> transactions,
  }) async {
    final document = pw.Document();
    document.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          pw.Text(
            AppText.name,
            style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 6),
          pw.Text(book.name, style: const pw.TextStyle(fontSize: 16)),
          pw.SizedBox(height: 14),
          pw.TableHelper.fromTextArray(
            headers: const ['Date', 'Title', 'Type', 'Amount', 'Balance'],
            data: transactions
                .map(
                  (transaction) => [
                    DateFormat.yMd().format(transaction.occurredAt),
                    transaction.title,
                    transaction.type.label,
                    money(transaction.amount),
                    money(transaction.runningBalance),
                  ],
                )
                .toList(),
          ),
        ],
      ),
    );
    await Printing.sharePdf(
      bytes: await document.save(),
      filename: '${book.name.replaceAll(' ', '_')}_report.pdf',
    );
  }

  static Future<void> exportExcelLike({
    required LedgerBook book,
    required List<LedgerTransaction> transactions,
  }) async {
    final rows = [
      [
        'Date',
        'Title',
        'Type',
        'Category',
        'Payment Mode',
        'Amount',
        'Balance',
        'Reference',
        'Notes',
      ],
      for (final transaction in transactions)
        [
          DateFormat('yyyy-MM-dd HH:mm').format(transaction.occurredAt),
          transaction.title,
          transaction.type.label,
          transaction.category,
          transaction.paymentMode,
          transaction.amount.toStringAsFixed(2),
          transaction.runningBalance.toStringAsFixed(2),
          transaction.externalReference,
          transaction.notes,
        ],
    ];
    final csv = rows
        .map(
          (row) =>
              row.map((cell) => '"${cell.replaceAll('"', '""')}"').join(','),
        )
        .join('\n');
    await FilePicker.platform.saveFile(
      dialogTitle: 'Export Excel-compatible CSV',
      fileName: '${book.name.replaceAll(' ', '_')}_report.csv',
      bytes: Uint8List.fromList(utf8.encode(csv)),
    );
  }
}

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  var index = 2;

  @override
  Widget build(BuildContext context) {
    final store = AppScope.watch(context);
    final pages = [
      const HomeScreen(),
      const BooksScreen(),
      const CalendarScreen(),
      const GoalsScreen(),
      const SettingsScreen(),
    ];
    if (!store.isLoaded) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 900;
        if (wide) {
          return Scaffold(
            body: Row(
              children: [
                NavigationRail(
                  selectedIndex: index,
                  onDestinationSelected: (value) =>
                      setState(() => index = value),
                  labelType: NavigationRailLabelType.all,
                  destinations: _destinations
                      .map(
                        (item) => NavigationRailDestination(
                          icon: Icon(item.icon),
                          label: Text(item.label),
                        ),
                      )
                      .toList(),
                ),
                const VerticalDivider(width: 1),
                Expanded(child: pages[index]),
              ],
            ),
          );
        }
        return Scaffold(
          backgroundColor: Colors.white,
          body: pages[index],
          bottomNavigationBar: DecoratedBox(
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: Color(0xFFE8ECED), width: .5),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: List.generate(_destinations.length, (i) {
                    final selected = i == index;
                    final color = selected ? AppTheme.deepEmerald : const Color(0xFFB0BAC0);
                    return Expanded(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => setState(() => index = i),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(_destinations[i].icon, size: 26, color: color),
                              const SizedBox(height: 3),
                              Text(
                                _destinations[i].label,
                                style: TextStyle(
                                  inherit: false,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: .3,
                                  color: color,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ),
                SizedBox(height: MediaQuery.paddingOf(context).bottom * 0.3),
              ],
            ),
          ),
        );
      },
    );
  }
}

const _destinations = [
  _Destination(Icons.home_filled, 'Home'),
  _Destination(Icons.menu_book_rounded, 'Books'),
  _Destination(Icons.calendar_month_rounded, 'Calendar'),
  _Destination(Icons.flag_rounded, 'Goals'),
  _Destination(Icons.settings_rounded, 'Settings'),
];

class _Destination {
  const _Destination(this.icon, this.label);
  final IconData icon;
  final String label;
}

class ProHeader extends StatelessWidget {
  const ProHeader({
    super.key,
    this.greeting,
    this.title,
    this.showSearch = false,
    this.showBell = true,
  });

  final String? greeting;
  final String? title;
  final bool showSearch;
  final bool showBell;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const ProAvatar(size: 44),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                AppText.name,
                style: Theme.of(context).appBarTheme.titleTextStyle,
              ),
            ),
            if (showSearch)
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.search, size: 24),
                color: AppTheme.navy,
              ),
            if (showBell)
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.notifications_rounded, size: 24),
                color: AppTheme.navy,
              ),
          ],
        ),
        if (greeting != null || title != null) ...[
          const SizedBox(height: 8),
          if (greeting != null)
            Text(
              greeting!,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontSize: 15,
                color: AppTheme.navy,
              ),
            ),
          if (title != null) ...[
            const SizedBox(height: 4),
            Text(title!, style: Theme.of(context).textTheme.headlineMedium),
          ],
        ],
      ],
    );
  }
}

class ProAvatar extends StatelessWidget {
  const ProAvatar({super.key, this.size = 42});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFF122435),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .08),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Icon(Icons.person, color: Colors.white, size: size * .55),
    );
  }
}

class ProCard extends StatelessWidget {
  const ProCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(24),
    this.color = Colors.white,
    this.radius = 34,
    this.borderColor,
    this.shadow = true,
  });

  final Widget child;
  final EdgeInsets padding;
  final Color color;
  final double radius;
  final Color? borderColor;
  final bool shadow;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
        border: borderColor == null ? null : Border.all(color: borderColor!),
        boxShadow: shadow
            ? [
                BoxShadow(
                  color: const Color(0xFF1A2D3A).withValues(alpha: .06),
                  blurRadius: 30,
                  offset: const Offset(0, 16),
                ),
              ]
            : null,
      ),
      child: child,
    );
  }
}

class SectionLabel extends StatelessWidget {
  const SectionLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: Theme.of(
        context,
      ).textTheme.labelLarge?.copyWith(color: AppTheme.navy, letterSpacing: 4),
    );
  }
}

class StatusPill extends StatelessWidget {
  const StatusPill({
    super.key,
    required this.label,
    this.color = AppTheme.deepEmerald,
    this.background,
    this.icon,
  });

  final String label;
  final Color color;
  final Color? background;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: background ?? color.withValues(alpha: .12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, color: color, size: 14),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class SoftIcon extends StatelessWidget {
  const SoftIcon({
    super.key,
    required this.icon,
    this.color = AppTheme.deepEmerald,
    this.size = 56,
  });

  final IconData icon;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: .12),
        borderRadius: BorderRadius.circular(size * .32),
      ),
      child: Icon(icon, color: color, size: size * .46),
    );
  }
}

class ProProgress extends StatelessWidget {
  const ProProgress({
    super.key,
    required this.value,
    this.color = AppTheme.deepEmerald,
    this.height = 10,
  });

  final double value;
  final Color color;
  final double height;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: LinearProgressIndicator(
        value: value.clamp(0, 1),
        minHeight: height,
        backgroundColor: const Color(0xFFE7EAEC),
        color: color,
      ),
    );
  }
}

class MiniBars extends StatelessWidget {
  const MiniBars({super.key, this.color = AppTheme.emerald});

  final Color color;

  @override
  Widget build(BuildContext context) {
    final heights = [28.0, 42.0, 36.0, 52.0, 45.0];
    return SizedBox(
      width: 88,
      height: 72,
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            for (var i = 0; i < heights.length; i++) ...[
              Container(
                width: 11,
                height: heights[i],
                decoration: BoxDecoration(
                  color: i == heights.length - 1
                      ? color
                      : color.withValues(alpha: .16 + i * .09),
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              if (i != heights.length - 1) const SizedBox(width: 6),
            ],
          ],
        ),
      ),
    );
  }
}

class LineChartCard extends StatelessWidget {
  const LineChartCard({
    super.key,
    required this.title,
    required this.subtitle,
    this.height = 160,
    this.secondary = false,
  });

  final String title;
  final String subtitle;
  final double height;
  final bool secondary;

  @override
  Widget build(BuildContext context) {
    return ProCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 6),
          SizedBox(
            height: height,
            width: double.infinity,
            child: CustomPaint(painter: FlowLinePainter(secondary: secondary)),
          ),
        ],
      ),
    );
  }
}

class FlowLinePainter extends CustomPainter {
  const FlowLinePainter({this.secondary = false});

  final bool secondary;

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = const Color(0xFFECEFF1)
      ..strokeWidth = 1;
    for (var i = 1; i <= 3; i++) {
      final y = size.height * i / 4;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }
    final points = [
      Offset(0, size.height * .72),
      Offset(size.width * .18, size.height * .64),
      Offset(size.width * .35, size.height * .68),
      Offset(size.width * .52, size.height * .58),
      Offset(size.width * .68, size.height * .34),
      Offset(size.width * .84, size.height * .56),
      Offset(size.width, size.height * .40),
    ];
    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (var i = 1; i < points.length; i++) {
      final previous = points[i - 1];
      final point = points[i];
      path.cubicTo(
        previous.dx + 24,
        previous.dy,
        point.dx - 24,
        point.dy,
        point.dx,
        point.dy,
      );
    }
    final fill = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(
      fill,
      Paint()
        ..shader = LinearGradient(
          colors: [
            AppTheme.emerald.withValues(alpha: .22),
            AppTheme.emerald.withValues(alpha: .02),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)),
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = AppTheme.deepEmerald
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke,
    );
    if (secondary) {
      final red = Path()
        ..moveTo(0, size.height * .82)
        ..cubicTo(
          size.width * .3,
          size.height * .76,
          size.width * .58,
          size.height * .88,
          size.width,
          size.height * .70,
        );
      canvas.drawPath(
        red,
        Paint()
          ..color = AppTheme.danger.withValues(alpha: .75)
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

Color transactionColor(TransactionType type) =>
    type == TransactionType.cashIn ? AppTheme.deepEmerald : AppTheme.danger;

IconData transactionIcon(TransactionType type) =>
    type == TransactionType.cashIn ? Icons.business_center : Icons.restaurant;

IconData categoryIcon(String value) {
  final lower = value.toLowerCase();
  if (lower.contains('food') || lower.contains('dining')) {
    return Icons.restaurant;
  }
  if (lower.contains('salary') || lower.contains('income')) {
    return Icons.business_center;
  }
  if (lower.contains('car') || lower.contains('vehicle'))
    return Icons.directions_car;
  if (lower.contains('home') || lower.contains('house')) return Icons.home;
  if (lower.contains('travel') || lower.contains('trip'))
    return Icons.beach_access;
  if (lower.contains('bill')) return Icons.receipt_long;
  return Icons.wallet_rounded;
}

String goalStatus(SavingsGoal goal) {
  if (goal.progress >= .7) return 'ON TRACK';
  if (goal.progress < .25) return 'FALLING BEHIND';
  return 'ACTIVE';
}

Color goalColor(SavingsGoal goal) {
  if (goal.progress < .25) return AppTheme.danger;
  return AppTheme.deepEmerald;
}

String daysLeftLabel(SavingsGoal goal) {
  if (goal.deadline == null) return 'AUTO-LINKED';
  final days = goal.deadline!.difference(DateTime.now()).inDays;
  if (days <= 0) return 'DEADLINE DUE';
  if (days > 60) return '${(days / 30).ceil()} MONTHS LEFT';
  return '$days DAYS LEFT';
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _showInsights = true;

  @override
  Widget build(BuildContext context) {
    final store = AppScope.watch(context);
    final recent = [...store.books]
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    final visibleBooks = recent.isEmpty ? store.books : recent;
    final balance = store.books.fold<double>(
      0,
      (total, book) => total + store.balanceFor(book.id),
    );

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 16),
          children: [
            const ProHeader(
              greeting: 'Good evening, Ray',
              title: 'Your Wealth Overview',
              showSearch: true,
            ),
            const SizedBox(height: 28),
          if (visibleBooks.isEmpty)
            ProCard(
              child: EmptyState(
                icon: Icons.menu_book_outlined,
                title: 'No books yet',
                message:
                    'Create separate books for personal, freelance, or business cash flow.',
                action: FilledButton.icon(
                  onPressed: () => showBookDialog(context),
                  icon: const Icon(Icons.add),
                  label: const Text('Create Book'),
                ),
              ),
            )
          else
            for (final entry in visibleBooks.indexed) ...[
              AccountOverviewCard(
                book: entry.$2,
                balance: store.balanceFor(entry.$2.id),
                accent: entry.$1 == 0
                    ? AppTheme.emerald
                    : const Color(0xFFB9D8F7),
                icon: entry.$1 == 0
                    ? Icons.account_balance_wallet_rounded
                    : Icons.business_center,
                growthLabel: '${store.transactionsForBook(entry.$2.id).length} transactions',
                onTap: () => openBook(context, entry.$2),
              ),
              const SizedBox(height: 28),
            ],
          AnimatedSize(
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeInOut,
            child: _showInsights
                ? Dismissible(
                    key: const ValueKey('insights'),
                    direction: DismissDirection.endToStart,
                    onDismissed: (_) => setState(() => _showInsights = false),
                    child: ProCard(
                      padding: const EdgeInsets.all(11),
                      color: AppTheme.deepEmerald,
                      radius: 28,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Smart Insights',
                                  style: Theme.of(context).textTheme.titleLarge
                                      ?.copyWith(color: Colors.white),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  balance >= 0
                                      ? "You've saved more than last month."
                                      : 'Spending is ahead of inflow.',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.white.withValues(alpha: .92),
                                  ),
                                ),
                                const SizedBox(height: 14),
                                FilledButton(
                                  style: FilledButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: AppTheme.deepEmerald,
                                    minimumSize: const Size(120, 40),
                                  ),
                                  onPressed: () {},
                                  child: const Text('View Report'),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () => setState(() => _showInsights = false),
                            icon: const Icon(Icons.close, size: 18),
                            color: Colors.white.withValues(alpha: .7),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showBookDialog(context),
        child: const Icon(Icons.add, size: 28),
      ),
    );
  }
}

class AccountOverviewCard extends StatelessWidget {
  const AccountOverviewCard({
    super.key,
    required this.book,
    required this.balance,
    required this.accent,
    required this.icon,
    required this.growthLabel,
    required this.onTap,
  });

  final LedgerBook book;
  final double balance;
  final Color accent;
  final IconData icon;
  final String growthLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(36),
      onTap: onTap,
      child: ProCard(
        padding: const EdgeInsets.all(11),
        radius: 28,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SoftIcon(icon: icon, color: accent, size: 54),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        book.name,
                        style: Theme.of(
                          context,
                        ).textTheme.headlineSmall?.copyWith(fontSize: 16),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        book.description.ifBlank('MAIN ACCOUNT').toUpperCase(),
                        style: Theme.of(
                          context,
                        ).textTheme.labelLarge?.copyWith(letterSpacing: 2.6),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.more_vert, color: Color(0xFFB4BDC7)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        money(balance),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(
                          context,
                        ).textTheme.headlineMedium?.copyWith(fontSize: 20),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.trending_up_rounded, color: AppTheme.deepEmerald, size: 18),
                          const SizedBox(width: 6),
                          Text(growthLabel, style: const TextStyle(color: AppTheme.deepEmerald, fontSize: 11, fontWeight: FontWeight.w900)),
                        ],
                      ),
                    ],
                  ),
                ),
                MiniBars(color: accent),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class BookListCard extends StatelessWidget {
  const BookListCard({
    super.key,
    required this.book,
    required this.balance,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  final LedgerBook book;
  final double balance;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final isPositive = balance >= 0;
    final color = isPositive ? AppTheme.deepEmerald : AppTheme.danger;
    return InkWell(
      borderRadius: BorderRadius.circular(30),
      onTap: onTap,
      child: ProCard(
        radius: 30,
        padding: const EdgeInsets.all(24),
        child: Row(
          children: [
            SoftIcon(icon: Icons.menu_book_rounded, color: color, size: 58),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(book.name, style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 4),
                  Text(
                    book.description.ifBlank('No description'),
                    style: Theme.of(context).textTheme.bodyMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Updated ${_relativeDate(book.updatedAt)}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  money(balance),
                  style: TextStyle(color: color, fontSize: 15, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 8),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') onEdit();
                    if (value == 'delete') onDelete();
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem(value: 'edit', child: Text('Edit')),
                    PopupMenuItem(value: 'delete', child: Text('Delete')),
                  ],
                  child: const Icon(Icons.more_vert, color: Color(0xFFB4BDC7)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _relativeDate(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays == 0) return 'today';
    if (diff.inDays == 1) return 'yesterday';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return DateFormat.MMMd().format(date);
  }
}

class BooksScreen extends StatefulWidget {
  const BooksScreen({super.key});

  @override
  State<BooksScreen> createState() => _BooksScreenState();
}

class _BooksScreenState extends State<BooksScreen> {
  final _search = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final store = AppScope.watch(context);
    final books = store.books
        .where(
          (b) =>
              _query.isEmpty ||
              b.name.toLowerCase().contains(_query.toLowerCase()) ||
              b.description.toLowerCase().contains(_query.toLowerCase()),
        )
        .toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 16),
          children: [
            const ProHeader(showSearch: false, showBell: false),
            const SizedBox(height: 8),
            const SectionLabel('My Books'),
            const SizedBox(height: 6),
            Text('My Financial Workspace', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 18),
          ProCard(
            radius: 22,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            color: AppTheme.cloud,
            shadow: false,
            child: TextField(
              controller: _search,
              onChanged: (v) => setState(() => _query = v),
              decoration: const InputDecoration(
                hintText: 'Search books...',
                prefixIcon: Icon(Icons.search_rounded, color: AppTheme.navy),
                filled: false,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
              ),
            ),
          ),
          const SizedBox(height: 26),
          if (store.books.isEmpty)
            ProCard(
              child: EmptyState(
                icon: Icons.menu_book_outlined,
                title: 'No books yet',
                message: 'Create separate books for personal, freelance, or business cash flow.',
                action: FilledButton.icon(
                  onPressed: () => showBookDialog(context),
                  icon: const Icon(Icons.add),
                  label: const Text('Create Book'),
                ),
              ),
            )
          else if (books.isEmpty)
            ProCard(
              child: const EmptyState(
                icon: Icons.search_off_rounded,
                title: 'No results',
                message: 'No books match your search.',
              ),
            )
          else
            for (final book in books) ...[
              BookListCard(
                book: book,
                balance: store.balanceFor(book.id),
                onTap: () => openBook(context, book),
                onEdit: () => showBookDialog(context, book: book),
                onDelete: () async {
                  await store.deleteBook(book.id);
                },
              ),
              const SizedBox(height: 6),
            ],
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showBookDialog(context),
        child: const Icon(Icons.add, size: 28),
      ),
    );
  }
}

class _BookMetricChip extends StatelessWidget {
  const _BookMetricChip({
    required this.label,
    required this.value,
    this.accentColor,
  });

  final String label;
  final String value;
  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    final accent = accentColor ?? Colors.white;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .15),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xB3FFFFFF),
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: accent,
              fontWeight: FontWeight.w900,
              fontSize: 14,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _CashflowBar extends StatelessWidget {
  const _CashflowBar({
    required this.label,
    required this.value,
    required this.maxValue,
    required this.color,
  });

  final String label;
  final double value;
  final double maxValue;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: Theme.of(context).textTheme.labelLarge,
        ),
        const SizedBox(height: 8),
        ProProgress(
          value: maxValue <= 0 ? 0 : value / maxValue,
          color: color,
          height: 8,
        ),
      ],
    );
  }
}

class CalendarPanel extends StatelessWidget {
  const CalendarPanel({
    super.key,
    required this.month,
    required this.byDay,
    required this.selectedDay,
    required this.onSelect,
  });

  final DateTime month;
  final Map<DateTime, List<LedgerTransaction>> byDay;
  final DateTime selectedDay;
  final ValueChanged<DateTime> onSelect;

  @override
  Widget build(BuildContext context) {
    final firstWeekday = month.weekday % 7;
    final daysInMonth = DateUtils.getDaysInMonth(month.year, month.month);
    final totalCells = firstWeekday + daysInMonth;
    return ProCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                for (final day in const [
                  'Sun',
                  'Mon',
                  'Tue',
                  'Wed',
                  'Thu',
                  'Fri',
                  'Sat',
                ])
                  Text(
                    day.toUpperCase(),
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontSize: 11,
                      letterSpacing: 1.6,
                    ),
                  ),
              ],
            ),
          ),
          GridView.builder(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: .72,
            ),
            itemCount: totalCells,
            itemBuilder: (context, index) {
              if (index < firstWeekday) {
                return const ColoredBox(color: Color(0xFFFAFBFB));
              }
              final day = DateTime(
                month.year,
                month.month,
                index - firstWeekday + 1,
              );
              final items = byDay[day] ?? const <LedgerTransaction>[];
              final isSelected = DateUtils.isSameDay(day, selectedDay);
              final income = items.any(
                (item) => item.type == TransactionType.cashIn,
              );
              final expense = items.any(
                (item) => item.type == TransactionType.cashOut,
              );
              return InkWell(
                onTap: () => onSelect(day),
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppTheme.mist
                        : index.isOdd
                        ? Colors.white
                        : const Color(0xFFFCFCFC),
                    border: Border.all(
                      color: isSelected
                          ? AppTheme.deepEmerald
                          : const Color(0xFFF3F4F4),
                    ),
                  ),
                  padding: const EdgeInsets.all(7),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${day.day}',
                        style: TextStyle(
                          fontWeight: isSelected
                              ? FontWeight.w900
                              : FontWeight.w700,
                          color: isSelected
                              ? AppTheme.deepEmerald
                              : AppTheme.ink,
                        ),
                      ),
                      const Spacer(),
                      if (items.isNotEmpty)
                        Row(
                          children: [
                            if (income)
                              const CircleAvatar(
                                radius: 3,
                                backgroundColor: AppTheme.deepEmerald,
                              ),
                            if (income && expense) const SizedBox(width: 4),
                            if (expense)
                              const CircleAvatar(
                                radius: 3,
                                backgroundColor: AppTheme.danger,
                              ),
                          ],
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class TransactionSummaryTile extends StatelessWidget {
  const TransactionSummaryTile({super.key, required this.transaction});

  final LedgerTransaction transaction;

  @override
  Widget build(BuildContext context) {
    final color = transactionColor(transaction.type);
    final sign = transaction.type == TransactionType.cashIn ? '+' : '−';
    final hasNote = transaction.notes.trim().isNotEmpty;
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: () => showTransactionDetail(context, transaction),
      child: ProCard(
        radius: 24,
        padding: const EdgeInsets.all(11),
        child: Row(
          children: [
            SoftIcon(icon: categoryIcon(transaction.category), color: color),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    transaction.category.ifBlank('Uncategorized'),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  if (hasNote) ...[
                    const SizedBox(height: 2),
                    Text(
                      transaction.notes,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.navy.withValues(alpha: .65),
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '$sign${money(transaction.amount)}',
                  style: Theme.of(
                    context,
                  ).textTheme.titleMedium?.copyWith(color: color),
                ),
                Text(
                  money(transaction.runningBalance),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 11,
                    color: AppTheme.navy.withValues(alpha: .55),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class BookDetailScreen extends StatefulWidget {
  const BookDetailScreen({super.key, required this.bookId});

  final String bookId;

  @override
  State<BookDetailScreen> createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends State<BookDetailScreen> {
  // type filter: 'all' | 'in' | 'out'
  String type = 'all';
  String category = 'all';
  String paymentMode = 'all';
  String date = 'all';

  String _dateGroupLabel(DateTime day) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    if (day == today) return 'Today';
    if (day == yesterday) return 'Yesterday';
    return DateFormat('MMM d, yyyy').format(day);
  }

  @override
  Widget build(BuildContext context) {
    final store = AppScope.watch(context);
    final book = store.bookById(widget.bookId);
    if (book == null) {
      return const Scaffold(
        body: EmptyState(
          icon: Icons.error_outline,
          title: 'Book missing',
          message: 'This book no longer exists.',
        ),
      );
    }
    final all = store.transactionsForBook(book.id);
    final filtered = all.where(_matches).toList();
    final cashIn = filtered
        .where((transaction) => transaction.type == TransactionType.cashIn)
        .fold<double>(0, (total, transaction) => total + transaction.amount);
    final cashOut = filtered
        .where((transaction) => transaction.type == TransactionType.cashOut)
        .fold<double>(0, (total, transaction) => total + transaction.amount);
    final grouped = <DateTime, List<LedgerTransaction>>{};
    for (final transaction in filtered) {
      final day = DateTime(
        transaction.occurredAt.year,
        transaction.occurredAt.month,
        transaction.occurredAt.day,
      );
      grouped.putIfAbsent(day, () => []).add(transaction);
    }
    final groupEntries = grouped.entries.toList()
      ..sort((a, b) => b.key.compareTo(a.key));

    // Build the horizontal filter chips for type
    final typeFilters = <(String, String)>[
      ('all', 'All'),
      ('in', 'Cash In'),
      ('out', 'Cash Out'),
      for (final cat in book.categories) (cat, cat),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(book.name),
        actions: [
          IconButton(
            tooltip: 'Edit book',
            onPressed: () => showBookDialog(context, book: book),
            icon: const Icon(Icons.edit_outlined),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) async {
              if (value == 'import') {
                if (!context.mounted) return;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ImportScreen(bookId: book.id),
                  ),
                );
              }
              if (value == 'graph') {
                if (!context.mounted) return;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BookVisualizerScreen(bookId: book.id),
                  ),
                );
              }
              if (value == 'pdf') {
                await ExportService.exportPdf(
                  book: book,
                  transactions: filtered,
                );
              }
              if (value == 'excel') {
                await ExportService.exportExcelLike(
                  book: book,
                  transactions: filtered,
                );
              }
              if (value == 'delete' && context.mounted) {
                await store.deleteBook(book.id);
                if (context.mounted) Navigator.pop(context);
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'import', child: Text('Import')),
              PopupMenuItem(value: 'graph', child: Text('View graph')),
              PopupMenuDivider(),
              PopupMenuItem(value: 'pdf', child: Text('Export PDF')),
              PopupMenuItem(value: 'excel', child: Text('Export Excel CSV')),
              PopupMenuDivider(),
              PopupMenuItem(value: 'delete', child: Text('Delete book')),
            ],
          ),
        ],
      ),
      // Change 7: bottom action bar replacing FAB
      floatingActionButton: null,
      bottomNavigationBar: DecoratedBox(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(0xFFE8ECED), width: .5)),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => openTransactionForm(context, book, initialType: TransactionType.cashIn),
                    icon: const Icon(Icons.arrow_downward_rounded, size: 18),
                    label: const Text('Cash In'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.deepEmerald,
                      side: const BorderSide(color: AppTheme.deepEmerald),
                      minimumSize: const Size(0, 52),
                      shape: const StadiumBorder(),
                      textStyle: const TextStyle(
                        inherit: false,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () => openTransactionForm(context, book, initialType: TransactionType.cashOut),
                    icon: const Icon(Icons.arrow_upward_rounded, size: 18),
                    label: const Text('Cash Out'),
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.red.shade600,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(0, 52),
                      shape: const StadiumBorder(),
                      textStyle: const TextStyle(
                        inherit: false,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 16),
        children: [
          // Change 1: Hero balance card — larger, centered amount
          ProCard(
            color: AppTheme.deepEmerald,
            radius: 34,
            padding: const EdgeInsets.all(28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'CURRENT BALANCE',
                  style: TextStyle(
                    color: Color(0xB3FFFFFF),
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  money(store.balanceFor(book.id)),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    inherit: false,
                    color: Colors.white,
                    fontSize: 34,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -1,
                  ),
                ),
                const SizedBox(height: 22),
                Row(
                  children: [
                    Expanded(
                      child: _BookMetricChip(
                        label: 'INFLOW',
                        value: money(cashIn),
                        accentColor: const Color(0xFF7FFFC0),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _BookMetricChip(
                        label: 'OUTFLOW',
                        value: money(cashOut),
                        accentColor: const Color(0xFFFF9999),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          // Change 6: View Detailed Analysis button
          OutlinedButton.icon(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => BookVisualizerScreen(bookId: book.id),
              ),
            ),
            icon: const Icon(Icons.bar_chart_rounded),
            label: const Text('View Detailed Analysis'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.deepEmerald,
              side: const BorderSide(color: AppTheme.deepEmerald),
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              textStyle: const TextStyle(
                inherit: false,
                fontSize: 14,
                fontWeight: FontWeight.w800,
                letterSpacing: .2,
              ),
            ),
          ),
          const SizedBox(height: 14),
          ProCard(
            color: AppTheme.cloud,
            shadow: false,
            radius: 22,
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                const Icon(Icons.auto_awesome, color: AppTheme.deepEmerald),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    cashOut == 0
                        ? 'No spending pressure in this view. Keep entries tagged for better insights.'
                        : 'Burn rate is ${(cashOut / max(cashIn, 1) * 100).clamp(0, 999).toStringAsFixed(0)}% of filtered inflow.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          // Change 3: Horizontal scrollable pill filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final filter in typeFilters) ...[
                  _FilterPill(
                    label: filter.$2,
                    selected: type == filter.$1 ||
                        (filter.$1 != 'all' &&
                            filter.$1 != 'in' &&
                            filter.$1 != 'out' &&
                            category == filter.$1),
                    onTap: () {
                      setState(() {
                        if (filter.$1 == 'all' ||
                            filter.$1 == 'in' ||
                            filter.$1 == 'out') {
                          type = filter.$1;
                          category = 'all';
                        } else {
                          category = filter.$1;
                          type = 'all';
                        }
                      });
                    },
                  ),
                  const SizedBox(width: 8),
                ],
              ],
            ),
          ),
          const SizedBox(height: 6),
          if (filtered.isEmpty)
            EmptyState(
              icon: Icons.receipt_long_outlined,
              title: 'No transactions',
              message: 'Add a cash in or cash out entry for this book.',
              action: FilledButton.icon(
                onPressed: () => openTransactionForm(context, book),
                icon: const Icon(Icons.add),
                label: const Text('Add transaction'),
              ),
            )
          else
            // Change 4: Date group headers with Today/Yesterday
            for (final entry in groupEntries) ...[
              Padding(
                padding: const EdgeInsets.only(top: 22, bottom: 10),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        _dateGroupLabel(entry.key),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    Text(
                      '${entry.value.length} transaction${entry.value.length == 1 ? '' : 's'}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              for (final transaction in entry.value) ...[
                TransactionSummaryTile(transaction: transaction),
                const SizedBox(height: 6),
              ],
            ],
        ],
      ),
    );
  }

  bool _matches(LedgerTransaction transaction) {
    if (type == 'in' && transaction.type != TransactionType.cashIn) {
      return false;
    }
    if (type == 'out' && transaction.type != TransactionType.cashOut) {
      return false;
    }
    if (category != 'all' && transaction.category != category) return false;
    if (paymentMode != 'all' && transaction.paymentMode != paymentMode) {
      return false;
    }
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final occurred = transaction.occurredAt;
    if (date == 'today' && occurred.isBefore(today)) return false;
    if (date == '7' &&
        occurred.isBefore(today.subtract(const Duration(days: 6)))) {
      return false;
    }
    if (date == 'month' && occurred.isBefore(DateTime(now.year, now.month))) {
      return false;
    }
    if (date == '3m' && occurred.isBefore(DateTime(now.year, now.month - 2))) {
      return false;
    }
    return true;
  }
}

class _FilterPill extends StatelessWidget {
  const _FilterPill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? AppTheme.deepEmerald : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? AppTheme.deepEmerald : AppTheme.navy.withValues(alpha: .35),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            inherit: false,
            color: selected ? Colors.white : AppTheme.navy,
            fontSize: 13,
            fontWeight: FontWeight.w800,
            letterSpacing: .2,
          ),
        ),
      ),
    );
  }
}

class TransactionFormScreen extends StatefulWidget {
  const TransactionFormScreen({
    super.key,
    required this.book,
    this.transaction,
    this.initialType,
  });

  final LedgerBook book;
  final LedgerTransaction? transaction;
  final TransactionType? initialType;

  @override
  State<TransactionFormScreen> createState() => _TransactionFormScreenState();
}

class _TransactionFormScreenState extends State<TransactionFormScreen> {
  final formKey = GlobalKey<FormState>();
  late final title = TextEditingController(
    text: widget.transaction?.title ?? '',
  );
  late final amount = TextEditingController(
    text: widget.transaction == null
        ? ''
        : widget.transaction!.amount.toStringAsFixed(2),
  );
  late final notes = TextEditingController(
    text: widget.transaction?.notes ?? '',
  );
  late TransactionType type =
      widget.transaction?.type ?? widget.initialType ?? TransactionType.cashOut;
  late DateTime occurredAt = widget.transaction?.occurredAt ?? DateTime.now();
  late String category = widget.transaction?.category ?? '';
  late String paymentMode = widget.transaction?.paymentMode ?? '';
  late String? goalId = widget.transaction?.goalId;

  @override
  Widget build(BuildContext context) {
    final store = AppScope.watch(context);
    final book = store.bookById(widget.book.id) ?? widget.book;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.transaction == null ? 'New Transaction' : 'Edit Transaction',
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.close),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 18),
            child: ProAvatar(size: 46),
          ),
        ],
      ),
      body: Form(
        key: formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 112),
          children: [
            Center(
              child: SectionLabel(
                widget.transaction == null
                    ? 'Transaction Amount'
                    : 'Updated Amount',
              ),
            ),
            const SizedBox(height: 6),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  '\$',
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    color: Colors.black.withValues(alpha: .38),
                    fontSize: 26,
                  ),
                ),
                Expanded(
                  child: TextFormField(
                    controller: amount,
                    textAlign: TextAlign.center,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      color: Colors.black.withValues(alpha: .12),
                      fontSize: 22,
                    ),
                    decoration: const InputDecoration(
                      hintText: '0.00',
                      filled: false,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                    ),
                    validator: (value) =>
                        (double.tryParse(value ?? '') ?? 0) <= 0
                        ? 'Enter an amount greater than zero'
                        : null,
                  ),
                ),
                Column(
                  children: [
                    IconButton(
                      onPressed: () {
                        final value = double.tryParse(amount.text) ?? 0;
                        amount.text = (value + 1).toStringAsFixed(2);
                      },
                      icon: const Icon(Icons.arrow_drop_up),
                    ),
                    IconButton(
                      onPressed: () {
                        final value = max(
                          (double.tryParse(amount.text) ?? 0) - 1,
                          0,
                        );
                        amount.text = value.toStringAsFixed(2);
                      },
                      icon: const Icon(Icons.arrow_drop_down),
                    ),
                  ],
                ),
              ],
            ),
            Center(
              child: Container(
                width: 68,
                height: 5,
                decoration: BoxDecoration(
                  color: AppTheme.deepEmerald.withValues(alpha: .22),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            const SizedBox(height: 34),
            ProCard(
              padding: const EdgeInsets.all(6),
              color: AppTheme.cloud,
              radius: 28,
              shadow: false,
              child: Row(
                children: [
                  Expanded(
                    child: _TypeButton(
                      label: 'Income',
                      icon: Icons.arrow_downward,
                      selected: type == TransactionType.cashIn,
                      onTap: () =>
                          setState(() => type = TransactionType.cashIn),
                    ),
                  ),
                  Expanded(
                    child: _TypeButton(
                      label: 'Expense',
                      icon: Icons.arrow_upward,
                      selected: type == TransactionType.cashOut,
                      onTap: () =>
                          setState(() => type = TransactionType.cashOut),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            ProCard(
              radius: 34,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Title', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: title,
                    decoration: const InputDecoration(
                      hintText: 'What was this for?',
                    ),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Enter a title'
                        : null,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Category',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    initialValue: category.isEmpty ? null : category,
                    decoration: InputDecoration(
                      suffixIcon: IconButton(
                        tooltip: 'Add category',
                        onPressed: () => showNamePrompt(
                          context,
                          'Add category',
                          (value) => store.addCategory(book.id, value),
                        ),
                        icon: const Icon(Icons.add),
                      ),
                    ),
                    items: [
                      for (final item in book.categories)
                        DropdownMenuItem(value: item, child: Text(item)),
                    ],
                    onChanged: (value) =>
                        setState(() => category = value ?? ''),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Payment Mode',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    initialValue: paymentMode.isEmpty ? null : paymentMode,
                    decoration: InputDecoration(
                      suffixIcon: IconButton(
                        tooltip: 'Add payment mode',
                        onPressed: () => showNamePrompt(
                          context,
                          'Add payment mode',
                          (value) => store.addPaymentMode(book.id, value),
                        ),
                        icon: const Icon(Icons.add),
                      ),
                    ),
                    items: [
                      for (final item in book.paymentModes)
                        DropdownMenuItem(value: item, child: Text(item)),
                    ],
                    onChanged: (value) =>
                        setState(() => paymentMode = value ?? ''),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            ProCard(
              radius: 28,
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  const SoftIcon(
                    icon: Icons.calendar_today,
                    color: AppTheme.navy,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Date & Time',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(
                          DateFormat.yMMMd().add_jm().format(occurredAt),
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () => _pickDateTime(context),
                    child: const Text('Change'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            ProCard(
              radius: 34,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Notes (Optional)',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: notes,
                    minLines: 3,
                    maxLines: 5,
                    decoration: const InputDecoration(
                      hintText: 'Add some details about the transaction...',
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Link to Goal',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    initialValue: goalId?.isEmpty ?? true ? null : goalId,
                    decoration: const InputDecoration(
                      hintText: 'No goal selected',
                      suffixIcon: Icon(Icons.flag),
                    ),
                    items: [
                      for (final goal in store.goals)
                        DropdownMenuItem(
                          value: goal.id,
                          child: Text(goal.name),
                        ),
                    ],
                    onChanged: type == TransactionType.cashIn
                        ? (value) => setState(() => goalId = value)
                        : null,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 36),
            FilledButton.icon(
              onPressed: () => _save(context, book),
              icon: const Icon(Icons.check_circle),
              label: Text(
                widget.transaction == null
                    ? 'Save Transaction'
                    : 'Save Changes',
              ),
              style: FilledButton.styleFrom(
                minimumSize: const Size(double.infinity, 64),
                backgroundColor: const Color(0xFF19B464),
                shadowColor: AppTheme.deepEmerald.withValues(alpha: .4),
                elevation: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDateTime(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      initialDate: occurredAt,
    );
    if (date == null || !context.mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(occurredAt),
    );
    setState(() {
      occurredAt = DateTime(
        date.year,
        date.month,
        date.day,
        time?.hour ?? occurredAt.hour,
        time?.minute ?? occurredAt.minute,
      );
    });
  }

  Future<void> _save(BuildContext context, LedgerBook book) async {
    if (!formKey.currentState!.validate()) return;
    final store = AppScope.read(context);
    final now = DateTime.now();
    final existing = widget.transaction;
    await store.saveTransaction(
      LedgerTransaction(
        id: existing?.id ?? AppStore._id('txn'),
        bookId: book.id,
        title: title.text.trim(),
        amount: double.parse(amount.text),
        type: type,
        occurredAt: occurredAt,
        createdAt: existing?.createdAt ?? now,
        updatedAt: now,
        category: category,
        paymentMode: paymentMode,
        notes: notes.text.trim(),
        goalId: type == TransactionType.cashIn ? goalId : null,
        runningBalance: existing?.runningBalance ?? 0,
        externalReference: existing?.externalReference ?? '',
        statementBalance: existing?.statementBalance,
        sequence: existing?.sequence ?? 0,
        importSource: existing?.importSource ?? '',
      ),
    );
    if (context.mounted) Navigator.pop(context);
  }
}

class _TypeButton extends StatelessWidget {
  const _TypeButton({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: .05),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: selected ? AppTheme.deepEmerald : AppTheme.navy),
            const SizedBox(width: 10),
            Text(
              label,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: selected ? AppTheme.deepEmerald : AppTheme.navy,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ImportScreen extends StatefulWidget {
  const ImportScreen({super.key, required this.bookId});

  final String bookId;

  @override
  State<ImportScreen> createState() => _ImportScreenState();
}

class BookVisualizerScreen extends StatefulWidget {
  const BookVisualizerScreen({super.key, required this.bookId});

  final String bookId;

  @override
  State<BookVisualizerScreen> createState() => _BookVisualizerScreenState();
}

class _BookVisualizerScreenState extends State<BookVisualizerScreen> {
  String range = 'monthly';

  @override
  Widget build(BuildContext context) {
    final store = AppScope.watch(context);
    final book = store.bookById(widget.bookId);
    if (book == null) {
      return const Scaffold(
        body: EmptyState(
          icon: Icons.error_outline,
          title: 'Book missing',
          message: 'This book no longer exists.',
        ),
      );
    }
    final transactions = store.transactionsForBook(book.id);
    final income = transactions
        .where((item) => item.type == TransactionType.cashIn)
        .fold<double>(0, (total, item) => total + item.amount);
    final expense = transactions
        .where((item) => item.type == TransactionType.cashOut)
        .fold<double>(0, (total, item) => total + item.amount);
    final net = income - expense;

    return Scaffold(
      appBar: AppBar(title: Text('${book.name} Visualizer')),
      body: ListView(
        padding: const EdgeInsets.all(11),
        children: [
          SegmentedButton<String>(
            selected: {range},
            onSelectionChanged: (value) => setState(() => range = value.first),
            segments: const [
              ButtonSegment(value: 'monthly', label: Text('Monthly')),
              ButtonSegment(value: 'quarterly', label: Text('Quarterly')),
              ButtonSegment(value: 'yearly', label: Text('Yearly')),
            ],
          ),
          const SizedBox(height: 6),
          ResponsiveMetrics(
            children: [
              MetricCard(
                'Income',
                money(income),
                Icons.south_west,
                color: Colors.green,
              ),
              MetricCard(
                'Burn rate',
                '${(expense / max(income, 1) * 100).clamp(0, 999).toStringAsFixed(0)}%',
                Icons.donut_large,
                color: Colors.orange,
              ),
              MetricCard('Net flow', money(net), Icons.stacked_line_chart),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Comparative Flow',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          FlowBars(income: income, expense: expense),
          const SizedBox(height: 6),
          Text(
            'Burn Rate Donut',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          BurnRateDonut(income: income, expense: expense),
        ],
      ),
    );
  }
}

class _ImportScreenState extends State<ImportScreen> {
  ImportPreview? preview;
  bool loading = false;
  String? error;

  @override
  Widget build(BuildContext context) {
    final store = AppScope.watch(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Import statement')),
      body: ListView(
        padding: const EdgeInsets.all(11),
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilledButton.icon(
                onPressed: loading
                    ? null
                    : () => _load(
                        () => ImportParser.parsePdf(
                          store: store,
                          bookId: widget.bookId,
                        ),
                      ),
                icon: const Icon(Icons.picture_as_pdf_outlined),
                label: const Text('Import PDF'),
              ),
              FilledButton.tonalIcon(
                onPressed: loading
                    ? null
                    : () => _load(
                        () => ImportParser.parseXls(
                          store: store,
                          bookId: widget.bookId,
                        ),
                      ),
                icon: const Icon(Icons.table_chart_outlined),
                label: const Text('Import XLS'),
              ),
            ],
          ),
          if (loading)
            const Padding(
              padding: EdgeInsets.only(top: 16),
              child: LinearProgressIndicator(),
            ),
          if (error != null) ...[
            const SizedBox(height: 6),
            Text(
              error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],
          if (preview != null) _ImportPreviewView(preview: preview!),
        ],
      ),
    );
  }

  Future<void> _load(Future<ImportPreview> Function() loader) async {
    setState(() {
      loading = true;
      error = null;
    });
    try {
      preview = await loader();
    } catch (exception) {
      error = 'Unable to parse statement: $exception';
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }
}

class _ImportPreviewView extends StatelessWidget {
  const _ImportPreviewView({required this.preview});

  final ImportPreview preview;

  @override
  Widget build(BuildContext context) {
    final store = AppScope.read(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 6),
        Text('Preview', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            Chip(label: Text('${preview.importable.length} importable')),
            Chip(label: Text('${preview.duplicates.length} duplicates')),
            Chip(label: Text('${preview.ignored.length} ignored')),
          ],
        ),
        if (preview.importable.isEmpty && preview.duplicates.isNotEmpty) ...[
          const SizedBox(height: 8),
          const Card(
            child: Padding(
              padding: EdgeInsets.all(11),
              child: Text(
                'All parsed entries already exist in this book. Nothing new will be imported.',
              ),
            ),
          ),
        ],
        const SizedBox(height: 8),
        FilledButton.icon(
          onPressed: preview.importable.isEmpty
              ? null
              : () async {
                  await store.commitImport(preview);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Imported ${preview.importable.length} transactions',
                        ),
                      ),
                    );
                    Navigator.pop(context);
                  }
                },
          icon: const Icon(Icons.check),
          label: const Text('Import transactions'),
        ),
        const SizedBox(height: 6),
        for (final transaction in preview.importable.take(25))
          ListTile(
            title: Text(transaction.title),
            subtitle: Text(transaction.type.label),
            trailing: Text(money(transaction.amount)),
          ),
        if (preview.ignored.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text('Skipped lines', style: Theme.of(context).textTheme.titleMedium),
          for (final line in preview.ignored.take(10))
            Text(line, maxLines: 1, overflow: TextOverflow.ellipsis),
        ],
      ],
    );
  }
}

class GoalsScreen extends StatefulWidget {
  const GoalsScreen({super.key});

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  bool _showTracking = true;

  @override
  Widget build(BuildContext context) {
    final store = AppScope.watch(context);
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 16),
          children: [
            const ProHeader(showSearch: false),
            const SizedBox(height: 8),
            Text(
              'Financial Goals',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 6),
          Text(
            'Visualizing your path to prosperity. Your progress updates automatically as you save.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 34),
          if (store.goals.isEmpty)
            ProCard(
              child: EmptyState(
                icon: Icons.flag_outlined,
                title: 'No goals yet',
                message: 'Create savings goals and link cash-in transactions.',
                action: FilledButton.icon(
                  onPressed: () => showGoalDialog(context),
                  icon: const Icon(Icons.add),
                  label: const Text('Add Goal'),
                ),
              ),
            )
          else
            for (final goal in store.goals) ...[
              GoalCard(
                goal: goal,
                onTap: () => showGoalDialog(context, goal: goal),
              ),
              const SizedBox(height: 22),
            ],
          AnimatedSize(
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeInOut,
            child: _showTracking
                ? Dismissible(
                    key: const ValueKey('tracking'),
                    direction: DismissDirection.endToStart,
                    onDismissed: (_) => setState(() => _showTracking = false),
                    child: ProCard(
                      color: const Color(0xFFEAF3F0),
                      borderColor: const Color(0xFFCFE3DA),
                      radius: 30,
                      padding: const EdgeInsets.all(11),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const StatusPill(
                                label: 'SMART TRACKING',
                                icon: Icons.auto_awesome,
                              ),
                              const Spacer(),
                              GestureDetector(
                                onTap: () => setState(() => _showTracking = false),
                                child: Icon(Icons.close, size: 18, color: AppTheme.navy.withValues(alpha: .5)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Automatic Progress Updates',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Link transactions to goals and your progress updates automatically.',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showGoalDialog(context),
        child: const Icon(Icons.add, size: 28),
      ),
    );
  }
}

class GoalCard extends StatelessWidget {
  const GoalCard({super.key, required this.goal, required this.onTap});

  final SavingsGoal goal;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = goalColor(goal);
    return InkWell(
      borderRadius: BorderRadius.circular(30),
      onTap: onTap,
      child: ProCard(
        radius: 30,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                SoftIcon(icon: categoryIcon(goal.name), color: color, size: 58),
                const Spacer(),
                StatusPill(
                  label: goalStatus(goal),
                  color: color,
                  background: color.withValues(alpha: .12),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(goal.name, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Target: ${money(goal.targetAmount)}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                Text(
                  '${money(goal.savedAmount)} saved',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppTheme.deepEmerald,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            ProProgress(value: goal.progress, color: color),
            const SizedBox(height: 8),
            Text(
              '${(goal.progress * 100).toStringAsFixed(1)}% COMPLETED • ${daysLeftLabel(goal)}',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontSize: 10,
                color: color,
                letterSpacing: .2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TrackingBenefit extends StatelessWidget {
  const _TrackingBenefit({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.deepEmerald),
        const SizedBox(width: 10),
        Text(
          label,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: AppTheme.deepEmerald,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});
  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late DateTime _month;
  DateTime? _selected;

  static const _monthNames = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _month = DateTime(now.year, now.month);
    _selected = DateTime(now.year, now.month, now.day);
  }

  @override
  Widget build(BuildContext context) {
    final store = AppScope.watch(context);
    final now = DateTime.now();

    final byDay = <String, List<LedgerTransaction>>{};
    for (final tx in store.transactions) {
      final key = '${tx.occurredAt.year}-${tx.occurredAt.month}-${tx.occurredAt.day}';
      byDay.putIfAbsent(key, () => []).add(tx);
    }

    final monthTxs = store.transactions.where((tx) =>
        tx.occurredAt.year == _month.year && tx.occurredAt.month == _month.month).toList();
    final monthIncome = monthTxs
        .where((t) => t.type == TransactionType.cashIn)
        .fold<double>(0, (s, t) => s + t.amount);
    final monthExpense = monthTxs
        .where((t) => t.type == TransactionType.cashOut)
        .fold<double>(0, (s, t) => s + t.amount);

    final firstDay = DateTime(_month.year, _month.month, 1);
    final daysInMonth = DateUtils.getDaysInMonth(_month.year, _month.month);
    final startOffset = firstDay.weekday % 7;

    final selKey = _selected == null
        ? null
        : '${_selected!.year}-${_selected!.month}-${_selected!.day}';
    final selectedTxs = selKey == null ? <LedgerTransaction>[] : (byDay[selKey] ?? []);

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 16),
        children: [
          ProHeader(title: 'Financial Timeline'),
          const SizedBox(height: 8),

          // Month navigation
          ProCard(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => setState(() =>
                      _month = DateTime(_month.year, _month.month - 1)),
                  icon: const Icon(Icons.chevron_left),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                Expanded(
                  child: Text(
                    '${_monthNames[_month.month - 1]} ${_month.year}',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                  ),
                ),
                TextButton(
                  onPressed: () => setState(() {
                    _month = DateTime(now.year, now.month);
                    _selected = DateTime(now.year, now.month, now.day);
                  }),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    foregroundColor: AppTheme.deepEmerald,
                  ),
                  child: const Text('Today', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                ),
                const SizedBox(width: 4),
                IconButton(
                  onPressed: () => setState(() =>
                      _month = DateTime(_month.year, _month.month + 1)),
                  icon: const Icon(Icons.chevron_right),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Monthly cashflow card
          ProCard(
            color: AppTheme.deepEmerald,
            radius: 20,
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  money(monthIncome - monthExpense),
                  style: const TextStyle(inherit: false, color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 2),
                Text(
                  'Net flow · ${_monthNames[_month.month - 1]}',
                  style: const TextStyle(inherit: false, color: Colors.white70, fontSize: 11),
                ),
                if (monthIncome + monthExpense > 0) ...[
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(99),
                    child: LinearProgressIndicator(
                      value: monthIncome / (monthIncome + monthExpense),
                      backgroundColor: Colors.white24,
                      valueColor: const AlwaysStoppedAnimation(Colors.white),
                      minHeight: 5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.arrow_upward, size: 11, color: Colors.white70),
                      const SizedBox(width: 4),
                      Text(money(monthIncome),
                          style: const TextStyle(inherit: false, color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
                      const Spacer(),
                      const Icon(Icons.arrow_downward, size: 11, color: Colors.white60),
                      const SizedBox(width: 4),
                      Text(money(monthExpense),
                          style: const TextStyle(inherit: false, color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w700)),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Calendar grid
          ProCard(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                Row(
                  children: ['S', 'M', 'T', 'W', 'T', 'F', 'S']
                      .map((d) => Expanded(
                            child: Center(
                              child: Text(d,
                                  style: const TextStyle(
                                      inherit: false, fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF9CA3AF))),
                            ),
                          ))
                      .toList(),
                ),
                const SizedBox(height: 6),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7,
                    childAspectRatio: 1,
                    mainAxisSpacing: 2,
                    crossAxisSpacing: 2,
                  ),
                  itemCount: startOffset + daysInMonth,
                  itemBuilder: (context, i) {
                    if (i < startOffset) return const SizedBox();
                    final day = i - startOffset + 1;
                    final date = DateTime(_month.year, _month.month, day);
                    final key = '${date.year}-${date.month}-${date.day}';
                    final txs = byDay[key] ?? [];
                    final isSelected = _selected != null &&
                        _selected!.year == date.year &&
                        _selected!.month == date.month &&
                        _selected!.day == date.day;
                    final isToday = date.year == now.year &&
                        date.month == now.month &&
                        date.day == now.day;
                    final hasIncome = txs.any((t) => t.type == TransactionType.cashIn);
                    final hasExpense = txs.any((t) => t.type == TransactionType.cashOut);

                    return GestureDetector(
                      onTap: () => setState(() => _selected = date),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppTheme.deepEmerald
                              : isToday ? AppTheme.mist : null,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('$day',
                                style: TextStyle(
                                    inherit: false,
                                    fontSize: 12,
                                    fontWeight: isSelected || isToday ? FontWeight.w800 : FontWeight.w500,
                                    color: isSelected ? Colors.white : const Color(0xFF191C1D))),
                            if (txs.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (hasIncome)
                                    Container(
                                      width: 4, height: 4,
                                      margin: const EdgeInsets.only(right: 1),
                                      decoration: BoxDecoration(
                                        color: isSelected ? Colors.white : AppTheme.deepEmerald,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  if (hasExpense)
                                    Container(
                                      width: 4, height: 4,
                                      decoration: BoxDecoration(
                                        color: isSelected ? Colors.white70 : Colors.redAccent,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Activity for selected day
          if (_selected != null) ...[
            Row(
              children: [
                Text(
                  'Activity · ${_monthNames[_selected!.month - 1]} ${_selected!.day}',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                ),
                const Spacer(),
                Text('${selectedTxs.length} transaction${selectedTxs.length == 1 ? '' : 's'}',
                    style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
            const SizedBox(height: 6),
            if (selectedTxs.isEmpty)
              ProCard(
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 14),
                child: Center(
                  child: Text('No transactions on this day',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey)),
                ),
              )
            else
              ...selectedTxs.map((tx) {
                final isTransfer = tx.category.toLowerCase() == 'transfer';
                final bookName = store.bookById(tx.bookId)?.name ?? '';
                final titleText = isTransfer
                    ? (tx.title.isNotEmpty ? tx.title : 'Transfer')
                    : (tx.category.isNotEmpty ? tx.category : tx.title.isNotEmpty ? tx.title : 'Transaction');
                final descText = tx.notes.isNotEmpty ? tx.notes : null;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: ProCard(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SoftIcon(
                          icon: tx.type == TransactionType.cashIn
                              ? Icons.arrow_downward_rounded
                              : Icons.arrow_upward_rounded,
                          color: tx.type == TransactionType.cashIn
                              ? AppTheme.deepEmerald
                              : Colors.redAccent,
                          size: 34,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      titleText,
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  if (bookName.isNotEmpty) ...[
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: AppTheme.mist,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        bookName,
                                        style: const TextStyle(
                                          inherit: false,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700,
                                          color: AppTheme.navy,
                                          letterSpacing: .2,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              if (descText != null)
                                Text(
                                  descText,
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${tx.type == TransactionType.cashIn ? '+' : '-'}${money(tx.amount)}',
                          style: TextStyle(
                            inherit: false,
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: tx.type == TransactionType.cashIn ? AppTheme.deepEmerald : Colors.redAccent,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
          ],
        ],
      ),
    );
  }
}

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  bool _showSurplus = true;
  bool _showGenerating = true;

  @override
  Widget build(BuildContext context) {
    final store = AppScope.watch(context);
    final income = store.transactions
        .where((item) => item.type == TransactionType.cashIn)
        .fold<double>(0, (total, item) => total + item.amount);
    final expense = store.transactions
        .where((item) => item.type == TransactionType.cashOut)
        .fold<double>(0, (total, item) => total + item.amount);
    final byCategory = _breakdown(
      store.transactions.where((item) => item.type == TransactionType.cashOut),
      (item) => item.category.ifBlank('Uncategorized'),
    );
    final firstBook = store.books.firstOrNull;
    final topCategoryEntries = byCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topCategory = topCategoryEntries.firstOrNull;
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 16),
          children: [
            const ProHeader(showBell: true),
            const SizedBox(height: 8),
            const SectionLabel('Monthly Report'),
            const SizedBox(height: 4),
            Text(
              'Financial Insights',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          Text(
            'Analyze your spending patterns and export professional records.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const StatusPill(
                label: 'DAY',
                background: AppTheme.deepEmerald,
                color: Colors.white,
              ),
              const SizedBox(width: 10),
              StatusPill(
                label: 'CATEGORY',
                color: AppTheme.navy,
                background: AppTheme.cloud,
              ),
              const SizedBox(width: 10),
              StatusPill(
                label: 'MODE',
                color: AppTheme.navy,
                background: AppTheme.cloud,
              ),
            ],
          ),
          const SizedBox(height: 22),
          InsightMetricCard(
            title: 'Total Income',
            value: money(income),
            caption: '+12% from last month',
            color: AppTheme.deepEmerald,
            icon: Icons.trending_up,
          ),
          const SizedBox(height: 18),
          InsightMetricCard(
            title: 'Total Expenses',
            value: money(expense),
            caption: '-5% less than average',
            color: AppTheme.danger,
            icon: Icons.trending_down,
          ),
          const SizedBox(height: 18),
          ProCard(
            color: const Color(0xFF4B6176),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Net Savings',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Colors.white.withValues(alpha: .85),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  money(income - expense),
                  style: Theme.of(
                    context,
                  ).textTheme.headlineMedium?.copyWith(color: Colors.white),
                ),
                const SizedBox(height: 8),
                const ProProgress(
                  value: .82,
                  color: AppTheme.emerald,
                  height: 8,
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          if (store.goals.isNotEmpty) ...[
            Text(
              'Active Goals Progress',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            for (final goal in store.goals.take(2)) ...[
              GoalMiniCard(goal: goal),
              const SizedBox(height: 8),
            ],
          ],
          const SizedBox(height: 18),
          ProCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Spending by Category',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    TextButton(onPressed: () {}, child: const Text('Details')),
                  ],
                ),
                Text(
                  topCategory == null
                      ? 'Top 5 expense areas this month'
                      : 'Top: ${topCategory.key}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 6),
                BurnRateDonut(income: income, expense: expense),
                const SizedBox(height: 6),
                BreakdownList(values: byCategory),
              ],
            ),
          ),
          const SizedBox(height: 6),
          LineChartCard(
            title: 'Comparative Flow',
            subtitle: 'Last 6 months: Income vs Expenses trend',
            secondary: true,
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeInOut,
            child: _showSurplus
                ? Dismissible(
                    key: const ValueKey('surplus'),
                    direction: DismissDirection.endToStart,
                    onDismissed: (_) => setState(() => _showSurplus = false),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 24),
                      child: ProCard(
                        color: const Color(0xFF35D07C),
                        radius: 30,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.lightbulb, color: Colors.white),
                                const Spacer(),
                                GestureDetector(
                                  onTap: () => setState(() => _showSurplus = false),
                                  child: Icon(Icons.close, size: 18, color: Colors.white.withValues(alpha: .7)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Surplus Alert',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'You have extra cash reserves this month. Consider allocating some to your Goal Fund.',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white),
                            ),
                            const SizedBox(height: 18),
                            FilledButton(
                              onPressed: firstBook == null
                                  ? null
                                  : () => openTransactionForm(context, firstBook),
                              style: FilledButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: AppTheme.deepEmerald,
                              ),
                              child: const Text('Transfer Now'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
          const SizedBox(height: 6),
          ProCard(
            color: AppTheme.cloud,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Export Data',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'Download high-quality financial statements for your records or tax filing.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 18),
                _ExportButton(
                  icon: Icons.picture_as_pdf,
                  title: 'Generate PDF',
                  subtitle: 'Professional formatted report',
                  onTap: firstBook == null
                      ? null
                      : () => ExportService.exportPdf(
                          book: firstBook,
                          transactions: store.transactionsForBook(firstBook.id),
                        ),
                ),
                const SizedBox(height: 8),
                _ExportButton(
                  icon: Icons.table_view,
                  title: 'Generate Excel',
                  subtitle: 'Raw data for deep analysis',
                  onTap: firstBook == null
                      ? null
                      : () => ExportService.exportExcelLike(
                          book: firstBook,
                          transactions: store.transactionsForBook(firstBook.id),
                        ),
                ),
              ],
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeInOut,
            child: _showGenerating
                ? Dismissible(
                    key: const ValueKey('generating'),
                    direction: DismissDirection.endToStart,
                    onDismissed: (_) => setState(() => _showGenerating = false),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 24),
                      child: ProCard(
                        borderColor: const Color(0xFFDDE3E4),
                        shadow: false,
                        child: Column(
                          children: [
                            Align(
                              alignment: Alignment.centerRight,
                              child: GestureDetector(
                                onTap: () => setState(() => _showGenerating = false),
                                child: Icon(Icons.close, size: 18, color: AppTheme.navy.withValues(alpha: .4)),
                              ),
                            ),
                            const SizedBox(
                              width: 54,
                              height: 54,
                              child: CircularProgressIndicator(value: .45, strokeWidth: 3),
                            ),
                            const SizedBox(height: 18),
                            Text(
                              'Generating Detailed Report',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "We're crunching the numbers for your quarterly audit.",
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
          const SizedBox(height: 6),
          Text(
            expense == 0
                ? 'CFO Insight: Your reports will become sharper once spending entries are categorized.'
                : 'CFO Insight: “${topCategory?.key ?? 'Uncategorized'} has changed your cash rhythm. Review it before funding the next goal.”',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.deepEmerald,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
        ),
      ),
    );
  }

  Map<String, double> _breakdown(
    Iterable<LedgerTransaction> transactions,
    String Function(LedgerTransaction transaction) key,
  ) {
    final values = <String, double>{};
    for (final transaction in transactions) {
      values.update(
        key(transaction),
        (value) => value + transaction.amount,
        ifAbsent: () => transaction.amount,
      );
    }
    return values;
  }
}

class InsightMetricCard extends StatelessWidget {
  const InsightMetricCard({
    super.key,
    required this.title,
    required this.value,
    required this.caption,
    required this.color,
    required this.icon,
  });

  final String title;
  final String value;
  final String caption;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return ProCard(
      radius: 22,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SoftIcon(icon: icon, color: color, size: 44),
          const SizedBox(height: 28),
          Text(
            title.toUpperCase(),
            style: Theme.of(context).textTheme.labelLarge,
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(color: color),
          ),
          const SizedBox(height: 6),
          Text(caption, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class GoalMiniCard extends StatelessWidget {
  const GoalMiniCard({super.key, required this.goal});

  final SavingsGoal goal;

  @override
  Widget build(BuildContext context) {
    final color = goalColor(goal);
    return ProCard(
      radius: 16,
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          SoftIcon(icon: categoryIcon(goal.name), color: color, size: 42),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(goal.name, style: Theme.of(context).textTheme.titleMedium),
                Text('Target: ${money(goal.targetAmount)}'),
                const SizedBox(height: 8),
                ProProgress(value: goal.progress, color: color, height: 6),
              ],
            ),
          ),
          Text(
            '${(goal.progress * 100).toStringAsFixed(0)}%',
            style: TextStyle(color: color, fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }
}

class _ExportButton extends StatelessWidget {
  const _ExportButton({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Future<void> Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: ProCard(
        radius: 18,
        padding: const EdgeInsets.all(11),
        shadow: false,
        child: Row(
          children: [
            SoftIcon(icon: icon, size: 42, color: AppTheme.deepEmerald),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleMedium),
                  Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            ),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = AppScope.watch(context);
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 16),
          children: [
            const ProHeader(showBell: false),
            const SizedBox(height: 8),
            Text('Settings', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 6),
          Text('Manage your app preferences', style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 32),
          const SectionLabel('Appearance'),
          const SizedBox(height: 8),
          ProCard(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    SoftIcon(icon: Icons.palette_rounded, color: AppTheme.deepEmerald, size: 40),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Theme', style: Theme.of(context).textTheme.titleMedium),
                          Text(
                            store.themeMode == ThemeMode.system
                                ? 'Following system'
                                : store.themeMode == ThemeMode.light
                                ? 'Light mode'
                                : 'Dark mode',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: SegmentedButton<ThemeMode>(
                        selected: {store.themeMode},
                        showSelectedIcon: false,
                        onSelectionChanged: (s) => store.setThemeMode(s.first),
                        style: SegmentedButton.styleFrom(
                          minimumSize: const Size(0, 44),
                        ),
                        segments: const [
                          ButtonSegment(
                            value: ThemeMode.light,
                            icon: Icon(Icons.light_mode_rounded, size: 18),
                            label: Text('Light'),
                          ),
                          ButtonSegment(
                            value: ThemeMode.dark,
                            icon: Icon(Icons.dark_mode_rounded, size: 18),
                            label: Text('Dark'),
                          ),
                          ButtonSegment(
                            value: ThemeMode.system,
                            icon: Icon(Icons.auto_mode_rounded, size: 18),
                            label: Text('Auto'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
          Center(
            child: Text(
              'Mero Khata v1.0.0',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: const Color(0xFFB6CDBF)),
            ),
          ),
        ],
        ),
      ),
    );
  }
}

class SettingsRow extends StatelessWidget {
  const SettingsRow({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.iconColor = AppTheme.deepEmerald,
    this.titleColor = AppTheme.ink,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final Color iconColor;
  final Color titleColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SoftIcon(icon: icon, color: iconColor, size: 58),
        const SizedBox(width: 18),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: titleColor,
                  fontSize: 20,
                ),
              ),
              Text(subtitle, style: Theme.of(context).textTheme.bodyLarge),
            ],
          ),
        ),
        ?trailing,
      ],
    );
  }
}

class ResponsiveMetrics extends StatelessWidget {
  const ResponsiveMetrics({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 760 ? children.length : 1;
        return GridView.count(
          crossAxisCount: columns,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: columns == 1 ? 2.65 : 2.35,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          children: children,
        );
      },
    );
  }
}

class MetricCard extends StatelessWidget {
  const MetricCard(this.title, this.value, this.icon, {super.key, this.color});

  final String title;
  final String value;
  final IconData icon;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final accent = color ?? scheme.primary;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(11),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: accent.withValues(alpha: .12),
              foregroundColor: accent,
              child: Icon(icon),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(title, style: Theme.of(context).textTheme.labelLarge),
                  const SizedBox(height: 4),
                  Text(value, style: Theme.of(context).textTheme.titleLarge),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SmartInsightCard extends StatelessWidget {
  const SmartInsightCard({
    super.key,
    required this.title,
    required this.message,
  });

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: LinearGradient(
            colors: [
              AppTheme.emerald.withValues(alpha: .16),
              scheme.surface.withValues(alpha: .72),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(18),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: AppTheme.emerald.withValues(alpha: .16),
              foregroundColor: AppTheme.deepEmerald,
              child: const Icon(Icons.auto_awesome),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 6),
                  Text(message),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FlowBars extends StatelessWidget {
  const FlowBars({super.key, required this.income, required this.expense});

  final double income;
  final double expense;

  @override
  Widget build(BuildContext context) {
    final maxValue = max(max(income, expense), 1).toDouble();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _FlowRow(
              label: 'Cash In',
              value: income,
              maxValue: maxValue,
              color: Colors.green,
            ),
            const SizedBox(height: 14),
            _FlowRow(
              label: 'Cash Out',
              value: expense,
              maxValue: maxValue,
              color: Colors.red,
            ),
          ],
        ),
      ),
    );
  }
}

class _FlowRow extends StatelessWidget {
  const _FlowRow({
    required this.label,
    required this.value,
    required this.maxValue,
    required this.color,
  });

  final String label;
  final double value;
  final double maxValue;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Text(label)),
            Text(money(value)),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(99),
          child: LinearProgressIndicator(
            minHeight: 12,
            value: (value / maxValue).clamp(0, 1),
            color: color,
            backgroundColor: color.withValues(alpha: .12),
          ),
        ),
      ],
    );
  }
}

class BurnRateDonut extends StatelessWidget {
  const BurnRateDonut({super.key, required this.income, required this.expense});

  final double income;
  final double expense;

  @override
  Widget build(BuildContext context) {
    final rate = (expense / max(income, 1)).clamp(0, 1).toDouble();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            SizedBox(
              width: 104,
              height: 104,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CircularProgressIndicator(
                    value: rate,
                    strokeWidth: 14,
                    strokeCap: StrokeCap.round,
                    color: AppTheme.emerald,
                    backgroundColor: Colors.orange.withValues(alpha: .16),
                  ),
                  Center(
                    child: Text(
                      '${(rate * 100).toStringAsFixed(0)}%',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Text(
                rate < .65
                    ? 'Healthy operating room. Your cash flow has space for goal allocation.'
                    : 'Spending is consuming most inflow. Review top categories before adding new goals.',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.action,
  });

  final IconData icon;
  final String title;
  final String message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 48,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 6),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center),
            if (action != null) ...[const SizedBox(height: 6), action!],
          ],
        ),
      ),
    );
  }
}

class FilterChipMenu extends StatelessWidget {
  const FilterChipMenu({
    super.key,
    required this.label,
    required this.value,
    required this.values,
    required this.onChanged,
  });

  final String label;
  final String value;
  final Map<String, String> values;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownMenu<String>(
      label: Text(label),
      initialSelection: value,
      dropdownMenuEntries: [
        for (final entry in values.entries)
          DropdownMenuEntry(value: entry.key, label: entry.value),
      ],
      onSelected: (value) {
        if (value != null) onChanged(value);
      },
    );
  }
}

class BreakdownList extends StatelessWidget {
  const BreakdownList({super.key, required this.values});

  final Map<String, double> values;

  @override
  Widget build(BuildContext context) {
    if (values.isEmpty) {
      return const Text('No spending data yet.');
    }
    final maxValue = values.values.fold<double>(0, max);
    final entries = values.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return Column(
      children: [
        for (final entry in entries)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(child: Text(entry.key)),
                    Text(money(entry.value)),
                  ],
                ),
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  value: maxValue == 0 ? 0 : entry.value / maxValue,
                ),
              ],
            ),
          ),
      ],
    );
  }
}

Future<void> showBookDialog(BuildContext context, {LedgerBook? book}) async {
  final store = AppScope.read(context);
  final name = TextEditingController(text: book?.name ?? '');
  final description = TextEditingController(text: book?.description ?? '');
  final formKey = GlobalKey<FormState>();
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (context) => Padding(
      padding: EdgeInsets.fromLTRB(
        16,
        16,
        16,
        MediaQuery.viewInsetsOf(context).bottom + 16,
      ),
      child: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              book == null ? 'New book' : 'Edit book',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 6),
            TextFormField(
              controller: name,
              decoration: const InputDecoration(labelText: 'Name'),
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'Enter a book name'
                  : null,
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: description,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            const SizedBox(height: 6),
            FilledButton.icon(
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;
                await store.saveBook(
                  id: book?.id,
                  name: name.text,
                  description: description.text,
                );
                if (context.mounted) Navigator.pop(context);
              },
              icon: const Icon(Icons.check),
              label: const Text('Save'),
            ),
          ],
        ),
      ),
    ),
  );
}

class GoalFormScreen extends StatefulWidget {
  const GoalFormScreen({super.key, this.goal});

  final SavingsGoal? goal;

  @override
  State<GoalFormScreen> createState() => _GoalFormScreenState();
}

class _GoalFormScreenState extends State<GoalFormScreen> {
  final formKey = GlobalKey<FormState>();
  late final name = TextEditingController(text: widget.goal?.name ?? '');
  late final target = TextEditingController(
    text: widget.goal == null
        ? ''
        : widget.goal!.targetAmount.toStringAsFixed(2),
  );
  late final saved = TextEditingController(
    text: widget.goal?.manualSaved.toStringAsFixed(2) ?? '0',
  );
  late DateTime? deadline = widget.goal?.deadline;
  var selectedCategory = 'Travel';

  @override
  Widget build(BuildContext context) {
    final goal = widget.goal;
    final progress = goal?.progress ?? 0;
    return Scaffold(
      appBar: AppBar(
        title: Text(goal == null ? 'New Financial Goal' : 'Edit Goal'),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(goal == null ? Icons.close : Icons.arrow_back),
        ),
        actions: goal == null
            ? null
            : const [
                Padding(
                  padding: EdgeInsets.only(right: 18),
                  child: ProAvatar(size: 44),
                ),
              ],
      ),
      body: Form(
        key: formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 26, 24, 42),
          children: [
            if (goal != null) ...[
              ProCard(
                radius: 34,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const SectionLabel('Current Progress'),
                        const Spacer(),
                        StatusPill(
                          label: '${(progress * 100).toStringAsFixed(1)}%',
                          color: AppTheme.deepEmerald,
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      goal.name,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text(
                          money(goal.savedAmount),
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(color: AppTheme.deepEmerald),
                        ),
                        Text(
                          ' saved',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        const Spacer(),
                        Text('Target: ${money(goal.targetAmount)}'),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ProProgress(value: progress),
                    const SizedBox(height: 26),
                    Row(
                      children: [
                        const Icon(
                          Icons.access_time_filled,
                          color: AppTheme.navy,
                        ),
                        const SizedBox(width: 10),
                        Text(daysLeftLabel(goal).toLowerCase()),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 36),
              Text(
                'Goal Details',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 22),
            ] else ...[
              const SectionLabel('How much do you need?'),
              const SizedBox(height: 8),
            ],
            TextFormField(
              controller: target,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              style: goal == null
                  ? Theme.of(context).textTheme.displaySmall?.copyWith(
                      color: Colors.black.withValues(alpha: .14),
                    )
                  : null,
              decoration: InputDecoration(
                labelText: goal == null ? null : 'TARGET AMOUNT',
                hintText: '0.00',
                prefixText: '\$ ',
                prefixStyle: TextStyle(
                  color: goal == null ? AppTheme.deepEmerald : Colors.black54,
                  fontSize: goal == null ? 42 : 18,
                  fontWeight: FontWeight.w900,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(goal == null ? 70 : 26),
                  borderSide: BorderSide.none,
                ),
              ),
              validator: (value) => (double.tryParse(value ?? '') ?? 0) <= 0
                  ? 'Enter a target amount'
                  : null,
            ),
            const SizedBox(height: 36),
            const SectionLabel('Goal Name'),
            const SizedBox(height: 14),
            TextFormField(
              controller: name,
              decoration: const InputDecoration(hintText: 'e.g., Holiday Fund'),
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'Enter a goal name'
                  : null,
            ),
            const SizedBox(height: 34),
            const SectionLabel('Choose a Category'),
            const SizedBox(height: 6),
            Row(
              children: [
                for (final item in const [
                  'Travel',
                  'Savings',
                  'Home',
                  'Car',
                ]) ...[
                  Expanded(
                    child: GoalCategoryChip(
                      label: item,
                      selected: selectedCategory == item,
                      onTap: () => setState(() => selectedCategory = item),
                    ),
                  ),
                  if (item != 'Car') const SizedBox(width: 12),
                ],
              ],
            ),
            const SizedBox(height: 34),
            Row(
              children: const [
                SectionLabel('Target Date'),
                Spacer(),
                StatusPill(label: 'Optional'),
              ],
            ),
            const SizedBox(height: 14),
            InkWell(
              borderRadius: BorderRadius.circular(28),
              onTap: _pickDeadline,
              child: InputDecorator(
                decoration: const InputDecoration(),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today, color: AppTheme.navy),
                    const SizedBox(width: 18),
                    Text(
                      deadline == null
                          ? 'Set a deadline'
                          : DateFormat.yMMMd().format(deadline!),
                      style: Theme.of(
                        context,
                      ).textTheme.bodyLarge?.copyWith(fontSize: 15),
                    ),
                  ],
                ),
              ),
            ),
            if (goal == null) ...[
              const SizedBox(height: 34),
              ProCard(
                child: Row(
                  children: [
                    const SoftIcon(icon: Icons.auto_awesome, size: 70),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Auto-Sync Enabled',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Simply tag transactions with this goal name and progress updates in real-time.',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              const SizedBox(height: 34),
              ProCard(
                color: AppTheme.cloud,
                borderColor: AppTheme.emerald.withValues(alpha: .5),
                child: Row(
                  children: [
                    SoftIcon(icon: categoryIcon(selectedCategory), size: 70),
                    const SizedBox(width: 18),
                    Expanded(
                      child: Text(
                        'Keep going, Ray! Saving consistently will help you reach this goal ahead of schedule.',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 36),
            FilledButton(
              onPressed: _save,
              style: FilledButton.styleFrom(
                minimumSize: const Size(double.infinity, 64),
                backgroundColor: const Color(0xFF19B464),
                elevation: 12,
              ),
              child: Text(goal == null ? 'Create Goal  ✓' : 'Save Changes'),
            ),
            if (goal != null) ...[
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: () async {
                  await AppScope.read(context).deleteGoal(goal.id);
                  if (context.mounted) Navigator.pop(context);
                },
                icon: const Icon(Icons.delete, color: AppTheme.danger),
                label: const Text(
                  'Delete Goal',
                  style: TextStyle(color: AppTheme.danger),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _pickDeadline() async {
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime(2100),
      initialDate: deadline ?? DateTime.now(),
    );
    if (picked != null) setState(() => deadline = picked);
  }

  Future<void> _save() async {
    if (!formKey.currentState!.validate()) return;
    await AppScope.read(context).saveGoal(
      id: widget.goal?.id,
      name: name.text,
      targetAmount: double.parse(target.text),
      manualSaved: double.tryParse(saved.text) ?? widget.goal?.manualSaved ?? 0,
      deadline: deadline,
    );
    if (mounted) Navigator.pop(context);
  }
}

class GoalCategoryChip extends StatelessWidget {
  const GoalCategoryChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });
  
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(28),
      onTap: onTap,
      child: Container(
        height: 94,
        decoration: BoxDecoration(
          color: selected ? AppTheme.deepEmerald : Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: AppTheme.deepEmerald.withValues(alpha: .25),
                    blurRadius: 22,
                    offset: const Offset(0, 12),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              categoryIcon(label),
              color: selected ? Colors.white : AppTheme.slate,
              size: 28,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : AppTheme.ink,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> showGoalDialog(BuildContext context, {SavingsGoal? goal}) async {
  await Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => GoalFormScreen(goal: goal)),
  );
}

Future<void> showNamePrompt(
  BuildContext context,
  String title,
  Future<void> Function(String value) onSave,
) async {
  final controller = TextEditingController();
  await showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: TextField(controller: controller, autofocus: true),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () async {
            await onSave(controller.text);
            if (context.mounted) Navigator.pop(context);
          },
          child: const Text('Save'),
        ),
      ],
    ),
  );
}

void openBook(BuildContext context, LedgerBook book) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => BookDetailScreen(bookId: book.id)),
  );
}

void openTransactionForm(
  BuildContext context,
  LedgerBook book, {
  LedgerTransaction? transaction,
  TransactionType? initialType,
}) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => TransactionFormScreen(
        book: book,
        transaction: transaction,
        initialType: initialType,
      ),
    ),
  );
}

class EntryDetailScreen extends StatelessWidget {
  const EntryDetailScreen({super.key, required this.transactionId});

  final String transactionId;

  @override
  Widget build(BuildContext context) {
    final store = AppScope.watch(context);
    final transaction = store.transactions
        .where((item) => item.id == transactionId)
        .firstOrNull;
    if (transaction == null) {
      return const Scaffold(
        body: EmptyState(
          icon: Icons.receipt_long_outlined,
          title: 'Entry missing',
          message: 'This transaction no longer exists.',
        ),
      );
    }
    final book = store.bookById(transaction.bookId);
    final color = transactionColor(transaction.type);
    final sign = transaction.type == TransactionType.cashIn ? '+' : '−';
    final logs = store.logsFor(transaction.id);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Entry Details'),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.close),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: FilledButton(
              onPressed: book == null
                  ? null
                  : () => openTransactionForm(
                      context,
                      book,
                      transaction: transaction,
                    ),
              style: FilledButton.styleFrom(minimumSize: const Size(76, 38)),
              child: const Text('Edit'),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 48),
        children: [
          Center(
            child: SoftIcon(
              icon: transactionIcon(transaction.type),
              color: color,
              size: 76,
            ),
          ),
          const SizedBox(height: 22),
          Text(
            transaction.title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            DateFormat.yMMMMd().add_jm().format(transaction.occurredAt),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 22),
          Text(
            '$sign${money(transaction.amount)}',
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.displaySmall?.copyWith(color: color, fontSize: 42),
          ),
          const SizedBox(height: 8),
          ProProgress(value: 1, color: color, height: 18),
          const SizedBox(height: 5),
          Text(
            transaction.category.ifBlank('Uncategorized').toUpperCase(),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              fontSize: 10,
              color: AppTheme.ink,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 40),
          const SectionLabel('Personal Notes'),
          const SizedBox(height: 14),
          ProCard(
            color: AppTheme.cloud,
            shadow: false,
            child: Text(
              transaction.notes.ifBlank(
                'No extra notes were attached to this transaction.',
              ),
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: AppTheme.ink),
            ),
          ),
          const SizedBox(height: 44),
          Row(
            children: const [
              SectionLabel('History Logs'),
              Spacer(),
              Icon(Icons.history, size: 18, color: AppTheme.navy),
            ],
          ),
          const SizedBox(height: 18),
          if (logs.isEmpty)
            const ProCard(child: Text('No history logs yet.'))
          else
            for (final entry in logs.indexed)
              HistoryLogTile(log: entry.$2, active: entry.$1 == 0),
          const SizedBox(height: 42),
          const SectionLabel('Attached Receipt'),
          const SizedBox(height: 18),
          ReceiptPlaceholder(),
          const SizedBox(height: 34),
          FilledButton(
            onPressed: () {},
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFE7E8EA),
              foregroundColor: AppTheme.ink,
              minimumSize: const Size(double.infinity, 58),
              elevation: 0,
            ),
            child: const Text('Split Transaction'),
          ),
          const SizedBox(height: 18),
          TextButton(
            onPressed: () async {
              await store.deleteTransaction(transaction.id);
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text(
              'Delete Record',
              style: TextStyle(color: AppTheme.danger),
            ),
          ),
        ],
      ),
    );
  }
}

class HistoryLogTile extends StatelessWidget {
  const HistoryLogTile({super.key, required this.log, required this.active});

  final TransactionLog log;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            CircleAvatar(
              radius: 6,
              backgroundColor: active
                  ? AppTheme.deepEmerald
                  : const Color(0xFFE0E4E6),
            ),
            Container(width: 1, height: 88, color: const Color(0xFFE0E4E6)),
          ],
        ),
        const SizedBox(width: 22),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: ProCard(
              radius: 22,
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    log.action
                        .split('_')
                        .map((part) => part.capitalize())
                        .join(' '),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    log.details,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 14),
                  Text(
                    DateFormat.yMMMd()
                        .add_jm()
                        .format(log.timestamp)
                        .toUpperCase(),
                    style: Theme.of(
                      context,
                    ).textTheme.labelLarge?.copyWith(fontSize: 9),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class ReceiptPlaceholder extends StatelessWidget {
  const ReceiptPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 360,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: const LinearGradient(
          colors: [Color(0xFF7A4E25), Color(0xFFD39A4C), Color(0xFF2A1B10)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .18),
            blurRadius: 28,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Center(
        child: Transform.rotate(
          angle: -.2,
          child: Container(
            width: 132,
            height: 190,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(height: 8, width: 84, color: Colors.black12),
                const SizedBox(height: 6),
                for (var i = 0; i < 8; i++) ...[
                  Container(
                    height: 5,
                    width: i.isEven ? 92 : 68,
                    color: Colors.black.withValues(alpha: .12),
                  ),
                  const SizedBox(height: 8),
                ],
                const Spacer(),
                Container(
                  height: 8,
                  width: 98,
                  color: AppTheme.danger.withValues(alpha: .25),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

void showTransactionDetail(
  BuildContext context,
  LedgerTransaction transaction,
) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => EntryDetailScreen(transactionId: transaction.id),
    ),
  );
}

void showDaySheet(
  BuildContext context,
  DateTime day,
  List<LedgerTransaction> transactions,
) {
  final store = AppScope.read(context);
  showModalBottomSheet<void>(
    context: context,
    builder: (context) => ListView(
      padding: const EdgeInsets.all(11),
      children: [
        Text(
          DateFormat.yMMMMd().format(day),
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        for (final transaction in transactions)
          ListTile(
            title: Text(transaction.title),
            subtitle: Text(store.bookById(transaction.bookId)?.name ?? ''),
            trailing: Text(money(transaction.amount)),
          ),
      ],
    ),
  );
}

String money(num value) {
  return NumberFormat.currency(symbol: 'Rs ', decimalDigits: 2).format(value);
}

String compactMoney(num value) {
  return NumberFormat.compactCurrency(
    symbol: 'Rs ',
    decimalDigits: 0,
  ).format(value);
}

extension FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}

extension BlankString on String {
  String ifBlank(String fallback) => trim().isEmpty ? fallback : this;
  String capitalize() =>
      isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';
}
