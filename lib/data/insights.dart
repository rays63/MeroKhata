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

enum BucketKind { day, week, month, quarter }

class TrendBucket {
  TrendBucket(this.label, this.start, this.end, this.kind, this.ordinal);

  /// English label (tests, exports). The UI words it from [kind]/[ordinal].
  final String label;
  final BucketKind kind;

  /// Weekday (1–7, Monday first), week number (1–5), month (1–12) or
  /// quarter (1–4).
  final int ordinal;

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
    this.tags = const [],
  });

  final List<TrendBucket> buckets;
  final double income;
  final double spending;

  /// Top spending categories, largest first.
  final List<Breakdown> categories;

  /// Spending by payment mode, largest first.
  final List<Breakdown> modes;

  /// Top tags by spending, largest first.
  final List<Breakdown> tags;

  /// Share of income kept, or null when there was no income.
  double? get savedRate => income <= 0 ? null : (income - spending) / income;

  /// Tallest bar, for scaling the chart.
  double get peak =>
      buckets.fold(0, (top, b) => max(top, max(b.inflow, b.outflow)));
}

/// Aggregates entries for the Insights tab. Opening balances aren't income,
/// so they're left out of trends and breakdowns (but still count in the
/// month's net flow, which mirrors the ledger).
/// Where a month's money came from and went, by category.
class FlowSummary {
  FlowSummary({required this.income, required this.spending});

  /// Income by category, largest first (share of total income).
  final List<Breakdown> income;

  /// Spending by category, largest first (share of total spending).
  final List<Breakdown> spending;

  double get totalIn => income.fold(0, (s, b) => s + b.amount);
  double get totalOut => spending.fold(0, (s, b) => s + b.amount);

  /// What was kept (positive) or taken from savings (negative).
  double get saved => totalIn - totalOut;
  bool get isEmpty => income.isEmpty && spending.isEmpty;
}

/// Spending added up day by day, this month against last month.
class PaceSummary {
  PaceSummary({
    required this.month,
    required this.days,
    required this.thisMonth,
    required this.lastMonth,
    required this.throughDay,
  });

  final DateTime month;

  /// Days in [month].
  final int days;

  /// Cumulative spending at the end of each day (index 0 = day 1), up to
  /// [throughDay].
  final List<double> thisMonth;

  /// Last month's cumulative spending for every one of its days.
  final List<double> lastMonth;

  /// Today for the current month, the last day for a past month.
  final int throughDay;

  double get spent => thisMonth.isEmpty ? 0 : thisMonth.last;

  /// Last month's spending by the same day of the month.
  double get lastByNow =>
      lastMonth.isEmpty ? 0 : lastMonth[min(throughDay, lastMonth.length) - 1];

  /// Where this month ends at the current rate, or null for a finished month.
  double? get projected =>
      throughDay >= days || throughDay == 0 ? null : spent / throughDay * days;

  bool get isEmpty => spent == 0 && lastMonth.every((v) => v == 0);
}

/// A shop or person paid often (from entry titles, e.g. "QR · Mega Mart").
class Place {
  Place(this.name, this.amount, this.count, this.category);

  final String name;
  final double amount;
  final int count;

  /// The category most of these payments used.
  final String category;
}

class Insights {
  Insights(this.entries, {DateTime? now}) : now = now ?? DateTime.now();

  final List<LedgerTransaction> entries;
  final DateTime now;

  /// Opening balances and transfers aren't income or spending.
  static bool _isOpening(LedgerTransaction entry) => !entry.countsAsFlow;

  bool _inMonth(DateTime date, DateTime month) =>
      date.year == month.year && date.month == month.month;

  List<Breakdown> _rank(Map<String, double> values) {
    final total = values.values.fold(0.0, (s, v) => s + v);
    return (values.entries.toList()..sort((a, b) => b.value.compareTo(a.value)))
        .map((e) => Breakdown(e.key, e.value, total <= 0 ? 0 : e.value / total))
        .toList();
  }

  String _category(LedgerTransaction e) =>
      e.category.trim().isEmpty ? uncategorised : e.category;

  /// Income and spending by category for [month]; transfers and opening
  /// balances left out.
  FlowSummary flow(DateTime month) {
    final ins = <String, double>{}, outs = <String, double>{};
    for (final e in entries) {
      if (_isOpening(e) || !_inMonth(e.occurredAt, month)) continue;
      final map = e.type == TransactionType.cashIn ? ins : outs;
      map[_category(e)] = (map[_category(e)] ?? 0) + e.amount;
    }
    return FlowSummary(income: _rank(ins), spending: _rank(outs));
  }

