import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:paisa_flow/data/insights.dart';
import 'package:paisa_flow/features/insights/charts.dart';
import 'package:paisa_flow/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _key = 'hissabkitab_data_v1';

Map<String, Object?> _account(String id, {String cur = 'NPR'}) => {
  'id': id,
  'name': id,
  'createdAt': '2026-01-01T00:00:00.000',
  'updatedAt': '2026-01-01T00:00:00.000',
  'currency': cur,
  'type': 'bank',
};

Map<String, Object?> _entry(
  String id,
  double amount,
  String category, {
  String type = 'cashOut',
  String book = 'NIC',
  int month = 10,
  int day = 5,
  String sub = '',
  String title = '',
}) => {
  'id': id,
  'bookId': book,
  'title': title.isEmpty ? id : title,
  'amount': amount,
  'type': type,
  'occurredAt': DateTime(2026, month, day, 12).toIso8601String(),
  'createdAt': DateTime(2026, month, day, 12).toIso8601String(),
  'updatedAt': DateTime(2026, month, day, 12).toIso8601String(),
  'category': category,
  'paymentMode': 'Cash',
  'notes': '',
  'subcategory': sub,
};

Future<AppStore> _store() async {
  SharedPreferences.setMockInitialValues({
    _key: jsonEncode({
      'onboarded': true,
      'defaultCurrency': 'NPR',
      'books': [_account('NIC'), _account('Japan', cur: 'JPY')],
      'transactions': [
        _entry('salary', 85000, 'Salary', type: 'cashIn', day: 1),
        _entry('rent', 20000, 'Rent', day: 2),
        _entry('lunch1', 600, 'Food', sub: 'Lunch', title: 'QR · Canteen'),
        _entry('lunch2', 400, 'Food', sub: 'Lunch', title: 'QR · Canteen'),
        _entry('mart', 9000, 'Food', day: 8, title: 'QR · Mega Mart'),
        _entry('sep', 7000, 'Food', month: 9),
        _entry('aug', 8000, 'Food', month: 8),
        _entry('ramen', 1200, 'Food', book: 'Japan'),
      ],
      'subcategories': {
        'Food': ['Lunch', 'Groceries'],
      },
    }),
  });
  final store = AppStore();
  await store.load();
  return store;
}

