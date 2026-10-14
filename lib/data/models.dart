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