  /// Day-by-day spending for [month] against the month before.
  PaceSummary pace(DateTime month) {
    final days = DateTime(month.year, month.month + 1, 0).day;
    final previous = DateTime(month.year, month.month - 1);
    final lastDays = DateTime(previous.year, previous.month + 1, 0).day;
    final current = _inMonth(now, month);
    final through = current ? now.day : (month.isAfter(now) ? 0 : days);
    List<double> cumulative(DateTime m, int length) {
      final daily = List<double>.filled(length, 0);
      for (final e in entries) {
        if (_isOpening(e) ||
            e.type != TransactionType.cashOut ||
            !_inMonth(e.occurredAt, m)) {
          continue;
        }
        final day = e.occurredAt.day;
        if (day <= length) daily[day - 1] += e.amount;
      }
      var run = 0.0;
      return [for (final v in daily) run += v];
    }

    return PaceSummary(
      month: month,
      days: days,
      thisMonth: cumulative(month, through),
      lastMonth: cumulative(previous, lastDays),
      throughDay: through,
    );
  }

  /// Where money went most in [month], by entry title.
  List<Place> places(DateTime month, {int limit = 5}) {
    final amount = <String, double>{};
    final count = <String, int>{};
    final cats = <String, Map<String, int>>{};
    for (final e in entries) {
      if (_isOpening(e) ||
          e.type != TransactionType.cashOut ||
          !_inMonth(e.occurredAt, month)) {
        continue;
      }
      final name = e.title.trim();
      if (name.isEmpty) continue;
      amount[name] = (amount[name] ?? 0) + e.amount;
      count[name] = (count[name] ?? 0) + 1;
      final byCat = cats[name] ??= {};
      byCat[_category(e)] = (byCat[_category(e)] ?? 0) + 1;
    }
    final names = amount.keys.toList()
      ..sort((a, b) => amount[b]!.compareTo(amount[a]!));
    return [
      for (final name in names.take(limit))
        Place(
          name,
          amount[name]!,
          count[name]!,
          (cats[name]!.entries.toList()
                ..sort((a, b) => b.value.compareTo(a.value)))
              .first
              .key,
        ),
    ];
  }

  /// Spending in [category] for the six months ending with [month], oldest
  /// first.
  List<(DateTime, double)> categoryMonths(String category, DateTime month) {
    final months = [
      for (var i = 5; i >= 0; i--) DateTime(month.year, month.month - i),
    ];
    return [
      for (final m in months)
        (
          m,
          entries
              .where(
                (e) =>
                    !_isOpening(e) &&
                    e.type == TransactionType.cashOut &&
                    _category(e) == category &&
                    _inMonth(e.occurredAt, m),
              )
              .fold(0.0, (s, e) => s + e.amount),
        ),
    ];
  }

  MonthSummary month(DateTime month) {
    final byDay = <int, List<LedgerTransaction>>{};
    var inflow = 0.0, outflow = 0.0;
    for (final entry in entries) {
      final date = entry.occurredAt;
      if (date.year != month.year || date.month != month.month) continue;
      (byDay[date.day] ??= []).add(entry);
      // Net flow keeps opening balances (they move the balance) but not
      // transfers, which only shift money between the user's accounts.
      if (entry.isTransferLeg) continue;
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
              BucketKind.day,
              day(-i).weekday,
            ),
        ];
      case TrendRange.month:
        // Five 6-day buckets: the last 30 days, ending tomorrow at 00:00.
        return [
          for (var i = 0; i < 5; i++)
            TrendBucket(
              'W${i + 1}',
              day(-29 + i * 6),
              day(-29 + (i + 1) * 6),
              BucketKind.week,
              i + 1,
            ),
        ];
      case TrendRange.quarter:
        return [
          for (var i = 2; i >= 0; i--)
            TrendBucket(
              DateFormat('MMM').format(DateTime(now.year, now.month - i)),
              DateTime(now.year, now.month - i),
              DateTime(now.year, now.month - i + 1),
              BucketKind.month,
              DateTime(now.year, now.month - i).month,
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
                BucketKind.quarter,
                (start.month - 1) ~/ 3 + 1,
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
    final byTag = <String, double>{};
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
        for (final tag in entry.tags) {
          byTag[tag] = (byTag[tag] ?? 0) + entry.amount;
        }
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
      tags: rank(byTag).take(5).toList(),
    );
  }
}
