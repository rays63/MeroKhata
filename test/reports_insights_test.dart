import 'package:flutter_test/flutter_test.dart';
import 'package:paisa_flow/data/export_service.dart';
import 'package:paisa_flow/data/insights.dart';
import 'package:paisa_flow/data/models.dart';
import 'package:paisa_flow/data/report.dart';
import 'package:paisa_flow/data/xlsx_writer.dart';
import 'package:spreadsheet_decoder/spreadsheet_decoder.dart';

final _now = DateTime(2026, 10, 14, 12);

LedgerTransaction _entry(
  String title,
  double amount, {
  bool isIn = false,
  String category = 'Food',
  String mode = 'Cash',
  DateTime? at,
  double balance = 0,
}) {
  final when = at ?? _now;
  return LedgerTransaction(
    id: title,
    bookId: 'b',
    title: title,
    amount: amount,
    type: isIn ? TransactionType.cashIn : TransactionType.cashOut,
    occurredAt: when,
    createdAt: when,
    updatedAt: when,
    category: category,
    paymentMode: mode,
    notes: '',
    goalId: null,
    runningBalance: balance,
    externalReference: '',
    statementBalance: null,
    sequence: 0,
    importSource: '',
  );
}

final _book = LedgerBook(
  id: 'b',
  name: 'Personal',
  description: '',
  createdAt: _now,
  updatedAt: _now,
);

