import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:paisa_flow/core/format.dart';
import 'package:paisa_flow/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _key = 'hissabkitab_data_v1';

/// Saved data in the shape the app wrote before the redesign: categories and
/// payment modes per book, no currency or colour.
Map<String, Object?> _legacyData() => {
  'books': [
    {
      'id': 'book_default',
      'name': 'Main Book',
      'description': 'Daily cash flow',
      'createdAt': '2026-01-01T00:00:00.000',
      'updatedAt': '2026-01-02T00:00:00.000',
      'categories': ['General', 'Salary', 'Food', 'Bills', 'Chiya'],
      'paymentModes': ['Cash', 'Bank', 'Wallet'],
    },
  ],
  'transactions': [
    {
      'id': 't1',
      'bookId': 'book_default',
      'title': 'Tea',
      'amount': 50,
      'type': 'cashOut',
      'occurredAt': '2026-01-02T09:00:00.000',
      'createdAt': '2026-01-02T09:00:00.000',
      'updatedAt': '2026-01-02T09:00:00.000',
      'category': 'Chiya',
      'paymentMode': 'Wallet',
      'notes': '',
    },
  ],
  'goals': [
    {
      'id': 'g1',
      'name': 'Laptop',
      'targetAmount': 1000,
      'manualSaved': 100,
      'savedAmount': 100,
    },
  ],
};

Future<AppStore> _load(Map<String, Object> prefs) async {
  SharedPreferences.setMockInitialValues(prefs);
  final store = AppStore();
  await store.load();
  return store;
}

void main() {
  test(
    'legacy data keeps per-book lists and gains currency and colour',
    () async {
      final store = await _load({_key: jsonEncode(_legacyData())});

      final book = store.books.single;
      expect(book.currency, 'NPR');
      expect(book.colorValue, itemColors.first);
      expect(book.description, 'Daily cash flow');
      expect(store.categories, containsAll(['Chiya', 'Bills', 'General']));
      expect(store.categories, containsAll(AppStore.defaultCategories));
      expect(store.paymentModes, containsAll(['Wallet', 'Bank', 'eSewa']));
      expect(store.goals.single.colorValue, itemColors.first);
      expect(store.onboarded, isTrue);
      expect(store.balanceFor('book_default'), -50);
    },
  );

  test('migrated lists are saved app-wide and survive a reload', () async {
    final store = await _load({_key: jsonEncode(_legacyData())});
    await store.addCategory('Momo');

    final reloaded = AppStore();
    await reloaded.load();
    expect(reloaded.categories, containsAll(['Chiya', 'Momo']));
  });

  test(
    'unreadable data is kept aside instead of leaving the app blank',
    () async {
      final store = await _load({_key: '{"books": [{"id": 1}]}'});

      expect(store.isLoaded, isTrue);
      expect(store.loadError, isNotNull);
      expect(store.books, hasLength(1));
      final prefs = await SharedPreferences.getInstance();
      final backups = prefs.getKeys().where(
        (k) => k.startsWith('${_key}_unreadable_'),
      );
      expect(backups, hasLength(1));
      expect(prefs.getString(backups.single), '{"books": [{"id": 1}]}');
    },
  );

  test(
    'renaming a book keeps its description and locks currency once used',
    () async {
      final store = await _load({_key: jsonEncode(_legacyData())});

      await store.saveBook(
        id: 'book_default',
        name: 'Personal',
        currency: 'USD',
      );

      final book = store.books.single;
      expect(book.name, 'Personal');
      expect(book.description, 'Daily cash flow');
      expect(book.currency, 'NPR', reason: 'the book already has entries');
    },
  );

  test('new book with an opening balance starts with that balance', () async {
    final store = await _load({});
    final id = await store.saveBook(
      name: 'Japan Trip',
      currency: 'JPY',
      openingBalance: 120000,
    );

    expect(store.bookById(id)!.currency, 'JPY');
    expect(store.balanceFor(id), 120000);
    expect(store.transactionsForBook(id).single.category, 'Opening balance');
  });

  test('renaming a category updates the entries that use it', () async {
    final store = await _load({_key: jsonEncode(_legacyData())});

    await store.renameCategory('Chiya', 'Tea');

    expect(store.categories, contains('Tea'));
    expect(store.categories, isNot(contains('Chiya')));
    expect(store.transactionById('t1')!.category, 'Tea');
  });

  test('editing an entry records each change in its history', () async {
    final store = await _load({_key: jsonEncode(_legacyData())});
    final entry = store.transactionById('t1')!;

    await store.saveTransaction(
      entry.copyWith(amount: 60, paymentMode: 'Cash', title: 'Chiya'),
    );

    final history = store.logsFor('t1').map((log) => log.details).toList();
    expect(
      history,
      containsAll([
        'Amount Rs 50 → Rs 60',
        'Title changed to “Chiya”',
        'Payment mode Wallet → Cash',
      ]),
    );
  });

  test('money formats per currency', () {
    expect(money(154720), 'Rs 1,54,720');
    expect(money(10.8), 'Rs 10.80');
    expect(money(2220, 'USD'), r'$ 2,220.00');
    expect(money(73200, 'JPY'), '¥ 73,200');
    expect(signedMoney(-3460), '− Rs 3,460');
    expect(balanceMoney(-500), '− Rs 500');
  });

  test(
    'setup on a fresh install replaces the starter book in one save',
    () async {
      final store = await _load({});
      expect(store.onboarded, isFalse);

      await store.finishSetup(
        name: 'Ghar',
        currency: 'INR',
        openingBalance: 500,
      );

      expect(store.books.single.name, 'Ghar');
      expect(store.books.single.currency, 'INR');
      expect(store.defaultCurrency, 'INR');
      final saved =
          jsonDecode((await SharedPreferences.getInstance()).getString(_key)!)
              as Map<String, Object?>;
      expect(saved['onboarded'], isTrue);
      expect((saved['books'] as List).single, containsPair('name', 'Ghar'));
    },
  );

  test('setup keeps books that already have entries', () async {
    final data = _legacyData()..remove('goals');
    final store = await _load({
      _key: jsonEncode({...data, 'onboarded': false}),
    });

    await store.finishSetup(name: 'Shop', currency: 'NPR');

    expect(store.books.map((b) => b.name), containsAll(['Main Book', 'Shop']));
    expect(store.transactionById('t1'), isNotNull);
  });

  test('unreadable data does not restart onboarding', () async {
    final store = await _load({_key: 'not json'});
    expect(store.onboarded, isTrue);
  });
}
