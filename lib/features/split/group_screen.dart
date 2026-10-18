import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/format.dart';
import '../../data/app_store.dart';
import '../../data/split.dart';
import '../../l10n/l10n.dart';
import '../../theme/tokens.dart';
import '../../widgets/option_sheet.dart';
import '../../widgets/pf.dart';
import 'expense_form_screen.dart';
import 'group_form_screen.dart';
import 'split_widgets.dart';

/// A group's balances with each member (settle up) and its expenses.
class GroupScreen extends StatelessWidget {
  const GroupScreen({super.key, required this.groupId});

  final String groupId;

  Future<void> _settle(
    BuildContext context,
    AppStore store,
    String friendId,
    double amount,
    String cur,
  ) async {
    final l = context.l10n;
    final name = personName(l, store, friendId);
    final choice = await showSettleSheet(
      context,
      friendName: name,
      amount: amount,
      currency: cur,
    );
    if (choice == null || !context.mounted) return;
    final bookId = choice.bookId;
    final settled = await store.settleGroup(
      groupId: groupId,
      friendId: friendId,
      bookId: bookId,
    );
    if (!context.mounted || settled == 0) return;
    showPfToast(
      context,
      bookId == null
          ? l.splitSettledToast(money(settled.abs(), cur), name)
          : (settled > 0 ? l.splitReceivedToast : l.splitPaidToast)(
              money(settled.abs(), cur),
              name,
              store.bookById(bookId)?.name ?? l.splitYourBook,
            ),
    );
  }

