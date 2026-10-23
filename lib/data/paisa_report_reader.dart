import 'dart:convert';
import 'dart:ui' show Rect;

import 'package:intl/intl.dart';

import '../core/amount_input.dart' show maxAmount;
import 'app_store.dart';
import 'models.dart';

/// Reads Paisa Flow's own exported reports back in, so a PDF or Excel file
/// made in Settings or a ledger can be imported into another account or
/// phone.
///
/// - Excel "All entries" reports are a plain table (Date, Title, Category,
///   Payment mode, Notes, Reference, Type, Amount, Balance).
/// - PDF reports made by this version carry the entries as JSON in the
///   document's keywords ([pdfMarker]), which round-trips exactly. Older
///   PDFs are read from their text, best effort.
class PaisaReportReader {
  static const source = 'Paisa Flow';
  static const pdfMarker = 'paisaflow-entries:v1:';
  static final _dateFormat = DateFormat('d MMM y, h:mm a');

  /// The hidden PDF keywords for [entries] (oldest first).
  static String encodeForPdf(List<LedgerTransaction> entries) =>
      pdfMarker +
      jsonEncode([
        for (final e in entries)
          {
            'd': e.occurredAt.toIso8601String(),
            't': e.title,
            'c': e.category,
            if (e.subcategory.isNotEmpty) 's': e.subcategory,
            if (e.paymentMode.isNotEmpty) 'm': e.paymentMode,
            if (e.notes.isNotEmpty) 'n': e.notes,
            if (e.externalReference.isNotEmpty) 'r': e.externalReference,
            if (e.tags.isNotEmpty) 'g': e.tags,
            'i': e.type == TransactionType.cashIn,
            'a': e.amount,
          },
      ]);

  /// Entries hidden in a Paisa Flow PDF's keywords, or null for any other
  /// PDF.
  static List<LedgerTransaction>? fromPdfKeywords(
    String? keywords,
    String bookId,
  ) {
    if (keywords == null || !keywords.startsWith(pdfMarker)) return null;
    try {
      final list = jsonDecode(keywords.substring(pdfMarker.length)) as List;
      return [
        for (final (i, raw) in list.indexed)
          if (((raw as Map)['a'] as num).abs() <= maxAmount)
            () {
              final m = raw.cast<String, Object?>();
              return _entry(
                bookId: bookId,
                date: DateTime.parse(m['d'] as String),
                title: m['t'] as String? ?? '',
                cashIn: m['i'] == true,
                amount: (m['a'] as num).toDouble().abs(),
                category: m['c'] as String? ?? '',
                subcategory: m['s'] as String? ?? '',
                mode: m['m'] as String? ?? '',
                notes: m['n'] as String? ?? '',
                reference: m['r'] as String? ?? '',
                tags: [for (final t in m['g'] as List? ?? const []) '$t'],
                sequence: i,
              );
            }(),
      ];
    } catch (_) {
      return null;
    }
  }

  /// True for text from any Paisa Flow report PDF.
  static bool isPaisaPdf(String text) {
    final flat = _flat(text);
    return flat.startsWith('Paisa Flow') &&
        RegExp(r'Page \d+ of \d+').hasMatch(flat) &&
        flat.contains('Cash in');
  }

  /// A day-, category- or mode-wise report: totals only, nothing to import.
  static bool isSummaryReport(String text) =>
      RegExp(r'(Day-wise|Category-wise|Payment mode) ·').hasMatch(_flat(text));

  static String _flat(String text) =>
      text.replaceAll(RegExp(r'\s+'), ' ').trim();

