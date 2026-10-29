import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../app/nav.dart';
import '../../core/format.dart';
import '../../data/app_store.dart';
import '../../data/models.dart';
import '../../l10n/l10n.dart';
import '../../theme/tokens.dart';
import '../../widgets/account_type.dart';
import '../../widgets/category_icons.dart';
import '../../widgets/entry_kind_toggle.dart';
import '../../widgets/entry_row.dart';
import '../../widgets/option_sheet.dart';
import '../../widgets/pf.dart';
import '../../widgets/tags.dart';

/// Every account's entries for a month, newest first, with filters.
class AllEntriesScreen extends StatefulWidget {
  const AllEntriesScreen({super.key, this.tag});

  /// Opens already filtered to this tag.
  final String? tag;

  @override
  State<AllEntriesScreen> createState() => _AllEntriesScreenState();
}

class _AllEntriesScreenState extends State<AllEntriesScreen> {
  late DateTime month = _thisMonth();
  String? bookId;
  AccountType? accountType;
  String? category;
  String? mode;
  late String? tag = widget.tag;
  EntryKind? kind;

  static DateTime _thisMonth() =>
      DateTime(DateTime.now().year, DateTime.now().month);

  bool get _filtered =>
      bookId != null ||
      accountType != null ||
      category != null ||
      mode != null ||
      tag != null ||
      kind != null;

  void _clear() => setState(() {
    bookId = null;
    accountType = null;
    category = null;
    mode = null;
    tag = null;
    kind = null;
  });

  bool _matches(AppStore store, LedgerTransaction e) {
    final book = store.bookById(e.bookId);
    // Across accounts a transfer shows once (its From side); filtered to one
    // account, that account's side shows.
    if (bookId == null && e.isTransferMirror) return false;
    if (bookId != null && e.bookId != bookId) return false;
    if (accountType != null && book?.accountType != accountType) return false;
    if (category != null && e.category != category) return false;
    if (mode != null && e.paymentMode != mode) return false;
    if (tag != null && !e.tags.contains(tag)) return false;
    return switch (kind) {
      null => true,
      EntryKind.transfer => e.isTransferLeg,
      EntryKind.cashIn => !e.isTransferLeg && e.type == TransactionType.cashIn,
      EntryKind.cashOut =>
        !e.isTransferLeg && e.type == TransactionType.cashOut,
    };
  }

  Future<void> _pick<T>({
    required String title,
    required T? current,
    required String allLabel,
    required List<SheetOption<T>> options,
    required ValueChanged<T?> onPicked,
  }) async {
    // A sentinel stands for "all" since null means the sheet was dismissed.
    const all = Object();
    final picked = await showOptionSheet<Object>(
      context,
      title: title,
      selected: current ?? all,
      options: () => [
        SheetOption<Object>(all, allLabel, LucideIcons.list),
        for (final o in options)
          SheetOption<Object>(o.value as Object, o.label, o.icon),
      ],
    );
    if (picked == null) return;
    setState(() => onPicked(identical(picked, all) ? null : picked as T));
  }