void main() {
  final oct = DateTime(2026, 10);

  group('subcategories', () {
    test('label reads "Food › Lunch"', () async {
      final store = await _store();
      expect(store.transactionById('lunch1')!.categoryLabel, 'Food › Lunch');
      expect(store.transactionById('mart')!.categoryLabel, 'Food');
    });

    test(
      'rename updates entries; delete moves them up to the parent',
      () async {
        final store = await _store();
        await store.renameSubcategory('Food', 'Lunch', 'Office lunch');
        expect(store.transactionById('lunch1')!.subcategory, 'Office lunch');
        expect(store.subcategoriesOf('Food'), ['Office lunch', 'Groceries']);
        await store.deleteSubcategory('Food', 'Office lunch');
        expect(store.transactionById('lunch1')!.subcategory, '');
        expect(store.transactionById('lunch1')!.category, 'Food');
        expect(store.subcategoriesOf('Food'), ['Groceries']);
      },
    );

    test('renaming a category carries its subcategories', () async {
      final store = await _store();
      await store.renameCategory('Food', 'Eating');
      expect(store.subcategoriesOf('Eating'), ['Lunch', 'Groceries']);
      expect(store.subcategoriesOf('Food'), isEmpty);
    });

    test('search finds subcategory names', () async {
      final store = await _store();
      expect(store.search('lunch').map((e) => e.id).toSet(), {
        'lunch1',
        'lunch2',
      });
    });
  });

  group('budgets', () {
    test('spending counts the scope only, never converted', () async {
      final store = await _store();
      expect(store.budgetSpent('currency:NPR', 'Food', oct), 10000);
      expect(store.budgetSpent('currency:JPY', 'Food', oct), 1200);
      expect(store.budgetSpent('account:NIC', null, oct), 30000);
    });

    test('the hint averages the 3 months before', () async {
      final store = await _store();
      // Sep 7,000 + Aug 8,000 + Jul 0 over 3 months.
      expect(store.budgetHint('currency:NPR', 'Food', oct), 5000);
    });

    test('one budget per scope and category; saved and deleted', () async {
      final store = await _store();
      await store.saveBudget(
        scope: 'currency:NPR',
        category: 'Food',
        amount: 9000,
      );
      await store.saveBudget(
        scope: 'currency:NPR',
        category: 'Food',
        amount: 12000,
      );
      await store.saveBudget(scope: 'currency:NPR', amount: 40000);
      expect(store.budgetsFor('currency:NPR'), hasLength(2));
      expect(store.budgetFor('currency:NPR', 'Food')!.amount, 12000);
      final reloaded = AppStore();
      await reloaded.load();
      expect(reloaded.budgetFor('currency:NPR', null)!.amount, 40000);
      await reloaded.deleteBudget(reloaded.budgetFor('currency:NPR', null)!.id);
      expect(reloaded.budgetFor('currency:NPR', null), isNull);
    });
  });

  group('insights charts', () {
    test('flow splits income and spending; saved is what is left', () async {
      final store = await _store();
      final nic = store.transactions.where((e) => e.bookId == 'NIC').toList();
      final flow = Insights(nic).flow(oct);
      expect(flow.totalIn, 85000);
      expect(flow.totalOut, 30000);
      expect(flow.saved, 55000);
      expect(flow.spending.first.name, 'Rent');
    });

    test('pace adds up spending day by day against last month', () async {
      final store = await _store();
      final nic = store.transactions.where((e) => e.bookId == 'NIC').toList();
      final pace = Insights(nic, now: DateTime(2026, 10, 10)).pace(oct);
      expect(pace.throughDay, 10);
      expect(pace.thisMonth[1], 20000);
      expect(pace.spent, 30000);
      expect(pace.lastMonth.last, 7000);
      expect(pace.projected, closeTo(93000, 1));
    });

    test('top places group payments by title', () async {
      final store = await _store();
      final places = Insights(store.transactions).places(oct);
      final canteen = places.firstWhere((p) => p.name == 'QR · Canteen');
      expect(canteen.count, 2);
      expect(canteen.amount, 1000);
      expect(canteen.category, 'Food');
    });

    test('category boxes fill the area, sized to scale', () {
      final items = [
        Breakdown('Rent', 60, .6),
        Breakdown('Food', 30, .3),
        Breakdown('Cafe', 10, .1),
      ];
      const area = Rect.fromLTWH(0, 0, 300, 200);
      final tiles = CategoryBoxes.layout(items, area);
      final total = tiles.fold(0.0, (s, t) => s + t.$2.width * t.$2.height);
      expect(total, closeTo(area.width * area.height, .01));
      final rent = tiles.firstWhere((t) => t.$1.name == 'Rent').$2;
      expect(rent.width * rent.height, closeTo(.6 * 300 * 200, .01));
    });

    test('small categories group into Others', () {
      final grouped = groupSmall([
        Breakdown('Rent', 97, .97),
        Breakdown('Tea', 2, .02),
        Breakdown('Gum', 1, .01),
      ], 'Others');
      expect(grouped.map((b) => b.name), ['Rent', 'Others']);
      expect(grouped.last.amount, 3);
    });

    test('card order and hidden cards are remembered', () async {
      final store = await _store();
      await store.saveInsightsLayout(
        ['places', 'charts', 'boxes', 'trends', 'modes', 'tags'],
        {'trends'},
      );
      final reloaded = AppStore();
      await reloaded.load();
      expect(reloaded.insightsOrder.first, 'places');
      expect(reloaded.insightsHidden, {'trends'});
    });
  });

  testWidgets('Insights shows the flow, boxes and a budget badge', (
    tester,
  ) async {
    final store = await _store();
    await store.saveBudget(
      scope: 'currency:NPR',
      category: 'Food',
      amount: 10000,
    );
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const PaisaFlowBootstrap());
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 2));
    await tester.tap(find.text('Insights').last);
    await tester.pumpAndSettle();
    expect(find.text('Customize'), findsOneWidget);
    expect(find.text('Flow'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
