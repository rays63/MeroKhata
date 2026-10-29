import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../app/nav.dart';
import '../../core/format.dart';
import '../../data/app_store.dart';
import '../../data/models.dart';
import '../../l10n/l10n.dart';
import '../../theme/tokens.dart';
import '../../widgets/entry_row.dart';
import '../../widgets/pf.dart';

/// Searches every account: title, notes, amount, reference and tags.
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final query = TextEditingController();

  @override
  void dispose() {
    query.dispose();
    super.dispose();
  }

  void _remember() => AppScope.read(context).addRecentSearch(query.text);

  void _use(String value) {
    query.text = value;
    query.selection = TextSelection.collapsed(offset: value.length);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final store = AppScope.watch(context);
    final c = context.pf;
    final l = context.l10n;
    final q = query.text.trim();
    final results = store.search(q);
    final groups = <(DateTime, List<LedgerTransaction>)>[];
    for (final e in results) {
      if (groups.isEmpty || !sameDay(groups.last.$1, e.occurredAt)) {
        groups.add((e.occurredAt, [e]));
      } else {
        groups.last.$2.add(e);
      }
    }
    final manyAccounts = store.books.length > 1;
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: pagePadding,
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          children: [
            Row(
              children: [
                PfIconButton(
                  icon: LucideIcons.arrowLeft,
                  tooltip: l.back,
                  onPressed: () => Navigator.maybePop(context),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Container(
                    height: 50,
                    padding: const EdgeInsets.only(left: 14, right: 6),
                    decoration: BoxDecoration(
                      color: c.card,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: c.pri, width: 1.5),
                    ),
                    child: Row(
                      children: [
                        Icon(LucideIcons.search, size: 18, color: c.mute),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: query,
                            autofocus: true,
                            textInputAction: TextInputAction.search,
                            onChanged: (_) => setState(() {}),
                            onSubmitted: (_) => _remember(),
                            style: pfText(15.5, weight: w800, color: c.ink),
                            decoration: InputDecoration(
                              hintText: l.searchHint,
                              hintStyle: pfText(
                                15.5,
                                weight: w800,
                                color: c.mute,
                              ),
                            ),
                          ),
                        ),
                        if (q.isNotEmpty)
                          PfIconButton(
                            icon: LucideIcons.x,
                            tooltip: l.searchClear,
                            size: 16,
                            background: c.card2,
                            foreground: c.sub,
                            onPressed: () => _use(''),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            if (q.isEmpty) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        l.searchRecent,
                        style: pfText(15, weight: w900),
                      ),
                    ),
                    if (store.recentSearches.isNotEmpty)
                      TextButton(
                        onPressed: store.clearRecentSearches,
                        child: Text(
                          l.clear,
                          style: pfText(13, weight: w800, color: c.sub),
                        ),
                      ),
                  ],
                ),
              ),
              if (store.recentSearches.isNotEmpty) ...[
                const SizedBox(height: 6),
                PfCard(
                  radius: 22,
                  child: Column(
                    children: [
                      for (var i = 0; i < store.recentSearches.length; i++) ...[
                        if (i > 0) const PfDivider(),
                        InkWell(
                          onTap: () => _use(store.recentSearches[i]),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  LucideIcons.history,
                                  size: 17,
                                  color: c.mute,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    store.recentSearches[i],
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: pfText(15, weight: w800),
                                  ),
                                ),
                                Icon(
                                  LucideIcons.arrowUpLeft,
                                  size: 16,
                                  color: c.mute,
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
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  l.searchTip,
                  style: pfText(12.5, weight: w700, color: c.sub, height: 1.45),
                ),
              ),
            ] else if (results.isEmpty)
              PfEmptyCard(
                icon: LucideIcons.searchX,
                title: l.searchNoneTitle(q),
                body: l.searchNoneBody,
                actionLabel: l.searchClear,
                onAction: () => _use(''),
              )
            else ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  l.searchResults(results.length),
                  style: pfText(13, weight: w800, color: c.sub),
                ),
              ),
              const SizedBox(height: 10),
              for (final (day, entries) in groups) ...[
                PfSectionLabel(l.dayLabel(day)),
                const SizedBox(height: 8),
                EntryGroupCard(
                  children: [
                    for (final e in entries)
                      EntryRow(
                        entry: e,
                        currency:
                            store.bookById(e.bookId)?.currency ??
                            store.defaultCurrency,
                        account: manyAccounts
                            ? store.bookById(e.bookId)?.name
                            : null,
                        showBalance: false,
                        highlight: q,
                        onTap: () {
                          _remember();
                          openEntry(context, e.id);
                        },
                      ),
                  ],
                ),
                const SizedBox(height: 14),
              ],
            ],
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
