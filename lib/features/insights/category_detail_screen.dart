import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../app/nav.dart';
import '../../core/format.dart';
import '../../data/app_store.dart';
import '../../data/insights.dart';
import '../../data/models.dart';
import '../../l10n/l10n.dart';
import '../../theme/tokens.dart';
import '../../widgets/category_icons.dart';
import '../../widgets/entry_row.dart';
import '../../widgets/pf.dart';
import '../budgets/budget_edit_screen.dart';
import 'charts.dart';

/// One spending category: this month against its 6-month average, and the
/// month's entries.
class CategoryDetailScreen extends StatefulWidget {
  const CategoryDetailScreen({
    super.key,
    required this.category,
    required this.month,
    this.bookId,
  });

  final String category;
  final DateTime month;

  /// Null = every account in the default currency.
  final String? bookId;

  @override
  State<CategoryDetailScreen> createState() => _CategoryDetailScreenState();
}

class _CategoryDetailScreenState extends State<CategoryDetailScreen> {
  bool asList = false;

  @override
  Widget build(BuildContext context) {
    final store = AppScope.watch(context);
    final c = context.pf;
    final l = context.l10n;
    final book = widget.bookId == null ? null : store.bookById(widget.bookId!);
    final currency = book?.currency ?? store.defaultCurrency;
    final ids = book != null
        ? {book.id}
        : {
            for (final b in store.books)
              if (b.currency == currency) b.id,
          };
    final entries = store.transactions
        .where((e) => ids.contains(e.bookId))
        .toList();
    final months = Insights(
      entries,
    ).categoryMonths(widget.category, widget.month);
    final current = months.last.$2;
    final earlier = months.take(5).where((m) => m.$2 > 0).map((m) => m.$2);
    final average = earlier.isEmpty
        ? 0.0
        : earlier.reduce((a, b) => a + b) / earlier.length;
    final diff = current - average;
    final monthName = DateFormat('MMMM').format(widget.month);
    final budgetScope = book == null
        ? 'currency:$currency'
        : 'account:${book.id}';
    final budget = store.budgetFor(budgetScope, widget.category)?.amount;
    final shown = [
      for (final e in store.entriesNewestFirst)
        if (ids.contains(e.bookId) &&
            e.countsAsFlow &&
            e.type == TransactionType.cashOut &&
            e.category == widget.category &&
            e.occurredAt.year == widget.month.year &&
            e.occurredAt.month == widget.month.month)
          e,
    ];
    final groups = <(DateTime, List<LedgerTransaction>)>[];
    for (final e in shown) {
      if (groups.isEmpty || !sameDay(groups.last.$1, e.occurredAt)) {
        groups.add((e.occurredAt, [e]));
      } else {
        groups.last.$2.add(e);
      }
    }
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: pagePadding,
          children: [
            PfHeader(
              title: widget.category,
              subtitle:
                  '${book?.name ?? l.insightsAllBooks(currency)} · $currency',
            ),
            const SizedBox(height: 16),
            PfCard(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  PfIconTile(
                    icon: entryIcon(widget.category),
                    background: c.outSoft,
                    foreground: c.cashOut,
                    size: 48,
                    radius: 16,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          DateFormat('MMMM y').format(widget.month),
                          style: pfText(12.5, weight: w800, color: c.sub),
                        ),
                        Text(
                          money(current, currency),
                          style: pfText(24, weight: w900),
                        ),
                        if (average > 0)
                          Text(
                            diff.abs() < average * .05
                                ? l.catUsual
                                : diff > 0
                                ? l.catMore(money(diff, currency))
                                : l.catLess(money(-diff, currency)),
                            style: pfText(
                              12.5,
                              weight: w800,
                              color: diff > average * .05
                                  ? c.cashOut
                                  : c.cashIn,
                            ),
                          ),
                        if (average > 0)
                          Text(
                            '${l.catAverage} ${money(average, currency)}',
                            style: pfText(12, weight: w700, color: c.sub),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            PfCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          l.catLast6,
                          style: pfText(15, weight: w900),
                        ),
                      ),
                      IconButton(
                        tooltip: asList ? l.chartShowChart : l.chartShowList,
                        onPressed: () => setState(() => asList = !asList),
                        icon: Icon(
                          asList ? Icons.bar_chart_rounded : Icons.list_rounded,
                          size: 20,
                          color: c.ink,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (asList)
                    for (final (m, v) in months.reversed)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                DateFormat('MMMM y').format(m),
                                style: pfText(13.5, weight: w700),
                              ),
                            ),
                            Text(
                              money(v, currency),
                              style: pfText(13.5, weight: w900),
                            ),
                          ],
                        ),
                      )
                  else
                    MonthBars(
                      months: [
                        for (final (m, v) in months)
                          (DateFormat('MMM').format(m), v),
                      ],
                      average: average,
                      budget: budget,
                      color: c.cashOut,
                      currency: currency,
                      semanticLabel:
                          '${l.catLast6}: ${[for (final (m, v) in months) '${DateFormat('MMM').format(m)} ${money(v, currency)}'].join(', ')}',
                    ),
                  const SizedBox(height: 6),
                  if (budget != null)
                    Text(
                      '— ${l.catBudgetLine(money(budget, currency))}',
                      style: pfText(11.5, weight: w800, color: c.gold),
                    )
                  else
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            l.catNoBudget,
                            style: pfText(12, weight: w700, color: c.sub),
                          ),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => BudgetEditScreen(
                                scope: budgetScope,
                                category: widget.category,
                              ),
                            ),
                          ),
                          child: Text(
                            l.paceSetBudget,
                            style: pfText(13, weight: w900, color: c.cashIn),
                          ),
                        ),
                      ],
                    ),
                  if (!asList && average > 0) ...[
                    const SizedBox(height: 6),
                    Text(
                      '- - ${l.catAverage} ${money(average, currency)}',
                      style: pfText(11.5, weight: w800, color: c.sub),
                    ),
                  ],
                ],
              ),
            ),
            if (shown.any((e) => e.subcategory.isNotEmpty)) ...[
              const SizedBox(height: 16),
              PfSectionLabel(l.subcategories),
              const SizedBox(height: 8),
              PfCard(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Column(
                  children: [
                    for (final (name, amount) in () {
                      final totals = <String, double>{};
                      for (final e in shown) {
                        totals[e.subcategory] =
                            (totals[e.subcategory] ?? 0) + e.amount;
                      }
                      return (totals.entries.toList()
                            ..sort((a, b) => b.value.compareTo(a.value)))
                          .map((e) => (e.key, e.value));
                    }())
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                name.isEmpty
                                    ? l.subNone(widget.category)
                                    : subcategoryLabel(widget.category, name),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: pfText(13.5, weight: w700),
                              ),
                            ),
                            Text.rich(
                              TextSpan(
                                text: money(amount, currency),
                                children: [
                                  TextSpan(
                                    text:
                                        ' · ${current <= 0 ? 0 : (amount / current * 100).round()}%',
                                    style: TextStyle(color: c.mute),
                                  ),
                                ],
                              ),
                              style: pfText(13.5, weight: w800),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),
            PfSectionLabel(l.catEntries(monthName)),
            const SizedBox(height: 8),
            if (shown.isEmpty)
              PfEmptyCard(
                icon: entryIcon(widget.category),
                title: widget.category,
                body: l.catNone(widget.category, monthName),
              ),
            for (final (day, items) in groups) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 4, 4, 6),
                child: Text(
                  l.dayLabel(day),
                  style: pfText(13, weight: w800, color: c.sub),
                ),
              ),
              EntryGroupCard(
                children: [
                  for (final e in items)
                    EntryRow(
                      entry: e,
                      currency: currency,
                      account: book == null
                          ? store.bookById(e.bookId)?.name
                          : null,
                      showBalance: false,
                      onTap: () => openEntry(context, e.id),
                    ),
                ],
              ),
              const SizedBox(height: 12),
            ],
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
