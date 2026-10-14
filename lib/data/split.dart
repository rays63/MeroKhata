/// Split bills: friends, groups with shared expenses, and one-off bills.
///
/// Balances only track what is between *you* and each friend — "Sita owes
/// you Rs 2,100" — as the design shows. If Sita paid and Bikash shared the
/// cost, that is between them and doesn't move your balances.
library;

/// Id used for the app's user in member lists and `paidBy`.
const me = 'me';

/// Avatar colours for friends, in the order they're assigned.
const friendColors = [
  0xFFE39A2E,
  0xFF8B5CF6,
  0xFFE5484D,
  0xFF3B7DD8,
  0xFF0E9AA7,
  0xFFD9467A,
];

const meColor = 0xFF0F7A4A;

class Friend {
  const Friend({
    required this.id,
    required this.name,
    required this.colorValue,
  });

  final String id;
  final String name;
  final int colorValue;

  String get initial =>
      name.trim().isEmpty ? '?' : name.trim()[0].toUpperCase();

  Map<String, Object?> toJson() => {
    'id': id,
    'name': name,
    'color': colorValue,
  };

  factory Friend.fromJson(Map<String, Object?> json) => Friend(
    id: json['id'] as String,
    name: json['name'] as String,
    colorValue: json['color'] as int? ?? friendColors.first,
  );
}

/// How a cost is divided: participant id → weight (1 each for an equal
/// split). Includes [me] when you take part.
typedef Shares = Map<String, int>;

/// Each participant's part of [amount], rounded to the paisa, with any
/// rounding remainder given to the first participant so parts add up exactly.
Map<String, double> splitAmount(double amount, Shares shares) {
  final active = {
    for (final e in shares.entries)
      if (e.value > 0) e.key: e.value,
  };
  final total = active.values.fold<int>(0, (a, b) => a + b);
  if (total == 0) return const {};
  final cents = (amount * 100).round();
  final parts = <String, int>{
    for (final e in active.entries) e.key: cents * e.value ~/ total,
  };
  final remainder = cents - parts.values.fold<int>(0, (a, b) => a + b);
  if (remainder != 0) {
    parts[parts.keys.first] = parts[parts.keys.first]! + remainder;
  }
  return {for (final e in parts.entries) e.key: e.value / 100};
}

/// What each friend owes you (positive) or you owe them (negative) for one
/// cost paid by [paidBy].
Map<String, double> balancesFor(double amount, String paidBy, Shares shares) {
  final parts = splitAmount(amount, shares);
  if (paidBy == me) {
    return {
      for (final e in parts.entries)
        if (e.key != me) e.key: e.value,
    };
  }
  final mine = parts[me];
  return mine == null ? const {} : {paidBy: -mine};
}

class GroupExpense {
  const GroupExpense({
    required this.id,
    required this.title,
    required this.amount,
    required this.paidBy,
    required this.shares,
    required this.createdAt,
    this.transactionId,
  });

  final String id;
  final String title;
  final double amount;

  /// [me] or a friend id.
  final String paidBy;
  final Shares shares;
  final DateTime createdAt;

  /// Ledger entry recorded for this expense, if any.
  final String? transactionId;

  Map<String, Object?> toJson() => {
    'id': id,
    'title': title,
    'amount': amount,
    'paidBy': paidBy,
    'shares': shares,
    'createdAt': createdAt.toIso8601String(),
    'transactionId': transactionId,
  };

  factory GroupExpense.fromJson(Map<String, Object?> json) => GroupExpense(
    id: json['id'] as String,
    title: json['title'] as String,
    amount: (json['amount'] as num).toDouble(),
    paidBy: json['paidBy'] as String,
    shares: (json['shares'] as Map).map(
      (key, value) => MapEntry(key as String, (value as num).toInt()),
    ),
    createdAt: DateTime.parse(json['createdAt'] as String),
    transactionId: json['transactionId'] as String?,
  );
}

/// A payment between you and a friend that clears (part of) a balance.
class Settlement {
  const Settlement({
    required this.id,
    required this.friendId,
    required this.amount,
    required this.at,
    this.transactionId,
  });

  final String id;
  final String friendId;

  /// Positive when the friend paid you, negative when you paid them.
  final double amount;
  final DateTime at;
  final String? transactionId;

  Map<String, Object?> toJson() => {
    'id': id,
    'friendId': friendId,
    'amount': amount,
    'at': at.toIso8601String(),
    'transactionId': transactionId,
  };

  factory Settlement.fromJson(Map<String, Object?> json) => Settlement(
    id: json['id'] as String,
    friendId: json['friendId'] as String,
    amount: (json['amount'] as num).toDouble(),
    at: DateTime.parse(json['at'] as String),
    transactionId: json['transactionId'] as String?,
  );
}

Map<String, double> _net(
  Iterable<Map<String, double>> costs,
  Iterable<Settlement> settlements,
) {
  final totals = <String, double>{};
  for (final cost in costs) {
    for (final e in cost.entries) {
      totals[e.key] = (totals[e.key] ?? 0) + e.value;
    }
  }
  for (final s in settlements) {
    totals[s.friendId] = (totals[s.friendId] ?? 0) - s.amount;
  }
  // Round away float dust so "settled up" is exact.
  return totals.map((k, v) => MapEntry(k, (v * 100).round() / 100));
}