  Future<void> _expenseActions(
    BuildContext context,
    AppStore store,
    GroupExpense expense,
  ) async {
    final l = context.l10n;
    final choice = await showOptionSheet<String>(
      context,
      title: expense.title,
      selected: null,
      options: () => [
        SheetOption('delete', l.expenseDelete, LucideIcons.trash2),
      ],
    );
    if (choice != 'delete' || !context.mounted) return;
    final group = store.groups.where((g) => g.id == groupId).firstOrNull;
    final settledWith = {
      for (final s in group?.settlements ?? const <Settlement>[])
        if (expense.shares.containsKey(s.friendId) ||
            expense.paidBy == s.friendId)
          personName(l, store, s.friendId),
    };
    final c = context.pf;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          l.splitDeleteTitle(expense.title),
          style: pfText(19, weight: w900),
        ),
        content: Text(
          settledWith.isEmpty
              ? l.expenseDeleteBody
              : l.expenseDeleteSettledBody(settledWith.join(', ')),
          style: pfText(14, weight: w600, color: c.sub),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l.cancel, style: pfText(14, color: c.sub)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l.delete, style: pfText(14, color: c.cashOut)),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    await store.deleteGroupExpense(groupId, expense.id);
    if (context.mounted) {
      showPfToast(
        context,
        expense.transactionId == null
            ? l.expenseDeleted
            : l.expenseDeletedEntryStays,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final store = AppScope.watch(context);
    final l = context.l10n;
    final c = context.pf;
    final group = store.groups.where((g) => g.id == groupId).firstOrNull;
    if (group == null) {
      return Scaffold(
        body: SafeArea(
          child: Padding(
            padding: pagePadding,
            child: PfHeader(title: l.groupTitle),
          ),
        ),
      );
    }
    final balances = group.balances;
    final net = group.net;
    final cur = group.currency;
    final members = [
      l.splitYou,
      for (final id in group.memberIds) personName(l, store, id),
    ].join(', ');

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: pagePadding,
          children: [
            PfHeader(
              title: group.name,
              subtitle: members,
              actions: [
                PfIconButton(
                  icon: LucideIcons.pencil,
                  size: 18,
                  tooltip: l.groupEdit,
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => GroupFormScreen(group: group),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: c.hero,
                borderRadius: BorderRadius.circular(26),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    net > .004
                        ? l.youreOwed
                        : net < -.004
                        ? l.youOwe
                        : l.splitAllSettled,
                    style: pfText(13, color: PfColors.heroLabel),
                  ),
                  Text(
                    money(net.abs(), cur),
                    style: pfText(30, weight: w900, color: Colors.white),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l.groupTotalSpent(money(group.totalSpent, cur)),
                    style: pfText(
                      12.5,
                      weight: w700,
                      color: PfColors.heroLabel,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(l.groupBalances, style: pfText(16, weight: w900)),
            ),
            const SizedBox(height: 16),
            PfCard(
              radius: 22,
              child: Column(
                children: [
                  for (final id in group.memberIds) ...[
                    if (id != group.memberIds.first) const PfDivider(),
                    _BalanceRow(
                      name: personName(l, store, id),
                      color: personColor(store, id),
                      amount: balances[id] ?? 0,
                      cur: cur,
                      onSettle: () =>
                          _settle(context, store, id, balances[id] ?? 0, cur),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(l.groupExpenses, style: pfText(16, weight: w900)),
            ),
            const SizedBox(height: 16),
            if (group.expenses.isEmpty)
              PfCard(
                radius: 22,
                padding: const EdgeInsets.all(18),
                child: Text(
                  l.groupNoExpenses,
                  style: pfText(14, weight: w700, color: c.sub),
                ),
              )
            else
              PfCard(
                radius: 22,
                child: Column(
                  children: [
                    for (final expense in group.expenses) ...[
                      if (expense != group.expenses.first) const PfDivider(),
                      InkWell(
                        onTap: () => _expenseActions(context, store, expense),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      expense.title,
                                      style: pfText(15),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      l.expensePaidByName(
                                        personName(l, store, expense.paidBy),
                                      ),
                                      style: pfText(
                                        12,
                                        weight: w700,
                                        color: c.sub,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                money(expense.amount, cur),
                                style: pfText(15, weight: w900),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            const SizedBox(height: 24),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(20, 10, 20, 14),
        child: PfButton(
          label: l.expenseAdd,
          icon: LucideIcons.plus,
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ExpenseFormScreen(groupId: groupId),
            ),
          ),
        ),
      ),
    );
  }
}

class _BalanceRow extends StatelessWidget {
  const _BalanceRow({
    required this.name,
    required this.color,
    required this.amount,
    required this.cur,
    required this.onSettle,
  });

  final String name;
  final Color color;
  final String cur;

  /// Positive: they owe you.
  final double amount;
  final VoidCallback onSettle;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final c = context.pf;
    final settled = amount.abs() < .005;
    final status = settled
        ? l.splitSettledUp
        : amount > 0
        ? l.splitOwesYou(money(amount, cur))
        : l.splitYouOweAmount(money(-amount, cur));
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          PersonAvatar(name: name, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: pfText(15), overflow: TextOverflow.ellipsis),
                Text(
                  status,
                  style: pfText(
                    12.5,
                    color: settled ? c.sub : c.amount(amount > 0),
                  ),
                ),
              ],
            ),
          ),
          if (!settled)
            PfSmallButton(
              label: l.splitSettle,
              onPressed: onSettle,
              height: 38,
              radius: 12,
              fontSize: 13,
              background: c.soft,
              foreground: c.cashIn,
            ),
        ],
      ),
    );
  }
}

/// A one-off bill: what each friend still owes, with settle-up.
class BillScreen extends StatelessWidget {
  const BillScreen({super.key, required this.billId});

  final String billId;

  Future<void> _settle(
    BuildContext context,
    AppStore store,
    String friendId,
    double amount,
    String cur,
  ) async {
    final l = context.l10n;
    final name = personName(l, store, friendId);
    final choice = await showSettleSheet(
      context,
      friendName: name,
      amount: amount,
      currency: cur,
    );
    if (choice == null || !context.mounted) return;
    final bookId = choice.bookId;
    final settled = await store.settleBill(
      billId: billId,
      friendId: friendId,
      bookId: bookId,
    );
    if (!context.mounted || settled == 0) return;
    showPfToast(
      context,
      bookId == null
          ? l.splitSettledToast(money(settled.abs(), cur), name)
          : l.splitReceivedToast(
              money(settled, cur),
              name,
              store.bookById(bookId)?.name ?? l.splitYourBook,
            ),
    );
  }

  Future<void> _delete(
    BuildContext context,
    AppStore store,
    SplitBill bill,
  ) async {
    final c = context.pf;
    final l = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          l.splitDeleteTitle(bill.title),
          style: pfText(19, weight: w900),
        ),
        content: Text(
          l.splitEntriesStay,
          style: pfText(14, weight: w600, color: c.sub),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l.cancel, style: pfText(14, color: c.sub)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l.delete, style: pfText(14, color: c.cashOut)),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    showPfToast(context, l.billDeleted);
    Navigator.pop(context);
    await store.deleteBill(bill.id);
  }

  @override
  Widget build(BuildContext context) {
    final store = AppScope.watch(context);
    final l = context.l10n;
    final c = context.pf;
    final bill = store.bills.where((b) => b.id == billId).firstOrNull;
    if (bill == null) {
      return Scaffold(
        body: SafeArea(
          child: Padding(
            padding: pagePadding,
            child: PfHeader(title: l.billTitle),
          ),
        ),
      );
    }
    final balances = bill.balances;
    final parts = splitAmount(bill.amount, bill.shares);
    final cur = bill.currency;
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: pagePadding,
          children: [
            PfHeader(
              title: bill.title,
              subtitle:
                  '${l.dayLabel(bill.createdAt)} · ${l.splitPeopleCount(bill.people)} · ${l.billPaidByYou}',
              actions: [
                PfIconButton(
                  icon: LucideIcons.trash2,
                  size: 18,
                  tooltip: l.billDelete,
                  onPressed: () => _delete(context, store, bill),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: c.hero,
                borderRadius: BorderRadius.circular(26),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    bill.settled ? l.splitAllSettled : l.billToCollect,
                    style: pfText(13, color: PfColors.heroLabel),
                  ),
                  Text(
                    money(bill.toCollect, cur),
                    style: pfText(30, weight: w900, color: Colors.white),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l.billTotalLine(
                      money(bill.amount, cur),
                      money(parts[me] ?? 0, cur),
                    ),
                    style: pfText(
                      12.5,
                      weight: w700,
                      color: PfColors.heroLabel,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            PfCard(
              radius: 22,
              child: Column(
                children: [
                  for (final id in balances.keys) ...[
                    if (id != balances.keys.first) const PfDivider(),
                    _BalanceRow(
                      name: personName(l, store, id),
                      color: personColor(store, id),
                      amount: balances[id]!,
                      cur: cur,
                      onSettle: () =>
                          _settle(context, store, id, balances[id]!, cur),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
