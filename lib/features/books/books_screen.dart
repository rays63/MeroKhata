import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../app/nav.dart';
import '../../core/format.dart';
import '../../data/app_store.dart';
import '../../data/models.dart';
import '../../theme/tokens.dart';
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
    if (store.books.isEmpty) return const _EmptyBooks();
    final query = search.text.trim().toLowerCase();
    final books = store.booksByRecent
        .where((book) => query.isEmpty || book.name.toLowerCase().contains(query))
        .toList();
    return ListView(
      padding: pagePadding,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Books',
                style: pfText(30, weight: w900, letterSpacing: -.6),
              ),
            ),
            PfSmallButton(
              label: 'New book',
              icon: LucideIcons.plus,
              onPressed: () => openNewBook(context),
            ),
          ],
        ),
        const SizedBox(height: 16),
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
                    hintText: 'Search books',
                    hintStyle: pfText(15, weight: w700, color: c.mute),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        for (final book in books) ...[
          _BookCard(
            book: book,
            store: store,
            menuOpen: menuFor == book.id,
            onToggleMenu: () =>
                setState(() => menuFor = menuFor == book.id ? null : book.id),
          ),
          const SizedBox(height: 10),
        ],
        if (books.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 10),
            child: Text(
              'No books match “${search.text.trim()}”',
              textAlign: TextAlign.center,
              style: pfText(15, weight: w700, color: c.sub),
            ),
          ),
        const SizedBox(height: 24),
      ],
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
    final count = store.entryCount(book.id);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete “${book.name}”?', style: pfText(19, weight: w900)),
        content: Text(
          count == 0
              ? 'This book has no entries.'
              : 'Its $count ${count == 1 ? 'entry' : 'entries'} will be deleted too. This can’t be undone.',
          style: pfText(14, weight: w600, color: c.sub),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: pfText(14, color: c.sub)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Delete', style: pfText(14, color: c.cashOut)),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    await store.deleteBook(book.id);
    if (context.mounted) showPfToast(context, '“${book.name}” deleted');
  }

  @override
  Widget build(BuildContext context) {
    final c = context.pf;
    final balance = store.balanceFor(book.id);
    final count = store.entryCount(book.id);
    return PfCard(
      child: Column(
        children: [
          InkWell(
            onTap: () => openBook(context, book.id),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  BookAvatar(
                    name: book.name,
                    color: Color(book.colorValue),
                    size: 52,
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
                          '${updatedLabel(book.updatedAt)} · $count ${count == 1 ? 'entry' : 'entries'}',
                          style: pfText(12.5, weight: w700, color: c.sub),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          balanceMoney(balance, book.currency),
                          style: pfText(
                            18,
                            weight: w900,
                            color: balance < 0 ? c.cashOut : c.ink,
                          ),
                        ),
                      ],
                    ),
                  ),
                  PfIconButton(
                    icon: LucideIcons.ellipsis,
                    tooltip: 'Book actions',
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
                            label: 'Rename',
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
                            label: 'Delete',
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
    return Padding(
      padding: pagePadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Books', style: pfText(30, weight: w900, letterSpacing: -.6)),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PfIconTile(
                    icon: LucideIcons.bookPlus,
                    background: c.soft,
                    foreground: c.cashIn,
                    size: 96,
                    radius: 32,
                    iconSize: 42,
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Start your first book',
                    style: pfText(26, weight: w900, letterSpacing: -.4, height: 1.15),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'One book per purpose — daily spending, your shop, a trip abroad. It takes under a minute.',
                    style: pfText(15, weight: w600, color: c.sub, height: 1.5),
                  ),
                  const SizedBox(height: 18),
                  PfButton(
                    label: 'New book',
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
                      'or import a statement',
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
