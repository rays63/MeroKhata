import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
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

final _now = DateTime.now();
String _day(int d) => DateTime(_now.year, _now.month, d, 9).toIso8601String();

Map<String, Object?> _entry(
  String title,
  String book,
  double amount,
  String type, {
  int day = 1,
  String notes = '',
  String ref = '',
  List<String> tags = const [],
}) => {
  'id': title,
  'bookId': book,
  'title': title,
  'amount': amount,
  'type': type,
  'occurredAt': _day(day),
  'createdAt': _day(day),
  'updatedAt': _day(day),
  'category': type == 'cashIn' ? 'Salary' : 'Food',
  'paymentMode': 'Cash',
  'notes': notes,
  'externalReference': ref,
  'tags': tags,
};

Future<AppStore> _store() async {
  SharedPreferences.setMockInitialValues({
    _key: jsonEncode({
      'onboarded': true,
      'defaultCurrency': 'NPR',
      'books': [
        _account('NIC', 'bank'),
        _account('eSewa', 'wallet'),
        _account('Japan', 'cash', cur: 'JPY'),
      ],
      'transactions': [
        _entry('Salary', 'NIC', 85000, 'cashIn', ref: 'NEFT-88213'),
        _entry('Momo with friends', 'eSewa', 960, 'cashOut', day: 2),
        _entry(
          'Gift',
          'NIC',
          5000,
          'cashOut',
          day: 2,
          notes: 'Sita wedding',
          tags: ['wedding'],
        ),
        _entry('Ramen', 'Japan', 1200, 'cashOut', day: 2),
      ],
    }),
  });
  final store = AppStore();
  await store.load();
  return store;
}

void main() {
  test('search covers title, note, amount, reference and tags', () async {
    final store = await _store();
    List<String> titles(String q) =>
        store.search(q).map((e) => e.title).toList();
    expect(titles('momo'), ['Momo with friends']);
    expect(titles('wedding'), ['Gift']);
    expect(titles('#wedding'), ['Gift']);
    expect(titles('5000'), ['Gift']);
    expect(titles('5,000'), ['Gift']);
    expect(titles('neft-88213'), ['Salary']);
    expect(titles('sekuwa'), isEmpty);
  });

  test('a transfer is found once', () async {
    final store = await _store();
    await store.saveTransfer(
      fromId: 'NIC',
      toId: 'eSewa',
      amount: 3000,
      when: DateTime(_now.year, _now.month, 3),
      notes: 'Load eSewa',
    );
    expect(store.search('load esewa'), hasLength(1));
  });

  test('recent searches are kept, newest first, and can be cleared', () async {
    final store = await _store();
    await store.addRecentSearch('momo');
    await store.addRecentSearch('rent');
    await store.addRecentSearch('momo');
    final reloaded = AppStore();
    await reloaded.load();
    expect(reloaded.recentSearches, ['momo', 'rent']);
    await reloaded.clearRecentSearches();
    expect(reloaded.recentSearches, isEmpty);
  });

  Future<void> pumpApp(WidgetTester tester) async {
    await _store();
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const PaisaFlowBootstrap());
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 2));
  }

  testWidgets('Home shows recent activity and opens All entries', (
    tester,
  ) async {
    await pumpApp(tester);
    expect(find.text('Recent activity'), findsOneWidget);
    expect(find.text('Momo with friends'), findsOneWidget);

    await tester.tap(find.text('See all'));
    await tester.pumpAndSettle();
    expect(find.text('All entries'), findsOneWidget);
    // Totals per currency, never converted.
    expect(find.text('Rs 85,000'), findsOneWidget);
    expect(find.text('¥ 1,200'), findsWidgets);

    await tester.tap(find.text('Tags'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('#wedding').last);
    await tester.pumpAndSettle();
    expect(find.text('Gift'), findsOneWidget);
    expect(find.text('Momo with friends'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('search shows matches and remembers the query', (tester) async {
    await pumpApp(tester);
    await tester.tap(find.byTooltip('Search'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'momo');
    await tester.pumpAndSettle();
    expect(find.text('1 result'), findsOneWidget);
    await tester.tap(find.textContaining('with friends'));
    await tester.pumpAndSettle();
    final store = AppScope.read(tester.element(find.byType(Scaffold).first));
    expect(store.recentSearches, ['momo']);
    expect(tester.takeException(), isNull);
  });
}
