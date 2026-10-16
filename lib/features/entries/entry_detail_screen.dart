import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../app/nav.dart';
import '../../core/format.dart';
import '../../data/app_store.dart';
import '../../data/models.dart';
import '../../l10n/l10n.dart';
import '../../theme/tokens.dart';
import '../../widgets/pf.dart';
import '../split/group_screen.dart';
import '../split/split_bill_screen.dart';

class EntryDetailScreen extends StatelessWidget {
  const EntryDetailScreen({super.key, required this.entryId});

  final String entryId;

  Future<void> _delete(BuildContext context, AppStore store) async {
    final c = context.pf;
    final l = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l.entryDeleteTitle, style: pfText(19, weight: w900)),
        content: Text(
          l.entryDeleteBody,
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
    final navigator = Navigator.of(context);
    showPfToast(context, l.entryDeletedToast);
    navigator.pop();
    await store.deleteTransaction(entryId);
  }

  @override
  Widget build(BuildContext context) {
    final store = AppScope.watch(context);
    final entry = store.transactionById(entryId);
    if (entry == null) return const Scaffold(body: SizedBox.shrink());
    final c = context.pf;
    final l = context.l10n;
    final book = store.bookById(entry.bookId);
    final currency = book?.currency ?? 'NPR';
    final isIn = entry.type == TransactionType.cashIn;
    final color = c.amount(isIn);
    final goal = entry.goalId == null || entry.goalId!.isEmpty
        ? null
        : store.goals.where((g) => g.id == entry.goalId).firstOrNull;
    final fields = <(String, String)>[
      (l.category, entry.category),
      if (entry.paymentMode.isNotEmpty) (l.paymentMode, entry.paymentMode),
      (
        l.entryDateTime,
        '${DateFormat('d MMM y').format(entry.occurredAt)} · ${timeLabel(entry.occurredAt)}',
      ),
      (l.book, book?.name ?? ''),
      if (entry.externalReference.isNotEmpty)
        (l.entryReference, entry.externalReference),
      if (entry.importSource.isNotEmpty)
        (l.entryImportedFromLabel, entry.importSource),
      if (goal != null) (l.entryGoal, goal.name),
      if (entry.notes.isNotEmpty) (l.entryNotes, entry.notes),
    ];
    final history = store.logsFor(entry.id);

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: pagePadding,
          children: [
            PfHeader(
              title: l.entryTitle,
              actions: [
                PfIconButton(
                  icon: LucideIcons.pencil,
                  size: 18,
                  tooltip: l.entryEditTitle,
                  onPressed: () => openEditEntry(context, entry),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PfBadge(
                    label: isIn ? l.entryBadgeCashIn : l.entryBadgeCashOut,
                    pill: true,
                    fontSize: 12,
                    background: c.amountSoft(isIn),
                    foreground: color,
                  ),
                  const SizedBox(height: 8),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      signedMoney(entry.signedAmount, currency),
                      style: pfText(
                        42,
                        weight: w900,
                        color: color,
                        letterSpacing: -1,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(entry.title, style: pfText(19)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            PfCard(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
              child: Column(
                children: [
                  for (final (label, value) in fields) ...[
                    _FieldLine(label: label, value: value),
                    const PfDivider(),
                  ],
                  _FieldLine(
                    label: l.entryRunningBalance,
                    value: balanceMoney(entry.runningBalance, currency),
                    strong: true,
                  ),
                ],
              ),
            ),
            // Split a cash-out once; entries a split created (expenses,
            // settlements) can't be split again.
            if (!isIn &&
                currency == store.defaultCurrency &&
                !store.isSplitEntry(entry.id)) ...[
              const SizedBox(height: 16),
              Builder(
                builder: (context) {
                  final bill = store.billForEntry(entry.id);
                  return PfButton(
                    label: bill == null
                        ? l.entrySplitWithFriends
                        : bill.settled
                        ? l.entryViewSplitSettled
                        : l.entryViewSplitToCollect(
                            money(bill.toCollect, currency),
                          ),
                    icon: LucideIcons.split,
                    trailingIcon: LucideIcons.chevronRight,
                    spread: true,
                    style: PfButtonStyle.gold,
                    height: 52,
                    radius: 18,
                    fontSize: 15,
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => bill == null
                            ? SplitBillScreen(
                                title: entry.title,
                                amount: entry.amount,
                                linkedEntryId: entry.id,
                              )
                            : BillScreen(billId: bill.id),
                      ),
                    ),
                  );
                },
              ),
            ],
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Row(
                children: [
                  Icon(LucideIcons.history, size: 16, color: c.sub),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      l.entryEditHistory,
                      style: pfText(16, weight: w900),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            PfCard(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 2),
              child: Column(
                children: [
                  for (var i = 0; i < history.length; i++)
                    _HistoryItem(
                      text: _historyText(l, history[i]),
                      when: DateFormat(
                        'd MMM, h:mm a',
                      ).format(history[i].timestamp),
                      latest: i == 0,
                    ),
                  if (history.isEmpty)
                    _HistoryItem(
                      text: entry.importSource.isEmpty
                          ? l.entryCreated
                          : l.entryImportedFrom(entry.importSource),
                      when: DateFormat('d MMM, h:mm a').format(entry.createdAt),
                      latest: true,
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            PfButton(
              label: l.entryDelete,
              icon: LucideIcons.trash2,
              style: PfButtonStyle.outlineDanger,
              height: 50,
              radius: 18,
              fontSize: 15,
              onPressed: () => _delete(context, store),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

class _FieldLine extends StatelessWidget {
  const _FieldLine({
    required this.label,
    required this.value,
    this.strong = false,
  });

  final String label;
  final String value;
  final bool strong;

  @override
  Widget build(BuildContext context) {
    final c = context.pf;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 13),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: pfText(14, weight: w700, color: c.sub),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: pfText(14, weight: strong ? w900 : w800),
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryItem extends StatelessWidget {
  const _HistoryItem({
    required this.text,
    required this.when,
    required this.latest,
  });

  final String text;
  final String when;
  final bool latest;

  @override
  Widget build(BuildContext context) {
    final c = context.pf;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Column(
            children: [
              Container(
                width: 12,
                height: 12,
                margin: const EdgeInsets.only(top: 4),
                decoration: BoxDecoration(
                  color: latest ? c.pri : c.line,
                  shape: BoxShape.circle,
                ),
              ),
              Expanded(child: Container(width: 2, color: c.line)),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(text, style: pfText(14)),
                  Text(
                    when,
                    style: pfText(12, weight: w700, color: c.sub),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Words a history line in the current language; older logs without a code
/// are shown as they were recorded.
String _historyText(AppLocalizations l, TransactionLog log) {
  String arg(int i) => i < log.args.length ? log.args[i] : '';
  return switch (log.code) {
    'created' => l.entryCreated,
    'imported' => l.entryImportedFrom(arg(0)),
    'amount' => l.historyAmount(arg(0), arg(1)),
    'title' => l.historyTitle(arg(0)),
    'category' => l.historyCategory(arg(0), arg(1)),
    'mode' => l.historyMode(arg(0), arg(1)),
    'typeIn' => l.historyTypeIn,
    'typeOut' => l.historyTypeOut,
    'date' => l.historyDate(arg(0)),
    'notes' => l.historyNotes,
    'goal' => l.historyGoal,
    'deleted' => l.historyDeleted,
    'splitGroup' => l.historySplitGroup(arg(0)),
    'splitBill' => l.historySplitBill,
    'settled' => l.historySettled(arg(0)),
    _ => log.details,
  };
}
