import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/format.dart';
import '../../data/app_store.dart';
import '../../data/models.dart';
import '../../data/transfer_hints.dart';
import '../../l10n/l10n.dart';
import '../../theme/tokens.dart';
import '../../widgets/pf.dart';
import '../../widgets/tags.dart';
import '../books/book_detail_screen.dart';

/// Review parsed statements: ready rows, duplicates (dimmed) and ignored
/// lines per file, plus any warnings, then import the ready ones.
class ImportPreviewScreen extends StatefulWidget {
  const ImportPreviewScreen({
    super.key,
    required this.bookId,
    required this.batch,
    this.problems = const [],
  });

  final String bookId;
  final ImportBatch batch;

  /// Files that were skipped or couldn't be read, one message each.
  final List<String> problems;

  @override
  State<ImportPreviewScreen> createState() => _ImportPreviewScreenState();
}

class _ImportPreviewScreenState extends State<ImportPreviewScreen> {
  bool saving = false;

  /// Rows the user turned into transfers: row id → their other account.
  final Map<String, String> transfers = {};

  /// Tags added to every imported row.
  List<String> tags = const [];

  /// Rows that look like a transfer to one of the user's accounts.
  late final Map<String, String> hints = () {
    final store = AppScope.read(context);
    final currency = store.bookById(widget.bookId)?.currency ?? 'NPR';
    return {
      for (final row in widget.batch.combined.importable)
        row.id: ?transferCounterpart(row, store.books, currency: currency),
    };
  }();

  /// Each file's ready and duplicate rows together, in date order.
  late final sections = [
    for (final (statement, preview) in widget.batch.files)
      (
        statement,
        preview,
        [
          for (final entry in preview.importable) (entry, false),
          for (final entry in preview.duplicates) (entry, true),
        ]..sort((a, b) {
          final date = a.$1.occurredAt.compareTo(b.$1.occurredAt);
          return date != 0 ? date : a.$1.sequence.compareTo(b.$1.sequence);
        }),
      ),
  ];

  void _backToBook() =>
      BookDetailScreen.returnTo(Navigator.of(context), widget.bookId);

  Future<void> _import() async {
    if (saving) return;
    setState(() => saving = true);
    final preview = widget.batch.combined;
    await AppScope.read(
      context,
    ).commitImport(preview, transfers: transfers, tags: tags);
    if (!mounted) return;
    final l = context.l10n;
    final dupes = preview.duplicates.length;
    showPfToast(
      context,
      [
        l.importImportedToast(preview.importable.length),
        if (dupes > 0) l.importDuplicatesSkippedToast(dupes),
      ].join(' · '),
    );
    _backToBook();
  }

  @override
  Widget build(BuildContext context) {
    final store = AppScope.watch(context);
    final c = context.pf;
    final l = context.l10n;
    final batch = widget.batch;
    final preview = batch.combined;
    final book = store.bookById(widget.bookId);
    final currency = book?.currency ?? 'NPR';
    final ready = preview.importable.length;
    final dupes = preview.duplicates.length;
    final ignored = preview.ignored.length;
    final lines = ready + dupes + ignored;
    final single = batch.files.length == 1;

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
                    title: l.importReviewTitle,
                    subtitle: single
                        ? l.importParsedLines(
                            batch.files.single.$1.fileName,
                            lines,
                          )
                        : l.importFilesParsed(batch.files.length, lines),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      _Count(
                        value: ready,
                        label: l.importReady,
                        color: c.cashIn,
                      ),
                      const SizedBox(width: 8),
                      _Count(
                        value: dupes,
                        label: l.importDuplicatesSkipped,
                        color: c.gold,
                      ),
                      const SizedBox(width: 8),
                      if (hints.isEmpty)
                        _Count(
                          value: ignored,
                          label: l.importIgnoredLines,
                          color: c.sub,
                        )
                      else
                        _Count(
                          value: transfers.length,
                          label: l.importAsTransfers,
                          color: c.blue,
                        ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  if (ready > 0) ...[
                    _TagAllButton(
                      label: tags.isEmpty
                          ? l.importTagAll(ready)
                          : l.importTaggedAll(tags.map(tagLabel).join(' ')),
                      onTap: () async {
                        final picked = await showTagPicker(
                          context,
                          selected: tags,
                        );
                        if (picked != null) setState(() => tags = picked);
                      },
                    ),
                    const SizedBox(height: 14),
                  ],
                  for (final problem in widget.problems) ...[
                    _Note(
                      icon: LucideIcons.fileX,
                      color: c.cashOut,
                      text: problem,
                    ),
                    const SizedBox(height: 10),
                  ],
                  if (batch.sources.length > 1) ...[
                    _Note(
                      icon: LucideIcons.triangleAlert,
                      color: c.gold,
                      text: l.importWarnMixedSources(batch.sources.join(', ')),
                    ),
                    const SizedBox(height: 10),
                  ],
                  for (final gap in batch.chainGaps) ...[
                    _Note(
                      icon: LucideIcons.triangleAlert,
                      color: c.gold,
                      text: l.importWarnChainGap(
                        gap.from,
                        gap.to,
                        balanceMoney(gap.closing, currency),
                        balanceMoney(gap.opening, currency),
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                  if (preview.openingBalance != null) ...[
                    _Note(
                      icon: LucideIcons.wallet,
                      color: c.cashIn,
                      text:
                          store.importSetsOpeningBalance(widget.bookId, preview)
                          ? single
                                ? l.importOpeningWillSet(
                                    balanceMoney(
                                      preview.openingBalance!,
                                      currency,
                                    ),
                                    balanceMoney(
                                      preview.closingBalance!,
                                      currency,
                                    ),
                                  )
                                : l.importOpeningWillSetFiles(
                                    balanceMoney(
                                      preview.openingBalance!,
                                      currency,
                                    ),
                                    batch.openingFrom!,
                                    balanceMoney(
                                      preview.closingBalance!,
                                      currency,
                                    ),
                                  )
                          : l.importOpeningInfo(
                              balanceMoney(preview.openingBalance!, currency),
                            ),
                    ),
                    const SizedBox(height: 14),
                  ],
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
                          Text(
                            l.importUpToDateTitle,
                            style: pfText(18, weight: w900),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            l.importUpToDateBody(
                              book?.name ?? l.importThisBook,
                            ),
                            style: pfText(
                              14,
                              weight: w600,
                              color: c.sub,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 14),
                          PfSmallButton(
                            label: l.importBackToBook,
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
            for (final (statement, filePreview, rows) in sections) ...[
              if (!single)
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(24, 4, 24, 8),
                  sliver: SliverToBoxAdapter(
                    child: _FileHeader(
                      name: statement.fileName,
                      counts: l.importFileCounts(
                        filePreview.importable.length,
                        filePreview.duplicates.length,
                        filePreview.ignored.length,
                      ),
                    ),
                  ),
                ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
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
                      final hint = duplicate ? null : hints[entry.id];
                      return _PreviewRow(
                        entry: entry,
                        duplicate: duplicate,
                        currency: currency,
                        transferTo: hint == null
                            ? null
                            : store.bookById(hint)?.name,
                        isTransfer: transfers.containsKey(entry.id),
                        onTransfer: hint == null
                            ? null
                            : () => setState(() {
                                if (transfers.remove(entry.id) == null) {
                                  transfers[entry.id] = hint;
                                }
                              }),
                      );
                    },
                  ),
                ),
              ),
            ],
            const SliverToBoxAdapter(child: SizedBox(height: 8)),
          ],
        ),
      ),
      bottomNavigationBar: ready == 0
          ? null
          : SafeArea(
              minimum: const EdgeInsets.fromLTRB(20, 10, 20, 14),
              child: PfButton(
                label: l.importButton(ready),
                icon: LucideIcons.download,
                onPressed: saving ? null : _import,
              ),
            ),
    );
  }
}

