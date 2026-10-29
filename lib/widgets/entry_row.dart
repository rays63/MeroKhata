import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../core/format.dart';
import '../data/app_store.dart';
import '../data/models.dart';
import '../theme/tokens.dart';
import 'category_icons.dart';
import 'pf.dart';
import 'tags.dart';
import '../l10n/l10n.dart';

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
    this.account,
    this.highlight,
  });

  final LedgerTransaction entry;
  final String currency;
  final VoidCallback onTap;
  final String? subtitle;
  final bool showBalance;

  /// Account name shown as a small chip, for lists that span accounts.
  final String? account;

  /// Search text to mark in the title, subtitle and amount.
  final String? highlight;

  @override
  Widget build(BuildContext context) {
    final c = context.pf;
    final isIn = entry.type == TransactionType.cashIn;
    final transfer = entry.isTransferLeg;
    final color = transfer ? c.blue : c.amount(isIn);
    final title = transfer
        ? transferTitle(context, AppScope.read(context), entry.transferId!)
        : entry.title;
    final meta =
        subtitle ??
        [
          transfer ? context.l10n.transfer : entry.categoryLabel,
          transfer ? entry.notes : entry.paymentMode,
        ].where((part) => part.trim().isNotEmpty).join(' · ');
    return Semantics(
      button: true,
      label: context.l10n.entrySemantics(
        title,
        transfer
            ? context.l10n.transfer
            : isIn
            ? context.l10n.cashIn
            : context.l10n.cashOut,
        money(entry.amount, currency),
      ),
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: LayoutBuilder(
            builder: (context, box) {
              final width = box.maxWidth;
              return Row(
                children: [
                  PfIconTile(
                    icon: transfer
                        ? LucideIcons.arrowLeftRight
                        : entryIcon(entry.category),
                    background: transfer ? c.blueSoft : c.amountSoft(isIn),
                    foreground: color,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text.rich(
                          _marked(title, c),
                          style: pfText(15, weight: w800, color: c.ink),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (meta.isNotEmpty ||
                            account != null ||
                            entry.tags.isNotEmpty)
                          Row(
                            children: [
                              if (account != null) ...[
                                Flexible(
                                  child: ConstrainedBox(
                                    constraints: const BoxConstraints(
                                      maxWidth: 96,
                                    ),
                                    child: PfBadge(
                                      label: account!,
                                      background: c.card2,
                                      foreground: c.sub,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                              ],
                              Flexible(
                                child: Text.rich(
                                  _marked(meta, c),
                                  style: pfText(12, weight: w700, color: c.sub),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (rowTagLabel(entry.tags) case final tag?) ...[
                                const SizedBox(width: 6),
                                Flexible(
                                  child: ConstrainedBox(
                                    constraints: const BoxConstraints(
                                      maxWidth: 110,
                                    ),
                                    child: Text(
                                      tag,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: pfText(
                                        11.5,
                                        weight: w800,
                                        color: c.tag,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  // The amount never takes more than 42% of the row, so the
                  // title always shows; very large amounts shrink to fit.
                  ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: width * .42),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: _amountMatches ? c.highlight : null,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              signedMoney(entry.signedAmount, currency),
                              style: pfText(15, weight: w900, color: color),
                            ),
                          ),
                        ),
                        if (showBalance)
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              context.l10n.balanceShort(
                                balanceMoney(entry.runningBalance, currency),
                              ),
                              style: pfText(11, weight: w800, color: c.mute),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

extension on EntryRow {
  /// [text] with the first match of [highlight] marked.
  TextSpan _marked(String text, PfColors c) {
    final q = highlight?.trim().replaceFirst(RegExp(r'^#'), '') ?? '';
    final at = q.isEmpty ? -1 : text.toLowerCase().indexOf(q.toLowerCase());
    if (at < 0) return TextSpan(text: text);
    return TextSpan(
      children: [
        TextSpan(text: text.substring(0, at)),
        TextSpan(
          text: text.substring(at, at + q.length),
          style: TextStyle(backgroundColor: c.highlight),
        ),
        TextSpan(text: text.substring(at + q.length)),
      ],
    );
  }

  bool get _amountMatches {
    final q = double.tryParse(highlight?.replaceAll(',', '').trim() ?? '');
    return q != null && q == entry.amount;
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

/// "NIC Asia → eSewa" for a transfer, whichever side is shown.
String transferTitle(BuildContext context, AppStore store, String transferId) {
  final l = context.l10n;
  String name(String? id) =>
      (id == null ? null : store.bookById(id)?.name) ??
      l.transferDeletedAccount;
  String? side(TransactionType type) => store.transactions
      .where(
        (e) => e.transferId == transferId && !e.transferFee && e.type == type,
      )
      .firstOrNull
      ?.bookId;
  return l.transferRowTitle(
    name(side(TransactionType.cashOut)),
    name(side(TransactionType.cashIn)),
  );
}
