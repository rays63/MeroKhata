import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
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
  String title,
  String day, {
  String category = 'Food',
  String mode = 'Cash',
  List<String> tags = const [],
}) => {
  'id': id,
  'bookId': 'Cash',
  'title': title,
  'amount': 450,
  'type': 'cashOut',
  'occurredAt': '2026-10-${day}T12:00:00.000',
  'createdAt': '2026-10-${day}T12:00:00.000',
  'updatedAt': '2026-10-${day}T12:00:00.000',
  'category': category,
  'paymentMode': mode,
  'notes': '',
  'tags': tags,
};

Future<AppStore> _store({
  List<Map<String, Object?>> templates = const [],
}) async {
  SharedPreferences.setMockInitialValues({
    _key: jsonEncode({
      'onboarded': true,
      'defaultCurrency': 'NPR',
      'books': [_account('Cash', 'cash'), _account('eSewa', 'wallet')],
      'transactions': [
        _entry('a', 'Pathao ride', '01', category: 'Transport'),
        _entry(
          'b',
          'Pathao ride',
          '05',
          category: 'Transport',
          mode: 'eSewa',
          tags: ['office'],
        ),
        _entry('c', 'Momo', '03'),
      ],
      'templates': templates,
    }),
  });
  final store = AppStore();
  await store.load();
  return store;
}

Future<void> _pump(WidgetTester tester) async {
  tester.view.physicalSize = const Size(1170, 2532);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(const PaisaFlowBootstrap());
  await tester.pumpAndSettle();
  await tester.pump(const Duration(seconds: 2));
}

Finder _form() => find
    .ancestor(of: find.text('Title'), matching: find.byType(Scrollable))
    .first;

void main() {
  test('title suggestions: newest per title, at least 2 letters', () async {
    final store = await _store();
    expect(store.titleSuggestions('p'), isEmpty);
    final found = store.titleSuggestions('pa');
    expect(found.map((e) => e.id), ['b']);
    expect(store.titleSuggestions('Pathao ride'), isEmpty);
  });

  test('templates are kept, renamed and deleted', () async {
    final store = await _store();
    final t = await store.addTemplate(
      const EntryTemplate(
        id: '',
        title: ' Momo ',
        type: TransactionType.cashOut,
        amount: 450,
        category: 'Food',
        paymentMode: 'Cash',
        bookId: 'Cash',
        tags: ['office'],
      ),
    );
    expect(t.title, 'Momo');
    await store.renameTemplate(t.id, 'Office momo');
    final reloaded = AppStore();
    await reloaded.load();
    expect(reloaded.templates.single.title, 'Office momo');
    expect(reloaded.templates.single.tags, ['office']);
    await reloaded.deleteTemplate(t.id);
    expect(reloaded.templates, isEmpty);
    // Deleting an account removes its templates.
    await store.addTemplate(t);
    await store.deleteBook('Cash');
    expect(store.templates, isEmpty);
  });

  testWidgets('a suggestion fills category, mode and tags', (tester) async {
    await _store();
    await _pump(tester);
    await tester.tap(find.text('Cash out').first);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).at(0), '250');
    await tester.enterText(find.byType(TextField).at(1), 'pat');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Pathao ride', findRichText: true));
    await tester.pumpAndSettle();
    expect(find.text('Transport'), findsOneWidget);
    expect(find.text('eSewa'), findsWidgets);
    expect(find.text('#office'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Save & add another keeps the form open for the next one', (
    tester,
  ) async {
    await _store();
    await _pump(tester);
    await tester.tap(find.text('Cash out').first);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).at(0), '120');
    await tester.enterText(find.byType(TextField).at(1), 'Tea');
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Save & add another'),
      300,
      scrollable: _form(),
    );
    await tester.tap(find.text('Save & add another'));
    await tester.pumpAndSettle();
    final store = AppScope.read(tester.element(find.byType(Scaffold).first));
    expect(store.transactions.where((e) => e.title == 'Tea'), hasLength(1));
    // Still on the form, ready for the next entry.
    expect(find.text('Save & add another'), findsOneWidget);
    expect(find.text('Tea'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('★ saves a template and its chip fills the form', (tester) async {
    await _store();
    await _pump(tester);
    await tester.tap(find.text('Cash out').first);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).at(0), '450');
    await tester.enterText(find.byType(TextField).at(1), 'Momo plate');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Template'));
    await tester.pumpAndSettle();
    final store = AppScope.read(tester.element(find.byType(Scaffold).first));
    expect(store.templates.single.title, 'Momo plate');

    await tester.tap(find.byTooltip('Close'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cash out').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Momo plate · Rs 450'));
    await tester.pumpAndSettle();
    expect(find.text('Momo plate'), findsOneWidget);
    expect(find.text('450'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