  /// Entries read from an older Paisa Flow PDF (exported before the hidden
  /// data), from where each word sits on the page. Cells come from the
  /// header's column positions, and each row starts at its "Cash in/out"
  /// word. Date, type and amount are reliable; text cells may have a stray
  /// space where a long word wrapped.
  static List<LedgerTransaction> fromPdfWords(
    List<({String text, Rect box, int page})> words,
    String bookId,
  ) {
    const names = {
      'Date': 'date',
      'Title': 'title',
      'Categor': 'category',
      'Payment': 'mode',
      'Notes': 'notes',
      'Referenc': 'reference',
      'Type': 'type',
      'Amount': 'amount',
      'Balance': 'balance',
    };
    final out = <LedgerTransaction>[];
    // Column name → header centre (headers are centred over their column),
    // carried to pages where the header doesn't repeat.
    var columns = <String, double>{};
    final pages = words.map((w) => w.page).toSet().toList()..sort();
    for (final page in pages) {
      final onPage = [
        for (final w in words)
          if (w.page == page) w,
      ];
      final date = onPage.where((w) => w.text == 'Date').firstOrNull;
      var top = double.negativeInfinity;
      if (date != null) {
        final header = <String, double>{};
        for (final w in onPage) {
          if ((w.box.center.dy - date.box.center.dy).abs() > 10) continue;
          for (final MapEntry(:key, :value) in names.entries) {
            if (w.text.startsWith(key)) {
              header.putIfAbsent(value, () => w.box.center.dx);
            }
          }
        }
        if (header.containsKey('type') && header.containsKey('amount')) {
          columns = header;
          top = date.box.bottom + date.box.height;
        }
      } else {
        final pageLabel = onPage.where((w) => w.text == 'Page').firstOrNull;
        if (pageLabel != null) top = pageLabel.box.bottom;
      }
      if (!columns.containsKey('type') || !columns.containsKey('amount')) {
        continue;
      }
      // Cells are left-aligned (amounts right-aligned), so a column starts
      // halfway between its header's centre and the previous one's.
      final order = columns.entries.toList()
        ..sort((a, b) => a.value.compareTo(b.value));
      final starts = {
        for (var i = 0; i < order.length; i++)
          order[i].key: i == 0
              ? double.negativeInfinity
              : (order[i - 1].value + order[i].value) / 2,
      };
      final typeStart = starts['type']!;
      final balanceStart = starts['balance'];
      final body = [
        for (final w in onPage)
          if (w.box.top > top) w,
      ];
      bool isType(({String text, Rect box, int page}) w) =>
          w.box.left >= typeStart &&
          const {'Cash', 'in', 'out'}.contains(w.text);
      final anchors = [
        for (final w in body)
          if (w.text == 'Cash' && isType(w)) w,
      ]..sort((a, b) => a.box.top.compareTo(b.box.top));
      String columnOf(({String text, Rect box, int page}) w) {
        if (w.box.left >= typeStart) {
          if (isType(w)) return 'type';
          if (balanceStart != null && w.box.right > balanceStart) {
            return 'balance';
          }
          return 'amount';
        }
        var name = '';
        for (final MapEntry(:key, :value) in starts.entries) {
          if (value <= typeStart && w.box.left >= value) {
            if (name.isEmpty || value >= starts[name]!) name = key;
          }
        }
        return name;
      }

      for (var i = 0; i < anchors.length; i++) {
        final slack = anchors[i].box.height / 2;
        final from = anchors[i].box.top - slack;
        final to = i + 1 < anchors.length
            ? anchors[i + 1].box.top - slack
            : double.infinity;
        final cells = <String, List<({String text, Rect box, int page})>>{};
        for (final w in body) {
          if (w.box.top >= from && w.box.top < to) {
            cells.putIfAbsent(columnOf(w), () => []).add(w);
          }
        }
        String cell(String name) {
          final list = cells[name] ?? const [];
          final sorted = [...list]
            ..sort(
              (a, b) => (a.box.top - b.box.top).abs() < 2
                  ? a.box.left.compareTo(b.box.left)
                  : a.box.top.compareTo(b.box.top),
            );
          return sorted.map((w) => w.text).join(' ');
        }

        final when = _tryDate(cell('date'));
        final amount = RegExp(r'[\d,]+(?:\.\d+)?').firstMatch(cell('amount'));
        final value = double.tryParse(
          amount?.group(0)?.replaceAll(',', '') ?? '',
        );
        if (when == null || value == null || value > maxAmount) continue;
        out.add(
          _entry(
            bookId: bookId,
            date: when,
            title: cell('title'),
            cashIn: cell('type') == 'Cash in',
            amount: value,
            category: cell('category'),
            mode: cell('mode'),
            notes: cell('notes'),
            reference: cell('reference'),
            sequence: out.length,
          ),
        );
      }
    }
    return out;
  }

  /// Entries from an exported Excel "All entries" table, or null when the
  /// rows aren't one.
  static List<LedgerTransaction>? fromTable(
    List<List<String>> rows,
    String bookId,
  ) {
    for (var h = 0; h < rows.length && h < 5; h++) {
      final header = [for (final c in rows[h]) c.trim().toLowerCase()];
      final type = header.indexOf('type');
      final amount = header.indexOf('amount');
      if (type == -1 || amount == -1 || !header.contains('date')) continue;
      int col(String name) => header.indexOf(name);
      String cell(List<String> row, int i) =>
          i >= 0 && i < row.length ? row[i].trim() : '';
      final out = <LedgerTransaction>[];
      for (final row in rows.skip(h + 1)) {
        final kind = cell(row, type).toLowerCase();
        if (kind != 'cash in' && kind != 'cash out') continue;
        final date = _tryDate(cell(row, col('date')));
        final value = double.tryParse(cell(row, amount).replaceAll(',', ''));
        if (date == null || value == null || value.abs() > maxAmount) {
          continue;
        }
        out.add(
          _entry(
            bookId: bookId,
            date: date,
            title: cell(row, col('title')),
            cashIn: kind == 'cash in',
            amount: value.abs(),
            category: cell(row, col('category')),
            mode: cell(row, col('payment mode')),
            notes: cell(row, col('notes')),
            reference: cell(row, col('reference')),
            balance: double.tryParse(cell(row, col('balance'))),
            sequence: out.length,
          ),
        );
      }
      return out;
    }
    return null;
  }

  /// A summary export (Day-wise etc.) has "Entries" and "Net" columns.
  static bool isSummaryTable(List<List<String>> rows) => rows
      .take(5)
      .any(
        (row) => row.map((c) => c.trim().toLowerCase()).toSet().containsAll({
          'entries',
          'cash in',
          'cash out',
          'net',
        }),
      );

  static DateTime? _tryDate(String text) {
    if (text.isEmpty) return null;
    try {
      return _dateFormat.parseLoose(text);
    } catch (_) {
      return DateTime.tryParse(text);
    }
  }

  static LedgerTransaction _entry({
    required String bookId,
    required DateTime date,
    required String title,
    required bool cashIn,
    required double amount,
    required String category,
    required int sequence,
    String subcategory = '',
    String mode = '',
    String notes = '',
    String reference = '',
    List<String> tags = const [],
    double? balance,
  }) {
    final now = DateTime.now();
    return LedgerTransaction(
      id: AppStore.newId('txn'),
      bookId: bookId,
      title: title.isEmpty ? (cashIn ? 'Cash in' : 'Cash out') : title,
      amount: amount,
      type: cashIn ? TransactionType.cashIn : TransactionType.cashOut,
      occurredAt: date,
      createdAt: now,
      updatedAt: now,
      category: category.isEmpty ? 'Imported' : category,
      paymentMode: mode,
      notes: notes,
      goalId: null,
      runningBalance: 0,
      externalReference: reference,
      statementBalance: balance,
      sequence: sequence,
      importSource: source,
      tags: tags,
      subcategory: subcategory,
    );
  }
}