void main() {
  group('Report', () {
    final entries = [
      _entry(
        'Groceries',
        3460,
        category: 'Groceries',
        mode: 'eSewa',
        balance: 81540,
      ),
      _entry(
        'Salary',
        85000,
        isIn: true,
        category: 'Salary',
        mode: 'Bank',
        balance: 85000,
      ),
      _entry(
        'Bill',
        1840,
        category: 'Utilities',
        mode: 'Khalti',
        at: _now.subtract(const Duration(days: 1)),
      ),
      _entry(
        'Recharge',
        500,
        category: 'Utilities',
        mode: 'Khalti',
        at: _now.subtract(const Duration(days: 1)),
      ),
    ];

    Report report(ReportType type, [Set<ReportField>? fields]) => Report(
      book: _book,
      entries: entries,
      type: type,
      fields: fields ?? ReportField.defaults,
      rangeLabel: 'This month',
    );

    test('totals', () {
      final r = report(ReportType.all);
      expect(r.inflow, 85000);
      expect(r.outflow, 5800);
      expect(r.net, 79200);
    });

    test('category-wise groups entries and sorts by size', () {
      final groups = report(ReportType.category).groups;
      expect(groups.map((g) => g.key), ['Salary', 'Groceries', 'Utilities']);
      final utilities = groups.last;
      expect(utilities.count, 2);
      expect(utilities.net, -2340);
    });

    test('day-wise keeps newest day first', () {
      final groups = report(ReportType.daily).groups;
      expect(groups.map((g) => g.key), ['14 Oct 2026', '13 Oct 2026']);
      expect(groups.first.net, 81540);
    });

    test('all-entries table follows the chosen fields, oldest first', () {
      final table = report(ReportType.all, {
        ReportField.title,
        ReportField.balance,
      }).table();
      expect(table.headers, ['Title', 'Type', 'Amount', 'Balance']);
      expect(table.rows.first, ['Recharge', 'Cash out', -500.0, 0.0]);
      expect(table.rows.last, ['Groceries', 'Cash out', -3460.0, 81540.0]);
    });

    test('summary table has totals per group', () {
      final table = report(ReportType.mode).table();
      expect(table.headers, ['Mode', 'Entries', 'Cash in', 'Cash out', 'Net']);
      expect(
        table.rows,
        anyElement(equals(['Khalti', 2, 0.0, 2340.0, -2340.0])),
      );
    });

    test('file name', () {
      expect(report(ReportType.category).fileStem, 'Personal_Categorywise');
    });
  });

  test('xlsx opens as a workbook with typed cells', () {
    final bytes = writeXlsx(
      sheetName: 'Personal & Co',
      headers: ['Title', 'Amount'],
      rows: [
        ['Momo <with> "friends"', -960.0],
        ['Salary', 85000.0],
      ],
    );
    final book = SpreadsheetDecoder.decodeBytes(bytes);
    final sheet = book.tables.values.single;
    expect(book.tables.keys.single, 'Personal & Co');
    expect(sheet.rows[0], ['Title', 'Amount']);
    expect(sheet.rows[1], ['Momo <with> "friends"', -960]);
    expect(sheet.rows[2][1], 85000);
  });

  group('Insights', () {
    final entries = [
      _entry(
        'Opening',
        42000,
        isIn: true,
        category: 'Opening balance',
        at: DateTime(2026, 10, 1, 9),
      ),
      _entry('Salary', 85000, isIn: true, category: 'Salary', at: _now),
      _entry('Groceries', 3460, category: 'Groceries', mode: 'eSewa', at: _now),
      _entry(
        'Rent',
        22000,
        category: 'Rent',
        mode: 'Bank',
        at: DateTime(2026, 10, 10, 10),
      ),
      _entry(
        'Bill',
        1840,
        category: 'Utilities',
        mode: 'Khalti',
        at: DateTime(2026, 10, 13, 8),
      ),
      _entry('August', 1000, category: 'Food', at: DateTime(2026, 8, 20)),
    ];
    final insights = Insights(entries, now: _now);

    test('month summary counts every entry, including opening balance', () {
      final october = insights.month(DateTime(2026, 10));
      expect(october.inflow, 127000);
      expect(october.outflow, 27300);
      expect(october.byDay.keys, containsAll([1, 10, 13, 14]));
      expect(october.byDay[14]!.length, 2);
      expect(insights.month(DateTime(2026, 9)).net, 0);
    });

    test('7 day trend has one bucket per day ending today', () {
      final trend = insights.trend(TrendRange.week);
      expect(trend.buckets.map((b) => b.label), [
        'Th',
        'Fr',
        'Sa',
        'Su',
        'Mo',
        'Tu',
        'We',
      ]);
      expect(trend.buckets.last.inflow, 85000);
      expect(trend.buckets[5].outflow, 1840);
      expect(trend.income, 85000);
      // Rent on the 10th is inside the last seven days.
      expect(trend.spending, 3460 + 1840 + 22000);
    });

    test('3 month trend excludes opening balance from income', () {
      final trend = insights.trend(TrendRange.quarter);
      expect(trend.buckets.map((b) => b.label), ['Aug', 'Sep', 'Oct']);
      expect(trend.buckets.first.outflow, 1000);
      expect(trend.income, 85000);
      expect(trend.savedRate, closeTo((85000 - 28300) / 85000, 1e-9));
    });

    test('breakdowns rank spending by category and mode', () {
      final trend = insights.trend(TrendRange.month);
      expect(trend.categories.first.name, 'Rent');
      expect(trend.categories.first.share, closeTo(22000 / 27300, 1e-9));
      expect(trend.modes.map((m) => m.name), ['Bank', 'eSewa', 'Khalti']);
    });

    test('year trend has four quarters ending this quarter', () {
      final trend = insights.trend(TrendRange.year);
      expect(trend.buckets.map((b) => b.label), ['Q1', 'Q2', 'Q3', 'Q4']);
      expect(trend.buckets.last.start, DateTime(2026, 10));
    });
  });

  testWidgets('PDF export builds with the bundled fonts', (tester) async {
    final report = Report(
      book: _book,
      entries: [
        _entry('मम खाजा', 960, category: 'खाना', balance: -960),
        _entry('Salary', 85000, isIn: true, balance: 84040),
      ],
      type: ReportType.all,
      fields: ReportField.values.toSet(),
      rangeLabel: 'All time',
      preparedBy: 'Aarav Shrestha',
    );
    final bytes = (await tester.runAsync(
      () => ExportService.buildPdf(report),
    ))!;
    expect(String.fromCharCodes(bytes.take(5)), '%PDF-');
    expect(bytes.length, greaterThan(10000));
  });

  test('file names keep Nepali letters', () {
    final report = Report(
      book: LedgerBook(
        id: 'b',
        name: 'घर खर्च / 2026',
        description: '',
        createdAt: _now,
        updatedAt: _now,
      ),
      entries: const [],
      type: ReportType.daily,
      fields: ReportField.defaults,
      rangeLabel: 'All time',
    );
    expect(report.fileStem, 'घर_खर्च_2026_Daywise');
  });

  test('xlsx sheet names are escaped after truncating', () {
    final name = '${'a' * 28}& Co [main]';
    final bytes = writeXlsx(sheetName: name, headers: ['A'], rows: const []);
    final book = SpreadsheetDecoder.decodeBytes(bytes);
    expect(book.tables.keys.single, '${'a' * 28}& C');
  });
}
