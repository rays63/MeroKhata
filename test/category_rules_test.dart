import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:paisa_flow/data/category_rules.dart';
import 'package:paisa_flow/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _in = TransactionType.cashIn;
const _out = TransactionType.cashOut;

void main() {
  test('keywords match whole words only, in any case', () {
    expect(suggestCategory('NEA bill payment', _out), 'Utilities');
    expect(suggestCategory('nea/2081/bill', _out), 'Utilities');
    expect(suggestCategory('NEAR GATE STORE', _out), isNull);
    expect(suggestCategory('Khanepani', _out), 'Utilities');
    expect(suggestCategory('QR PAYMENT, CAFE DU MONDE', _out), 'Cafe');
    expect(suggestCategory('Momo house', _out), 'Food');
    expect(suggestCategory('Thakali Restaurant', _out), 'Food');
    expect(suggestCategory('Cafeteria', _out), isNull);
  });

  test('salary only matches money coming in', () {
    expect(suggestCategory('SALARY FOR OCT', _in), 'Salary');
    expect(suggestCategory('SALARY ADVANCE RETURN', _out), isNull);
  });

  test('cash-out rules ignore money coming in', () {
    expect(suggestCategory('Daraz refund', _in), isNull);
    expect(suggestCategory('Daraz order', _out), 'Shopping');
    expect(suggestCategory('Ncell cashback', _in), isNull);
  });

  test('"top up" and "top-up" match topup', () {
    expect(suggestCategory('NTC top up 9841', _out), 'Cellular topup');
    expect(suggestCategory('Mobile Top-Up', _out), 'Cellular topup');
    expect(suggestCategory('TOPUP', _out), 'Cellular topup');
    expect(suggestCategory('top of the month', _out), isNull);
  });

  test('the first matching rule wins', () {
    expect(suggestCategory('Ncell top up at cafe', _out), 'Cellular topup');
    expect(suggestCategory('cafe momo', _out), 'Cafe');
  });

  test('imported rows get suggestions, others stay Imported', () async {
    SharedPreferences.setMockInitialValues({});
    final store = AppStore();
    await store.load();
    final bookId = store.books.first.id;
    store.categories.remove('Cellular topup');
    final csv = utf8.encode(
      [
        'Date,Description,Debit,Credit,Balance',
        '2026-01-01,NTC top up,100,,900',
        '2026-01-02,Chiya,25,,875',
        '2026-01-03,Salary January,,5000,5875',
      ].join('\n'),
    );
    final preview = ImportParser.parseXlsBytes(
      store: store,
      bookId: bookId,
      bytes: csv,
    );
    expect(preview.importable.map((row) => row.category), [
      'Cellular topup',
      'Imported',
      'Salary',
    ]);

    await store.commitImport(preview);
    expect(store.categories, contains('Cellular topup'));
    expect(store.categories, isNot(contains('Imported')));
  });
}
