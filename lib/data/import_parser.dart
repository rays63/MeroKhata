import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:spreadsheet_decoder/spreadsheet_decoder.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart' as sfpdf;

import 'app_store.dart';
import 'legacy_xls_reader.dart';
import 'models.dart';

typedef _TableHeader = ({
  int row,
  int date,
  int? description,
  int debit,
  int credit,
  int? balance,
  int? reference,
  int? status,
});

class ImportParser {
  static Future<ImportPreview> parsePdf({
    required AppStore store,
    required String bookId,
  }) async {
    final file = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['pdf'],
      withData: true,
    );
    final bytes = file?.files.single.bytes;
    if (bytes == null) {
      return const ImportPreview(
        source: 'PDF',
        importable: [],
        duplicates: [],
        ignored: [],
      );
    }
    return parsePdfBytes(store: store, bookId: bookId, bytes: bytes);
  }

  static ImportPreview parsePdfBytes({
    required AppStore store,
    required String bookId,
    required List<int> bytes,
  }) {
    sfpdf.PdfDocument? document;
    final String text;
    try {
      document = sfpdf.PdfDocument(inputBytes: bytes);
      text = sfpdf.PdfTextExtractor(document).extractText();
    } finally {
      document?.dispose();
    }
    final (parsed, ignored) = _statementRecords(text, bookId, 'PDF');
    if (parsed.isEmpty) {
      return _parseText(
        store: store,
        bookId: bookId,
        source: 'PDF',
        text: text,
      );
    }
    return store.previewImport(
      bookId: bookId,
      source: 'PDF',
      parsed: parsed,
      ignored: ignored,
    );
  }

  static Future<ImportPreview> parseXls({
    required AppStore store,
    required String bookId,
  }) async {
    final file = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['xls', 'xlsx', 'csv', 'tsv'],
      withData: true,
    );
    final bytes = file?.files.single.bytes;
    if (bytes == null) {
      return const ImportPreview(
        source: 'XLS',
        importable: [],
        duplicates: [],
        ignored: [],
      );
    }
    return parseXlsBytes(store: store, bookId: bookId, bytes: bytes);
  }

  static ImportPreview parseXlsBytes({
    required AppStore store,
    required String bookId,
    required List<int> bytes,
  }) {
    List<List<String>> rows;
    try {
      if (LegacyXlsReader.isLegacyXls(bytes)) {
        rows = LegacyXlsReader.read(bytes).expand((sheet) => sheet).toList();
      } else {
        final workbook = SpreadsheetDecoder.decodeBytes(bytes);
        rows = [
          for (final table in workbook.tables.values)
            for (final row in table.rows)
              row.map((cell) => cell?.toString().trim() ?? '').toList(),
        ];
      }
    } catch (_) {
      final text = utf8.decode(bytes, allowMalformed: true);
      rows = _delimitedRows(text);
      if (_findHeader(rows) == null) {
        return _parseText(
          store: store,
          bookId: bookId,
          source: 'XLS',
          text: text,
        );
      }
    }
    final (parsed, ignored) = _tableRecords(rows, bookId, 'XLS');
    return store.previewImport(
      bookId: bookId,
      source: 'XLS',
      parsed: parsed,
      ignored: ignored,
    );
  }

  /// Parses bank statement text where every table cell is extracted on its
  /// own line (NIC Asia, Nabil, Standard Chartered, ...). Each record is a
  /// date line, one or more description lines, then debit, credit and
  /// balance lines ("-" for an empty column).
  static (List<LedgerTransaction>, List<String>) _statementRecords(
    String text,
    String bookId,
    String source,
  ) {
    final parsed = <LedgerTransaction>[];
    final ignored = <String>[];
    var inTable = false;
    var creditFirst = false;
    final headerColumns = <String>[];
    var inHeader = false;
    DateTime? date;
    final description = StringBuffer();
    final run = <String>[];
    final values = <double>[];
    var sequence = 0;

    for (final raw in text.split(RegExp(r'\r?\n'))) {
      final token = raw.trim();
      if (token.isEmpty) continue;
      final lower = token.toLowerCase();

      // The column header ("Description ... Balance") marks the table body.
      // It repeats on every page, sometimes after the account summary, so a
      // record still open at that point is page furniture, not a transaction.
      if (lower == 'description') {
        date = null;
        inHeader = true;
        headerColumns.clear();
        continue;
      }
      if (inHeader) {
        if (lower == 'balance') {
          inHeader = false;
          inTable = true;
          final first = headerColumns.firstOrNull ?? '';
          creditFirst = first.contains('credit') || first.contains('deposit');
        } else {
          headerColumns.add(lower);
        }
        continue;
      }
      if (!inTable) continue;

      if (date == null) {
        date = _statementDate(token);
        description.clear();
        run.clear();
        values.clear();
        continue;
      }

      final amount = token == '-' ? 0.0 : _statementAmount(token);
      if (amount == null) {
        run.forEach(description.write);
        run.clear();
        values.clear();
        description.write(raw);
        continue;
      }
      run.add(raw);
      values.add(amount);
      if (values.length < 3) continue;

      final title = description
          .toString()
          .replaceAll(RegExp(r'\s+'), ' ')
          .trim();
      final debit = creditFirst ? values[1] : values[0];
      final credit = creditFirst ? values[0] : values[1];
      final balance = values[2];
      final titleLower = title.toLowerCase();
      if ((debit == 0 && credit == 0) ||
          titleLower == 'opening balance' ||
          titleLower == 'closing balance') {
        ignored.add('$title | ${run.join(' | ')}');
      } else {
        parsed.add(
          _transaction(
            bookId: bookId,
            title: title.isEmpty ? 'Imported transaction' : title,
            amount: debit > 0 ? debit : credit,
            type: debit > 0 ? TransactionType.cashOut : TransactionType.cashIn,
            date: date,
            source: source,
            sequence: ++sequence,
            balance: balance,
          ),
        );
      }
      date = null;
    }
    return (parsed, ignored);
  }

  static DateTime? _statementDate(String token) {
    final match = RegExp(
      r'^(\d{4}-\d{2}-\d{2}|\d{2}[-/]\d{2}[-/]\d{4})'
      r'(?: \d{1,2}:\d{2}(?::\d{0,2}(?:\.\d+)?)?)?$',
    ).firstMatch(token);
    return match == null ? null : _parseDate(token);
  }

  static double? _statementAmount(String token) {
    final match = RegExp(
      r'^(?:NPR\.?\s*)?(-?[\d,]+\.\d{1,2})$',
    ).firstMatch(token);
    return match == null ? null : _parseAmount(match.group(1)!);
  }

  /// Parses spreadsheet rows using the header row to locate the date,
  /// description, debit, credit, balance, reference and status columns.
  static (List<LedgerTransaction>, List<String>) _tableRecords(
    List<List<String>> rows,
    String bookId,
    String source,
  ) {
    final parsed = <LedgerTransaction>[];
    final ignored = <String>[];
    final header = _findHeader(rows);
    if (header == null) {
      var sequence = 0;
      for (final cells in rows.skip(1)) {
        if (cells.every((cell) => cell.isEmpty)) continue;
        final transaction = _fromCells(cells, bookId, source, ++sequence);
        if (transaction == null) {
          ignored.add(cells.join(' | '));
        } else {
          parsed.add(transaction);
        }
      }
      return (parsed, ignored);
    }

    String cell(List<String> cells, int? index) =>
        index == null || index >= cells.length ? '' : cells[index].trim();

    var sequence = 0;
    for (final cells in rows.skip(header.row + 1)) {
      if (cells.every((value) => value.trim().isEmpty)) continue;
      final date = _parseDate(cell(cells, header.date));
      final status = cell(cells, header.status).toLowerCase();
      final debit = _parseAmount(cell(cells, header.debit))?.abs() ?? 0;
      final credit = _parseAmount(cell(cells, header.credit))?.abs() ?? 0;
      final skipped =
          date == null ||
          (debit == 0 && credit == 0) ||
          (status.isNotEmpty &&
              !const {
                'complete',
                'completed',
                'success',
                'successful',
              }.contains(status));
      if (skipped) {
        ignored.add(cells.join(' | '));
        continue;
      }
      final title = cell(cells, header.description);
      parsed.add(
        _transaction(
          bookId: bookId,
          title: title.isEmpty ? 'Imported transaction' : title,
          amount: debit > 0 ? debit : credit,
          type: debit > 0 ? TransactionType.cashOut : TransactionType.cashIn,
          date: date,
          source: source,
          sequence: ++sequence,
          reference: cell(cells, header.reference),
          balance: _parseAmount(cell(cells, header.balance)),
        ),
      );
    }
    return (parsed, ignored);
  }

  static _TableHeader? _findHeader(List<List<String>> rows) {
    for (var index = 0; index < rows.length; index++) {
      int? date, description, debit, credit, balance, reference, status;
      final cells = rows[index];
      for (var column = 0; column < cells.length; column++) {
        final name = cells[column].toLowerCase().replaceAll(
          RegExp(r'[^a-z]'),
          '',
        );
        if (name.isEmpty) continue;
        if (date == null && name.contains('date')) {
          date = column;
        } else if (description == null &&
            RegExp(
              'description|particular|narration|remark|detail',
            ).hasMatch(name)) {
          description = column;
        } else if (debit == null &&
            (name == 'dr' ||
                name.startsWith('debit') ||
                name.startsWith('withdraw'))) {
          debit = column;
        } else if (credit == null &&
            (name == 'cr' ||
                name.startsWith('credit') ||
                name.startsWith('deposit'))) {
          credit = column;
        } else if (balance == null && name.startsWith('balance')) {
          balance = column;
        } else if (reference == null &&
            (name.startsWith('ref') || name.contains('cheque'))) {
          reference = column;
        } else if (status == null && name == 'status') {
          status = column;
        }
      }
      if (date != null && debit != null && credit != null) {
        return (
          row: index,
          date: date,
          description: description,
          debit: debit,
          credit: credit,
          balance: balance,
          reference: reference,
          status: status,
        );
      }
    }
    return null;
  }

  static List<List<String>> _delimitedRows(String text) {
    final lines = text.split(RegExp(r'\r?\n'));
    final delimiter = lines.any((line) => line.contains('\t')) ? '\t' : ',';
    return [for (final line in lines) _splitDelimited(line, delimiter)];
  }

  static List<String> _splitDelimited(String line, String delimiter) {
    final cells = <String>[];
    final current = StringBuffer();
    var quoted = false;
    for (var i = 0; i < line.length; i++) {
      final char = line[i];
      if (char == '"') {
        if (quoted && i + 1 < line.length && line[i + 1] == '"') {
          current.write('"');
          i++;
        } else {
          quoted = !quoted;
        }
      } else if (char == delimiter && !quoted) {
        cells.add(current.toString().trim());
        current.clear();
      } else {
        current.write(char);
      }
    }
    cells.add(current.toString().trim());
    return cells;
  }

  static ImportPreview _parseText({
    required AppStore store,
    required String bookId,
    required String source,
    required String text,
  }) {
    final parsed = <LedgerTransaction>[];
    final ignored = <String>[];
    var sequence = 0;
    for (final line in text.split(RegExp(r'\r?\n'))) {
      final clean = line.trim().replaceAll(RegExp(r'\s+'), ' ');
      if (clean.isEmpty || _isHeader(clean)) continue;
      sequence++;
      final transaction = _fromLine(clean, bookId, source, sequence);
      if (transaction == null) {
        ignored.add(clean);
      } else {
        parsed.add(transaction);
      }
    }
    return store.previewImport(
      bookId: bookId,
      source: source,
      parsed: parsed,
      ignored: ignored,
    );
  }

  static LedgerTransaction? _fromCells(
    List<String> cells,
    String bookId,
    String source,
    int sequence,
  ) {
    final date = cells.map(_parseDate).whereType<DateTime>().firstOrNull;
    final amounts = cells.map(_parseAmount).whereType<double>().toList();
    if (date == null || amounts.isEmpty) return null;
    final joined = cells.join(' ');
    final title = cells.firstWhere(
      (cell) =>
          cell.length > 2 &&
          _parseDate(cell) == null &&
          _parseAmount(cell) == null,
      orElse: () => 'Imported transaction',
    );
    final reference = cells.firstWhere(
      (cell) => RegExp(r'[A-Za-z]{2,}\d{2,}|\d{6,}').hasMatch(cell),
      orElse: () => '',
    );
    final amount = amounts.firstWhere((value) => value != 0, orElse: () => 0);
    final lower = joined.toLowerCase();
    final type =
        amount < 0 ||
            lower.contains('debit') ||
            lower.contains('withdrawal') ||
            lower.contains(' dr ')
        ? TransactionType.cashOut
        : TransactionType.cashIn;
    return _transaction(
      bookId: bookId,
      title: title,
      amount: amount.abs(),
      type: type,
      date: date,
      source: source,
      sequence: sequence,
      reference: reference,
    );
  }

  static LedgerTransaction? _fromLine(
    String line,
    String bookId,
    String source,
    int sequence,
  ) {
    final date = _firstDate(line);
    final amounts = RegExp(r'[-+]?\d[\d,]*(\.\d+)?')
        .allMatches(line)
        .map((match) => _parseAmount(match.group(0)!))
        .whereType<double>()
        .toList();
    if (date == null || amounts.isEmpty) return null;
    final amount = amounts.last;
    final balance = amounts.length > 1 ? amounts[amounts.length - 2] : null;
    final lower = line.toLowerCase();
    final type =
        amount < 0 ||
            lower.contains('debit') ||
            lower.contains('withdrawal') ||
            lower.contains(' cash out ') ||
            lower.contains(' dr ')
        ? TransactionType.cashOut
        : TransactionType.cashIn;
    final title = line
        .replaceAll(RegExp(r'\d{1,4}[-/]\d{1,2}[-/]\d{1,4}'), '')
        .replaceAll(RegExp(r'[-+]?\d[\d,]*(\.\d+)?'), '')
        .replaceAll(
          RegExp(r'\b(debit|credit|dr|cr)\b', caseSensitive: false),
          '',
        )
        .trim();
    return _transaction(
      bookId: bookId,
      title: title.isEmpty ? 'Imported transaction' : title,
      amount: amount.abs(),
      type: type,
      date: date,
      source: source,
      sequence: sequence,
      balance: balance,
    );
  }

  static LedgerTransaction _transaction({
    required String bookId,
    required String title,
    required double amount,
    required TransactionType type,
    required DateTime date,
    required String source,
    required int sequence,
    String reference = '',
    double? balance,
  }) {
    final now = DateTime.now();
    return LedgerTransaction(
      id: AppStore.newId('txn'),
      bookId: bookId,
      title: title,
      amount: amount,
      type: type,
      occurredAt: date,
      createdAt: now,
      updatedAt: now,
      category: 'Imported',
      paymentMode: '',
      notes: '',
      goalId: null,
      runningBalance: 0,
      externalReference: reference,
      statementBalance: balance,
      sequence: sequence,
      importSource: source,
    );
  }

  static bool _isHeader(String line) {
    final lower = line.toLowerCase();
    return lower.contains('date') &&
        (lower.contains('description') ||
            lower.contains('particular') ||
            lower.contains('amount'));
  }

  static DateTime? _firstDate(String input) {
    final match = RegExp(
      r'\b(\d{4}[-/]\d{1,2}[-/]\d{1,2}|\d{1,2}[-/]\d{1,2}[-/]\d{2,4})\b',
    ).firstMatch(input);
    return match == null ? null : _parseDate(match.group(1)!);
  }

  static DateTime? _parseDate(String input) {
    final match = RegExp(
      r'^(\S+?)(?:[ T](\d{1,2}):(\d{2})(?::(\d{0,2}))?(?:\.\d+)?)?$',
    ).firstMatch(input.trim());
    if (match == null) return null;
    for (final pattern in const [
      'yyyy-MM-dd',
      'yyyy/MM/dd',
      'dd-MM-yyyy',
      'dd/MM/yyyy',
      'dd-MMM-yyyy',
      'MM-dd-yyyy',
      'MM/dd/yyyy',
    ]) {
      try {
        final date = DateFormat(pattern).parseStrict(match.group(1)!);
        return DateTime(
          date.year,
          date.month,
          date.day,
          int.tryParse(match.group(2) ?? '') ?? 0,
          int.tryParse(match.group(3) ?? '') ?? 0,
          int.tryParse(match.group(4) ?? '') ?? 0,
        );
      } on FormatException {
        continue;
      }
    }
    return null;
  }

  static double? _parseAmount(String input) {
    return double.tryParse(
      input.replaceAll(',', '').replaceAll(RegExp(r'[^0-9.+-]'), ''),
    );
  }
}
