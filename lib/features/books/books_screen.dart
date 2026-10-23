import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../app/nav.dart';
import '../../core/format.dart';
import '../../l10n/l10n.dart';
import '../../data/app_store.dart';
import '../../data/models.dart';
import '../../theme/tokens.dart';
import '../../widgets/account_type.dart';
import '../../widgets/pf.dart';

class BooksScreen extends StatefulWidget {
  const BooksScreen({super.key});

  @override
  State<BooksScreen> createState() => _BooksScreenState();
}

class _BooksScreenState extends State<BooksScreen> {
  final search = TextEditingController();
  String? menuFor;

  @override
  void dispose() {
    search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final store = AppScope.watch(context);
    final c = context.pf;
    final l = context.l10n;
    if (store.books.isEmpty) return const _EmptyBooks();
    final query = search.text.trim().toLowerCase();
    final books = store.booksByRecent
        .where(
          (book) => query.isEmpty || book.name.toLowerCase().contains(query),
        )
        .toList();
    final untyped = store.untypedBooks.length;
    return ListView(
      padding: pagePadding,
      children: [
        Builder(
          builder: (context) {
            final title = Text(
              l.bookListTitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: pfText(30, weight: w900, letterSpacing: -.6),
            );
            final actions = [
              PfIconButton(
                icon: LucideIcons.hash,
                tooltip: l.tags,
                onPressed: () => openManageTags(context),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: PfSmallButton(
                  label: l.bookNew,
                  icon: LucideIcons.plus,
                  onPressed: () => openNewBook(context),
                ),
              ),
            ];
            // Large text: the title gets its own line so neither it nor
            // "New account" is cut off.
            if (MediaQuery.textScalerOf(context).scale(10) > 12) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  title,
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: actions,
                  ),
                ],
              );
            }
            return Row(
              children: [
                Expanded(child: title),
                ...actions,
              ],
            );
          },
        ),
        const SizedBox(height: 14),
        _SummaryCard(store: store),
        if (untyped > 0) ...[
          const SizedBox(height: 14),
          _TypePromptCard(count: untyped),
        ],
        const SizedBox(height: 14),
        Container(
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: c.card,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            children: [
              Icon(LucideIcons.search, size: 18, color: c.mute),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: search,
                  onChanged: (_) => setState(() {}),
                  style: pfText(15, weight: w700, color: c.ink),
                  decoration: InputDecoration(
                    hintText: l.bookSearchHint,
                    hintStyle: pfText(15, weight: w700, color: c.mute),
                  ),
                ),
              ),
            ],
          ),
        ),
        for (final type in AccountType.values)
          if (books.any((book) => book.accountType == type)) ...[
            const SizedBox(height: 14),
            _GroupHeader(
              type: type,
              books: books.where((book) => book.accountType == type),
              store: store,
            ),
            for (final book in books.where((b) => b.accountType == type)) ...[
              const SizedBox(height: 8),
              _BookCard(
                book: book,
                store: store,
                menuOpen: menuFor == book.id,
                onToggleMenu: () => setState(
                  () => menuFor = menuFor == book.id ? null : book.id,
                ),
              ),
            ],
          ],
        if (books.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 10),
            child: Text(
              l.bookSearchNoMatch(search.text.trim()),
              textAlign: TextAlign.center,
              style: pfText(15, weight: w700, color: c.sub),
            ),
          ),
        const SizedBox(height: 24),
      ],
    );
  }
}

