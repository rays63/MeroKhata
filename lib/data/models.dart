import 'dart:math';

enum TransactionType {
  cashIn('Cash In'),
  cashOut('Cash Out');

  const TransactionType(this.label);
  final String label;
}

/// Palette used for book avatars and goal bars, in the order new items
/// receive them.
const itemColors = [
  0xFF10A65A,
  0xFF3B7DD8,
  0xFF8B5CF6,
  0xFFE39A2E,
  0xFF0E9AA7,
  0xFFE5484D,
];

class LedgerBook {
  const LedgerBook({
    required this.id,
    required this.name,
    required this.description,
    required this.createdAt,
    required this.updatedAt,
    this.currency = 'NPR',
    this.colorValue = 0xFF10A65A,
  });

  final String id;
  final String name;
  final String description;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// ISO code; fixed once the book has entries.
  final String currency;
  final int colorValue;

  LedgerBook copyWith({
    String? name,
    String? description,
    DateTime? updatedAt,
    String? currency,
  }) {
    return LedgerBook(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      currency: currency ?? this.currency,
      colorValue: colorValue,
    );
  }

  Map<String, Object?> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'currency': currency,
    'color': colorValue,
  };

  factory LedgerBook.fromJson(Map<String, Object?> json, {int index = 0}) =>
      LedgerBook(
        id: json['id'] as String,
        name: json['name'] as String,
        description: json['description'] as String? ?? '',
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
        currency: json['currency'] as String? ?? 'NPR',
        colorValue:
            json['color'] as int? ?? itemColors[index % itemColors.length],
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
    this.colorValue = 0xFF10A65A,
  });

  final String id;
  final String name;
  final double targetAmount;
  final double manualSaved;
  final double savedAmount;
  final DateTime? deadline;
  final int colorValue;

  double get remaining => max(0, targetAmount - savedAmount).toDouble();
  double get progress =>
      targetAmount <= 0 ? 0 : (savedAmount / targetAmount).clamp(0, 1);
  bool get reached => targetAmount > 0 && savedAmount >= targetAmount;

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
      colorValue: colorValue,
    );
  }

  Map<String, Object?> toJson() => {
    'id': id,
    'name': name,
    'targetAmount': targetAmount,
    'manualSaved': manualSaved,
    'savedAmount': savedAmount,
    'deadline': deadline?.toIso8601String(),
    'color': colorValue,
  };

  factory SavingsGoal.fromJson(Map<String, Object?> json, {int index = 0}) =>
      SavingsGoal(
        id: json['id'] as String,
        name: json['name'] as String,
        targetAmount: (json['targetAmount'] as num).toDouble(),
        manualSaved: (json['manualSaved'] as num? ?? 0).toDouble(),
        savedAmount: (json['savedAmount'] as num? ?? 0).toDouble(),
        deadline: json['deadline'] == null
            ? null
            : DateTime.parse(json['deadline'] as String),
        colorValue:
            json['color'] as int? ?? itemColors[index % itemColors.length],
      );
}

/// The person using the app, captured during onboarding.
class UserProfile {
  const UserProfile({this.name = '', this.phone = '', this.email = ''});

  final String name;
  final String phone;
  final String email;

  Map<String, Object?> toJson() => {
    'name': name,
    'phone': phone,
    'email': email,
  };

  factory UserProfile.fromJson(Map<String, Object?> json) => UserProfile(
    name: json['name'] as String? ?? '',
    phone: json['phone'] as String? ?? '',
    email: json['email'] as String? ?? '',
  );
}

/// One line of an entry's edit history.
///
/// [details] is an English sentence kept for older data and exports; [code]
/// and [args] let the UI word it in the current language (e.g. code
/// `amount`, args `[Rs 3,200, Rs 3,460]`). Logs saved before codes existed
/// have a null [code] and are shown as recorded.
class TransactionLog {
  const TransactionLog({
    required this.id,
    required this.transactionId,
    required this.action,
    required this.details,
    required this.timestamp,
    this.code,
    this.args = const [],
  });

  final String id;
  final String transactionId;
  final String action;
  final String details;
  final DateTime timestamp;
  final String? code;
  final List<String> args;

  Map<String, Object?> toJson() => {
    'id': id,
    'transactionId': transactionId,
    'action': action,
    'details': details,
    'timestamp': timestamp.toIso8601String(),
    'code': code,
    'args': args,
  };

  factory TransactionLog.fromJson(Map<String, Object?> json) => TransactionLog(
    id: json['id'] as String,
    transactionId: json['transactionId'] as String,
    action: json['action'] as String,
    details: json['details'] as String,
    timestamp: DateTime.parse(json['timestamp'] as String),
    code: json['code'] as String?,
    args: (json['args'] as List? ?? const []).map((e) => e.toString()).toList(),
  );
}

class ImportPreview {
  const ImportPreview({
    required this.source,
    required this.importable,
    required this.duplicates,
    required this.ignored,
    this.openingBalance,
    this.closingBalance,
  });

  final String source;
  final List<LedgerTransaction> importable;
  final List<LedgerTransaction> duplicates;
  final List<String> ignored;

  /// The account balance before the statement's first transaction and after
  /// its last one. Null when the format has no balance column.
  final double? openingBalance;
  final double? closingBalance;
}

/// One statement file read by the parser, not yet compared with a book.
class ParsedStatement {
  const ParsedStatement({
    required this.fileName,
    required this.format,
    required this.rows,
    required this.ignored,
    this.source,
    this.account,
    this.openingBalance,
    this.closingBalance,
  });

  final String fileName;

  /// 'PDF' or 'XLS'.
  final String format;
  final List<LedgerTransaction> rows;
  final List<String> ignored;

  /// The bank or wallet ("NIC Asia", "eSewa", …); null for unknown formats.
  final String? source;

  /// Digits of the account number, when the statement shows it readably.
  final String? account;
  final double? openingBalance;
  final double? closingBalance;

  /// The statement's first transaction date, used to order a batch.
  DateTime? get periodStart => rows.isEmpty
      ? null
      : rows
            .map((row) => row.occurredAt)
            .reduce((a, b) => a.isBefore(b) ? a : b);

  /// Every balance the statement passes through, opening included.
  Set<String> get balanceKeys => {
    if (openingBalance != null) openingBalance!.toStringAsFixed(2),
    for (final row in rows)
      if (row.statementBalance != null)
        row.statementBalance!.toStringAsFixed(2),
  };
}

/// [from] ends at [closing] but the next statement, [to], doesn't continue
/// from there: a statement in between may be missing.
class ChainGap {
  const ChainGap({
    required this.from,
    required this.to,
    required this.closing,
    required this.opening,
  });

  final String from;
  final String to;
  final double closing;
  final double opening;
}

/// Several statements checked against one book, in statement-period order.
class ImportBatch {
  const ImportBatch({
    required this.files,
    required this.combined,
    required this.sources,
    required this.chainGaps,
    this.openingFrom,
  });

  /// The file the opening balance comes from: the earliest statement.
  final String? openingFrom;

  /// Each file with its own importable / duplicate / ignored rows.
  final List<(ParsedStatement, ImportPreview)> files;

  /// Everything together. Its opening balance is the earliest statement's;
  /// for several files its closing balance is what the book will hold after
  /// import (the opening balance plus every imported row).
  final ImportPreview combined;

  /// Distinct sources in the batch ('PDF'/'XLS' for unknown formats). More
  /// than one means files from different banks or wallets.
  final List<String> sources;
  final List<ChainGap> chainGaps;
}
