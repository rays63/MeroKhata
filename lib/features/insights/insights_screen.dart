import 'dart:math';

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
import '../../widgets/tags.dart';
import '../budgets/budgets_screen.dart';
import 'category_detail_screen.dart';
import 'charts.dart';
import 'insights_layout_screen.dart';

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
  _Chart chart = _Chart.flow;
  bool chartsAsList = false;
  bool boxesAsList = false;

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
    final flow = insights.flow(month);
    final dayEntries =
        selected.year == month.year && selected.month == month.month
        ? summary.byDay[selected.day] ?? const <LedgerTransaction>[]
        : const <LedgerTransaction>[];
    final monthName = DateFormat('MMMM').format(month);
    final budgetScope = book == null
        ? 'currency:$currency'
        : 'account:${book.id}';
    final scope = _Scope(
      budgetScope: budgetScope,
      insights: insights,
      summary: summary,
      flow: flow,
      trend: trend,
      currency: currency,
      monthName: monthName,
      dayEntries: dayEntries,
    );

    final visible = [
      for (final id in store.insightsOrder)
        if (!store.insightsHidden.contains(id)) id,
    ];
    final hidden = store.insightsHidden.length;

    return ListView(
      padding: pagePadding,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                l.insightsTitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: pfText(30, weight: w900, letterSpacing: -.6),
              ),
            ),
            PfSmallButton(
              label: l.insightsCustomize,
              icon: LucideIcons.slidersHorizontal,
              background: c.card,
              foreground: c.ink,
              fontSize: 13,
              onPressed: _customize,
            ),
          ],
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
        _monthBar(c, l),
        for (final id in visible) ...[
          const SizedBox(height: 16),
          ...switch (id) {
            'charts' => _chartsCard(scope, c, l),
            'boxes' => [_boxesCard(scope, c, l)],
            'places' => [_placesCard(scope, c, l)],
            'trends' => _trendsCard(scope, c, l),
            'modes' => [_ByMode(trend: trend, currency: currency)],
            'tags' => [_Tags(trend: trend, currency: currency)],
            _ => const <Widget>[],
          },
        ],
        if (visible.isEmpty) ...[
          const SizedBox(height: 16),
          PfEmptyCard(
            icon: LucideIcons.layoutDashboard,
            title: l.layoutAllHiddenTitle,
            body: l.layoutAllHiddenBody,
            actionLabel: l.insightsCustomize,
            onAction: _customize,
          ),
        ] else if (hidden > 0) ...[
          const SizedBox(height: 12),
          Center(
            child: TextButton.icon(
              onPressed: _customize,
              icon: Icon(LucideIcons.eyeOff, size: 16, color: c.sub),
              label: Text(
                l.layoutHidden(hidden),
                style: pfText(13, weight: w800, color: c.sub),
              ),
            ),
          ),
        ],
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            children: [
              Icon(LucideIcons.arrowLeftRight, size: 14, color: c.blue),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l.insightsTransfersNote,
                  style: pfText(12.5, weight: w700, color: c.blue),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Future<void> _openBudgets(String scope) => Navigator.of(
    context,
  ).push(MaterialPageRoute(builder: (_) => BudgetsScreen(scope: scope)));

  Future<void> _customize() => Navigator.of(
    context,
  ).push(MaterialPageRoute(builder: (_) => const InsightsLayoutScreen()));

  Widget _monthBar(PfColors c, AppLocalizations l) => PfCard(
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
          // One line that shrinks with large text instead of wrapping out of
          // the bar.
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
  );

  Widget _listToggle(bool asList, VoidCallback onTap, PfColors c) {
    final l = context.l10n;
    return IconButton(
      tooltip: asList ? l.chartShowChart : l.chartShowList,
      onPressed: onTap,
      style: IconButton.styleFrom(backgroundColor: c.card2),
      icon: Icon(
        asList ? LucideIcons.chartColumn : LucideIcons.list,
        size: 18,
        color: c.ink,
      ),
    );
  }

  List<Widget> _chartsCard(_Scope s, PfColors c, AppLocalizations l) {
    final head = Row(
      children: [
        Expanded(
          child: PfSegment<_Chart>(
            value: chart,
            height: 38,
            onChanged: (value) => setState(() => chart = value),
            items: [
              (_Chart.flow, l.chartFlow, null),
              (_Chart.calendar, l.chartCalendar, null),
              (_Chart.pace, l.chartPace, null),
            ],
          ),
        ),
        const SizedBox(width: 8),
        _listToggle(chartsAsList, () {
          setState(() => chartsAsList = !chartsAsList);
        }, c),
      ],
    );
    final rule = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(LucideIcons.info, size: 14, color: c.sub),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              l.chartsRule,
              style: pfText(12, weight: w700, color: c.sub),
            ),
          ),
        ],
      ),
    );
    if (chart == _Chart.calendar) {
      return [
        head,
        const SizedBox(height: 14),
        ...chartsAsList ? [_calendarList(s, c, l)] : _calendar(s, c, l),
        const SizedBox(height: 12),
        rule,
      ];
    }
    return [
      head,
      const SizedBox(height: 14),
      PfCard(
        padding: const EdgeInsets.all(16),
        child: chart == _Chart.flow ? _flow(s, c, l) : _pace(s, c, l),
      ),
      const SizedBox(height: 12),
      rule,
    ];
  }

  Widget _flow(_Scope s, PfColors c, AppLocalizations l) {
    final f = s.flow;
    final cur = s.currency;
    final header = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l.flowTitle(s.monthName), style: pfText(16, weight: w900)),
        Text(
          l.flowSub(money(f.totalIn, cur), money(f.totalOut, cur)),
          style: pfText(12.5, weight: w700, color: c.sub),
        ),
      ],
    );
    if (f.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          header,
          const SizedBox(height: 16),
          Text(
            l.flowEmpty(s.monthName),
            style: pfText(14, weight: w700, color: c.sub),
          ),
        ],
      );
    }
    final saved = f.saved;
    final note = saved >= 0
        ? (
            LucideIcons.piggyBank,
            c.gold,
            l.flowSaved(
              money(saved, cur),
              f.totalIn <= 0 ? 0 : (saved / f.totalIn * 100).round(),
            ),
          )
        : (LucideIcons.trendingDown, c.cashOut, l.flowOver(money(-saved, cur)));
    final ins = groupSmall(f.income, l.flowOthers);
    final outs = groupSmall(f.spending, l.flowOthers);
    final body = chartsAsList
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _ListHead(l.flowIncome, money(f.totalIn, cur), c.cashIn),
              for (final b in f.income)
                _ListLine(b.name, money(b.amount, cur), b.share),
              const SizedBox(height: 10),
              _ListHead(l.flowSpending, money(f.totalOut, cur), c.cashOut),
              for (final b in f.spending)
                _ListLine(b.name, money(b.amount, cur), b.share),
            ],
          )
        : FlowChart(
            left: [
              for (final b in ins) FlowNode(b.name, b.amount, c.cashIn),
              if (saved < 0) FlowNode(l.flowFromBalance, -saved, c.cashOut),
            ],
            right: [
              for (final (i, b) in outs.indexed)
                FlowNode(
                  b.name,
                  b.amount,
                  b.name == l.flowOthers
                      ? c.mute
                      : chartColors[i % chartColors.length],
                ),
              if (saved > 0) FlowNode(l.flowSavedNode, saved, c.gold),
            ],
            middleColor: c.btn,
            currency: cur,
            semanticLabel:
                '${l.flowSub(money(f.totalIn, cur), money(f.totalOut, cur))}. ${note.$3}',
          );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        header,
        const SizedBox(height: 14),
        body,
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(note.$1, size: 16, color: note.$2),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                note.$3,
                style: pfText(13, weight: w800, color: note.$2),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _pace(_Scope s, PfColors c, AppLocalizations l) {
    final p = s.insights.pace(month);
    final cur = s.currency;
    final header = Text(l.paceTitle, style: pfText(16, weight: w900));
    if (p.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          header,
          const SizedBox(height: 16),
          Text(
            l.paceEmpty(s.monthName),
            style: pfText(14, weight: w700, color: c.sub),
          ),
        ],
      );
    }
    final store = AppScope.read(context);
    final budget = store.budgetFor(s.budgetScope, null)?.amount;
    final budgetStatus = budget == null
        ? null
        : p.spent > budget
        ? l.paceOverBudget(money(p.spent - budget, cur))
        : (p.projected ?? p.spent) > budget
        ? l.paceGoingOver(
            money(((p.projected ?? p.spent) - budget).roundToDouble(), cur),
          )
        : l.paceWithin(money(budget - p.spent, cur));
    final diff = p.spent - p.lastByNow;
    final status = diff.abs() < 1
        ? l.paceSame
        : diff > 0
        ? l.paceMore(money(diff, cur))
        : l.paceLess(money(-diff, cur));
    final throughDate = DateTime(month.year, month.month, max(1, p.throughDay));
    if (chartsAsList) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          header,
          Text(
            status,
            style: pfText(12.5, weight: w700, color: c.sub),
          ),
          const SizedBox(height: 10),
          _PaceRow(
            cells: [l.paceDay, l.paceThisMonth, l.paceLastMonth],
            header: true,
          ),
          for (var d = 1; d <= p.days; d++)
            if (d % 5 == 0 || d == 1 || d == p.days || d == p.throughDay)
              _PaceRow(
                cells: [
                  '$d',
                  d <= p.thisMonth.length
                      ? money(p.thisMonth[d - 1], cur)
                      : '—',
                  d <= p.lastMonth.length
                      ? money(p.lastMonth[d - 1], cur)
                      : '—',
                ],
              ),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        header,
        const SizedBox(height: 4),
        Text(
          money(p.spent, cur),
          style: pfText(24, weight: w900, color: c.cashOut),
        ),
        Text(
          l.paceSpentBy(DateFormat('d MMM').format(throughDate)),
          style: pfText(12.5, weight: w700, color: c.sub),
        ),
        if (p.projected case final projected?)
          Text(
            l.paceProjected(money(projected.roundToDouble(), cur)),
            style: pfText(12.5, weight: w800, color: c.ink),
          ),
        const SizedBox(height: 12),
        PaceChart(
          pace: p,
          currency: cur,
          budget: budget,
          semanticLabel: [?budgetStatus, status].join('. '),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 14,
          runSpacing: 6,
          children: [
            _Legend(color: c.cashOut, label: l.paceThisMonth),
            _Legend(
              color: c.cashOut.withValues(alpha: .55),
              label: l.paceProjection,
              dashed: true,
            ),
            _Legend(color: c.mute, label: l.paceLastMonth, dashed: true),
            if (budget != null)
              _Legend(color: c.gold, label: l.paceBudget, dashed: true),
          ],
        ),
        const SizedBox(height: 10),
        if (budgetStatus != null)
          Text(
            budgetStatus,
            style: pfText(
              13.5,
              weight: w900,
              color: p.spent > budget!
                  ? c.cashOut
                  : (p.projected ?? p.spent) > budget
                  ? c.gold
                  : c.cashIn,
            ),
          ),
        Text(status, style: pfText(13, weight: w800)),
        if (budget == null) ...[
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: Text(
                  l.paceNoBudgetSet,
                  style: pfText(12, weight: w700, color: c.sub),
                ),
              ),
              PfSmallButton(
                label: l.paceSetBudget,
                height: 36,
                radius: 12,
                fontSize: 13,
                background: c.soft,
                foreground: c.cashIn,
                onPressed: () => _openBudgets(s.budgetScope),
              ),
            ],
          ),
        ],
      ],
    );
  }

  List<Widget> _calendar(_Scope s, PfColors c, AppLocalizations l) => [
    _NetFlowCard(
      summary: s.summary,
      currency: s.currency,
      monthName: s.monthName,
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
          final list = s.summary.byDay[day];
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
            l.insightsTransactionCount(s.dayEntries.length),
            style: pfText(13, weight: w700, color: c.sub),
          ),
        ],
      ),
    ),
    const SizedBox(height: 16),
    if (s.dayEntries.isEmpty)
      PfCard(
        radius: 22,
        padding: const EdgeInsets.all(18),
        child: Text(
          l.insightsNoActivity,
          style: pfText(14, weight: w700, color: c.sub),
        ),
      ),
    for (final entry in s.dayEntries) ...[
      _ActivityRow(
        entry: entry,
        bookName: AppScope.read(context).bookById(entry.bookId)?.name ?? '',
        currency:
            AppScope.read(context).bookById(entry.bookId)?.currency ??
            s.currency,
      ),
      const SizedBox(height: 8),
    ],
  ];

  Widget _calendarList(_Scope s, PfColors c, AppLocalizations l) {
    final days = s.summary.byDay.keys.toList()..sort((a, b) => b - a);
    return PfCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l.calListTitle(s.monthName), style: pfText(16, weight: w900)),
          const SizedBox(height: 8),
          if (days.isEmpty)
            Text(
              l.flowEmpty(s.monthName),
              style: pfText(14, weight: w700, color: c.sub),
            ),
          for (final day in days)
            InkWell(
              onTap: () => setState(() {
                selected = DateTime(month.year, month.month, day);
                chartsAsList = false;
              }),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 9),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${l.dayLabel(DateTime(month.year, month.month, day))} · ${l.insightsTransactionCount(s.summary.byDay[day]!.length)}',
                        style: pfText(13.5, weight: w800),
                      ),
                    ),
                    for (final isIn in [true, false])
                      if (s.summary.byDay[day]!
                              .where(
                                (e) =>
                                    e.countsAsFlow &&
                                    (e.type == TransactionType.cashIn) == isIn,
                              )
                              .fold(0.0, (t, e) => t + e.amount)
                          case final v when v > 0)
                        Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: Text(
                            '${isIn ? '+' : '−'} ${money(v, s.currency)}',
                            style: pfText(
                              13,
                              weight: w900,
                              color: c.amount(isIn),
                            ),
                          ),
                        ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _boxesCard(_Scope s, PfColors c, AppLocalizations l) {
    final f = s.flow;
    final boxes = groupSmall(f.spending, l.flowOthers, minShare: .02, max: 8);
    void open(String category) => Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CategoryDetailScreen(
          category: category,
          month: month,
          bookId: bookId,
        ),
      ),
    );
    return PfCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l.insightsWhereItWent,
                      style: pfText(16, weight: w900),
                    ),
                    Text(
                      l.boxesTap,
                      style: pfText(12, weight: w700, color: c.sub),
                    ),
                  ],
                ),
              ),
              _listToggle(boxesAsList, () {
                setState(() => boxesAsList = !boxesAsList);
              }, c),
            ],
          ),
          const SizedBox(height: 12),
          if (f.spending.isEmpty)
            Text(
              l.flowEmpty(s.monthName),
              style: pfText(14, weight: w700, color: c.sub),
            )
          else if (boxesAsList)
            for (final b in f.spending)
              InkWell(
                onTap: () => open(b.name),
                child: _ListLine(b.name, money(b.amount, s.currency), b.share),
              )
          else
            CategoryBoxes(
              items: boxes,
              currency: s.currency,
              othersLabel: l.flowOthers,
              onOpen: open,
              badge: (category) {
                final b = AppScope.read(
                  context,
                ).budgetFor(s.budgetScope, category);
                if (b == null || b.amount <= 0) return null;
                final spent = f.spending
                    .where((x) => x.name == category)
                    .fold(0.0, (t, x) => t + x.amount);
                final share = spent / b.amount;
                return share > 1
                    ? l.budgetBadgeOver
                    : share >= .8
                    ? '${(share * 100).round()}%'
                    : null;
              },
            ),
        ],
      ),
    );
  }

  Widget _placesCard(_Scope s, PfColors c, AppLocalizations l) {
    final places = s.insights.places(month);
    final top = places.isEmpty ? 1.0 : places.first.amount;
    return PfCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l.placesTitle, style: pfText(16, weight: w900)),
          Text(
            l.placesSub(s.monthName),
            style: pfText(12, weight: w700, color: c.sub),
          ),
          const SizedBox(height: 10),
          if (places.isEmpty)
            Text(
              l.placesEmpty(s.monthName),
              style: pfText(14, weight: w700, color: c.sub),
            ),
          for (final (i, p) in places.indexed)
            InkWell(
              onTap: () {
                AppScope.read(context).addRecentSearch(p.name);
                openSearch(context);
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    SizedBox(
                      width: 22,
                      child: Text(
                        '${i + 1}',
                        style: pfText(14, weight: w900, color: c.sub),
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  p.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: pfText(14, weight: w800),
                                ),
                              ),
                              Text(
                                money(p.amount, s.currency),
                                style: pfText(14, weight: w900),
                              ),
                            ],
                          ),
                          Text(
                            l.placesMeta(p.count, p.category),
                            style: pfText(11.5, weight: w700, color: c.sub),
                          ),
                          const SizedBox(height: 4),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(3),
                            child: LinearProgressIndicator(
                              value: p.amount / top,
                              minHeight: 5,
                              color: c.btn,
                              backgroundColor: c.card2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  List<Widget> _trendsCard(_Scope s, PfColors c, AppLocalizations l) => [
    Padding(
      padding: const EdgeInsets.fromLTRB(4, 6, 4, 0),
      child: Text(l.insightsTrends, style: pfText(18, weight: w900)),
    ),
    const SizedBox(height: 16),
    PfSegment<TrendRange>(
      value: range,
      height: 36,
      onChanged: (value) => setState(() => range = value),
      items: [for (final r in TrendRange.values) (r, _rangeLabel(l, r), null)],
    ),
    const SizedBox(height: 16),
    Row(
      children: [
        Expanded(
          child: _Figure(
            label: l.insightsIncome,
            value: money(s.trend.income, s.currency),
            color: c.cashIn,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _Figure(
            label: s.trend.savedRate == null
                ? l.insightsSpending
                : l.insightsSpendingSaved((s.trend.savedRate! * 100).round()),
            value: money(s.trend.spending, s.currency),
            color: c.cashOut,
          ),
        ),
      ],
    ),
    const SizedBox(height: 16),
    _TrendChart(trend: s.trend, currency: s.currency),
  ];
}

enum _Chart { flow, calendar, pace }

/// What every card on the screen is drawn from, for the chosen scope.
class _Scope {
  const _Scope({
    required this.budgetScope,
    required this.insights,
    required this.summary,
    required this.flow,
    required this.trend,
    required this.currency,
    required this.monthName,
    required this.dayEntries,
  });

  /// `currency:NPR` or `account:<id>`, for budgets.
  final String budgetScope;
  final Insights insights;
  final MonthSummary summary;
  final FlowSummary flow;
  final TrendSummary trend;
  final String currency;
  final String monthName;
  final List<LedgerTransaction> dayEntries;
}

class _ListHead extends StatelessWidget {
  const _ListHead(this.label, this.total, this.color);

  final String label;
  final String total;
  final Color color;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      children: [
        Expanded(
          child: Text(label, style: pfText(14, weight: w900)),
        ),
        Text(
          total,
          style: pfText(14, weight: w900, color: color),
        ),
      ],
    ),
  );
}

