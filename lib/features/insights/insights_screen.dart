import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../app/nav.dart';
import '../../core/format.dart';
import '../../data/app_store.dart';
import '../../data/insights.dart';
import '../../data/report.dart' show uncategorised;
import '../../data/models.dart';
import '../../l10n/l10n.dart';
import '../../theme/tokens.dart';
import '../../widgets/category_icons.dart';
import '../../widgets/month_grid.dart';
import '../../widgets/pf.dart';

String _rangeLabel(AppLocalizations l, TrendRange range) => switch (range) {
  TrendRange.week => l.insightsRange7d,
  TrendRange.month => l.insightsRange30d,
  TrendRange.quarter => l.insightsRange3m,
  TrendRange.year => l.insightsRange1y,
};

/// Month view (net flow, calendar, day activity) plus trends and spending
/// breakdowns, for all books in the home currency or a single book.
class InsightsScreen extends StatefulWidget {
  const InsightsScreen({super.key});

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen> {
  /// Null means every book in the home currency.
  String? bookId;
  late DateTime month = _thisMonth();
  late DateTime selected = DateUtils.dateOnly(DateTime.now());
  TrendRange range = TrendRange.month;

  static DateTime _thisMonth() =>
      DateTime(DateTime.now().year, DateTime.now().month);

  void _shiftMonth(int delta) => setState(() {
    month = DateTime(month.year, month.month + delta);
    final now = DateTime.now();
    selected = month == _thisMonth() ? DateUtils.dateOnly(now) : month;
  });

  void _today() => setState(() {
    month = _thisMonth();
    selected = DateUtils.dateOnly(DateTime.now());
  });

  @override
  Widget build(BuildContext context) {
    final store = AppScope.watch(context);
    final c = context.pf;
    final l = context.l10n;
    final home = store.defaultCurrency;
    final homeBooks = store.booksByRecent
        .where((book) => book.currency == home)
        .toList();
    final book = bookId == null ? null : store.bookById(bookId!);
    final scopeIds = book == null
        ? homeBooks.map((b) => b.id).toSet()
        : {book.id};
    final currency = book?.currency ?? home;
    final entries = store.transactions
        .where((entry) => scopeIds.contains(entry.bookId))
        .toList();
    final insights = Insights(entries);
    final summary = insights.month(month);
    final trend = insights.trend(range);
    final dayEntries =
        selected.year == month.year && selected.month == month.month
        ? summary.byDay[selected.day] ?? const <LedgerTransaction>[]
        : const <LedgerTransaction>[];
    final monthName = DateFormat('MMMM').format(month);

    return ListView(
      padding: pagePadding,
      children: [
        Text(
          l.insightsTitle,
          style: pfText(30, weight: w900, letterSpacing: -.6),
        ),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          clipBehavior: Clip.none,
          child: Row(
            children: [
              _ScopeChip(
                label: l.insightsAllBooks(home),
                selected: book == null,
                onTap: () => setState(() => bookId = null),
              ),
              for (final b in store.booksByRecent) ...[
                const SizedBox(width: 8),
                _ScopeChip(
                  label: b.currency == home
                      ? b.name
                      : '${b.name} · ${b.currency}',
                  selected: book?.id == b.id,
                  onTap: () => setState(() => bookId = b.id),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 16),
        PfCard(
          radius: 26,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 60),
            child: Row(
              children: [
                IconButton(
                  tooltip: l.insightsPrevMonth,
                  onPressed: () => _shiftMonth(-1),
                  icon: Icon(LucideIcons.chevronLeft, size: 22, color: c.ink),
                ),
                // One line that shrinks with large text instead of wrapping
                // out of the bar.
                Expanded(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      DateFormat('MMMM y').format(month),
                      maxLines: 1,
                      style: pfText(18, weight: w900),
                    ),
                  ),
                ),
                TextButton(
                  onPressed: _today,
                  child: Text(
                    l.today,
                    style: pfText(
                      14,
                      weight: w900,
                      color: c.cashIn,
                      letterSpacing: .8,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: l.insightsNextMonth,
                  onPressed: () => _shiftMonth(1),
                  icon: Icon(LucideIcons.chevronRight, size: 22, color: c.ink),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        _NetFlowCard(
          summary: summary,
          currency: currency,
          monthName: monthName,
        ),
        const SizedBox(height: 16),
        PfCard(
          radius: 28,
          padding: const EdgeInsets.fromLTRB(10, 16, 10, 10),
          child: MonthGrid(
            month: month,
            selected: selected,
            shortWeekdays: true,
            activity: (day) {
              final list = summary.byDay[day];
              if (list == null) return (false, false);
              return (
                list.any((e) => e.type == TransactionType.cashIn),
                list.any((e) => e.type == TransactionType.cashOut),
              );
            },
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
                child: Text(
                  l.insightsActivityOn(DateFormat('MMMM d').format(selected)),
                  style: pfText(16, weight: w900),
                ),
              ),
              Text(
                l.insightsTransactionCount(dayEntries.length),
                style: pfText(13, weight: w700, color: c.sub),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (dayEntries.isEmpty)
          PfCard(
            radius: 22,
            padding: const EdgeInsets.all(18),
            child: Text(
              l.insightsNoActivity,
              style: pfText(14, weight: w700, color: c.sub),
            ),
          ),
        for (final entry in dayEntries) ...[
          _ActivityRow(
            entry: entry,
            bookName: store.bookById(entry.bookId)?.name ?? '',
            currency: store.bookById(entry.bookId)?.currency ?? currency,
          ),
          const SizedBox(height: 8),
        ],
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 6, 4, 0),
          child: Text(l.insightsTrends, style: pfText(18, weight: w900)),
        ),
        const SizedBox(height: 16),
        PfSegment<TrendRange>(
          value: range,
          height: 36,
          onChanged: (value) => setState(() => range = value),
          items: [
            for (final r in TrendRange.values) (r, _rangeLabel(l, r), null),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _Figure(
                label: l.insightsIncome,
                value: money(trend.income, currency),
                color: c.cashIn,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _Figure(
                label: trend.savedRate == null
                    ? l.insightsSpending
                    : l.insightsSpendingSaved((trend.savedRate! * 100).round()),
                value: money(trend.spending, currency),
                color: c.cashOut,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _TrendChart(trend: trend, currency: currency),
        const SizedBox(height: 16),
        _WhereItWent(trend: trend, currency: currency),
        const SizedBox(height: 16),
        _ByMode(trend: trend, currency: currency),
        const SizedBox(height: 24),
      ],
    );
  }
}

class _ScopeChip extends StatelessWidget {
  const _ScopeChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.pf;
    return Semantics(
      selected: selected,
      button: true,
      child: Material(
        color: selected ? c.ink : c.card,
        shape: const StadiumBorder(),
        child: InkWell(
          customBorder: const StadiumBorder(),
          onTap: onTap,
          child: Container(
            height: 38,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            alignment: Alignment.center,
            child: Text(
              label,
              style: pfText(13, color: selected ? c.bg : c.sub),
            ),
          ),
        ),
      ),
    );
  }
}

class _NetFlowCard extends StatelessWidget {
  const _NetFlowCard({
    required this.summary,
    required this.currency,
    required this.monthName,
  });

  final MonthSummary summary;
  final String currency;
  final String monthName;

  @override
  Widget build(BuildContext context) {
    final c = context.pf;
    final l = context.l10n;
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
      decoration: BoxDecoration(
        color: c.hero,
        borderRadius: BorderRadius.circular(26),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              balanceMoney(summary.net, currency),
              style: pfText(
                28,
                weight: w900,
                color: Colors.white,
                letterSpacing: -.5,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            l.insightsNetFlow(monthName),
            style: pfText(13, weight: w700, color: PfColors.heroLabel),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: summary.inShare,
              minHeight: 8,
              color: Colors.white,
              backgroundColor: Colors.white.withValues(alpha: .22),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(LucideIcons.arrowUp, size: 14, color: Colors.white),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  money(summary.inflow, currency),
                  style: pfText(13.5, weight: w900, color: Colors.white),
                ),
              ),
              const Icon(
                LucideIcons.arrowDown,
                size: 14,
                color: Color(0xFFFFD6D6),
              ),
              const SizedBox(width: 6),
              Text(
                money(summary.outflow, currency),
                style: pfText(
                  13.5,
                  weight: w900,
                  color: const Color(0xFFFFD6D6),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActivityRow extends StatelessWidget {
  const _ActivityRow({
    required this.entry,
    required this.bookName,
    required this.currency,
  });

  final LedgerTransaction entry;
  final String bookName;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final c = context.pf;
    final isIn = entry.type == TransactionType.cashIn;
    final color = c.amount(isIn);
    return PfCard(
      radius: 22,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      onTap: () => openEntry(context, entry.id),
      child: Row(
        children: [
          PfIconTile(
            icon: entryIcon(entry.category),
            background: c.amountSoft(isIn),
            foreground: color,
            size: 44,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              entry.title,
              style: pfText(15),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            flex: 0,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 96),
              child: PfBadge(label: bookName, fontSize: 11),
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            flex: 0,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                signedMoney(entry.signedAmount, currency),
                style: pfText(14.5, weight: w900, color: color),
              ),
            ),
          ),
        ],
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
    return PfCard(
      radius: 22,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: pfText(12.5, color: c.sub),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: pfText(20, weight: w900, color: color),
            ),
          ),
        ],
      ),
    );
  }
}

class _TrendChart extends StatelessWidget {
  const _TrendChart({required this.trend, required this.currency});

  final TrendSummary trend;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final c = context.pf;
    final l = context.l10n;
    final peak = trend.peak;
    double fraction(double value) =>
        peak <= 0 ? .02 : (value / peak).clamp(.02, 1);
    Widget legend(Color color, String label) => Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: pfText(11.5, color: c.sub)),
      ],
    );
    return PfCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l.insightsCashFlowTrend,
                  style: pfText(16, weight: w900),
                ),
              ),
              legend(c.pri, l.insightsLegendIn),
              const SizedBox(width: 10),
              legend(c.cashOut, l.insightsLegendOut),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 150,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (final bucket in trend.buckets) ...[
                  if (bucket != trend.buckets.first) const SizedBox(width: 8),
                  Expanded(
                    child: Semantics(
                      label: l.insightsBarSemantics(
                        _bucketLabel(l, bucket),
                        money(bucket.inflow, currency),
                        money(bucket.outflow, currency),
                      ),
                      excludeSemantics: true,
                      child: Column(
                        children: [
                          Expanded(
                            child: LayoutBuilder(
                              builder: (context, box) => Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  _Bar(
                                    height:
                                        box.maxHeight * fraction(bucket.inflow),
                                    width: box.maxWidth * .42,
                                    color: c.pri,
                                  ),
                                  const SizedBox(width: 3),
                                  _Bar(
                                    height:
                                        box.maxHeight *
                                        fraction(bucket.outflow),
                                    width: box.maxWidth * .42,
                                    color: c.cashOut,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _bucketLabel(l, bucket),
                            style: pfText(11, color: c.sub),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar({required this.height, required this.width, required this.color});

  final double height;
  final double width;
  final Color color;

  @override
  Widget build(BuildContext context) => AnimatedContainer(
    duration: const Duration(milliseconds: 260),
    curve: Curves.easeOutCubic,
    width: width,
    height: height,
    decoration: BoxDecoration(
      color: color,
      borderRadius: const BorderRadius.vertical(
        top: Radius.circular(6),
        bottom: Radius.circular(3),
      ),
    ),
  );
}

class _WhereItWent extends StatelessWidget {
  const _WhereItWent({required this.trend, required this.currency});

  final TrendSummary trend;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final c = context.pf;
    final l = context.l10n;
    return PfCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l.insightsWhereItWent, style: pfText(16, weight: w900)),
          if (trend.categories.isEmpty) ...[
            const SizedBox(height: 14),
            Text(
              l.insightsNoSpending,
              style: pfText(14, weight: w700, color: c.sub),
            ),
          ],
          for (var i = 0; i < trend.categories.length; i++) ...[
            const SizedBox(height: 14),
            Row(
              children: [
                Icon(
                  categoryIcon(trend.categories[i].name),
                  size: 15,
                  color: c.sub,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    displayGroupName(l, trend.categories[i].name),
                    style: pfText(14),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text.rich(
                  TextSpan(
                    text: money(trend.categories[i].amount, currency),
                    children: [
                      TextSpan(
                        text:
                            ' · ${(trend.categories[i].share * 100).round()}%',
                        style: pfText(14, color: c.mute),
                      ),
                    ],
                  ),
                  style: pfText(14),
                ),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: trend.categories[i].share.clamp(.04, 1),
                minHeight: 8,
                backgroundColor: c.card2,
                color: chartColors[i % chartColors.length],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ByMode extends StatelessWidget {
  const _ByMode({required this.trend, required this.currency});

  final TrendSummary trend;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final c = context.pf;
    final l = context.l10n;
    return PfCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l.insightsByMode, style: pfText(16, weight: w900)),
          const SizedBox(height: 12),
          if (trend.modes.isEmpty)
            Text(
              l.insightsNoSpending,
              style: pfText(14, weight: w700, color: c.sub),
            )
          else
            LayoutBuilder(
              builder: (context, box) => Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final mode in trend.modes)
                    Container(
                      width: (box.maxWidth - 8) / 2,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: c.card2,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            displayGroupName(l, mode.name),
                            style: pfText(12, color: c.sub),
                            overflow: TextOverflow.ellipsis,
                          ),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              money(mode.amount, currency),
                              style: pfText(15, weight: w900),
                            ),
                          ),
                        ],
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

/// Chart axis label in the current language.
String _bucketLabel(AppLocalizations l, TrendBucket bucket) =>
    switch (bucket.kind) {
      BucketKind.day => l.weekdaysTwo.split(',')[bucket.ordinal % 7],
      BucketKind.week => l.insightsWeekBucket(bucket.ordinal),
      // Month names follow the app's date format (English), like dates.
      BucketKind.month => bucket.label,
      BucketKind.quarter => l.insightsQuarterBucket(bucket.ordinal),
    };

/// Placeholder group names from the data layer, translated for display.
String displayGroupName(AppLocalizations l, String name) => switch (name) {
  uncategorised => l.uncategorised,
  'Not set' => l.notSet,
  _ => name,
};
