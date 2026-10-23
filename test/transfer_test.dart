import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:paisa_flow/data/insights.dart';
import 'package:paisa_flow/data/transfer_hints.dart';
import 'package:paisa_flow/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _key = 'hissabkitab_data_v1';

Map<String, Object?> _account(String id, String type, {String cur = 'NPR'}) => {
  'id': id,
  'name': id,
  'createdAt': '2026-01-01T00:00:00.000',
  'updatedAt': '2026-01-01T00:00:00.000',
  'currency': cur,
  'type': type,
};

Map<String, Object?> _entry(String id, String book, double amount) => {
  'id': id,
  'bookId': book,
  'title': id,
  'amount': amount,
  'type': 'cashIn',
  'occurredAt': '2026-10-01T09:00:00.000',
  'createdAt': '2026-10-01T09:00:00.000',
  'updatedAt': '2026-10-01T09:00:00.000',
  'category': 'Salary',
  'paymentMode': 'Bank transfer',
  'notes': '',
};

Future<AppStore> _store() async {
  SharedPreferences.setMockInitialValues({
    _key: jsonEncode({
      'onboarded': true,
      'defaultCurrency': 'NPR',
      'books': [
        _account('NIC', 'bank'),
        _account('eSewa', 'wallet'),
        _account('Cash', 'cash'),
        _account('Visa', 'card'),
        _account('USD', 'bank', cur: 'USD'),
      ],
      'transactions': [_entry('salary', 'NIC', 50000)],
    }),
  });
  final store = AppStore();
  await store.load();
  return store;
}

final _when = DateTime(2026, 10, 9, 11, 20);

LedgerTransaction _row(String id, String title, String notes, String type) =>
    LedgerTransaction.fromJson({
      'id': id,
      'bookId': 'NIC',
      'title': title,
      'amount': 3000,
      'type': type,
      'occurredAt': '2026-10-02T00:00:00.000',
      'createdAt': '2026-10-02T00:00:00.000',
      'updatedAt': '2026-10-02T00:00:00.000',
      'category': 'Imported',
      'paymentMode': 'NIC Asia',
      'notes': notes,
      'externalReference': 'REF-$id',
      'statementBalance': 47000,
      'importSource': 'NIC Asia',
    });

