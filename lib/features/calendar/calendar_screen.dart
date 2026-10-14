import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../app/nav.dart';
import '../../core/format.dart';
import '../../data/app_store.dart';
import '../../data/models.dart';
import '../../l10n/l10n.dart';
import '../../theme/tokens.dart';
import '../../widgets/entry_row.dart';
import '../../widgets/month_grid.dart';
import '../../widgets/pf.dart';
import '../../widgets/store_sheets.dart';

/// Month grid with cash-in (green) / cash-out (red) dots; tap a day to see
/// its entries.
class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  String? bookId;
  late DateTime month = DateTime(DateTime.now().year, DateTime.now().month);
  late DateTime selected = DateUtils.dateOnly(DateTime.now());

  void _shiftMonth(int delta) => setState(() {
    month = DateTime(month.year, month.month + delta);
    final now = DateTime.now();
    selected = month.year == now.year && month.month == now.month
        ? DateUtils.dateOnly(now)
        : month;
  });

  @override
  Widget build(BuildContext context) {
    final store = AppScope.watch(context);
    final c = context.pf;
    final l = context.l10n;
    final book =
        store.bookById(bookId ?? '') ?? store.booksByRecent.firstOrNull;
    if (book == null) return const Scaffold(body: SizedBox.shrink());
    final entries = store.transactionsForBook(book.id);
    final byDay = <DateTime, List<LedgerTransaction>>{};
    for (final entry in entries) {
      if (entry.occurredAt.year != month.year ||
          entry.occurredAt.month != month.month) {
        continue;
      }
      (byDay[DateUtils.dateOnly(entry.occurredAt)] ??= []).add(entry);
    }
    final dayEntries = byDay[selected] ?? const [];
    var dayIn = 0.0, dayOut = 0.0;
    for (final entry in dayEntries) {
      if (entry.type == TransactionType.cashIn) {
        dayIn += entry.amount;
      } else {
        dayOut += entry.amount;
      }
    }
    final now = DateTime.now();
    final label = sameDay(selected, now)
        ? l.entryWhenToday(DateFormat('d MMM').format(selected))
        : DateFormat('EEE, d MMM').format(selected);

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: pagePadding,
          children: [
            PfHeader(
              title: l.calendar,
              actions: [
                Material(
                  color: c.card,
                  shape: const StadiumBorder(),
                  child: InkWell(
                    customBorder: const StadiumBorder(),
                    onTap: store.books.length < 2
                        ? null
                        : () async {
                            final picked = await pickBook(
                              context,
                              selected: book.id,
                            );
                            if (picked != null) setState(() => bookId = picked);
                          },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 120),
                            child: Text(
                              book.name,
                              style: pfText(12, weight: w900, color: c.sub),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (store.books.length > 1) ...[
                            const SizedBox(width: 4),
                            Icon(
                              LucideIcons.chevronDown,
                              size: 13,
                              color: c.sub,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            PfCard(
              radius: 26,
              padding: const EdgeInsets.fromLTRB(14, 18, 14, 18),
              child: MonthGrid(
                month: month,
                selected: selected,
                showOutsideDays: true,
                activity: (day) {
                  final list = byDay[DateTime(month.year, month.month, day)];
                  if (list == null) return (false, false);
                  return (
                    list.any((e) => e.type == TransactionType.cashIn),
                    list.any((e) => e.type == TransactionType.cashOut),
                  );
                },
                onPrev: () => _shiftMonth(-1),
                onNext: () => _shiftMonth(1),
                onSelect: (day) => setState(() => selected = day),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Expanded(
                    child: Text(label, style: pfText(17, weight: w900)),
                  ),
                  Text(
                    l.entryCount(dayEntries.length),
                    style: pfText(13, color: c.sub),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _DayTotal(
                    label: l.cashIn,
                    value: '+ ${money(dayIn, book.currency)}',
                    background: c.soft,
                    foreground: c.cashIn,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _DayTotal(
                    label: l.cashOut,
                    value: '− ${money(dayOut, book.currency)}',
                    background: c.outSoft,
                    foreground: c.cashOut,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (dayEntries.isEmpty)
              PfCard(
                radius: 22,
                padding: const EdgeInsets.all(20),
                child: Text(
                  l.calNoEntries,
                  style: pfText(14, weight: w700, color: c.sub),
                ),
              )
            else
              EntryGroupCard(
                children: [
                  for (final entry in dayEntries)
                    EntryRow(
                      entry: entry,
                      currency: book.currency,
                      showBalance: false,
                      onTap: () => openEntry(context, entry.id),
                    ),
                ],
              ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

class _DayTotal extends StatelessWidget {
  const _DayTotal({
    required this.label,
    required this.value,
    required this.background,
    required this.foreground,
  });

  final String label;
  final String value;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: pfText(12, color: foreground)),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: pfText(17, weight: w900, color: foreground),
            ),
          ),
        ],
      ),
    );
  }
}