class _ListLine extends StatelessWidget {
  const _ListLine(this.name, this.amount, this.share);

  final String name;
  final String amount;
  final double share;

  @override
  Widget build(BuildContext context) {
    final c = context.pf;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(categoryIcon(name), size: 15, color: c.sub),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: pfText(13.5, weight: w700),
            ),
          ),
          Text.rich(
            TextSpan(
              text: amount,
              children: [
                TextSpan(
                  text: ' · ${(share * 100).round()}%',
                  style: TextStyle(color: c.mute),
                ),
              ],
            ),
            style: pfText(13.5, weight: w800),
          ),
        ],
      ),
    );
  }
}

class _PaceRow extends StatelessWidget {
  const _PaceRow({required this.cells, this.header = false});

  final List<String> cells;
  final bool header;

  @override
  Widget build(BuildContext context) {
    final c = context.pf;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          for (var i = 0; i < cells.length; i++)
            Expanded(
              flex: i == 0 ? 1 : 3,
              child: Text(
                cells[i],
                textAlign: i == 0 ? TextAlign.left : TextAlign.right,
                style: header
                    ? pfText(11, weight: w900, color: c.sub)
                    : pfText(13, weight: w800),
              ),
            ),
        ],
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({
    required this.color,
    required this.label,
    this.dashed = false,
  });

