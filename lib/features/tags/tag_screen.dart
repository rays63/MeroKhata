import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../app/nav.dart';
import '../../core/format.dart';
import '../../data/app_store.dart';
import '../../data/models.dart';
import '../../l10n/l10n.dart';
import '../../theme/tokens.dart';
import '../../widgets/account_type.dart';
import '../../widgets/entry_row.dart';
import '../../widgets/pf.dart';
import '../../widgets/tags.dart';
import 'manage_tags_screen.dart';

/// Everything one tag covers: what it cost, which accounts paid, and its
/// entries day by day.
class TagScreen extends StatelessWidget {
  const TagScreen({super.key, required this.tag});

  final String tag;

  @override
  Widget build(BuildContext context) {
    final store = AppScope.watch(context);
    final c = context.pf;
    final l = context.l10n;
    final entries = store.entriesTagged(tag);
    final spent = <String, double>{}, received = <String, double>{};
    final accountIds = <String>{};
    for (final entry in entries) {
      final book = store.bookById(entry.bookId);
      if (book == null) continue;
      accountIds.add(book.id);
      if (entry.isTransferLeg) {
        final legs = store.transferLegs(entry.transferId!);
        if (legs != null) accountIds.add(legs.toId);
      }
      if (!entry.countsAsFlow) continue;
      final totals = entry.type == TransactionType.cashIn ? received : spent;
      totals[book.currency] = (totals[book.currency] ?? 0) + entry.amount;
    }
    String joined(Map<String, double> totals) => totals.isEmpty
        ? money(0, store.defaultCurrency)
        : [
            for (final MapEntry(key: cur, value: v) in totals.entries)
              money(v, cur),
          ].join(' · ');
    final accounts = [for (final id in accountIds) ?store.bookById(id)];
    final groups = <(DateTime, List<LedgerTransaction>)>[];
    for (final entry in entries) {
      if (groups.isEmpty || !sameDay(groups.last.$1, entry.occurredAt)) {
        groups.add((entry.occurredAt, [entry]));
      } else {
        groups.last.$2.add(entry);
      }
    }

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: pagePadding,
          children: [
            Row(
              children: [
                PfIconButton(
                  icon: LucideIcons.arrowLeft,
                  tooltip: l.back,
                  onPressed: () => Navigator.maybePop(context),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    tagLabel(tag),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: pfText(20, weight: w900, color: c.tag),
                  ),
                ),
                PfIconButton(
                  icon: LucideIcons.pencil,
                  size: 19,
                  tooltip: l.tagRenameTitle(tag),
                  onPressed: () async {
                    final renamed = await renameTagDialog(context, tag);
                    if (renamed != null && context.mounted) {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (_) => TagScreen(tag: renamed),
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 14),
            PfCard(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      [
                        joined(spent),
                        l.bookCount(accounts.length),
                        l.entryCount(entries.length),
                      ].join(' · '),
                      style: pfText(13, weight: w800, color: c.sub),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _Figure(
                            label: l.tagSpent,
                            value: joined(spent),
                            color: c.cashOut,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _Figure(
                            label: l.tagReceived,
                            value: joined(received),
                            color: c.cashIn,
                          ),
                        ),
                      ],
                    ),
                    if (accounts.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          for (final book in accounts)
                            ActionChip(
                              avatar: Icon(
                                accountTypeIcon(book.accountType),
                                size: 14,
                                color: c.sub,
                              ),
                              label: Text(
                                book.name,
                                style: pfText(12, weight: w800, color: c.ink),
                              ),
                              backgroundColor: c.card2,
                              side: BorderSide.none,
                              shape: const StadiumBorder(),
                              onPressed: () => openBook(context, book.id),
                            ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            if (entries.isEmpty)
              PfEmptyCard(
                icon: LucideIcons.hash,
                title: tagLabel(tag),
                body: l.tagEmpty,
              ),
            for (final (day, items) in groups) ...[
              PfSectionLabel(l.dayLabel(day)),
              const SizedBox(height: 8),
              EntryGroupCard(
                children: [
                  for (final entry in items)
                    EntryRow(
                      entry: entry,
                      currency: store.bookById(entry.bookId)?.currency ?? 'NPR',
                      account: store.bookById(entry.bookId)?.name,
                      showBalance: false,
                      onTap: () => openEntry(context, entry.id),
                    ),
                ],
              ),
              const SizedBox(height: 14),
            ],
          ],
        ),
      ),
    );
  }
}

class _Figure extends StatelessWidget {
  const _Figure({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final c = context.pf;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: pfText(12, weight: w800, color: c.sub),
        ),
        Text(
          value,
          style: pfText(18, weight: w900, color: color),
        ),
      ],
    );
  }
}
