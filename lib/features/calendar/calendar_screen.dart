import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../app/nav.dart';
import '../../core/format.dart';
import '../../data/app_store.dart';
import '../../data/models.dart';
import '../../theme/tokens.dart';
import '../../widgets/entry_row.dart';
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
        ? 'Today, ${DateFormat('d MMM').format(selected)}'
        : DateFormat('EEE, d MMM').format(selected);

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: pagePadding,
          children: [
            PfHeader(
              title: 'Calendar',
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
                            Icon(LucideIcons.chevronDown, size: 13, color: c.sub),
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
              child: _MonthGrid(
                month: month,
                selected: selected,
                byDay: byDay,
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
                  Expanded(child: Text(label, style: pfText(17, weight: w900))),
                  Text(
                    '${dayEntries.length} ${dayEntries.length == 1 ? 'entry' : 'entries'}',
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
                    label: 'Cash in',
                    value: '+ ${money(dayIn, book.currency)}',
                    background: c.soft,
                    foreground: c.cashIn,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _DayTotal(
                    label: 'Cash out',
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
                  'No entries on this day.',
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

class _MonthGrid extends StatelessWidget {
  const _MonthGrid({
    required this.month,
    required this.selected,
    required this.byDay,
    required this.onPrev,
    required this.onNext,
    required this.onSelect,
  });

  final DateTime month;
  final DateTime selected;
  final Map<DateTime, List<LedgerTransaction>> byDay;
  final VoidCallback onPrev;
  final VoidCallback onNext;
  final ValueChanged<DateTime> onSelect;

  @override
  Widget build(BuildContext context) {
    final c = context.pf;
    final today = DateUtils.dateOnly(DateTime.now());
    final days = DateUtils.getDaysInMonth(month.year, month.month);
    final lead = DateTime(month.year, month.month).weekday % 7; // Sunday first
    final previousDays = DateUtils.getDaysInMonth(month.year, month.month - 1);
    final cells = lead + days;
    final rows = (cells / 7).ceil();
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(6, 0, 6, 14),
          child: Row(
            children: [
              IconButton(
                tooltip: 'Previous month',
                onPressed: onPrev,
                icon: Icon(LucideIcons.chevronLeft, size: 20, color: c.mute),
              ),
              Expanded(
                child: Text(
                  DateFormat('MMMM y').format(month),
                  textAlign: TextAlign.center,
                  style: pfText(17, weight: w900),
                ),
              ),
              IconButton(
                tooltip: 'Next month',
                onPressed: onNext,
                icon: Icon(LucideIcons.chevronRight, size: 20, color: c.mute),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Row(
            children: [
              for (final day in const ['SUN', 'MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT'])
                Expanded(
                  child: Text(
                    day,
                    textAlign: TextAlign.center,
                    style: pfText(11, weight: w900, color: c.mute),
                  ),
                ),
            ],
          ),
        ),
        for (var row = 0; row < rows; row++)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              children: [
                for (var col = 0; col < 7; col++)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: _cell(context, row * 7 + col, lead, days, previousDays, today),
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _cell(
    BuildContext context,
    int index,
    int lead,
    int days,
    int previousDays,
    DateTime today,
  ) {
    final c = context.pf;
    final dayNumber = index - lead + 1;
    if (dayNumber < 1 || dayNumber > days) {
      final text = dayNumber < 1 ? previousDays + dayNumber : dayNumber - days;
      return SizedBox(
        height: 46,
        child: Center(
          child: Text('$text', style: pfText(14, color: c.mute.withValues(alpha: .6))),
        ),
      );
    }
    final date = DateTime(month.year, month.month, dayNumber);
    final isSelected = date == selected;
    final isToday = date == today;
    final entries = byDay[date] ?? const [];
    final hasIn = entries.any((e) => e.type == TransactionType.cashIn);
    final hasOut = entries.any((e) => e.type == TransactionType.cashOut);
    final fg = isSelected ? c.onBtn : (date.isAfter(today) ? c.mute : c.ink);
    Widget dot(bool on, Color color) => Container(
      width: 5,
      height: 5,
      margin: const EdgeInsets.symmetric(horizontal: 1),
      decoration: BoxDecoration(
        color: on ? (isSelected ? c.onBtn : color) : Colors.transparent,
        shape: BoxShape.circle,
      ),
    );
    return Semantics(
      selected: isSelected,
      button: true,
      label:
          '${DateFormat('d MMMM').format(date)}${entries.isEmpty ? '' : ', ${entries.length} entries'}',
      excludeSemantics: true,
      child: Material(
        color: isSelected ? c.btn : (isToday ? c.soft : Colors.transparent),
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => onSelect(date),
          child: SizedBox(
            height: 46,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('$dayNumber', style: pfText(14, color: fg)),
                const SizedBox(height: 3),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [dot(hasIn, c.pri), dot(hasOut, c.cashOut)],
                ),
              ],
            ),
          ),
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
            child: Text(value, style: pfText(17, weight: w900, color: foreground)),
          ),
        ],
      ),
    );
  }
}