void main() {
  test('a transfer moves money and is not income or spending', () async {
    final store = await _store();
    final id = await store.saveTransfer(
      fromId: 'NIC',
      toId: 'eSewa',
      amount: 5000,
      when: _when,
      notes: 'Load eSewa',
    );
    expect(store.balanceFor('NIC'), 45000);
    expect(store.balanceFor('eSewa'), 5000);
    final legs = store.transferLegs(id)!;
    expect(legs.out.countsAsFlow, isFalse);
    expect(legs.into.countsAsFlow, isFalse);
    // Net worth is unchanged by moving money around.
    expect(store.totalsFor('NPR').net, 50000);
  });

  test('a fee is a real expense in the From account', () async {
    final store = await _store();
    final id = await store.saveTransfer(
      fromId: 'NIC',
      toId: 'Cash',
      amount: 10000,
      fee: 25,
      when: _when,
    );
    final fee = store.transferLegs(id)!.fee!;
    expect(fee.title, 'ATM fee');
    expect(fee.category, 'Bank fees');
    expect(fee.countsAsFlow, isTrue);
    expect(store.balanceFor('NIC'), 50000 - 10000 - 25);
    expect(store.balanceFor('Cash'), 10000);
    expect(store.categories, contains('Bank fees'));
  });

  test('paying a card bill reduces what is owed', () async {
    final store = await _store();
    await store.saveTransfer(
      fromId: 'NIC',
      toId: 'Visa',
      amount: 4000,
      when: _when,
    );
    // Card had nothing owed, so it is now in credit by the payment.
    expect(store.balanceFor('Visa'), 4000);
    expect(store.totalsFor('NPR').owed, -4000);
  });

  test('different currencies keep both amounts, never converted', () async {
    final store = await _store();
    final id = await store.saveTransfer(
      fromId: 'NIC',
      toId: 'USD',
      amount: 13340,
      toAmount: 100,
      when: _when,
    );
    expect(store.balanceFor('NIC'), 50000 - 13340);
    expect(store.balanceFor('USD'), 100);
    expect(store.transferLegs(id)!.into.amount, 100);
  });

  test('editing moves the transfer and its fee to new accounts', () async {
    final store = await _store();
    final id = await store.saveTransfer(
      fromId: 'NIC',
      toId: 'eSewa',
      amount: 5000,
      fee: 10,
      when: _when,
    );
    await store.saveTransfer(
      transferId: id,
      fromId: 'NIC',
      toId: 'Cash',
      amount: 3000,
      when: _when,
    );
    expect(store.balanceFor('eSewa'), 0);
    expect(store.balanceFor('Cash'), 3000);
    expect(store.balanceFor('NIC'), 47000);
    expect(store.transferLegs(id)!.fee, isNull);
    expect(store.transactions.where((e) => e.transferId == id), hasLength(2));
  });

  test('deleting either side removes the whole transfer and fee', () async {
    final store = await _store();
    final id = await store.saveTransfer(
      fromId: 'NIC',
      toId: 'eSewa',
      amount: 5000,
      fee: 10,
      when: _when,
    );
    await store.deleteTransaction(store.transferLegs(id)!.into.id);
    expect(store.transactions.where((e) => e.transferId == id), isEmpty);
    expect(store.balanceFor('NIC'), 50000);
    expect(store.balanceFor('eSewa'), 0);
  });

  test('deleting only the fee keeps the transfer', () async {
    final store = await _store();
    final id = await store.saveTransfer(
      fromId: 'NIC',
      toId: 'eSewa',
      amount: 5000,
      fee: 10,
      when: _when,
    );
    await store.deleteTransaction(store.transferLegs(id)!.fee!.id);
    final legs = store.transferLegs(id)!;
    expect(legs.fee, isNull);
    expect(store.balanceFor('NIC'), 45000);
  });

  test('transfers survive a restart', () async {
    final store = await _store();
    final id = await store.saveTransfer(
      fromId: 'NIC',
      toId: 'eSewa',
      amount: 5000,
      fee: 10,
      when: _when,
    );
    final reloaded = AppStore();
    await reloaded.load();
    final legs = reloaded.transferLegs(id)!;
    expect(legs.out.bookId, 'NIC');
    expect(legs.into.bookId, 'eSewa');
    expect(legs.fee!.transferFee, isTrue);
  });

  test(
    'Insights leaves transfers out of income, spending and net flow',
    () async {
      final store = await _store();
      await store.saveTransfer(
        fromId: 'NIC',
        toId: 'eSewa',
        amount: 5000,
        fee: 10,
        when: _when,
      );
      final october = Insights(store.transactions).month(DateTime(2026, 10));
      // Salary 50,000 in; only the fee is spending.
      expect(october.inflow, 50000);
      expect(october.outflow, 10);
    },
  );

  test('statement rows that look like transfers find the account', () async {
    final store = await _store();
    String? hint(String title, String notes, [String type = 'cashOut']) =>
        transferCounterpart(
          _row('r', title, notes, type),
          store.books,
          currency: 'NPR',
        );
    expect(hint('eSewa load', 'LoadeSewa 9841234567'), 'eSewa');
    expect(hint('ATM withdrawal', 'ATM WDL DURBARMARG'), 'Cash');
    expect(hint('NABIL CARD PMT 4417', ''), 'Visa');
    expect(hint('eSewa withdrawal', 'ESWWD:1234', 'cashIn'), 'eSewa');
    expect(hint('QR · Himalayan Java', 'QR PAYMENT-123'), isNull);
    // No Khalti account, so nothing is suggested.
    expect(hint('Khalti load', 'Khalti Load 98'), isNull);
  });

  test('an imported row made into a transfer gets its other side', () async {
    final store = await _store();
    final row = _row('r1', 'eSewa load', 'LoadeSewa 9841234567', 'cashOut');
    final other = _row('r2', 'QR · Mart', 'QR PAYMENT', 'cashOut');
    await store.commitImport(
      ImportPreview(
        source: 'NIC Asia',
        importable: [row, other],
        duplicates: const [],
        ignored: const [],
      ),
      transfers: {'r1': 'eSewa'},
    );
    final leg = store.transactionById('r1')!;
    expect(leg.isTransferLeg, isTrue);
    expect(leg.externalReference, 'REF-r1');
    expect(leg.statementBalance, 47000);
    final legs = store.transferLegs(leg.transferId!)!;
    expect(legs.toId, 'eSewa');
    expect(store.balanceFor('eSewa'), 3000);
    expect(store.transactionById('r2')!.isTransferLeg, isFalse);
    expect(store.categories, isNot(contains('Transfer')));
  });

  testWidgets('Transfer from Home records both sides', (tester) async {
    await _store();
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const PaisaFlowBootstrap());
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 2));

    await tester.tap(find.text('Transfer'));
    await tester.pumpAndSettle();
    expect(find.text('From'), findsOneWidget);
    expect(find.text('To'), findsOneWidget);
    expect(find.text('Wallet top-up'), findsOneWidget);

    await tester.enterText(find.byType(TextField).first, '5000');
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Save entry'),
      300,
      scrollable: find
          .ancestor(of: find.text('From'), matching: find.byType(Scrollable))
          .first,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save entry'));
    await tester.pumpAndSettle();

    final store = AppScope.read(tester.element(find.byType(Scaffold).first));
    expect(store.balanceFor('NIC'), 45000);
    expect(store.balanceFor('eSewa'), 5000);
    expect(tester.takeException(), isNull);
  });
}
