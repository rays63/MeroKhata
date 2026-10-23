import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:paisa_flow/core/amount_input.dart';
import 'package:paisa_flow/data/export_service.dart';
import 'package:paisa_flow/data/paisa_report_reader.dart';
import 'package:paisa_flow/data/report.dart';
import 'package:paisa_flow/data/xlsx_writer.dart';
import 'package:paisa_flow/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart' as sfpdf;

final _now = DateTime(2026, 10, 14, 12, 30);

LedgerTransaction _entry(
  String title,
  double amount, {
  bool isIn = false,
  String category = 'Food',
  String sub = '',
  String mode = 'Cash',
  String notes = '',
  String reference = '',
  List<String> tags = const [],
  int day = 14,
  double balance = 0,
}) {
  final when = DateTime(2026, 10, day, 12, 30);
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
    notes: notes,
    goalId: null,
    runningBalance: balance,
    externalReference: reference,
    statementBalance: null,
    sequence: 0,
    importSource: '',
    tags: tags,
    subcategory: sub,
  );
}

final _book = LedgerBook(
  id: 'b',
  name: 'Personal',
  description: '',
  createdAt: _now,
  updatedAt: _now,
);

// Newest first, as a ledger passes them to a report.
final _entries = [
  _entry(
    'Mega Mart',
    3460.5,
    category: 'Food',
    sub: 'Groceries',
    mode: 'eSewa',
    notes: 'weekly',
    reference: 'TXN-77',
    tags: ['home'],
    day: 14,
    balance: 81539.5,
  ),
  _entry(
    'Salary',
    85000,
    isIn: true,
    category: 'Salary',
    day: 1,
    balance: 85000,
  ),
];

Report _report(ReportType type) => Report(
  book: _book,
  entries: _entries,
  type: type,
  fields: ReportField.values.toSet(),
  rangeLabel: 'All time',
);

List<int> _xlsx(Report report) {
  final table = report.table();
  return writeXlsx(
    sheetName: report.book.name,
    headers: table.headers,
    rows: table.rows,
  );
}

