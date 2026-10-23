import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:paisa_flow/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart' as sfpdf;

/// Real bank/wallet statements kept locally (not committed). Tests that need
/// them are skipped when the folder is absent.
final _statements = Directory('.claude/test statement');

/// Statements from sources without a parser yet (Khalti: build 6) are kept
/// in the folder for later but left out of these checks.
const _notSupportedYet = {'khalti.xls'};

bool _isSupportedStatement(File file) =>
    RegExp(r'\.(pdf|xls)$').hasMatch(file.path) &&
    !_notSupportedYet.contains(file.uri.pathSegments.last);

File _file(String name) => File('${_statements.path}/$name');

/// Passwords for locked statements, keyed by file name, in
/// `.claude/test statement/passwords.json` (local only, never committed).
final Map<String, String> _passwords = () {
  final file = _file('passwords.json');
  if (!file.existsSync()) return <String, String>{};
  return (jsonDecode(file.readAsStringSync()) as Map).cast<String, String>();
}();

bool _hasPassword(File file) =>
    _passwords.containsKey(file.uri.pathSegments.last);

bool _isLocked(File file) {
  try {
    sfpdf.PdfDocument(inputBytes: file.readAsBytesSync()).dispose();
    return false;
  } on ArgumentError catch (error) {
    return error.name == 'password';
  }
}

ImportPreview _parse(AppStore store, String bookId, File file) {
  final bytes = file.readAsBytesSync();
  return file.path.endsWith('.pdf')
      ? ImportParser.parsePdfBytes(
          store: store,
          bookId: bookId,
          bytes: bytes,
          password: _passwords[file.uri.pathSegments.last],
        )
      : ImportParser.parseXlsBytes(store: store, bookId: bookId, bytes: bytes);
}

double _total(Iterable<LedgerTransaction> rows, TransactionType type) => rows
    .where((row) => row.type == type)
    .fold(0, (total, row) => total + row.amount);

/// Opening and closing balances printed in a PDF statement's summary, if any.
(double, double)? _summary(File file) {
  final document = sfpdf.PdfDocument(
    inputBytes: file.readAsBytesSync(),
    password: _passwords[file.uri.pathSegments.last],
  );
  final text = sfpdf.PdfTextExtractor(document).extractText();
  document.dispose();
  double? find(String label) {
    final match = RegExp(
      '$label\\s*:?\\s*(?:NPR\\.\\s*)?([\\d,]+\\.\\d{2})',
    ).firstMatch(text);
    return match == null
        ? null
        : double.parse(match.group(1)!.replaceAll(',', ''));
  }

  final opening = find('Opening Balance');
  final closing = find('Closing Balance');
  return opening == null || closing == null ? null : (opening, closing);
}

Future<AppStore> _freshStore() async {
  SharedPreferences.setMockInitialValues({});
  final store = AppStore();
  await store.load();
  return store;
}

