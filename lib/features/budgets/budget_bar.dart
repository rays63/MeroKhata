import 'package:flutter/material.dart';

import '../../core/format.dart';
import '../../l10n/l10n.dart';
import '../../theme/tokens.dart';

/// Green below 80%, gold from 80%, red over 100%.
Color budgetColor(PfColors c, double spent, double limit) {
  final share = limit <= 0 ? 0 : spent / limit;
  return share > 1
      ? c.cashOut
      : share >= .8
      ? c.gold
      : c.btn;
}

/// "Rs 2,300 left" or "Rs 640 over" — the words carry the state, not only
/// the colour.
String budgetStatus(
  AppLocalizations l,
  double spent,
  double limit,
  String cur,
) => spent > limit
    ? l.budgetOver(money(spent - limit, cur))
    : l.budgetLeft(money(limit - spent, cur));

/// Budget progress: the fill stops at 100%; going over shows in red and in
/// the status text, never by the bar overflowing.
class BudgetBar extends StatelessWidget {
  const BudgetBar({
    super.key,
    required this.spent,
    required this.limit,
    this.thick = false,
  });

  final double spent;
  final double limit;

  /// 12px for the overall budget, 8px otherwise.
  final bool thick;

  @override
  Widget build(BuildContext context) {
    final c = context.pf;
    final share = limit <= 0 ? 0.0 : (spent / limit).clamp(0.0, 1.0);
    return ClipRRect(
      borderRadius: BorderRadius.circular(99),
      child: LinearProgressIndicator(
        value: share,
        minHeight: thick ? 12 : 8,
        backgroundColor: c.card2,
        color: budgetColor(c, spent, limit),
      ),
    );
  }
}
