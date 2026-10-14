import 'dart:math';

import 'package:intl/intl.dart';

import 'models.dart';
import 'report.dart' show uncategorised;

enum TrendRange {
  week('7D'),
  month('30D'),
  quarter('3M'),
  year('1Y');

  const TrendRange(this.label);
  final String label;
}

class TrendBucket {
  TrendBucket(this.label, this.start, this.end);

  final String label;

  /// Inclusive start, exclusive end.
  final DateTime start;
  final DateTime end;
  double inflow = 0;
  double outflow = 0;

  bool contains(DateTime date) => !date.isBefore(start) && date.isBefore(end);
}

class Breakdown {
  Breakdown(this.name, this.amount, this.share);

  final String name;
  final double amount;

  /// 0–1 of total spending.
  final double share;
}

class MonthSummary {
  MonthSummary(this.month, this.byDay, this.inflow, this.outflow);

  final DateTime month;

  /// Day of month → entries that day.
  final Map<int, List<LedgerTransaction>> byDay;
  final double inflow;
  final double outflow;

  double get net => inflow - outflow;

  /// Share of the month's movement that was cash in (0 when nothing moved).
  double get inShare => inflow + outflow == 0 ? 0 : inflow / (inflow + outflow);
}

class TrendSummary {
  TrendSummary({
    required this.buckets,
    required this.income,
    required this.spending,
    required this.categories,
    required this.modes,
  });

  final List<TrendBucket> buckets;
  final double income;
  final double spending;

  /// Top spending categories, largest first.
  final List<Breakdown> categories;

  /// Spending by payment mode, largest first.
  final List<Breakdown> modes;

  /// Share of income kept, or null when there was no income.
  double? get savedRate => income <= 0 ? null : (income - spending) / income;

  /// Tallest bar, for scaling the chart.
  double get peak =>
      buckets.fold(0, (top, b) => max(top, max(b.inflow, b.outflow)));
}

/// Aggregates entries for the Insights tab. Opening balances aren't income,
/// so they're left out of trends and breakdowns (but still count in the
/// month's net flow, which mirrors the ledger).
class Insights {
  Insights(this.entries, {DateTime? now}) : now = now ?? DateTime.now();

  final List<LedgerTransaction> entries;
  final DateTime now;

  static bool _isOpening(LedgerTransaction entry) =>
      entry.category == 'Opening balance';

  MonthSummary month(DateTime month) {
    final byDay = <int, List<LedgerTransaction>>{};
    var inflow = 0.0, outflow = 0.0;
    for (final entry in entries) {
      final date = entry.occurredAt;
      if (date.year != month.year || date.month != month.month) continue;
      (byDay[date.day] ??= []).add(entry);
      if (entry.type == TransactionType.cashIn) {
        inflow += entry.amount;
      } else {
        outflow += entry.amount;
      }
    }
    for (final list in byDay.values) {
      list.sort((a, b) => b.occurredAt.compareTo(a.occurredAt));
    }
    return MonthSummary(
      DateTime(month.year, month.month),
      byDay,
      inflow,
      outflow,
    );
  }

  List<TrendBucket> _buckets(TrendRange range) {
    // Calendar arithmetic (not Duration) so daylight-saving days stay whole.
    DateTime day(int offset) => DateTime(now.year, now.month, now.day + offset);
    switch (range) {
      case TrendRange.week:
        return [
          for (var i = 6; i >= 0; i--)
            TrendBucket(
              DateFormat('E').format(day(-i)).substring(0, 2),
              day(-i),
              day(-i + 1),
            ),
        ];
      case TrendRange.month:
        // Five 6-day buckets: the last 30 days, ending tomorrow at 00:00.
        return [
          for (var i = 0; i < 5; i++)
            TrendBucket('W${i + 1}', day(-29 + i * 6), day(-29 + (i + 1) * 6)),
        ];
      case TrendRange.quarter:
        return [
          for (var i = 2; i >= 0; i--)
            TrendBucket(
              DateFormat('MMM').format(DateTime(now.year, now.month - i)),
              DateTime(now.year, now.month - i),
              DateTime(now.year, now.month - i + 1),
            ),
        ];
      case TrendRange.year:
        final quarterStart = DateTime(now.year, ((now.month - 1) ~/ 3) * 3 + 1);
        return [
          for (var i = 3; i >= 0; i--)
            () {
              final start = DateTime(
                quarterStart.year,
                quarterStart.month - i * 3,
              );
              return TrendBucket(
                'Q${(start.month - 1) ~/ 3 + 1}',
                start,
                DateTime(start.year, start.month + 3),
              );
            }(),
        ];
    }
  }

  TrendSummary trend(TrendRange range) {
    final buckets = _buckets(range);
    final first = buckets.first.start;
    final last = buckets.last.end;
    var income = 0.0, spending = 0.0;
    final byCategory = <String, double>{};
    final byMode = <String, double>{};
    for (final entry in entries) {
      final date = entry.occurredAt;
      if (_isOpening(entry) || date.isBefore(first) || !date.isBefore(last)) {
        continue;
      }
      final bucket = buckets.firstWhere((b) => b.contains(date));
      if (entry.type == TransactionType.cashIn) {
        bucket.inflow += entry.amount;
        income += entry.amount;
      } else {
        bucket.outflow += entry.amount;
        spending += entry.amount;
        final category = entry.category.trim().isEmpty
            ? uncategorised
            : entry.category;
        final mode = entry.paymentMode.trim().isEmpty
            ? 'Not set'
            : entry.paymentMode;
        byCategory[category] = (byCategory[category] ?? 0) + entry.amount;
        byMode[mode] = (byMode[mode] ?? 0) + entry.amount;
      }
    }
    List<Breakdown> rank(Map<String, double> values) =>
        (values.entries.toList()..sort((a, b) => b.value.compareTo(a.value)))
            .map(
              (e) => Breakdown(
                e.key,
                e.value,
                spending <= 0 ? 0 : e.value / spending,
              ),
            )
            .toList();
    return TrendSummary(
      buckets: buckets,
      income: income,
      spending: spending,
      categories: rank(byCategory).take(5).toList(),
      modes: rank(byMode),
    );
  }
}