void main() {
  final skip = _statements.existsSync()
      ? false
      : 'Local test statements not present';

  group('statement parsing', () {
    final files = _statements.existsSync()
        ? (_statements
              .listSync(recursive: true)
              .whereType<File>()
              .where(_isSupportedStatement)
              .toList()
            ..sort((a, b) => a.path.compareTo(b.path)))
        : <File>[];

    for (final file in files) {
      final name = file.path.split('test statement/').last;
      final locked = file.path.endsWith('.pdf') && _isLocked(file);
      if (locked) {
        test('$name asks for a password, then rejects a wrong one', () {
          final bytes = file.readAsBytesSync();
          ImportPreview parse(String? password) => ImportParser.parsePdfBytes(
            store: AppStore(),
            bookId: 'book',
            bytes: bytes,
            password: password,
          );
          expect(
            () => parse(null),
            throwsA(
              isA<PdfPasswordException>().having(
                (e) => e.wrongPassword,
                'wrongPassword',
                isFalse,
              ),
            ),
          );
          expect(
            () => parse('not-the-password'),
            throwsA(
              isA<PdfPasswordException>().having(
                (e) => e.wrongPassword,
                'wrongPassword',
                isTrue,
              ),
            ),
          );
        });
      }
      test(
        '$name parses every row consistently',
        () {
          final rows = _parse(AppStore(), 'book', file).importable;
          expect(rows, isNotEmpty);

          // Each row's previous balance (balance - signed amount) must be the
          // balance of another row, except for the very first transaction,
          // which starts from the opening balance. A dropped, merged or
          // mis-signed row breaks this chain.
          final balances = {
            for (final row in rows) row.statementBalance!.toStringAsFixed(2),
          };
          final breaks = rows.where(
            (row) => !balances.contains(
              (row.statementBalance! - row.signedAmount).toStringAsFixed(2),
            ),
          );
          expect(breaks, hasLength(1), reason: breaks.join('\n'));
          expect(
            rows.where((row) => row.title == 'Imported transaction'),
            isEmpty,
          );

          if (file.path.endsWith('.pdf')) {
            final summary = _summary(file);
            if (summary != null) {
              final (opening, closing) = summary;
              final net =
                  _total(rows, TransactionType.cashIn) -
                  _total(rows, TransactionType.cashOut);
              expect(opening + net, closeTo(closing, 0.005));
            }
          }
        },
        skip: locked && !_passwords.containsKey(file.uri.pathSegments.last)
            ? 'Add its password to passwords.json'
            : false,
      );
    }
  }, skip: skip);

  test('eSewa legacy .xls imports completed rows with references', () {
    final preview = _parse(
      AppStore(),
      'book',
      _file('eSewa_statement_2026-02-24_2026-03-26.xls'),
    );
    final rows = preview.importable;
    expect(rows, hasLength(54));
    expect(_total(rows, TransactionType.cashIn), closeTo(34906, 0.001));
    expect(_total(rows, TransactionType.cashOut), closeTo(34841, 0.001));
    // eSewa reuses a transfer's reference for its fee; both must be kept.
    final shared = rows.where((row) => row.externalReference == '1CLG381');
    expect(shared.map((row) => row.amount), unorderedEquals([830, 10]));
    final first = rows.first;
    expect(first.externalReference, '1E8ZYLN');
    expect(first.title, 'Fund Transferred by Ashmita Basnet');
    expect(first.type, TransactionType.cashIn);
    expect(first.amount, 50);
    expect(first.occurredAt, DateTime(2026, 3, 26, 13, 15, 59));
  }, skip: skip);

  group('payment mode from source', () {
    String expectedSource(String name) {
      if (name.startsWith('Nic/')) return ImportParser.nicAsia;
      if (name.startsWith('Nabil/') || name.startsWith('Statements-')) {
        return ImportParser.nabil;
      }
      if (name.startsWith('Standart') || name.startsWith('SCpassword')) {
        return ImportParser.standardChartered;
      }
      if (name.startsWith('eSewa')) return ImportParser.esewa;
      throw StateError('No expected source for $name');
    }

    test('every statement gets its bank or wallet as payment mode', () {
      final files = _statements
          .listSync(recursive: true)
          .whereType<File>()
          .where(_isSupportedStatement)
          .where((file) => !_isLocked(file) || _hasPassword(file));
      for (final file in files) {
        final name = file.path.split('test statement/').last;
        final rows = _parse(AppStore(), 'book', file).importable;
        expect(rows.map((row) => row.paymentMode).toSet(), {
          expectedSource(name),
        }, reason: name);
      }
    });

    test('eSewa entries appear under the eSewa filter after import', () async {
      final store = await _freshStore();
      final bookId = store.books.first.id;
      store.paymentModes.remove(ImportParser.esewa);
      final preview = _parse(
        store,
        bookId,
        _file('eSewa_statement_2026-02-24_2026-03-26.xls'),
      );
      await store.commitImport(preview);

      expect(store.paymentModes, contains(ImportParser.esewa));
      // The book screen's payment-mode filter keeps entries whose mode
      // equals the picked one.
      final filtered = store
          .transactionsForBook(bookId)
          .where((entry) => entry.paymentMode == ImportParser.esewa);
      // The imported rows plus the opening balance added to this empty book.
      expect(filtered, hasLength(preview.importable.length + 1));
      expect(filtered, isNotEmpty);
    });
  }, skip: skip);

  group('opening balance', () {
    List<File> readable() =>
        _statements
            .listSync(recursive: true)
            .whereType<File>()
            .where(_isSupportedStatement)
            .where((file) => !_isLocked(file) || _hasPassword(file))
            .toList()
          ..sort((a, b) => a.path.compareTo(b.path));

    test('an empty book ends at the statement closing balance', () async {
      for (final file in readable()) {
        final name = file.path.split('test statement/').last;
        final store = await _freshStore();
        final bookId = store.books.first.id;
        final preview = _parse(store, bookId, file);
        expect(preview.openingBalance, isNotNull, reason: name);
        expect(store.importSetsOpeningBalance(bookId, preview), isTrue);

        final summary = file.path.endsWith('.pdf') ? _summary(file) : null;
        if (summary != null) {
          expect(preview.openingBalance, closeTo(summary.$1, 0.005));
          expect(preview.closingBalance, closeTo(summary.$2, 0.005));
        }

        await store.commitImport(preview);
        // openingBalance + net == closing balance.
        expect(
          store.balanceFor(bookId),
          closeTo(preview.closingBalance!, 0.005),
          reason: name,
        );
        final openings = store
            .transactionsForBook(bookId)
            .where((entry) => entry.category == 'Opening balance');
        expect(openings, hasLength(1), reason: name);
      }
    });

    test('a book with entries keeps its balance as it is', () async {
      final store = await _freshStore();
      final bookId = store.books.first.id;
      final existing = _parse(store, bookId, _file('Nic/DEC 2025.pdf'));
      await store.commitImport(existing);
      final before = store.transactionsForBook(bookId).length;

      final preview = _parse(store, bookId, _file('Nic/Jan26.pdf'));
      expect(preview.openingBalance, isNotNull);
      expect(store.importSetsOpeningBalance(bookId, preview), isFalse);
      await store.commitImport(preview);

      expect(
        store.transactionsForBook(bookId),
        hasLength(before + preview.importable.length),
      );
      expect(
        store
            .transactionsForBook(bookId)
            .where((entry) => entry.category == 'Opening balance'),
        hasLength(1), // Only the one from the first import into the empty book.
      );
    });
  }, skip: skip);

  group('multi-file import', () {
    ParsedStatement read(String bookId, String name) => ImportParser.readPdf(
      fileName: name.split('/').last,
      bookId: bookId,
      bytes: _file(name).readAsBytesSync(),
    );

    test('a batch imports the same rows as one file after another', () async {
      final sequential = await _freshStore();
      final seqBook = sequential.books.first.id;
      final december = _parse(sequential, seqBook, _file('Nic/DEC 2025.pdf'));
      await sequential.commitImport(december);
      final january = _parse(sequential, seqBook, _file('Nic/Jan26.pdf'));

      final store = await _freshStore();
      final bookId = store.books.first.id;
      final batch = store.previewBatch(bookId, [
        read(bookId, 'Nic/Jan26.pdf'),
        read(bookId, 'Nic/DEC 2025.pdf'),
      ]);
      expect(batch.files.first.$1.fileName, 'DEC 2025.pdf');
      expect(
        batch.combined.importable,
        hasLength(december.importable.length + january.importable.length),
      );
      expect(
        batch.files.last.$2.duplicates,
        hasLength(january.duplicates.length),
      );
      expect(batch.chainGaps, isEmpty);
    });

    test('a year of NIC statements flags only the missing day', () async {
      final store = await _freshStore();
      final bookId = store.books.first.id;
      final files = _statements
          .listSync(recursive: true)
          .whereType<File>()
          .where((file) => file.path.contains('/Nic/'))
          .map((file) => read(bookId, 'Nic/${file.uri.pathSegments.last}'))
          .toList()
          .reversed
          .toList();
      final batch = store.previewBatch(bookId, files);

      final starts = [for (final (s, _) in batch.files) s.periodStart!];
      expect(starts, [...starts]..sort());
      expect(batch.sources, [ImportParser.nicAsia]);
      // Aug.pdf ends on 27 Aug and sep28.pdf starts on 29 Aug.
      expect(batch.chainGaps.map((gap) => '${gap.from}>${gap.to}'), [
        'Aug.pdf>sep28.pdf',
      ]);

      await store.commitImport(batch.combined);
      final gap = batch.chainGaps.single;
      // The preview's "balance after import" is what the book ends at.
      expect(
        store.balanceFor(bookId),
        closeTo(batch.combined.closingBalance!, 0.005),
      );
      // Everything else continues, so the book is off the bank's final
      // balance by exactly the missing day.
      expect(
        store.balanceFor(bookId),
        closeTo(
          batch.files.last.$1.closingBalance! + gap.closing - gap.opening,
          0.005,
        ),
      );
    });
  }, skip: skip);

  group('duplicate detection', () {
    test('re-importing the same statement flags every row', () async {
      final store = await _freshStore();
      final bookId = store.books.first.id;
      for (final name in [
        'Nic/DEC 2025.pdf',
        'Nabil/May.pdf',
        'Standart charterd.pdf',
        'eSewa_statement_2026-02-24_2026-03-26.xls',
      ]) {
        final first = _parse(store, bookId, _file(name));
        expect(first.duplicates, isEmpty, reason: name);
        await store.commitImport(first);

        final again = _parse(store, bookId, _file(name));
        expect(again.importable, isEmpty, reason: name);
        expect(again.duplicates, hasLength(first.importable.length));
      }
    });

    test('overlapping statements only import the new rows', () async {
      final store = await _freshStore();
      final bookId = store.books.first.id;
      // DEC 2025 covers December; Jan26 covers December and January.
      final december = _parse(store, bookId, _file('Nic/DEC 2025.pdf'));
      await store.commitImport(december);

      final january = _parse(store, bookId, _file('Nic/Jan26.pdf'));
      expect(january.duplicates, hasLength(december.importable.length));
      expect(
        january.duplicates.every((row) => row.occurredAt.month == 12),
        isTrue,
      );
      expect(
        january.importable.every((row) => row.occurredAt.month == 1),
        isTrue,
      );
    });

    test('a different book is not affected', () async {
      final store = await _freshStore();
      final bookId = store.books.first.id;
      await store.commitImport(_parse(store, bookId, _file('Nabil/May.pdf')));

      final other = _parse(store, 'other_book', _file('Nabil/May.pdf'));
      expect(other.duplicates, isEmpty);
    });

    test('duplicates survive an app restart', () async {
      final store = await _freshStore();
      final bookId = store.books.first.id;
      await store.commitImport(_parse(store, bookId, _file('Nic/Oct.pdf')));

      final reloaded = AppStore();
      await reloaded.load();
      final again = _parse(reloaded, bookId, _file('Nic/Oct.pdf'));
      expect(again.importable, isEmpty);
    });
  }, skip: skip);

  test('identical rows within one statement are all kept', () async {
    final store = await _freshStore();
    final bookId = store.books.first.id;
    LedgerTransaction row() {
      final now = DateTime(2026, 3, 1);
      return LedgerTransaction(
        id: 'id_${now.microsecondsSinceEpoch}',
        bookId: bookId,
        title: 'Chiya',
        amount: 25,
        type: TransactionType.cashOut,
        occurredAt: now,
        createdAt: now,
        updatedAt: now,
        category: 'Imported',
        paymentMode: '',
        notes: '',
        goalId: null,
        runningBalance: 0,
        externalReference: '',
        statementBalance: null,
        sequence: 0,
        importSource: 'PDF',
      );
    }

    final first = store.previewImport(
      bookId: bookId,
      source: 'PDF',
      parsed: [row(), row()],
      ignored: const [],
    );
    expect(first.importable, hasLength(2));
    await store.commitImport(first);

    // Two already exist, so only the third identical row is new.
    final second = store.previewImport(
      bookId: bookId,
      source: 'PDF',
      parsed: [row(), row(), row()],
      ignored: const [],
    );
    expect(second.duplicates, hasLength(2));
    expect(second.importable, hasLength(1));
  });

  test('unknown statement layouts keep an empty payment mode', () {
    expect(ImportParser.detectSource('Date Description Debit Credit'), isNull);
    expect(
      ImportParser.detectSource(
        "Electronic Account Statement\nAccount Holder's\nS.N\nWithdraw",
      ),
      ImportParser.nabil,
    );
    expect(
      ImportParser.detectSource(
        'Electronic Account Statement\nAccount Name: X\nDebit\nCredit',
      ),
      ImportParser.nicAsia,
    );
  });

  group('statement balances', () {
    LedgerTransaction row(
      int day,
      TransactionType type,
      double amount,
      double balance,
      int sequence,
    ) {
      final at = DateTime(2026, 1, day, 10);
      return LedgerTransaction(
        id: 't$sequence',
        bookId: 'book',
        title: 'Row $sequence',
        amount: amount,
        type: type,
        occurredAt: at,
        createdAt: at,
        updatedAt: at,
        category: 'Imported',
        paymentMode: '',
        notes: '',
        goalId: null,
        runningBalance: 0,
        externalReference: '',
        statementBalance: balance,
        sequence: sequence,
        importSource: 'PDF',
      );
    }

    // 50 → +50 on 1 Jan → 100 → −30 on 2 Jan → 70, listed newest first.
    final newestFirst = [
      row(2, TransactionType.cashOut, 30, 70, 1),
      row(1, TransactionType.cashIn, 50, 100, 2),
    ];

    test('newest-first statements start from the oldest row', () {
      final (opening, closing) = ImportParser.statementBalances(newestFirst);
      expect(opening, 50);
      expect(closing, 70);
    });

    test('an explicit opening balance line wins', () {
      final (opening, closing) = ImportParser.statementBalances(
        newestFirst,
        text: 'Opening Balance :\n1,234.50\nClosing Balance :\n70.00',
      );
      expect(opening, 1234.5);
      expect(closing, 70);
    });

    test('formats without a balance column are skipped', () async {
      SharedPreferences.setMockInitialValues({});
      final store = AppStore();
      await store.load();
      final bookId = store.books.first.id;
      final plain = row(1, TransactionType.cashIn, 50, 0, 1);
      final noBalance = LedgerTransaction.fromJson({
        ...plain.toJson(),
        'bookId': bookId,
        'statementBalance': null,
      });
      expect(ImportParser.statementBalances([noBalance]), (null, null));

      final preview = store.previewImport(
        bookId: bookId,
        source: 'PDF',
        parsed: [noBalance],
        ignored: const [],
      );
      expect(store.importSetsOpeningBalance(bookId, preview), isFalse);
      await store.commitImport(preview);
      expect(store.transactionsForBook(bookId), hasLength(1));
    });
  });
}