/// Assets / Liabilities / Total for each currency, never converted.
class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.store});

  final AppStore store;

  @override
  Widget build(BuildContext context) {
    final c = context.pf;
    final currencies = store.accountCurrencies;
    return PfCard(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var i = 0; i < currencies.length; i++) ...[
              if (i > 0) ...[
                const SizedBox(height: 12),
                Divider(height: 1, thickness: 1, color: c.line),
                const SizedBox(height: 12),
              ],
              _SummaryRow(
                currency: currencies[i],
                totals: store.totalsFor(currencies[i]),
                large: i == 0,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.currency,
    required this.totals,
    required this.large,
  });

  final String currency;
  final AccountTotals totals;
  final bool large;

  @override
  Widget build(BuildContext context) {
    final c = context.pf;
    final l = context.l10n;
    final size = large ? 17.0 : 14.5;
    Widget cell(String label, String value, Color color) => Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: pfText(11.5, weight: w800, color: c.sub),
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              maxLines: 1,
              style: pfText(size, weight: w900, color: color),
            ),
          ),
        ],
      ),
    );
    final onlyLiabilities = totals.assets == 0 && totals.owed > 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                '$currency · ${Currency.of(currency).name}'.toUpperCase(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: pfText(
                  11,
                  weight: w900,
                  color: c.sub,
                  letterSpacing: .5,
                ),
              ),
            ),
            if (onlyLiabilities)
              PfBadge(
                label: l.accountLiabilities,
                background: c.outSoft,
                foreground: c.cashOut,
              ),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            cell(l.accountAssets, money(totals.assets, currency), c.cashIn),
            const SizedBox(width: 8),
            cell(l.accountLiabilities, money(totals.owed, currency), c.cashOut),
            const SizedBox(width: 8),
            cell(l.accountTotal, balanceMoney(totals.net, currency), c.ink),
          ],
        ),
      ],
    );
  }
}

