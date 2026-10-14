import 'package:flutter/material.dart';

import '../core/format.dart';
import '../data/models.dart';
import '../theme/tokens.dart';
import 'category_icons.dart';
import 'pf.dart';

/// One ledger line: category tile, title, "Category · Mode", signed amount
/// and (optionally) the running balance underneath.
class EntryRow extends StatelessWidget {
  const EntryRow({
    super.key,
    required this.entry,
    required this.currency,
    required this.onTap,
    this.subtitle,
    this.showBalance = true,
  });

  final LedgerTransaction entry;
  final String currency;
  final VoidCallback onTap;
  final String? subtitle;
  final bool showBalance;

  @override
  Widget build(BuildContext context) {
    final c = context.pf;
    final isIn = entry.type == TransactionType.cashIn;
    final color = c.amount(isIn);
    final meta =
        subtitle ??
        [
          entry.category,
          entry.paymentMode,
        ].where((part) => part.trim().isNotEmpty).join(' · ');
    return Semantics(
      button: true,
      label:
          '${entry.title}, ${isIn ? 'cash in' : 'cash out'} ${money(entry.amount, currency)}',
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              PfIconTile(
                icon: entryIcon(entry.category),
                background: c.amountSoft(isIn),
                foreground: color,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.title,
                      style: pfText(15, weight: w800, color: c.ink),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (meta.isNotEmpty)
                      Text(
                        meta,
                        style: pfText(12, weight: w700, color: c.sub),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    signedMoney(entry.signedAmount, currency),
                    style: pfText(15, weight: w900, color: color),
                  ),
                  if (showBalance)
                    Text(
                      'Bal ${balanceMoney(entry.runningBalance, currency)}',
                      style: pfText(11, weight: w800, color: c.mute),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A card of [EntryRow]s separated by hairlines.
class EntryGroupCard extends StatelessWidget {
  const EntryGroupCard({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return PfCard(
      radius: 22,
      child: Column(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) const PfDivider(),
            children[i],
          ],
        ],
      ),
    );
  }
}