  @override
  Widget build(BuildContext context) {
    final store = AppScope.watch(context);
    final c = context.pf;
    final l = context.l10n;
    final all = store.entriesNewestFirst;
    final inMonth = [
      for (final e in all)
        if (e.occurredAt.year == month.year &&
            e.occurredAt.month == month.month)
          e,
    ];
    final shown = [
      for (final e in inMonth)
        if (_matches(store, e)) e,
    ];
    String currencyOf(LedgerTransaction e) =>
        store.bookById(e.bookId)?.currency ?? store.defaultCurrency;

    // Month totals per currency; transfers and opening balances left out.
    final income = <String, double>{}, spending = <String, double>{};
    for (final e in shown) {
      if (!e.countsAsFlow) continue;
      final totals = e.type == TransactionType.cashIn ? income : spending;
      totals[currencyOf(e)] = (totals[currencyOf(e)] ?? 0) + e.amount;
    }
    final currencies = {...income.keys, ...spending.keys}.toList()
      ..sort((a, b) => a == store.defaultCurrency ? -1 : a.compareTo(b));
    if (currencies.isEmpty) currencies.add(store.defaultCurrency);
    final hasTransfers = shown.any((e) => e.isTransferLeg);
    final groups = <(DateTime, List<LedgerTransaction>)>[];
    for (final e in shown) {
      if (groups.isEmpty || !sameDay(groups.last.$1, e.occurredAt)) {
        groups.add((e.occurredAt, [e]));
      } else {
        groups.last.$2.add(e);
      }
    }
    final manyAccounts = store.books.length > 1;
    final book = bookId == null ? null : store.bookById(bookId!);

    Widget filterChip(String label, bool active, VoidCallback onTap) => Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Material(
        color: active ? c.soft : c.card,
        borderRadius: BorderRadius.circular(99),
        child: InkWell(
          borderRadius: BorderRadius.circular(99),
          onTap: onTap,
          child: Container(
            constraints: const BoxConstraints(minHeight: 38),
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: pfText(
                    13,
                    weight: w800,
                    color: active ? c.cashIn : c.sub,
                  ),
                ),
                const SizedBox(width: 6),
                Icon(
                  LucideIcons.chevronDown,
                  size: 14,
                  color: active ? c.cashIn : c.sub,
                ),
              ],
            ),
          ),
        ),
      ),
    );

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: pagePadding,
          children: [
            PfHeader(
              title: l.allEntriesTitle,
              actions: [
                PfIconButton(
                  icon: LucideIcons.search,
                  tooltip: l.search,
                  onPressed: () => openSearch(context),
                ),
              ],
            ),
            const SizedBox(height: 14),
            PfCard(
              child: SizedBox(
                height: 56,
                child: Row(
                  children: [
                    IconButton(
                      tooltip: l.feedPreviousMonth,
                      onPressed: () => setState(
                        () => month = DateTime(month.year, month.month - 1),
                      ),
                      icon: Icon(LucideIcons.chevronLeft, color: c.ink),
                    ),
                    Expanded(
                      child: Text(
                        DateFormat('MMMM y').format(month),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: pfText(17, weight: w900),
                      ),
                    ),
                    IconButton(
                      tooltip: l.feedNextMonth,
                      onPressed: () => setState(
                        () => month = DateTime(month.year, month.month + 1),
                      ),
                      icon: Icon(LucideIcons.chevronRight, color: c.ink),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            PfCard(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final (label, color, value) in [
                    (l.feedIncome, c.cashIn, (String cur) => income[cur] ?? 0),
                    (
                      l.feedExpenses,
                      c.cashOut,
                      (String cur) => spending[cur] ?? 0,
                    ),
                    (
                      l.accountTotal,
                      c.ink,
                      (String cur) => (income[cur] ?? 0) - (spending[cur] ?? 0),
                    ),
                  ])
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: pfText(12, weight: w800, color: c.sub),
                          ),
                          for (final cur in currencies)
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Text(
                                balanceMoney(value(cur), cur),
                                maxLines: 1,
                                style: pfText(15, weight: w900, color: color),
                              ),
                            ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              clipBehavior: Clip.none,
              child: Row(
                children: [
                  if (_filtered)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: PfSmallButton(
                        label: l.clear,
                        icon: LucideIcons.x,
                        height: 38,
                        radius: 99,
                        fontSize: 13,
                        background: c.ink,
                        foreground: c.bg,
                        onPressed: _clear,
                      ),
                    ),
                  if (manyAccounts)
                    filterChip(
                      book?.name ?? l.feedFilterAccount,
                      bookId != null,
                      () => _pick<String>(
                        title: l.feedFilterAccount,
                        current: bookId,
                        allLabel: l.feedAllAccounts,
                        options: [
                          for (final b in store.booksByRecent)
                            SheetOption(
                              b.id,
                              b.name,
                              accountTypeIcon(b.accountType),
                            ),
                        ],
                        onPicked: (v) => bookId = v,
                      ),
                    ),
                  filterChip(
                    accountType == null
                        ? l.feedFilterAccountType
                        : accountTypeLabel(l, accountType!),
                    accountType != null,
                    () => _pick<AccountType>(
                      title: l.feedFilterAccountType,
                      current: accountType,
                      allLabel: l.feedAllTypes,
                      options: [
                        for (final t in AccountType.values)
                          SheetOption(
                            t,
                            accountTypeLabel(l, t),
                            accountTypeIcon(t),
                          ),
                      ],
                      onPicked: (v) => accountType = v,
                    ),
                  ),
                  filterChip(
                    category ?? l.category,
                    category != null,
                    () => _pick<String>(
                      title: l.category,
                      current: category,
                      allLabel: l.ledgerAllCategories,
                      options: [
                        for (final v in {
                          ...store.categories,
                          for (final e in inMonth) e.category,
                        })
                          if (v.trim().isNotEmpty)
                            SheetOption(v, v, categoryIcon(v)),
                      ],
                      onPicked: (v) => category = v,
                    ),
                  ),
                  filterChip(
                    mode ?? l.paymentMode,
                    mode != null,
                    () => _pick<String>(
                      title: l.paymentMode,
                      current: mode,
                      allLabel: l.ledgerAllModes,
                      options: [
                        for (final v in {
                          ...store.paymentModes,
                          for (final e in inMonth) e.paymentMode,
                        })
                          if (v.trim().isNotEmpty)
                            SheetOption(v, v, LucideIcons.wallet),
                      ],
                      onPicked: (v) => mode = v,
                    ),
                  ),
                  filterChip(
                    tag == null ? l.tags : tagLabel(tag!),
                    tag != null,
                    () => _pick<String>(
                      title: l.tags,
                      current: tag,
                      allLabel: l.feedAllTags,
                      options: [
                        for (final (t, _) in store.allTags)
                          SheetOption(t, tagLabel(t), LucideIcons.hash),
                      ],
                      onPicked: (v) => tag = v,
                    ),
                  ),
                  filterChip(
                    switch (kind) {
                      null => l.feedFilterKind,
                      EntryKind.cashIn => l.cashIn,
                      EntryKind.cashOut => l.cashOut,
                      EntryKind.transfer => l.transfer,
                    },
                    kind != null,
                    () => _pick<EntryKind>(
                      title: l.feedFilterKind,
                      current: kind,
                      allLabel: l.feedEverything,
                      options: [
                        SheetOption(
                          EntryKind.cashIn,
                          l.cashIn,
                          LucideIcons.arrowDownLeft,
                        ),
                        SheetOption(
                          EntryKind.cashOut,
                          l.cashOut,
                          LucideIcons.arrowUpRight,
                        ),
                        SheetOption(
                          EntryKind.transfer,
                          l.transfer,
                          LucideIcons.arrowLeftRight,
                        ),
                      ],
                      onPicked: (v) => kind = v,
                    ),
                  ),
                ],
              ),
            ),
            if (hasTransfers) ...[
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
            ],
            const SizedBox(height: 14),
            if (all.isEmpty)
              PfEmptyCard(
                icon: LucideIcons.notebookPen,
                title: l.feedEmptyTitle,
                body: l.feedEmptyBody,
                actionLabel: l.feedAddEntry,
                onAction: () =>
                    openNewEntry(context, type: TransactionType.cashOut),
              )
            else if (inMonth.isEmpty)
              PfEmptyCard(
                icon: LucideIcons.calendarX,
                title: l.feedMonthEmptyTitle(DateFormat('MMMM').format(month)),
                body: l.feedMonthEmptyBody,
                actionLabel: l.feedGoToThisMonth,
                onAction: () => setState(() => month = _thisMonth()),
              )
            else if (shown.isEmpty)
              PfEmptyCard(
                icon: LucideIcons.funnelX,
                title: l.ledgerNoMatchTitle,
                body: l.feedNoMatchBody,
                actionLabel: l.ledgerClearFilters,
                onAction: _clear,
              ),
            for (final (day, entries) in groups) ...[
              _DayHeader(
                label: l.dayLabel(day),
                entries: entries,
                currencyOf: currencyOf,
              ),
              const SizedBox(height: 8),
              EntryGroupCard(
                children: [
                  for (final e in entries)
                    EntryRow(
                      entry: e,
                      currency: currencyOf(e),
                      account: manyAccounts && bookId == null
                          ? store.bookById(e.bookId)?.name
                          : null,
                      showBalance: bookId != null,
                      onTap: () => openEntry(context, e.id),
                    ),
                ],
              ),
              const SizedBox(height: 14),
            ],
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

/// "Today      + Rs 5,000  − Rs 1,200", per currency, flows only.
class _DayHeader extends StatelessWidget {
  const _DayHeader({
    required this.label,
    required this.entries,
    required this.currencyOf,
  });

  final String label;
  final List<LedgerTransaction> entries;
  final String Function(LedgerTransaction) currencyOf;

  @override
  Widget build(BuildContext context) {
    final c = context.pf;
    final ins = <String, double>{}, outs = <String, double>{};
    for (final e in entries) {
      if (!e.countsAsFlow) continue;
      final map = e.type == TransactionType.cashIn ? ins : outs;
      map[currencyOf(e)] = (map[currencyOf(e)] ?? 0) + e.amount;
    }
    String joined(Map<String, double> m, String sign) => [
      for (final MapEntry(key: cur, value: v) in m.entries)
        '$sign ${money(v, cur)}',
    ].join(' · ');
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: pfText(13, weight: w800, color: c.sub),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Wrap(
              alignment: WrapAlignment.end,
              spacing: 8,
              children: [
                if (ins.isNotEmpty)
                  Text(
                    joined(ins, '+'),
                    style: pfText(13, weight: w800, color: c.cashIn),
                  ),
                if (outs.isNotEmpty)
                  Text(
                    joined(outs, '−'),
                    style: pfText(13, weight: w800, color: c.cashOut),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