class _TypePromptCard extends StatelessWidget {
  const _TypePromptCard({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final c = context.pf;
    final l = context.l10n;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: c.goldSoft,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(LucideIcons.shapes, size: 20, color: c.gold),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l.accountTypePrompt,
                  style: pfText(14.5, weight: w900, height: 1.3),
                ),
                const SizedBox(height: 2),
                Text(
                  l.accountTypePromptBody(count),
                  style: pfText(12.5, weight: w700, color: c.sub, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// "🏦 Bank        Rs 1,20,000" — a type's subtotal per currency.
class _GroupHeader extends StatelessWidget {
  const _GroupHeader({
    required this.type,
    required this.books,
    required this.store,
  });

  final AccountType type;
  final Iterable<LedgerBook> books;
  final AppStore store;

  @override
  Widget build(BuildContext context) {
    final c = context.pf;
    final l = context.l10n;
    final byCurrency = <String, double>{};
    for (final book in books) {
      byCurrency[book.currency] =
          (byCurrency[book.currency] ?? 0) + store.balanceFor(book.id);
    }
    final liability = type.isLiability;
    final subtotal = [
      for (final MapEntry(key: currency, value: total) in byCurrency.entries)
        liability ? money(-total, currency) : balanceMoney(total, currency),
    ].join(' · ');
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          Icon(accountTypeIcon(type), size: 16, color: c.sub),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              accountTypeLabel(l, type),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: pfText(13.5, weight: w900, color: c.sub),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: Text(
              liability ? l.accountOwedAmount(subtotal) : subtotal,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.end,
              style: pfText(
                13,
                weight: w900,
                color: liability ? c.cashOut : c.sub,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BookCard extends StatelessWidget {
  const _BookCard({
    required this.book,
    required this.store,
    required this.menuOpen,
    required this.onToggleMenu,
  });

  final LedgerBook book;
  final AppStore store;
  final bool menuOpen;
  final VoidCallback onToggleMenu;

  Future<void> _delete(BuildContext context) async {
    final c = context.pf;
    final l = context.l10n;
    final count = store.entryCount(book.id);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          l.bookDeleteTitle(book.name),
          style: pfText(19, weight: w900),
        ),
        content: Text(
          count == 0 ? l.bookDeleteEmpty : l.bookDeleteWithEntries(count),
          style: pfText(14, weight: w600, color: c.sub),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l.cancel, style: pfText(14, color: c.sub)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l.delete, style: pfText(14, color: c.cashOut)),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    await store.deleteBook(book.id);
    if (context.mounted) showPfToast(context, l.bookDeleted(book.name));
  }

  @override
  Widget build(BuildContext context) {
    final c = context.pf;
    final l = context.l10n;
    final balance = store.balanceFor(book.id);
    final count = store.entryCount(book.id);
    final liability = book.isLiability;
    return PfCard(
      child: Column(
        children: [
          InkWell(
            onTap: () => openBook(context, book.id),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  PfIconTile(
                    icon: accountTypeIcon(book.accountType),
                    background: Color(book.colorValue),
                    foreground: Colors.white,
                    size: 48,
                    radius: 16,
                    iconSize: 21,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                book.name,
                                style: pfText(16, weight: w800),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            PfBadge(label: book.currency),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${liability ? l.accountOutstanding : l.accountBalance} · ${l.entryCount(count)}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: pfText(12, weight: w700, color: c.sub),
                        ),
                        const SizedBox(height: 3),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            !liability
                                ? balanceMoney(balance, book.currency)
                                : balance <= 0
                                ? money(-balance, book.currency)
                                : l.accountCredit(
                                    money(balance, book.currency),
                                  ),
                            maxLines: 1,
                            style: pfText(
                              18,
                              weight: w900,
                              color: liability || balance < 0
                                  ? c.cashOut
                                  : c.ink,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (book.type == null) ...[
                    const SizedBox(width: 8),
                    PfSmallButton(
                      label: l.accountSetType,
                      height: 36,
                      radius: 12,
                      fontSize: 12.5,
                      background: c.goldSoft,
                      foreground: c.gold,
                      onPressed: () => openRenameBook(context, book),
                    ),
                  ],
                  const SizedBox(width: 8),
                  PfIconButton(
                    icon: LucideIcons.ellipsis,
                    tooltip: l.bookActions,
                    size: 18,
                    background: c.card2,
                    foreground: c.sub,
                    onPressed: onToggleMenu,
                  ),
                ],
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            child: menuOpen
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: PfButton(
                            label: l.bookRename,
                            icon: LucideIcons.pencil,
                            style: PfButtonStyle.neutral,
                            height: 44,
                            radius: 14,
                            fontSize: 14,
                            onPressed: () {
                              onToggleMenu();
                              openRenameBook(context, book);
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: PfButton(
                            label: l.delete,
                            icon: LucideIcons.trash2,
                            style: PfButtonStyle.softDanger,
                            height: 44,
                            radius: 14,
                            fontSize: 14,
                            onPressed: () => _delete(context),
                          ),
                        ),
                      ],
                    ),
                  )
                : const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }
}

class _EmptyBooks extends StatelessWidget {
  const _EmptyBooks();

  @override
  Widget build(BuildContext context) {
    final c = context.pf;
    final l = context.l10n;
    return Padding(
      padding: pagePadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l.bookListTitle,
            style: pfText(30, weight: w900, letterSpacing: -.6),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PfIconTile(
                    icon: LucideIcons.walletCards,
                    background: c.soft,
                    foreground: c.cashIn,
                    size: 96,
                    radius: 32,
                    iconSize: 42,
                  ),
                  const SizedBox(height: 18),
                  Text(
                    l.bookEmptyTitle,
                    style: pfText(
                      26,
                      weight: w900,
                      letterSpacing: -.4,
                      height: 1.15,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    l.bookEmptyBody,
                    style: pfText(15, weight: w600, color: c.sub, height: 1.5),
                  ),
                  const SizedBox(height: 18),
                  PfButton(
                    label: l.bookNew,
                    icon: LucideIcons.plus,
                    expand: false,
                    height: 56,
                    fontSize: 16,
                    onPressed: () => openNewBook(context),
                  ),
                  TextButton(
                    onPressed: () => openImport(context),
                    style: TextButton.styleFrom(padding: EdgeInsets.zero),
                    child: Text(
                      l.bookEmptyImport,
                      style: pfText(15, weight: w800, color: c.cashIn),
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
}
