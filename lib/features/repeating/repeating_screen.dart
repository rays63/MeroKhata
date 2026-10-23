import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/format.dart';
import '../../data/app_store.dart';
import '../../data/models.dart';
import '../../l10n/l10n.dart';
import '../../theme/tokens.dart';
import '../../widgets/category_icons.dart';
import '../../widgets/pf.dart';
import '../entries/entry_form_screen.dart';

/// Settings → Repeating entries: what repeats, when it's next due, and a
/// way to stop it.
class RepeatingScreen extends StatelessWidget {
  const RepeatingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = AppScope.watch(context);
    final c = context.pf;
    final l = context.l10n;
    final items = [...store.recurring]
      ..sort((a, b) => a.nextDue.compareTo(b.nextDue));
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: pagePadding,
          children: [
            PfHeader(title: l.repeatingTitle),
            const SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                l.repeatingHint,
                style: pfText(13.5, weight: w700, color: c.sub, height: 1.45),
              ),
            ),
            const SizedBox(height: 14),
            if (items.isEmpty)
              PfEmptyCard(
                icon: LucideIcons.repeat,
                title: l.repeatingTitle,
                body: l.repeatingEmpty,
              )
            else
              PfCard(
                child: Column(
                  children: [
                    for (var i = 0; i < items.length; i++) ...[
                      if (i > 0) const PfDivider(),
                      _Row(item: items[i], store: store),
                    ],
                  ],
                ),
              ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.item, required this.store});

  final RecurringEntry item;
  final AppStore store;

  @override
  Widget build(BuildContext context) {
    final c = context.pf;
    final l = context.l10n;
    final isIn = item.type == TransactionType.cashIn;
    final color = item.isTransfer ? c.blue : c.amount(isIn);
    final currency =
        store.bookById(item.bookId)?.currency ?? store.defaultCurrency;
    final where = item.isTransfer
        ? l.transferRowTitle(
            store.bookById(item.bookId)?.name ?? l.transferDeletedAccount,
            store.bookById(item.toBookId!)?.name ?? l.transferDeletedAccount,
          )
        : store.bookById(item.bookId)?.name ?? '';
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
      child: Row(
        children: [
          PfIconTile(
            icon: item.isTransfer
                ? LucideIcons.arrowLeftRight
                : entryIcon(item.category),
            background: item.isTransfer ? c.blueSoft : c.amountSoft(isIn),
            foreground: color,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: pfText(15, weight: w800),
                ),
                Text(
                  '${repeatLabel(l, item.repeat)} · $where',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: pfText(12, weight: w700, color: c.sub),
                ),
                Text(
                  l.repeatingNext(DateFormat('d MMM y').format(item.nextDue)),
                  style: pfText(11.5, weight: w800, color: c.cashIn),
                ),
              ],
            ),
          ),
          Text(
            money(item.amount, currency),
            style: pfText(14, weight: w900, color: color),
          ),
          IconButton(
            tooltip: l.repeatingStop(item.title),
            onPressed: () async {
              await store.deleteRecurring(item.id);
              if (context.mounted) showPfToast(context, l.repeatingStopped);
            },
            icon: Icon(LucideIcons.trash2, size: 18, color: c.cashOut),
          ),
        ],
      ),
    );
  }
}
