import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/format.dart';
import '../../data/app_store.dart';
import '../../data/split.dart';
import '../../l10n/l10n.dart';
import '../../theme/tokens.dart';
import '../../widgets/pf.dart';
import 'group_form_screen.dart';
import 'group_screen.dart';
import 'split_bill_screen.dart';
import 'split_widgets.dart';

/// Split tab: totals owed both ways, split a bill, and groups / bills.
class SplitScreen extends StatefulWidget {
  const SplitScreen({super.key});

  @override
  State<SplitScreen> createState() => _SplitScreenState();
}

class _SplitScreenState extends State<SplitScreen> {
  bool showBills = false;

  void _push(Widget screen) =>
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));

  @override
  Widget build(BuildContext context) {
    final store = AppScope.watch(context);
    final l = context.l10n;
    final c = context.pf;
    return ListView(
      padding: pagePadding,
      children: [
        Text(l.split, style: pfText(30, weight: w900, letterSpacing: -.6)),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _Total(
                label: l.youreOwed,
                amount: store.owedToYou,
                cur: store.defaultCurrency,
                background: c.soft,
                foreground: c.cashIn,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _Total(
                label: l.youOwe,
                amount: store.youOwe,
                cur: store.defaultCurrency,
                background: c.outSoft,
                foreground: c.cashOut,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        PfButton(
          label: l.splitABill,
          icon: LucideIcons.split,
          trailingIcon: LucideIcons.arrowRight,
          spread: true,
          height: 56,
          fontSize: 16,
          onPressed: () => _push(const SplitBillScreen()),
        ),
        const SizedBox(height: 16),
        PfSegment<bool>(
          value: showBills,
          onChanged: (value) => setState(() => showBills = value),
          items: [(false, l.splitGroups, null), (true, l.splitBills, null)],
        ),
        const SizedBox(height: 16),
        if (!showBills) ..._groups(store, l) else ..._bills(store, l),
        const SizedBox(height: 24),
      ],
    );
  }

  List<Widget> _groups(AppStore store, AppLocalizations l) => [
    if (store.groups.isEmpty)
      PfEmptyCard(
        icon: LucideIcons.users,
        title: l.splitNoGroupsTitle,
        body: l.splitNoGroupsBody,
      ),
    if (store.groups.isEmpty) const SizedBox(height: 12),
    for (final group in store.groups) ...[
      _GroupTile(
        group: group,
        onTap: () => _push(GroupScreen(groupId: group.id)),
      ),
      const SizedBox(height: 10),
    ],
    PfButton(
      label: l.splitNewGroup,
      icon: LucideIcons.plus,
      style: PfButtonStyle.soft,
      height: 52,
      radius: 18,
      fontSize: 15,
      onPressed: () => _push(const GroupFormScreen()),
    ),
  ];

  List<Widget> _bills(AppStore store, AppLocalizations l) => [
    if (store.bills.isEmpty)
      PfEmptyCard(
        icon: LucideIcons.receipt,
        title: l.splitNoBillsTitle,
        body: l.splitNoBillsBody,
      )
    else
      PfCard(
        radius: 22,
        child: Column(
          children: [
            for (final bill in store.bills) ...[
              if (bill != store.bills.first) const PfDivider(),
              _BillRow(
                bill: bill,
                onTap: () => _push(BillScreen(billId: bill.id)),
              ),
            ],
          ],
        ),
      ),
  ];
}

class _Total extends StatelessWidget {
  const _Total({
    required this.label,
    required this.amount,
    required this.cur,
    required this.background,
    required this.foreground,
  });

  final String label;
  final double amount;
  final String cur;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: pfText(12.5, color: foreground)),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              money(amount, cur),
              style: pfText(22, weight: w900, color: foreground),
            ),
          ),
        ],
      ),
    );
  }
}

String _keep(String text) => text.replaceAll(' ', '\u00A0');

class _GroupTile extends StatelessWidget {
  const _GroupTile({required this.group, required this.onTap});

  final SplitGroup group;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final c = context.pf;
    final net = group.net;
    final cur = group.currency;
    final people = group.memberIds.length + 1;
    final expenses = group.expenses.length;
    final (status, color) = net > .004
        ? (l.splitGroupOwed(money(net, cur)), c.cashIn)
        : net < -.004
        ? (l.splitYouOweAmount(money(-net, cur)), c.cashOut)
        : (l.splitSettledUp, c.sub);
    return PfCard(
      radius: 22,
      padding: const EdgeInsets.all(16),
      onTap: onTap,
      child: Row(
        children: [
          AvatarStack(ids: [me, ...group.memberIds]),
          const SizedBox(width: 14),
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  group.name,
                  style: pfText(16, weight: w900),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                // Non-breaking spaces keep "3 expenses" together; it only
                // wraps at the dot.
                Text(
                  '${_keep(l.splitPeopleCount(people))} · '
                  '${_keep(l.splitExpenseCount(expenses))}',
                  style: pfText(12.5, weight: w700, color: c.sub),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Flexible so longer translations wrap instead of squeezing the name.
          Flexible(
            flex: 2,
            child: Text(
              status,
              textAlign: TextAlign.end,
              style: pfText(13, weight: w900, color: color),
            ),
          ),
        ],
      ),
    );
  }
}

class _BillRow extends StatelessWidget {
  const _BillRow({required this.bill, required this.onTap});

  final SplitBill bill;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final c = context.pf;
    final cur = bill.currency;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            PfIconTile(
              icon: LucideIcons.receipt,
              background: c.goldSoft,
              foreground: c.gold,
              size: 40,
              iconSize: 18,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    bill.title,
                    style: pfText(15),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '${l.dayLabel(bill.createdAt)} · ${l.splitPeopleCount(bill.people)}',
                    style: pfText(12, weight: w700, color: c.sub),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(money(bill.amount, cur), style: pfText(15, weight: w900)),
                Text(
                  bill.settled
                      ? l.splitBillSettled
                      : l.splitToCollectAmount(money(bill.toCollect, cur)),
                  style: pfText(11.5, color: c.cashIn),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