/// A file's name and its ready / duplicate / ignored counts.
class _FileHeader extends StatelessWidget {
  const _FileHeader({required this.name, required this.counts});

  final String name;
  final String counts;

  @override
  Widget build(BuildContext context) {
    final c = context.pf;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          name,
          style: pfText(15, weight: w900, color: c.ink),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          counts,
          style: pfText(12, weight: w700, color: c.sub),
        ),
      ],
    );
  }
}

/// An info or warning line above the rows.
class _Note extends StatelessWidget {
  const _Note({required this.icon, required this.color, required this.text});

  final IconData icon;
  final Color color;
  final String text;

  @override
  Widget build(BuildContext context) {
    final c = context.pf;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: pfText(14, weight: w700, color: c.sub, height: 1.45),
            ),
          ),
        ],
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
            Text(
              '$value',
              style: pfText(26, weight: w900, color: color),
            ),
            Text(
              label,
              style: pfText(12, color: c.sub),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
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
    this.transferTo,
    this.isTransfer = false,
    this.onTransfer,
  });

  final LedgerTransaction entry;
  final bool duplicate;
  final String currency;

  /// The account this row looks like a transfer to (or from).
  final String? transferTo;
  final bool isTransfer;

  /// Makes the row a transfer, or undoes that.
  final VoidCallback? onTransfer;

  @override
  Widget build(BuildContext context) {
    final c = context.pf;
    final l = context.l10n;
    final isIn = entry.type == TransactionType.cashIn;
    final meta = [
      DateFormat('d MMM').format(entry.occurredAt),
      entry.category,
      if (entry.externalReference.isNotEmpty)
        l.importRef(entry.externalReference),
    ].join(' · ');
    final row = Opacity(
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
                  Text(
                    meta,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: pfText(11.5, weight: w700, color: c.sub),
                  ),
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
                  Text(
                    l.importDuplicateBadge,
                    style: pfText(10.5, weight: w900, color: c.gold),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
    if (transferTo == null) return row;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        row,
        Container(
          margin: const EdgeInsets.fromLTRB(52, 0, 16, 12),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: isTransfer ? c.soft : c.blueSoft,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                isTransfer ? LucideIcons.check : LucideIcons.arrowLeftRight,
                size: 14,
                color: isTransfer ? c.cashIn : c.blue,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  isTransfer
                      ? l.importWillTransfer
                      : isIn
                      ? l.importLooksTransferFrom(transferTo!)
                      : l.importLooksTransferTo(transferTo!),
                  style: pfText(
                    12,
                    weight: w800,
                    color: isTransfer ? c.cashIn : c.blue,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              PfSmallButton(
                label: isTransfer ? l.importUndo : l.importMakeTransfer,
                height: 30,
                radius: 10,
                fontSize: 12,
                background: isTransfer ? Colors.transparent : c.blue,
                foreground: isTransfer ? c.cashIn : Colors.white,
                onPressed: onTransfer,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TagAllButton extends StatelessWidget {
  const _TagAllButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.pf;
    return Material(
      color: c.tagSoft,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(LucideIcons.hash, size: 18, color: c.tag),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: pfText(14.5, weight: w900, color: c.tag),
                ),
              ),
              Icon(LucideIcons.chevronRight, size: 18, color: c.tag),
            ],
          ),
        ),
      ),
    );
  }
}
