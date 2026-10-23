import 'package:intl/intl.dart';

import '../core/format.dart';
import 'models.dart';

/// Shared label for entries without a category (reports and Insights).
const uncategorised = 'Uncategorised';

enum ReportType {
  all('All entries', 'ENTRY'),
  daily('Day-wise', 'DAY'),
  category('Category-wise', 'CATEGORY'),
  mode('Payment mode', 'MODE');

  const ReportType(this.label, this.column);
  final String label;

  /// Heading of the first preview column.
  final String column;

  String get fileTag => label.replaceAll(RegExp(r'\W'), '');
}

/// Optional columns of an "All entries" export. Amount is always included.
enum ReportField {
  date('Date'),
  title('Title'),
  category('Category'),
  mode('Payment mode'),
  notes('Notes'),
  balance('Balance'),
  reference('Reference');

  const ReportField(this.label);
  final String label;

  static const defaults = {date, title, category, mode, balance};
}

/// One line of a grouped report (a day, category or payment mode).
class ReportGroup {
  ReportGroup(this.key);

  final String key;
  int count = 0;
  double inflow = 0;
  double outflow = 0;

  double get net => inflow - outflow;
}

/// A snapshot of a book's filtered entries, ready to preview or export.
class Report {
  Report({
    required this.book,
    required this.entries,
    required this.type,
    required this.fields,
    required this.rangeLabel,
    this.preparedBy = '',
  });

  final LedgerBook book;

  /// Newest first, as shown in the ledger.
  final List<LedgerTransaction> entries;
  final ReportType type;
  final Set<ReportField> fields;
  final String rangeLabel;
  final String preparedBy;

  String get currency => book.currency;

  double get inflow => entries
      .where((e) => e.type == TransactionType.cashIn)
      .fold(0, (sum, e) => sum + e.amount);

  double get outflow => entries
      .where((e) => e.type == TransactionType.cashOut)
      .fold(0, (sum, e) => sum + e.amount);

  double get net => inflow - outflow;

  /// Groups in first-seen order (newest day first for day-wise), or empty
  /// for an "All entries" report. Computed once per report.
  late final List<ReportGroup> groups = _group();

  List<ReportGroup> _group() {
    if (type == ReportType.all) return const [];
    final dayFormat = DateFormat('d MMM y');
    String keyOf(LedgerTransaction entry) => switch (type) {
      ReportType.daily => dayFormat.format(entry.occurredAt),
      ReportType.category =>
        entry.category.trim().isEmpty ? uncategorised : entry.category,
      ReportType.mode =>
        entry.paymentMode.trim().isEmpty ? 'Not set' : entry.paymentMode,
      ReportType.all => '',
    };
    final groups = <String, ReportGroup>{};
    for (final entry in entries) {
      final key = keyOf(entry);
      final group = groups.putIfAbsent(key, () => ReportGroup(key));
      group.count++;
      if (entry.type == TransactionType.cashIn) {
        group.inflow += entry.amount;
      } else {
        group.outflow += entry.amount;
      }
    }
    final list = groups.values.toList();
    if (type != ReportType.daily) {
      list.sort((a, b) => b.net.abs().compareTo(a.net.abs()));
    }
    return list;
  }

  /// Entries in export order: oldest first, so the balance column reads
  /// down like a passbook.
  List<LedgerTransaction> get chronological => entries.reversed.toList();

  /// Ordered export columns for an "All entries" report.
  List<ReportField> get columns => [
    for (final field in ReportField.values)
      if (fields.contains(field)) field,
  ];

  /// Header row and data rows as plain values (numbers stay numbers so the
  /// spreadsheet can sum them).
  ({List<String> headers, List<List<Object>> rows}) table() {
    if (type != ReportType.all) {
      return (
        headers: [
          type.column.toLowerCaseTitle(),
          'Entries',
          'Cash in',
          'Cash out',
          'Net',
        ],
        rows: [
          for (final group in groups)
            [group.key, group.count, group.inflow, group.outflow, group.net],
        ],
      );
    }
    final cols = columns;
    return (
      headers: [
        for (final field in cols)
          if (field != ReportField.balance) field.label,
        'Type',
        'Amount',
        if (cols.contains(ReportField.balance)) 'Balance',
      ],
      rows: [
        for (final entry in chronological)
          [
            for (final field in cols)
              if (field != ReportField.balance) _cell(entry, field),
            entry.type == TransactionType.cashIn ? 'Cash in' : 'Cash out',
            entry.signedAmount,
            if (cols.contains(ReportField.balance)) entry.runningBalance,
          ],
      ],
    );
  }

  static Object _cell(LedgerTransaction entry, ReportField field) =>
      switch (field) {
        ReportField.date => DateFormat(
          'd MMM y, h:mm a',
        ).format(entry.occurredAt),
        ReportField.title => entry.title,
        ReportField.category => entry.category,
        ReportField.mode => entry.paymentMode,
        ReportField.notes => entry.notes,
        ReportField.balance => entry.runningBalance,
        ReportField.reference => entry.externalReference,
      };

  /// e.g. `Personal_Categorywise`; keeps Devanagari and other letters.
  String get fileStem {
    final name = book.name
        .replaceAll(RegExp(r'[^\p{L}\p{M}\p{N}_-]+', unicode: true), '_')
        .replaceAll(RegExp(r'^_+|_+$'), '');
    return '${name.isEmpty ? 'Account' : name}_${type.fileTag}';
  }

  String formatAmount(num value) => money(value, currency);
}

extension on String {
  String toLowerCaseTitle() =>
      isEmpty ? this : '${this[0]}${substring(1).toLowerCase()}';
}
