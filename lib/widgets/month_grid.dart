import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../theme/tokens.dart';
import 'pf.dart';

/// Sunday-first month grid with a green (cash in) and red (cash out) dot
/// under days that had activity. Used by Calendar and Insights.
class MonthGrid extends StatelessWidget {
  const MonthGrid({
    super.key,
    required this.month,
    required this.selected,
    required this.activity,
    required this.onSelect,
    this.onPrev,
    this.onNext,
    this.showOutsideDays = false,
    this.shortWeekdays = false,
  });

  final DateTime month;
  final DateTime selected;

  /// Day of month → (had cash in, had cash out).
  final (bool, bool) Function(int day) activity;
  final ValueChanged<DateTime> onSelect;

  /// When set, a "‹ October 2026 ›" header is drawn above the grid.
  final VoidCallback? onPrev;
  final VoidCallback? onNext;

  /// Greyed-out trailing/leading days from the neighbouring months.
  final bool showOutsideDays;

  /// "S M T…" instead of "SUN MON TUE…".
  final bool shortWeekdays;

  @override
  Widget build(BuildContext context) {
    final c = context.pf;
    final today = DateUtils.dateOnly(DateTime.now());
    final days = DateUtils.getDaysInMonth(month.year, month.month);
    final lead = DateTime(month.year, month.month).weekday % 7;
    final previousDays = DateUtils.getDaysInMonth(month.year, month.month - 1);
    final rows = ((lead + days) / 7).ceil();
    final weekdays = shortWeekdays
        ? const ['S', 'M', 'T', 'W', 'T', 'F', 'S']
        : const ['SUN', 'MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT'];

    Widget cell(int index) {
      final dayNumber = index - lead + 1;
      if (dayNumber < 1 || dayNumber > days) {
        if (!showOutsideDays) return const SizedBox(height: 46);
        final text = dayNumber < 1
            ? previousDays + dayNumber
            : dayNumber - days;
        return SizedBox(
          height: 46,
          child: Center(
            child: Text(
              '$text',
              style: pfText(14, color: c.mute.withValues(alpha: .6)),
            ),
          ),
        );
      }
      final date = DateTime(month.year, month.month, dayNumber);
      final isSelected = date == selected;
      final isToday = date == today;
      final (hasIn, hasOut) = activity(dayNumber);
      final fg = isSelected
          ? c.onBtn
          : (date.isAfter(today) && showOutsideDays ? c.mute : c.ink);
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
        label: [
          DateFormat('d MMMM').format(date),
          if (hasIn) 'cash in',
          if (hasOut) 'cash out',
        ].join(', '),
        excludeSemantics: true,
        child: Material(
          color: isSelected
              ? c.btn
              : (isToday && showOutsideDays ? c.soft : Colors.transparent),
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

    // Day cells have a fixed height; cap text growth so numbers and dots fit.
    return MediaQuery.withClampedTextScaling(
      maxScaleFactor: 1.4,
      child: Column(
        children: [
          if (onPrev != null || onNext != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(6, 0, 6, 14),
              child: Row(
                children: [
                  IconButton(
                    tooltip: 'Previous month',
                    onPressed: onPrev,
                    icon: Icon(
                      LucideIcons.chevronLeft,
                      size: 20,
                      color: c.mute,
                    ),
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
                    icon: Icon(
                      LucideIcons.chevronRight,
                      size: 20,
                      color: c.mute,
                    ),
                  ),
                ],
              ),
            ),
          Padding(
            padding: EdgeInsets.only(bottom: shortWeekdays ? 8 : 6),
            child: Row(
              children: [
                for (final day in weekdays)
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
                        child: cell(row * 7 + col),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