class SplitGroup {
  const SplitGroup({
    required this.id,
    required this.name,
    required this.memberIds,
    required this.createdAt,
    this.currency = 'NPR',
    this.expenses = const [],
    this.settlements = const [],
  });

  final String id;
  final String name;

  /// Fixed when the group is created; balances are kept in it.
  final String currency;

  /// Friend ids; you are always a member.
  final List<String> memberIds;
  final DateTime createdAt;
  final List<GroupExpense> expenses;
  final List<Settlement> settlements;

  double get totalSpent => expenses.fold(0, (sum, e) => sum + e.amount);

  /// Friend id → what they owe you (negative: you owe them), after
  /// settlements. Every member appears, settled ones with 0.
  Map<String, double> get balances {
    final net = _net(
      expenses.map((e) => balancesFor(e.amount, e.paidBy, e.shares)),
      settlements,
    );
    // Members first; anyone else with an open balance (e.g. removed after a
    // settlement) still shows so nothing is hidden.
    return {
      for (final id in memberIds) id: net[id] ?? 0,
      for (final e in net.entries)
        if (!memberIds.contains(e.key) && e.value.abs() >= .005) e.key: e.value,
    };
  }

  double get net => balances.values.fold(0, (a, b) => a + b);

  SplitGroup copyWith({
    String? name,
    List<String>? memberIds,
    List<GroupExpense>? expenses,
    List<Settlement>? settlements,
  }) => SplitGroup(
    id: id,
    name: name ?? this.name,
    memberIds: memberIds ?? this.memberIds,
    createdAt: createdAt,
    currency: currency,
    expenses: expenses ?? this.expenses,
    settlements: settlements ?? this.settlements,
  );

  Map<String, Object?> toJson() => {
    'id': id,
    'name': name,
    'memberIds': memberIds,
    'createdAt': createdAt.toIso8601String(),
    'currency': currency,
    'expenses': expenses.map((e) => e.toJson()).toList(),
    'settlements': settlements.map((s) => s.toJson()).toList(),
  };

  factory SplitGroup.fromJson(Map<String, Object?> json) => SplitGroup(
    id: json['id'] as String,
    name: json['name'] as String,
    memberIds: (json['memberIds'] as List).cast<String>(),
    createdAt: DateTime.parse(json['createdAt'] as String),
    currency: json['currency'] as String? ?? 'NPR',
    expenses: (json['expenses'] as List? ?? const [])
        .cast<Map>()
        .map((e) => GroupExpense.fromJson(e.cast()))
        .toList(),
    settlements: (json['settlements'] as List? ?? const [])
        .cast<Map>()
        .map((e) => Settlement.fromJson(e.cast()))
        .toList(),
  );
}

/// A one-off bill you paid and split with friends.
class SplitBill {
  const SplitBill({
    required this.id,
    required this.title,
    required this.amount,
    required this.shares,
    required this.createdAt,
    this.currency = 'NPR',
    this.settlements = const [],
    this.transactionId,
  });

  final String id;
  final String title;
  final double amount;
  final Shares shares;
  final DateTime createdAt;
  final String currency;
  final List<Settlement> settlements;

  /// The ledger entry for the full amount, if recorded or split from one.
  final String? transactionId;

  int get people => shares.values.where((w) => w > 0).length;

  /// Friend id → what they still owe you.
  Map<String, double> get balances {
    final net = _net([balancesFor(amount, me, shares)], settlements);
    return {
      for (final e in shares.entries)
        if (e.key != me && e.value > 0) e.key: net[e.key] ?? 0,
    };
  }

  double get toCollect => balances.values.fold(0, (a, b) => a + b);

  bool get settled => toCollect.abs() < .005;

  SplitBill copyWith({List<Settlement>? settlements}) => SplitBill(
    id: id,
    title: title,
    amount: amount,
    shares: shares,
    createdAt: createdAt,
    currency: currency,
    settlements: settlements ?? this.settlements,
    transactionId: transactionId,
  );

  Map<String, Object?> toJson() => {
    'id': id,
    'title': title,
    'amount': amount,
    'shares': shares,
    'createdAt': createdAt.toIso8601String(),
    'currency': currency,
    'settlements': settlements.map((s) => s.toJson()).toList(),
    'transactionId': transactionId,
  };

  factory SplitBill.fromJson(Map<String, Object?> json) => SplitBill(
    id: json['id'] as String,
    title: json['title'] as String,
    amount: (json['amount'] as num).toDouble(),
    shares: (json['shares'] as Map).map(
      (key, value) => MapEntry(key as String, (value as num).toInt()),
    ),
    createdAt: DateTime.parse(json['createdAt'] as String),
    currency: json['currency'] as String? ?? 'NPR',
    settlements: (json['settlements'] as List? ?? const [])
        .cast<Map>()
        .map((e) => Settlement.fromJson(e.cast()))
        .toList(),
    transactionId: json['transactionId'] as String?,
  );
}

/// Rounds user-entered money to the paisa / cent.
double roundMoney(double value) => (value * 100).round() / 100;