void main() {
  group('importing Paisa Flow reports', () {
    test('an Excel "All entries" report reads back', () {
      final parsed = ImportParser.readXls(
        fileName: 'Personal_Allentries.xlsx',
        bookId: 'x',
        bytes: _xlsx(_report(ReportType.all)),
      );
      expect(parsed.source, PaisaReportReader.source);
      expect(parsed.rows, hasLength(2));
      final salary = parsed.rows.first;
      expect(salary.title, 'Salary');
      expect(salary.type, TransactionType.cashIn);
      expect(salary.amount, 85000);
      expect(salary.occurredAt, DateTime(2026, 10, 1, 12, 30));
      final mart = parsed.rows.last;
      expect(mart.type, TransactionType.cashOut);
      expect(mart.amount, 3460.5);
      expect(mart.category, 'Food');
      expect(mart.paymentMode, 'eSewa');
      expect(mart.notes, 'weekly');
      expect(mart.externalReference, 'TXN-77');
      expect(mart.bookId, 'x');
    });

    test('an Excel summary report says it has no entries', () {
      expect(
        () => ImportParser.readXls(
          fileName: 'Personal_Daywise.xlsx',
          bookId: 'x',
          bytes: _xlsx(_report(ReportType.daily)),
        ),
        throwsA(isA<SummaryReportException>()),
      );
    });

    testWidgets('a PDF report reads back exactly', (tester) async {
      final bytes = (await tester.runAsync(
        () => ExportService.buildPdf(_report(ReportType.all)),
      ))!;
      final parsed = ImportParser.readPdf(
        fileName: 'Personal_Allentries.pdf',
        bookId: 'x',
        bytes: bytes,
      );
      expect(parsed.source, PaisaReportReader.source);
      expect(parsed.rows.map((e) => e.title), ['Salary', 'Mega Mart']);
      final mart = parsed.rows.last;
      expect(mart.amount, 3460.5);
      expect(mart.subcategory, 'Groceries');
      expect(mart.tags, ['home']);
      expect(mart.occurredAt, DateTime(2026, 10, 14, 12, 30));
    });

    testWidgets('an older PDF report is read from its text', (tester) async {
      final bytes = (await tester.runAsync(
        () => ExportService.buildPdf(_report(ReportType.all)),
      ))!;
      final document = sfpdf.PdfDocument(inputBytes: bytes);
      final text = sfpdf.PdfTextExtractor(document).extractText();
      final words = [
        for (final line in sfpdf.PdfTextExtractor(document).extractTextLines())
          for (final word in line.wordCollection)
            (text: word.text, box: word.bounds, page: line.pageIndex),
      ];
      document.dispose();
      expect(PaisaReportReader.isPaisaPdf(text), isTrue);
      final rows = PaisaReportReader.fromPdfWords(words, 'x');
      expect(rows.map((e) => e.title), ['Salary', 'Mega Mart']);
      expect(rows.last.category, 'Food');
      expect(rows.last.paymentMode, 'eSewa');
      expect(rows.last.externalReference, 'TXN-77');
      expect(rows.last.occurredAt, DateTime(2026, 10, 14, 12, 30));
      expect(rows.map((e) => (e.type, e.amount)), [
        (TransactionType.cashIn, 85000),
        (TransactionType.cashOut, 3460.5),
      ]);
    });

    testWidgets('a PDF summary report says it has no entries', (tester) async {
      final bytes = (await tester.runAsync(
        () => ExportService.buildPdf(_report(ReportType.category)),
      ))!;
      expect(
        () => ImportParser.readPdf(
          fileName: 'Personal_Categorywise.pdf',
          bookId: 'x',
          bytes: bytes,
        ),
        throwsA(isA<SummaryReportException>()),
      );
    });
  });

  group('amount input', () {
    TextEditingValue type(
      String before,
      String after, {
      bool decimals = true,
    }) => AmountInputFormatter(decimals: decimals).formatEditUpdate(
      TextEditingValue(
        text: before,
        selection: TextSelection.collapsed(offset: before.length),
      ),
      TextEditingValue(
        text: after,
        selection: TextSelection.collapsed(offset: after.length),
      ),
    );

    test('blocks a second decimal point and a third decimal', () {
      expect(type('1.1', '1.1.').text, '1.1');
      expect(type('1.25', '1.255').text, '1.25');
      expect(type('12', '12.').text, '12.');
    });

    test('stops at 11 digits before the point', () {
      expect(type('99999999999', '999999999999').text, '99999999999');
      expect(type('', '1111111111111111111111').text, '');
    });

    test('drops pasted commas and letters', () {
      expect(type('', '1,250.50').text, '1250.50');
      expect(type('12', '12a').text, '12');
    });

    test('whole numbers only when decimals are off', () {
      expect(type('12', '12.', decimals: false).text, '12');
    });

    test('readAmount says what is wrong', () {
      expect(readAmount('').problem, AmountProblem.empty);
      expect(readAmount('1.1.1').problem, AmountProblem.invalid);
      expect(readAmount('0').problem, AmountProblem.zero);
      expect(readAmount('0', allowZero: true).value, 0);
      expect(readAmount('100000000000').problem, AmountProblem.tooLarge);
      expect(readAmount('1,250.5').value, 1250.5);
      expect(readAmount('$maxAmount').value, maxAmount);
    });
  });

  testWidgets('a huge amount still leaves room for the title', (tester) async {
    SharedPreferences.setMockInitialValues({
      'hissabkitab_data_v1': jsonEncode({
        'onboarded': true,
        'defaultCurrency': 'NPR',
        'books': [
          {
            'id': 'b',
            'name': 'Personal',
            'createdAt': '2026-01-01T00:00:00.000',
            'updatedAt': '2026-01-01T00:00:00.000',
            'currency': 'NPR',
            'type': 'bank',
          },
        ],
        'transactions': [
          {
            'id': 'big',
            'bookId': 'b',
            'title': 'Land deposit',
            'amount': maxAmount,
            'type': 'cashIn',
            'occurredAt': DateTime.now().toIso8601String(),
            'createdAt': DateTime.now().toIso8601String(),
            'updatedAt': DateTime.now().toIso8601String(),
            'category': 'Salary',
            'paymentMode': 'Cash',
            'notes': '',
          },
        ],
      }),
    });
    tester.view.physicalSize = const Size(1080, 2340);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const PaisaFlowBootstrap());
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 2));
    expect(find.text('Land deposit'), findsWidgets);
    expect(tester.takeException(), isNull);
  });
}
