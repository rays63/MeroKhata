import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../app/nav.dart';
import '../../core/format.dart';
import '../../data/app_store.dart';
import '../../data/models.dart';
import '../../l10n/l10n.dart';
import '../../theme/tokens.dart';
import '../../widgets/category_icons.dart';
import '../../widgets/entry_row.dart';
import '../../widgets/option_sheet.dart';
import '../../widgets/pf.dart';
import '../reports/report_screen.dart';

enum DateRange {
  today('Today'),
  week('Last 7 days'),
  month('This month'),
  all('All time');

  const DateRange(this.label);

  /// English label for data and exports; use [localizedLabel] in the UI.
  final String label;

  String localizedLabel(AppLocalizations l) => switch (this) {
    DateRange.today => l.today,
    DateRange.week => l.ledgerRangeWeek,
    DateRange.month => l.ledgerRangeMonth,
    DateRange.all => l.ledgerRangeAll,
  };

  bool contains(DateTime date, DateTime now) {
    final today = DateTime(now.year, now.month, now.day);
    return switch (this) {
      DateRange.today => sameDay(date, now),
      DateRange.week => !date.isBefore(today.subtract(const Duration(days: 6))),
      DateRange.month => date.year == now.year && date.month == now.month,
      DateRange.all => true,
    };
  }
}

/// The ledger: filters, summary, entries grouped by day with a running
/// balance, and Cash in / Cash out pinned to the bottom.
class BookDetailScreen extends StatefulWidget {
  const BookDetailScreen({super.key, required this.bookId});

  final String bookId;

  static String routeName(String bookId) => 'book/$bookId';

  /// Named so flows like import can return to this exact book.
  static Route<void> route(String bookId) => MaterialPageRoute(
    settings: RouteSettings(name: routeName(bookId)),
    builder: (_) => BookDetailScreen(bookId: bookId),
  );

  /// Pops back to [bookId]'s ledger, opening it if it isn't on the stack.
  static void returnTo(NavigatorState navigator, String bookId) {
    var found = false;
    navigator.popUntil((route) {
      found = route.settings.name == routeName(bookId);
      return found || route.isFirst;
    });
    if (!found) navigator.push(route(bookId));
  }

