import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:paisa_flow/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

Map<String, Object?> _arb(String locale) =>
    jsonDecode(File('lib/l10n/app_$locale.arb').readAsStringSync())
        as Map<String, Object?>;

Set<String> _placeholders(String message) => {
  for (final m in RegExp(r'\{(\w+)[,}]').allMatches(message)) m.group(1)!,
};

Future<void> _pumpApp(WidgetTester tester, {required String language}) async {
  tester.view.physicalSize = const Size(390, 844) * 3;
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  SharedPreferences.setMockInitialValues({
    'paisaflow_language': language,
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
  await tester.pumpAndSettle();
}

void main() {
  test('every English string has a Nepali translation', () {
    final en = _arb('en');
    final ne = _arb('ne');
    final keys = en.keys.where((k) => !k.startsWith('@')).toSet();
    final neKeys = ne.keys.where((k) => !k.startsWith('@')).toSet();
    expect(keys.difference(neKeys), isEmpty, reason: 'missing in app_ne.arb');
    expect(neKeys.difference(keys), isEmpty, reason: 'stale in app_ne.arb');
  });

  test('translations keep the same placeholders', () {
    final en = _arb('en');
    final ne = _arb('ne');
    for (final key in en.keys.where((k) => !k.startsWith('@'))) {
      final enMessage = en[key] as String;
      final neMessage = ne[key] as String;
      // Plural selectors may drop the "=1" case in Nepali, but every
      // placeholder used in English must still appear.
      expect(
        _placeholders(neMessage).containsAll(_placeholders(enMessage)),
        isTrue,
        reason: '$key: "$neMessage" vs "$enMessage"',
      );
    }
  });

  testWidgets('the app runs in Nepali with Mukta', (tester) async {
    await _pumpApp(tester, language: 'ne');

    expect(find.text('गृह'), findsOneWidget);
    expect(find.text('खाताहरू'), findsOneWidget);
    expect(find.text('भर्खर अपडेट भएका'), findsOneWidget);
    final context = tester.element(find.text('गृह'));
    expect(Theme.of(context).textTheme.bodyMedium!.fontFamily, 'Mukta');
    expect(Localizations.localeOf(context).languageCode, 'ne');
    expect(tester.takeException(), isNull);
  });

  testWidgets('switching language updates the app live', (tester) async {
    await _pumpApp(tester, language: 'en');
    expect(find.text('Home'), findsOneWidget);

    final store = AppScope.read(tester.element(find.text('Home')));
    await store.setLanguage('ne');
    await tester.pumpAndSettle();
    expect(find.text('गृह'), findsOneWidget);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('paisaflow_language'), 'ne');
  });
}
