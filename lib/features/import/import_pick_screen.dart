import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../data/app_store.dart';
import '../../data/import_parser.dart';
import '../../data/models.dart';
import '../../l10n/l10n.dart';
import '../../theme/tokens.dart';
import '../../widgets/pf.dart';
import '../../widgets/store_sheets.dart';
import 'import_preview_screen.dart';

/// Choose a PDF bank statement or XLS wallet export to import into a book.
class ImportPickScreen extends StatefulWidget {
  const ImportPickScreen({
    super.key,
    required this.bookId,
    this.canChangeBook = false,
  });

  /// The book to import into at first.
  final String bookId;

  /// Opened from Home: the user may pick another book.
  final bool canChangeBook;

  @override
  State<ImportPickScreen> createState() => _ImportPickScreenState();
}

class _ImportPickScreenState extends State<ImportPickScreen> {
  bool loading = false;
  String? error;
  late String bookId = widget.bookId;

  Future<void> _changeBook() async {
    final picked = await pickBook(context, selected: bookId);
    if (picked != null && mounted) setState(() => bookId = picked);
  }

  /// Picks one or more statements, reads each on its own (a locked, wrong
  /// or unreadable file never blocks the others) and opens one combined
  /// preview.
  Future<void> _choose({required bool pdf}) async {
    setState(() => error = null);
    final allowed = pdf ? const ['pdf'] : const ['xls', 'xlsx', 'csv', 'tsv'];
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: allowed,
      allowMultiple: true,
      withData: true,
    );
    final files = result?.files ?? const <PlatformFile>[];
    if (files.isEmpty || !mounted) return;
    final store = AppScope.read(context);
    final l = context.l10n;
    final statements = <ParsedStatement>[];
    final problems = <String>[];
    setState(() => loading = true);
    try {
      for (final file in files) {
        final bytes = file.bytes;
        if (bytes == null) {
          problems.add(l.importFileUnreadable(file.name));
          continue;
        }
        // Some pickers ignore the type filter, so check the extension too.
        if (!allowed.contains(file.extension?.toLowerCase())) {
          problems.add(
            l.importWrongFileType(
              file.name,
              allowed.map((ext) => '.$ext').join(', '),
            ),
          );
          continue;
        }
        try {
          final statement = await _read(file.name, bytes, pdf: pdf);
          if (!mounted) return;
          if (statement == null) {
            problems.add(l.importPasswordSkipped(file.name));
          } else if (statement.rows.isEmpty) {
            problems.add(
              pdf
                  ? l.importNoEntriesPdf(file.name)
                  : l.importNoEntriesXls(file.name),
            );
          } else {
            statements.add(statement);
          }
        } catch (exception) {
          problems.add(l.importReadError(file.name, exception.toString()));
        }
      }
      if (!mounted) return;
      if (statements.isEmpty) {
        setState(() => error = problems.join('\n'));
        return;
      }
      final batch = store.previewBatch(bookId, statements);
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ImportPreviewScreen(
            bookId: bookId,
            batch: batch,
            problems: problems,
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  /// Reads one statement, asking for its password while it is locked.
  /// Returns null when the user cancels the password prompt.
  Future<ParsedStatement?> _read(
    String fileName,
    List<int> bytes, {
    required bool pdf,
  }) async {
    String? password;
    while (true) {
      // Let the progress indicator paint before the synchronous parse.
      await Future<void>.delayed(const Duration(milliseconds: 16));
      try {
        return pdf
            ? ImportParser.readPdf(
                fileName: fileName,
                bookId: bookId,
                bytes: bytes,
                password: password,
              )
            : ImportParser.readXls(
                fileName: fileName,
                bookId: bookId,
                bytes: bytes,
              );
      } on PdfPasswordException catch (locked) {
        if (!mounted) return null;
        setState(() => loading = false);
        password = await _askPassword(
          fileName,
          wrongPassword: locked.wrongPassword,
        );
        if (password == null || !mounted) return null;
        setState(() => loading = true);
      }
    }
  }

  /// Asks for a locked statement's password. It is only used to open the
  /// file and is never saved.
  Future<String?> _askPassword(String fileName, {required bool wrongPassword}) {
    return showDialog<String>(
      context: context,
      builder: (_) =>
          _PasswordDialog(fileName: fileName, wrongPassword: wrongPassword),
    );
  }

  @override
  Widget build(BuildContext context) {
    final store = AppScope.watch(context);
    final c = context.pf;
    final l = context.l10n;
    final book = store.bookById(bookId);
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: pagePadding,
          children: [
            PfHeader(
              title: l.ledgerImportStatement,
              subtitle: l.importInto(book?.name ?? ''),
              onSubtitleTap: widget.canChangeBook && store.books.length > 1
                  ? (loading ? null : _changeBook)
                  : null,
            ),
            const SizedBox(height: 16),
            _SourceCard(
              icon: LucideIcons.fileText,
              background: c.outSoft,
              foreground: c.cashOut,
              title: l.importPdfTitle,
              body: l.importPdfBody,
              action: l.importPdfAction,
              onTap: loading ? null : () => _choose(pdf: true),
            ),
            const SizedBox(height: 16),
            _SourceCard(
              icon: LucideIcons.fileSpreadsheet,
              background: c.soft,
              foreground: c.cashIn,
              title: l.importXlsTitle,
              body: l.importXlsBody,
              action: l.importXlsAction,
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
              child: Column(
                children: [
                  _Tip(LucideIcons.eye, l.importTipReview),
                  const SizedBox(height: 10),
                  _Tip(LucideIcons.copyCheck, l.importTipDuplicates),
                  const SizedBox(height: 10),
                  _Tip(LucideIcons.scanLine, l.importTipScanned),
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

class _PasswordDialog extends StatefulWidget {
  const _PasswordDialog({required this.fileName, required this.wrongPassword});

  final String fileName;
  final bool wrongPassword;

  @override
  State<_PasswordDialog> createState() => _PasswordDialogState();
}

class _PasswordDialogState extends State<_PasswordDialog> {
  final controller = TextEditingController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.pf;
    final l = context.l10n;
    return AlertDialog(
      title: Text(l.pdfPasswordTitle, style: pfText(19, weight: w900)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.wrongPassword
                ? l.pdfPasswordWrong
                : l.pdfPasswordBody(widget.fileName),
            style: pfText(
              14,
              weight: w700,
              color: widget.wrongPassword ? c.cashOut : c.sub,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            autofocus: true,
            obscureText: true,
            enableSuggestions: false,
            autocorrect: false,
            onSubmitted: (value) => Navigator.pop(context, value),
            style: pfText(17, color: c.ink),
            decoration: InputDecoration(
              hintText: l.pdfPasswordHint,
              hintStyle: pfText(17, color: c.mute),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l.cancel, style: pfText(14, color: c.sub)),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, controller.text),
          child: Text(l.pdfPasswordOpen, style: pfText(14, color: c.cashIn)),
        ),
      ],
    );
  }
}
