import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../data/app_store.dart';
import '../../data/import_parser.dart';
import '../../theme/tokens.dart';
import '../../widgets/pf.dart';
import 'import_preview_screen.dart';

/// Choose a PDF bank statement or XLS wallet export to import into a book.
class ImportPickScreen extends StatefulWidget {
  const ImportPickScreen({super.key, required this.bookId});

  final String bookId;

  @override
  State<ImportPickScreen> createState() => _ImportPickScreenState();
}

class _ImportPickScreenState extends State<ImportPickScreen> {
  bool loading = false;
  String? error;

  Future<void> _choose({required bool pdf}) async {
    setState(() => error = null);
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: pdf
          ? const ['pdf']
          : const ['xls', 'xlsx', 'csv', 'tsv'],
      withData: true,
    );
    final file = result?.files.single;
    final bytes = file?.bytes;
    if (file == null || bytes == null || !mounted) return;
    setState(() => loading = true);
    final store = AppScope.read(context);
    try {
      // Let the progress indicator paint before the synchronous parse.
      await Future<void>.delayed(const Duration(milliseconds: 16));
      final preview = pdf
          ? ImportParser.parsePdfBytes(
              store: store,
              bookId: widget.bookId,
              bytes: bytes,
            )
          : ImportParser.parseXlsBytes(
              store: store,
              bookId: widget.bookId,
              bytes: bytes,
            );
      if (!mounted) return;
      if (preview.importable.isEmpty && preview.duplicates.isEmpty) {
        setState(
          () => error = pdf
              ? 'No entries found in ${file.name}. Scanned, image-only PDFs aren’t supported yet.'
              : 'No entries found in ${file.name}. Check it has date, debit and credit columns.',
        );
        return;
      }
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ImportPreviewScreen(
            bookId: widget.bookId,
            fileName: file.name,
            preview: preview,
          ),
        ),
      );
    } catch (exception) {
      if (mounted) {
        setState(() => error = 'Couldn’t read ${file.name}: $exception');
      }
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final store = AppScope.watch(context);
    final c = context.pf;
    final book = store.bookById(widget.bookId);
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: pagePadding,
          children: [
            PfHeader(
              title: 'Import statement',
              subtitle: 'into ${book?.name ?? ''}',
            ),
            const SizedBox(height: 16),
            _SourceCard(
              icon: LucideIcons.fileText,
              background: c.outSoft,
              foreground: c.cashOut,
              title: 'PDF bank statement',
              body:
                  'Text-based PDFs with date, description, withdraw, deposit and balance columns.',
              action: 'Choose PDF →',
              onTap: loading ? null : () => _choose(pdf: true),
            ),
            const SizedBox(height: 16),
            _SourceCard(
              icon: LucideIcons.fileSpreadsheet,
              background: c.soft,
              foreground: c.cashIn,
              title: 'XLS wallet statement',
              body:
                  'Legacy .xls exports from wallets. Keeps original descriptions and reference codes.',
              action: 'Choose XLS →',
              onTap: loading ? null : () => _choose(pdf: false),
            ),
            if (loading) ...[
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  color: c.pri,
                  backgroundColor: c.card2,
                ),
              ),
            ],
            if (error != null) ...[
              const SizedBox(height: 16),
              PfErrorBanner(error!),
            ],
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              decoration: BoxDecoration(
                color: c.card2,
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Column(
                children: [
                  _Tip(
                    LucideIcons.eye,
                    'You’ll review everything before it’s saved.',
                  ),
                  SizedBox(height: 10),
                  _Tip(
                    LucideIcons.copyCheck,
                    'Re-importing the same statement won’t create duplicates.',
                  ),
                  SizedBox(height: 10),
                  _Tip(
                    LucideIcons.scanLine,
                    'Scanned, image-only PDFs aren’t supported yet.',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SourceCard extends StatelessWidget {
  const _SourceCard({
    required this.icon,
    required this.background,
    required this.foreground,
    required this.title,
    required this.body,
    required this.action,
    required this.onTap,
  });

  final IconData icon;
  final Color background;
  final Color foreground;
  final String title;
  final String body;
  final String action;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.pf;
    return PfCard(
      radius: 26,
      padding: const EdgeInsets.all(20),
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PfIconTile(
            icon: icon,
            background: background,
            foreground: foreground,
            size: 56,
            radius: 18,
            iconSize: 26,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: pfText(17, weight: w900)),
                const SizedBox(height: 4),
                Text(
                  body,
                  style: pfText(13.5, weight: w600, color: c.sub, height: 1.45),
                ),
                const SizedBox(height: 10),
                Text(
                  action,
                  style: pfText(13.5, weight: w900, color: c.cashIn),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Tip extends StatelessWidget {
  const _Tip(this.icon, this.text);

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final c = context.pf;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 17, color: c.ink),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: pfText(13.5, weight: w700, color: c.sub, height: 1.4),
          ),
        ),
      ],
    );
  }
}
