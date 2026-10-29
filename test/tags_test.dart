import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:paisa_flow/data/insights.dart';
import 'package:paisa_flow/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _key = 'hissabkitab_data_v1';

Map<String, Object?> _account(String id, String type) => {
  'id': id,
  'name': id,
  'createdAt': '2026-01-01T00:00:00.000',
  'updatedAt': '2026-01-01T00:00:00.000',
  'currency': 'NPR',
  'type': type,
};

Map<String, Object?> _entry(
  String id,
  String book,
  double amount,
  String type, {
  List<String> tags = const [],
}) => {
  'id': id,
  'bookId': book,
  'title': id,
  'amount': amount,
  'type': type,
  'occurredAt': '${_today()}T09:00:00.000',
  'createdAt': '${_today()}T09:00:00.000',
  'updatedAt': '${_today()}T09:00:00.000',
  'category': 'Food',
  'paymentMode': 'Cash',
  'notes': '',
  'tags': tags,
};

String _today() => DateTime.now().toIso8601String().substring(0, 10);

Future<AppStore> _store() async {
  SharedPreferences.setMockInitialValues({
    _key: jsonEncode({
      'onboarded': true,
      'defaultCurrency': 'NPR',
      'books': [_account('NIC', 'bank'), _account('eSewa', 'wallet')],
      'transactions': [
        _entry('ticket', 'NIC', 80000, 'cashOut', tags: ['japan-trip']),
        _entry('hotel', 'eSewa', 30000, 'cashOut', tags: ['japan-trip']),
        _entry('gift', 'NIC', 5000, 'cashIn', tags: ['wedding']),
        _entry('tea', 'NIC', 50, 'cashOut'),
      ],
    }),
  });
  final store = AppStore();
  await store.load();
  return store;
}

void main() {
  test('tags are normalized', () {
    expect(normalizeTag('#Japan Trip'), 'japan-trip');
    expect(normalizeTag('  ##wedding '), 'wedding');
    expect(normalizeTag('#'), '');
  });

  test('tags in use are listed, most used first', () async {
    final store = await _store();
    expect(store.allTags, [('japan-trip', 2), ('wedding', 1)]);
    expect(
      store.entriesTagged('japan-trip').map((e) => e.id),
      unorderedEquals(['hotel', 'ticket']),
    );
  });

  test('rename, merge and delete update every entry', () async {
    final store = await _store();
    await store.renameTag('japan-trip', '#Japan 2026');
    expect(store.transactionById('ticket')!.tags, ['japan-2026']);
    await store.mergeTag('wedding', 'japan-2026');
    expect(store.transactionById('gift')!.tags, ['japan-2026']);
    expect(store.allTags, [('japan-2026', 3)]);
    await store.deleteTag('japan-2026');
    expect(store.transactionById('ticket')!.tags, isEmpty);
    // The entries themselves stay.
    expect(store.transactions, hasLength(4));
    expect(store.allTags, isEmpty);
  });

  test(
    'a tag created without entries is kept and survives a restart',
    () async {
      final store = await _store();
      expect(await store.addTag('#Dashain 2026'), 'dashain-2026');
      final reloaded = AppStore();
      await reloaded.load();
      expect(reloaded.allTags.map((e) => e.$1), contains('dashain-2026'));
      expect(reloaded.transactionById('ticket')!.tags, ['japan-trip']);
    },
  );

  test('a tagged transfer counts once', () async {
    final store = await _store();
    await store.saveTransfer(
      fromId: 'NIC',
      toId: 'eSewa',
      amount: 1000,
      when: DateTime.now(),
      tags: ['japan-trip'],
    );
    expect(store.allTags.first, ('japan-trip', 3));
    expect(store.entriesTagged('japan-trip'), hasLength(3));
  });

  test('import can tag every row', () async {
    final store = await _store();
    final row = LedgerTransaction.fromJson(
      _entry('imp', 'NIC', 700, 'cashOut'),
    );
    await store.commitImport(
      ImportPreview(
        source: 'NIC Asia',
        importable: [row],
        duplicates: const [],
        ignored: const [],
      ),
      tags: ['kirana-pasal'],
    );
    expect(store.transactionById('imp')!.tags, ['kirana-pasal']);
    expect(store.tags, contains('kirana-pasal'));
  });

  test('Insights ranks tags by spending', () async {
    final store = await _store();
    final trend = Insights(store.transactions).trend(TrendRange.month);
    expect(trend.tags.single.name, 'japan-trip');
    expect(trend.tags.single.amount, 110000);
  });

  testWidgets('tag an entry from the form and open its summary', (
    tester,
  ) async {
    await _store();
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const PaisaFlowBootstrap());
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 2));

    await tester.tap(find.text('Cash out').first);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).at(0), '450');
    await tester.enterText(find.byType(TextField).at(1), 'Momo');
    final form = find
        .ancestor(of: find.text('Momo'), matching: find.byType(Scrollable))
        .first;
    await tester.scrollUntilVisible(
      find.text('Add tag'),
      300,
      scrollable: form,
    );
    await tester.tap(find.text('Add tag'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).last, 'Dashain 2026');
    await tester.pumpAndSettle();
    expect(find.text('Create #dashain-2026'), findsOneWidget);
    await tester.tap(find.text('Create #dashain-2026'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();
    expect(find.text('#dashain-2026'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Save entry'),
      300,
      scrollable: form,
    );
    await tester.tap(find.text('Save entry'));
    await tester.pumpAndSettle();

    final store = AppScope.read(tester.element(find.byType(Scaffold).first));
    final momo = store.transactions.firstWhere((e) => e.title == 'Momo');
    expect(momo.tags, ['dashain-2026']);
    expect(tester.takeException(), isNull);
  });
}
