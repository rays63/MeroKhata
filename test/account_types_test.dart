import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:paisa_flow/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _key = 'hissabkitab_data_v1';

Map<String, Object?> _account(String id, String currency, {String? type}) => {
  'id': id,
  'name': id,
  'createdAt': '2026-01-01T00:00:00.000',
  'updatedAt': '2026-01-01T00:00:00.000',
  'currency': currency,
  'type': ?type,
};

Map<String, Object?> _entry(
  String id,
  String book,
  double amount,
  String type,
) => {
  'id': id,
  'bookId': book,
  'title': id,
  'amount': amount,
  'type': type,
  'occurredAt': '2026-10-01T09:00:00.000',
  'createdAt': '2026-10-01T09:00:00.000',
  'updatedAt': '2026-10-01T09:00:00.000',
  'category': 'Food',
  'paymentMode': 'Cash',
  'notes': '',
};

Future<AppStore> _store(Map<String, Object?> data) async {
  SharedPreferences.setMockInitialValues({
    _key: jsonEncode({'onboarded': true, 'defaultCurrency': 'NPR', ...data}),
  });
  final store = AppStore();
  await store.load();
  return store;
}

void main() {
  test('accounts saved before types load untyped and count as Other', () async {
    final store = await _store({
      'books': [_account('old', 'NPR')],
      'transactions': [],
    });
    final book = store.books.single;
    expect(book.type, isNull);
    expect(book.accountType, AccountType.other);
    expect(store.untypedBooks, hasLength(1));
  });

  test('a type survives a restart and clears the untyped prompt', () async {
    final store = await _store({
      'books': [_account('old', 'NPR')],
      'transactions': [],
    });
    await store.saveBook(id: 'old', name: 'NIC Asia', type: AccountType.bank);
    final reloaded = AppStore();
    await reloaded.load();
    expect(reloaded.books.single.type, AccountType.bank);
    expect(reloaded.untypedBooks, isEmpty);
  });

  test('card and loan balances are owed and come off net worth', () async {
    final store = await _store({
      'books': [
        _account('nic', 'NPR', type: 'bank'),
        _account('card', 'NPR', type: 'card'),
        _account('loan', 'NPR', type: 'loan'),
        _account('jp', 'JPY', type: 'cash'),
      ],
      'transactions': [
        _entry('a', 'nic', 50000, 'cashIn'),
        _entry('b', 'card', 12000, 'cashOut'),
        _entry('c', 'loan', 30000, 'cashOut'),
        _entry('d', 'jp', 7000, 'cashIn'),
      ],
    });
    final npr = store.totalsFor('NPR');
    expect(npr.assets, 50000);
    expect(npr.owed, 42000);
    expect(npr.net, 8000);
    // Other currencies are never added in.
    expect(store.totalsFor('JPY').net, 7000);
    expect(store.accountCurrencies, ['NPR', 'JPY']);
  });

  test('the opening amount on a new card is recorded as owed', () async {
    final store = await _store({'books': [], 'transactions': []});
    final id = await store.saveBook(
      name: 'Visa',
      type: AccountType.card,
      openingBalance: 5000,
    );
    expect(store.balanceFor(id), -5000);
    expect(store.totalsFor('NPR').owed, 5000);
  });

  test('"Later" on the type prompt is remembered', () async {
    final store = await _store({
      'books': [_account('old', 'NPR')],
      'transactions': [],
    });
    await store.dismissTypePrompt();
    final reloaded = AppStore();
    await reloaded.load();
    expect(reloaded.typePromptLater, isTrue);
  });

  testWidgets('Accounts groups by type and shows what is owed', (tester) async {
    SharedPreferences.setMockInitialValues({
      _key: jsonEncode({
        'onboarded': true,
        'defaultCurrency': 'NPR',
        'books': [
          _account('NIC Asia', 'NPR', type: 'bank'),
          _account('Visa', 'NPR', type: 'card'),
          _account('Old book', 'NPR'),
        ],
        'transactions': [
          _entry('a', 'NIC Asia', 50000, 'cashIn'),
          _entry('b', 'Visa', 12000, 'cashOut'),
        ],
      }),
    });
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const PaisaFlowBootstrap());
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 2));

    expect(find.text('Net worth · NPR'), findsOneWidget);
    expect(find.text('Set a type to group your accounts'), findsOneWidget);

    await tester.tap(find.text('Accounts').last);
    await tester.pumpAndSettle();
    expect(find.text('Bank'), findsOneWidget);
    expect(find.text('Card'), findsOneWidget);
    expect(find.text('Owed Rs 12,000'), findsOneWidget);
    expect(find.textContaining('Outstanding'), findsOneWidget);
    expect(find.text('Set type'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
