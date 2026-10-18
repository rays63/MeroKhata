import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:paisa_flow/app/nav.dart';
import 'package:paisa_flow/main.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A CSV statement: one `date,description,debit,credit,balance` per row.
Uint8List _csv(List<String> rows) =>
    utf8.encode(['Date,Description,Debit,Credit,Balance', ...rows].join('\n'));

ParsedStatement _read(String bookId, String name, List<String> rows) =>
    ImportParser.readXls(fileName: name, bookId: bookId, bytes: _csv(rows));

ParsedStatement _statement(
  String name, {
  String? source,
  String? account,
  required double opening,
  required double closing,
  required int day,
}) {
  final at = DateTime(2026, 1, day);
  return ParsedStatement(
    fileName: name,
    format: 'PDF',
    source: source,
    account: account,
    openingBalance: opening,
    closingBalance: closing,
    rows: [
      LedgerTransaction(
        id: name,
        bookId: 'book',
        title: name,
        amount: closing - opening,
        type: TransactionType.cashIn,
        occurredAt: at,
        createdAt: at,
        updatedAt: at,
        category: 'Imported',
        paymentMode: source ?? '',
        notes: '',
        goalId: null,
        runningBalance: 0,
        externalReference: '',
        statementBalance: closing,
        sequence: 1,
        importSource: 'PDF',
      ),
    ],
    ignored: const [],
  );
}

Future<AppStore> _store() async {
  SharedPreferences.setMockInitialValues({});
  final store = AppStore();
  await store.load();
  return store;
}

/// Returns the queued files as one multi-select pick.
class _MultiPicker extends FilePicker with MockPlatformInterfaceMixin {
  _MultiPicker(this.files);

  final List<PlatformFile> files;

  @override
  Future<FilePickerResult?> pickFiles({
    String? dialogTitle,
    String? initialDirectory,
    FileType type = FileType.any,
    List<String>? allowedExtensions,
    Function(FilePickerStatus)? onFileLoading,
    bool allowCompression = false,
    int compressionQuality = 0,
    bool allowMultiple = false,
    bool withData = false,
    bool withReadStream = false,
    bool lockParentWindow = false,
    bool readSequential = false,
  }) async => FilePickerResult(files);
}

void main() {
  test('a row in two overlapping files is imported once', () async {
    final store = await _store();
    final bookId = store.books.first.id;
    // Given out of order: the batch sorts by statement period.
    final later = _read(bookId, 'jan-2.csv', [
      '2026-01-03,Tea,25,,175',
      '2026-01-04,Salary,,500,675',
    ]);
    final earlier = _read(bookId, 'jan-1.csv', [
      '2026-01-01,Momo,50,,150',
      '2026-01-02,Bus,25,,125',
      '2026-01-02,Refund,,75,200',
      '2026-01-03,Tea,25,,175',
    ]);
    final batch = store.previewBatch(bookId, [later, earlier]);

    expect(batch.files.map((f) => f.$1.fileName), ['jan-1.csv', 'jan-2.csv']);
    expect(batch.files.last.$2.duplicates.single.title, 'Tea');
    expect(batch.combined.importable, hasLength(5));
    expect(batch.combined.duplicates, hasLength(1));
    // The earliest statement's opening balance, the latest's closing one.
    expect(batch.combined.openingBalance, 200);
    expect(batch.combined.closingBalance, 675);

    await store.commitImport(batch.combined);
    expect(store.balanceFor(bookId), 675);
  });

  test('a gap between two statements of one account is flagged', () async {
    final store = await _store();
    final batch = store.previewBatch(store.books.first.id, [
      _statement(
        'jan',
        source: 'NIC Asia',
        account: '1',
        opening: 0,
        closing: 100,
        day: 1,
      ),
      _statement(
        'mar',
        source: 'NIC Asia',
        account: '1',
        opening: 300,
        closing: 400,
        day: 20,
      ),
    ]);
    final gap = batch.chainGaps.single;
    expect(
      (gap.from, gap.to, gap.closing, gap.opening),
      ('jan', 'mar', 100, 300),
    );
    expect(batch.sources, ['NIC Asia']);
  });

  test('statements that continue each other have no gap', () async {
    final store = await _store();
    final batch = store.previewBatch(store.books.first.id, [
      _statement(
        'jan',
        source: 'NIC Asia',
        account: '1',
        opening: 0,
        closing: 100,
        day: 1,
      ),
      _statement(
        'feb',
        source: 'NIC Asia',
        account: '1',
        opening: 100,
        closing: 150,
        day: 10,
      ),
    ]);
    expect(batch.chainGaps, isEmpty);
  });

  test(
    'different accounts or unreadable accounts skip the chain check',
    () async {
      final store = await _store();
      final bookId = store.books.first.id;
      final otherAccount = store.previewBatch(bookId, [
        _statement(
          'a',
          source: 'NIC Asia',
          account: '1',
          opening: 0,
          closing: 100,
          day: 1,
        ),
        _statement(
          'b',
          source: 'NIC Asia',
          account: '2',
          opening: 900,
          closing: 950,
          day: 10,
        ),
      ]);
      expect(otherAccount.chainGaps, isEmpty);

      final noAccount = store.previewBatch(bookId, [
        _statement('a', source: 'Nabil Bank', opening: 0, closing: 100, day: 1),
        _statement(
          'b',
          source: 'Nabil Bank',
          opening: 900,
          closing: 950,
          day: 10,
        ),
      ]);
      expect(noAccount.chainGaps, isEmpty);
    },
  );

  test('files from different sources are reported', () async {
    final store = await _store();
    final batch = store.previewBatch(store.books.first.id, [
      _statement(
        'bank',
        source: 'NIC Asia',
        account: '1',
        opening: 0,
        closing: 100,
        day: 1,
      ),
      _statement('wallet', source: 'eSewa', opening: 0, closing: 40, day: 2),
    ]);
    expect(batch.sources, ['NIC Asia', 'eSewa']);
    expect(batch.chainGaps, isEmpty);
  });

  testWidgets('one unreadable file does not block the others', (tester) async {
    tester.view.physicalSize = const Size(390, 844) * 3;
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    final good = _csv(['2026-01-01,Momo,50,,150', '2026-01-02,Bus,25,,125']);
    final bad = utf8.encode('not a statement');
    FilePicker.platform = _MultiPicker([
      PlatformFile(name: 'broken.csv', size: bad.length, bytes: bad),
      PlatformFile(name: 'good.csv', size: good.length, bytes: good),
    ]);
    SharedPreferences.setMockInitialValues({
      'hissabkitab_data_v1': jsonEncode({
        'books': [
          {
            'id': 'b',
            'name': 'Personal',
            'createdAt': '2026-01-01T00:00:00.000',
            'updatedAt': '2026-01-01T00:00:00.000',
          },
        ],
        'transactions': [],
        'onboarded': true,
      }),
    });
    await tester.pumpWidget(const PaisaFlowBootstrap());
    await tester.pumpAndSettle(const Duration(seconds: 3));
    openImport(tester.element(find.byType(IndexedStack)), bookId: 'b');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Choose XLS →'));
    await tester.pumpAndSettle();

    expect(find.text('Review import'), findsOneWidget);
    expect(
      find.textContaining('No entries found in broken.csv'),
      findsOneWidget,
    );
    expect(find.text('Import 2 entries'), findsOneWidget);
  });
}