  @override
  State<BookDetailScreen> createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends State<BookDetailScreen> {
  DateRange range = DateRange.all;
  String? category;
  String? mode;
  TransactionType? type;

  @override
  void initState() {
    super.initState();
    // Each book reopens with the filters it was left with (All time when
    // it has never been filtered).
    final saved = AppScope.read(context).bookFilters(widget.bookId);
    range = DateRange.values.asNameMap()[saved['range']] ?? DateRange.all;
    category = saved['category'];
    mode = saved['mode'];
    type = TransactionType.values.asNameMap()[saved['type']];
  }

  /// Applies a filter change and remembers it for this book.
  void _setFilters(VoidCallback change) {
    setState(change);
    AppScope.read(context).saveBookFilters(widget.bookId, {
      if (range != DateRange.all) 'range': range.name,
      'category': ?category,
      'mode': ?mode,
      'type': ?type?.name,
    });
  }

  void _clearFilters() => _setFilters(() {
    range = DateRange.all;
    category = null;
    mode = null;
    type = null;
  });

  Future<void> _pickRange(DateRange current) async {
    final l = context.l10n;
    final picked = await showOptionSheet<DateRange>(
      context,
      title: l.ledgerDateRange,
      selected: current,
      options: () => [
        for (final value in DateRange.values)
          SheetOption(value, value.localizedLabel(l), LucideIcons.calendar),
      ],
    );
    if (picked != null) _setFilters(() => range = picked);
  }

  Future<void> _pickCategory(AppStore store) async {
    const all = '\u0000all';
    final l = context.l10n;
    final picked = await showOptionSheet<String>(
      context,
      title: l.ledgerFilterCategory,
      selected: category ?? all,
      options: () => [
        SheetOption(all, l.ledgerAllCategories, LucideIcons.layers),
        for (final value in _used(store, (e) => e.category, store.categories))
          SheetOption(value, value, categoryIcon(value)),
      ],
    );
    if (picked != null) {
      _setFilters(() => category = picked == all ? null : picked);
    }
  }

  Future<void> _pickMode(AppStore store) async {
    const all = '\u0000all';
    final l = context.l10n;
    final picked = await showOptionSheet<String>(
      context,
      title: l.ledgerFilterMode,
      selected: mode ?? all,
      options: () => [
        SheetOption(all, l.ledgerAllModes, LucideIcons.wallet),
        for (final value in _used(
          store,
          (e) => e.paymentMode,
          store.paymentModes,
        ))
          SheetOption(value, value, LucideIcons.wallet),
      ],
    );
    if (picked != null) _setFilters(() => mode = picked == all ? null : picked);
  }

  /// The shared list plus any value this book's entries use (e.g. imported).
  List<String> _used(
    AppStore store,
    String Function(LedgerTransaction) field,
    List<String> base,
  ) {
    final values = [...base];
    for (final entry in store.transactions) {
      if (entry.bookId != widget.bookId) continue;
      final value = field(entry);
      if (value.trim().isNotEmpty && !values.contains(value)) values.add(value);
    }
    return values;
  }

  void _openReport(
    String bookId,
    List<LedgerTransaction> entries,
    DateRange range,
  ) => Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => ReportScreen(
        bookId: bookId,
        entries: entries,
        // English for the exported file; translated for the screen.
        rangeLabel: range.label,
        rangeDisplayLabel: range.localizedLabel(context.l10n),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final store = AppScope.watch(context);
    final book = store.bookById(widget.bookId);
    if (book == null) return const Scaffold(body: SizedBox.shrink());
    final c = context.pf;
    final l = context.l10n;
    final now = DateTime.now();
    final all = store.transactionsForBook(book.id);
    final effectiveRange = range;
    final filtered = [
      for (final entry in all)
        if (effectiveRange.contains(entry.occurredAt, now) &&
            (category == null || entry.category == category) &&
            (mode == null || entry.paymentMode == mode) &&
            (type == null || entry.type == type))
          entry,
    ];
    var inflow = 0.0, outflow = 0.0;
    for (final entry in filtered) {
      if (entry.type == TransactionType.cashIn) {
        inflow += entry.amount;
      } else {
        outflow += entry.amount;
      }
    }
    final groups = <(DateTime, List<LedgerTransaction>)>[];
    for (final entry in filtered) {
      if (groups.isEmpty || !sameDay(groups.last.$1, entry.occurredAt)) {
        groups.add((entry.occurredAt, [entry]));
      } else {
        groups.last.$2.add(entry);
      }
    }
    final balance = store.balanceFor(book.id);
    final info = Currency.of(book.currency);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: pagePadding,
              sliver: SliverList.list(
                children: [
                  PfHeader(
                    title: book.name,
                    subtitle: '${info.code} · ${info.name}',
                    actions: [
                      PfIconButton(
                        icon: LucideIcons.fileUp,
                        size: 19,
                        tooltip: l.ledgerImportStatement,
                        onPressed: () => openImport(context, bookId: book.id),
                      ),
                      PfIconButton(
                        icon: LucideIcons.fileChartColumn,
                        size: 19,
                        tooltip: l.ledgerReport,
                        onPressed: () =>
                            _openReport(book.id, filtered, effectiveRange),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _BalanceHero(
                    balance: balance,
                    inflow: inflow,
                    outflow: outflow,
                    currency: book.currency,
                  ),
                  const SizedBox(height: 14),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    clipBehavior: Clip.none,
                    child: Row(
                      children: [
                        _FilterChip(
                          icon: LucideIcons.calendar,
                          label: effectiveRange.localizedLabel(l),
                          active: true,
                          onTap: () => _pickRange(effectiveRange),
                        ),
                        const SizedBox(width: 8),
                        _FilterChip(
                          icon: LucideIcons.tag,
                          label: category ?? l.category,
                          active: category != null,
                          onTap: () => _pickCategory(store),
                        ),
                        const SizedBox(width: 8),
                        _FilterChip(
                          icon: LucideIcons.wallet,
                          label: mode ?? l.paymentMode,
                          active: mode != null,
                          onTap: () => _pickMode(store),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  PfSegment<TransactionType?>(
                    value: type,
                    onChanged: (value) => _setFilters(() => type = value),
                    items: [
                      (null, l.all, null),
                      (TransactionType.cashIn, l.cashIn, null),
                      (TransactionType.cashOut, l.cashOut, null),
                    ],
                  ),
                  const SizedBox(height: 14),
                  if (groups.isEmpty)
                    all.isEmpty
                        ? PfEmptyCard(
                            icon: LucideIcons.notebookPen,
                            title: l.ledgerEmptyTitle,
                            body: l.ledgerEmptyBody,
                            actionLabel: l.ledgerImportStatement,
                            onAction: () =>
                                openImport(context, bookId: book.id),
                          )
                        : PfEmptyCard(
                            icon: LucideIcons.funnelX,
                            title: l.ledgerNoMatchTitle,
                            body: l.ledgerNoMatchBody,
                            actionLabel: l.ledgerClearFilters,
                            onAction: _clearFilters,
                          ),
                ],
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList.builder(
                itemCount: groups.length,
                itemBuilder: (context, index) {
                  final (day, entries) = groups[index];
                  final net = entries.fold(
                    0.0,
                    (sum, e) => sum + e.signedAmount,
                  );
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        PfSectionLabel(
                          l.dayLabel(day),
                          trailing: signedMoney(net, book.currency),
                        ),
                        const SizedBox(height: 8),
                        EntryGroupCard(
                          children: [
                            for (final entry in entries)
                              EntryRow(
                                entry: entry,
                                currency: book.currency,
                                subtitle: _subtitle(store, entry),
                                onTap: () => openEntry(context, entry.id),
                              ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
      bottomNavigationBar: _CashButtons(bookId: book.id, colors: c),
    );
  }

  String _subtitle(AppStore store, LedgerTransaction entry) {
    final goal = entry.goalId == null || entry.goalId!.isEmpty
        ? null
        : store.goals.where((g) => g.id == entry.goalId).firstOrNull;
    return [
      entry.category,
      entry.paymentMode,
      if (goal != null) goal.name,
    ].where((part) => part.trim().isNotEmpty).join(' · ');
  }
}

class _BalanceHero extends StatelessWidget {
  const _BalanceHero({
    required this.balance,
    required this.inflow,
    required this.outflow,
    required this.currency,
  });

  final double balance;
  final double inflow;
  final double outflow;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final c = context.pf;
    final l = context.l10n;
    return Container(
      decoration: BoxDecoration(
        color: c.hero,
        borderRadius: BorderRadius.circular(28),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned(
            right: -50,
            bottom: -80,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(color: c.hero2, shape: BoxShape.circle),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l.ledgerNetBalance,
                  style: pfText(13, color: PfColors.heroLabel),
                ),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    balanceMoney(balance, currency),
                    style: pfText(
                      32,
                      weight: w900,
                      color: Colors.white,
                      letterSpacing: -.6,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 22,
                  runSpacing: 8,
                  children: [
                    _HeroFigure(
                      label: l.ledgerInflow,
                      labelColor: PfColors.heroInLabel,
                      value: '+ ${money(inflow, currency)}',
                    ),
                    _HeroFigure(
                      label: l.ledgerOutflow,
                      labelColor: PfColors.heroOutLabel,
                      value: '− ${money(outflow, currency)}',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroFigure extends StatelessWidget {
  const _HeroFigure({
    required this.label,
    required this.labelColor,
    required this.value,
  });

  final String label;
  final Color labelColor;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: pfText(11, weight: w900, color: labelColor, letterSpacing: .5),
        ),
        Text(
          value,
          style: pfText(16, weight: w900, color: Colors.white),
        ),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.pf;
    final fg = active ? c.cashIn : c.sub;
    return Material(
      color: active ? c.soft : c.card,
      shape: const StadiumBorder(),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: onTap,
        child: Container(
          height: 38,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Row(
            children: [
              Icon(icon, size: 14, color: fg),
              const SizedBox(width: 6),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 180),
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: pfText(13, color: fg),
                ),
              ),
              const SizedBox(width: 6),
              Icon(LucideIcons.chevronDown, size: 14, color: fg),
            ],
          ),
        ),
      ),
    );
  }
}

class _CashButtons extends StatelessWidget {
  const _CashButtons({required this.bookId, required this.colors});

  final String bookId;
  final PfColors colors;

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;
    final l = context.l10n;
    return Container(
      padding: EdgeInsets.fromLTRB(20, 14, 20, bottom + 14),
      decoration: BoxDecoration(
        color: colors.bg,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .12),
            blurRadius: 24,
            spreadRadius: -12,
            offset: const Offset(0, -12),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: PfButton(
              label: l.cashIn,
              icon: LucideIcons.plus,
              height: 54,
              radius: 18,
              fontSize: 15.5,
              onPressed: () => openNewEntry(
                context,
                bookId: bookId,
                type: TransactionType.cashIn,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: PfButton(
              label: l.cashOut,
              icon: LucideIcons.minus,
              style: PfButtonStyle.danger,
              height: 54,
              radius: 18,
              fontSize: 15.5,
              onPressed: () => openNewEntry(
                context,
                bookId: bookId,
                type: TransactionType.cashOut,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