  final Color color;
  final String label;
  final bool dashed;

  @override
  Widget build(BuildContext context) {
    final c = context.pf;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            for (var i = 0; i < (dashed ? 2 : 1); i++) ...[
              if (i > 0) const SizedBox(width: 3),
              Container(
                width: dashed ? 7 : 16,
                height: 3,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: pfText(11.5, weight: w700, color: c.sub),
        ),
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

/// Top tags by spending in the trend range; each opens its summary.
class _Tags extends StatelessWidget {
  const _Tags({required this.trend, required this.currency});

  final TrendSummary trend;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final c = context.pf;
    final l = context.l10n;
    return PfCard(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l.insightsTagsTitle,
                  style: pfText(16, weight: w900),
                ),
              ),
              TextButton(
                onPressed: () => openManageTags(context),
                child: Text(
                  l.seeAll,
                  style: pfText(13.5, weight: w800, color: c.cashIn),
                ),
              ),
            ],
          ),
          if (trend.tags.isEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text(
                l.insightsTagsEmpty,
                style: pfText(14, weight: w700, color: c.sub),
              ),
            ),
          for (final tag in trend.tags)
            InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => openTag(context, tag.name),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        tagLabel(tag.name),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: pfText(14.5, weight: w800, color: c.tag),
                      ),
                    ),
                    Text(money(tag.amount, currency), style: pfText(14)),
                    const SizedBox(width: 4),
                    Icon(LucideIcons.chevronRight, size: 16, color: c.mute),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
