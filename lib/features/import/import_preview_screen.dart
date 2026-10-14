import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/format.dart';
import '../../data/app_store.dart';
import '../../data/models.dart';
import '../../theme/tokens.dart';
import '../../widgets/pf.dart';
import '../books/book_detail_screen.dart';

/// Review a parsed statement: ready rows, duplicates (dimmed) and ignored
/// lines, then import the ready ones.
class ImportPreviewScreen extends StatefulWidget {
  const ImportPreviewScreen({
    super.key,
    required this.bookId,
    required this.fileName,
    required this.preview,
  });

  final String bookId;
  final String fileName;
  final ImportPreview preview;

  @override
  State<ImportPreviewScreen> createState() => _ImportPreviewScreenState();
}

class _ImportPreviewScreenState extends State<ImportPreviewScreen> {
  bool saving = false;

  /// Ready and duplicate rows together, in statement (date) order.
  late final rows = [
    for (final entry in widget.preview.importable) (entry, false),
    for (final entry in widget.preview.duplicates) (entry, true),
  ]..sort((a, b) {
      final date = a.$1.occurredAt.compareTo(b.$1.occurredAt);
      return date != 0 ? date : a.$1.sequence.compareTo(b.$1.sequence);
    });

  void _backToBook() =>
      BookDetailScreen.returnTo(Navigator.of(context), widget.bookId);

  Future<void> _import() async {
    if (saving) return;
    setState(() => saving = true);
    final preview = widget.preview;
    await AppScope.read(context).commitImport(preview);
    if (!mounted) return;
    final dupes = preview.duplicates.length;
    showPfToast(
      context,
      'Imported ${preview.importable.length} ${preview.importable.length == 1 ? 'entry' : 'entries'}'
      '${dupes == 0 ? '' : ' · $dupes ${dupes == 1 ? 'duplicate' : 'duplicates'} skipped'}',
    );
    _backToBook();
  }

  @override
  Widget build(BuildContext context) {
    final store = AppScope.watch(context);
    final c = context.pf;
    final preview = widget.preview;
    final book = store.bookById(widget.bookId);
    final currency = book?.currency ?? 'NPR';
    final ready = preview.importable.length;
    final dupes = preview.duplicates.length;
    final ignored = preview.ignored.length;
    final lines = ready + dupes + ignored;

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
                    title: 'Review import',
                    subtitle: '${widget.fileName} · parsed $lines lines',
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      _Count(value: ready, label: 'Ready to import', color: c.cashIn),
                      const SizedBox(width: 8),
                      _Count(value: dupes, label: 'Duplicates skipped', color: c.gold),
                      const SizedBox(width: 8),
                      _Count(value: ignored, label: 'Non-entry lines', color: c.sub),
                    ],
                  ),
                  const SizedBox(height: 14),
                  if (ready == 0) ...[
                    Container(
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        color: c.goldSoft,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(LucideIcons.copyCheck, size: 30, color: c.gold),
                          const SizedBox(height: 10),
                          Text('Already up to date', style: pfText(18, weight: w900)),
                          const SizedBox(height: 10),
                          Text(
                            'Every entry in this statement is already in ${book?.name ?? 'this book'}. Nothing new to import.',
                            style: pfText(14, weight: w600, color: c.sub, height: 1.5),
                          ),
                          const SizedBox(height: 14),
                          PfSmallButton(
                            label: 'Back to book',
                            onPressed: _backToBook,
                            radius: 14,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                  ],
                ],
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: DecoratedSliver(
                decoration: BoxDecoration(
                  color: c.card,
                  borderRadius: BorderRadius.circular(22),
                ),
                sliver: SliverList.separated(
                  itemCount: rows.length,
                  separatorBuilder: (_, _) => const PfDivider(),
                  itemBuilder: (context, index) {
                    final (entry, duplicate) = rows[index];
                    return _PreviewRow(
                      entry: entry,
                      duplicate: duplicate,
                      currency: currency,
                    );
                  },
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
      bottomNavigationBar: ready == 0
          ? null
          : SafeArea(
              minimum: const EdgeInsets.fromLTRB(20, 10, 20, 14),
              child: PfButton(
                label: 'Import $ready ${ready == 1 ? 'entry' : 'entries'}',
                icon: LucideIcons.download,
                onPressed: saving ? null : _import,
              ),
            ),
    );
  }
}

class _Count extends StatelessWidget {
  const _Count({required this.value, required this.label, required this.color});

  final int value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final c = context.pf;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: c.card,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$value', style: pfText(26, weight: w900, color: color)),
            Text(label, style: pfText(12, color: c.sub)),
          ],
        ),
      ),
    );
  }
}

class _PreviewRow extends StatelessWidget {
  const _PreviewRow({
    required this.entry,
    required this.duplicate,
    required this.currency,
  });

  final LedgerTransaction entry;
  final bool duplicate;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final c = context.pf;
    final isIn = entry.type == TransactionType.cashIn;
    final meta = [
      DateFormat('d MMM').format(entry.occurredAt),
      if (entry.externalReference.isNotEmpty) 'Ref ${entry.externalReference}',
    ].join(' · ');
    return Opacity(
      opacity: duplicate ? .5 : 1,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: duplicate ? c.mute : c.pri,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                duplicate ? LucideIcons.minus : LucideIcons.check,
                size: 14,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.title,
                    style: pfText(14),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(meta, style: pfText(11.5, weight: w700, color: c.sub)),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  signedMoney(entry.signedAmount, currency),
                  style: pfText(14, weight: w900, color: c.amount(isIn)),
                ),
                if (duplicate)
                  Text('DUPLICATE', style: pfText(10.5, weight: w900, color: c.gold)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
