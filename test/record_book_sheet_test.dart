import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:paisa_flow/features/split/split_widgets.dart';
import 'package:paisa_flow/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<BuildContext> _app(WidgetTester tester) async {
  tester.view.physicalSize = const Size(390, 844) * 3;
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  SharedPreferences.setMockInitialValues({
    'hissabkitab_data_v1': jsonEncode({
      'books': [
        for (final (id, name) in [('p', 'Personal'), ('n', 'Nic')])
          {
            'id': id,
            'name': name,
            'currency': 'NPR',
            'createdAt': '2026-01-01T00:00:00.000',
            'updatedAt': '2026-01-01T00:00:00.000',
          },
      ],
      'transactions': [],
      'onboarded': true,
    }),
  });
  await tester.pumpWidget(const PaisaFlowBootstrap());
  await tester.pumpAndSettle(const Duration(seconds: 3));
  return tester.element(find.byType(IndexedStack));
}

void main() {
  testWidgets('asks which book, one tap picks it', (tester) async {
    final context = await _app(tester);
    final choice = showSettleSheet(
      context,
      friendName: 'Sita',
      amount: 500,
      currency: 'NPR',
    );
    await tester.pumpAndSettle();

    expect(find.text('Add as cash in to Personal'), findsOneWidget);
    expect(find.text('Add as cash in to Nic'), findsOneWidget);
    expect(find.text('Don’t record in an account'), findsOneWidget);
    await tester.tap(find.text('Add as cash in to Nic'));
    await tester.pumpAndSettle();
    expect((await choice)?.bookId, 'n');
  });

  testWidgets('no book in the currency offers create or skip', (tester) async {
    final context = await _app(tester);
    final choice = showSettleSheet(
      context,
      friendName: 'Sita',
      amount: -20,
      currency: 'GBP',
    );
    await tester.pumpAndSettle();

    expect(find.text('You don’t have a GBP account yet.'), findsOneWidget);
    expect(find.text('Create a GBP account'), findsOneWidget);
    expect(find.text('Add as cash out to Personal'), findsNothing);
    await tester.tap(find.text('Don’t record in an account'));
    await tester.pumpAndSettle();
    final picked = await choice;
    expect(picked, isNotNull);
    expect(picked!.bookId, isNull);
  });

  testWidgets('dismissing the sheet cancels', (tester) async {
    final context = await _app(tester);
    final choice = showSettleSheet(
      context,
      friendName: 'Sita',
      amount: 500,
      currency: 'NPR',
    );
    await tester.pumpAndSettle();
    await tester.tapAt(const Offset(195, 40));
    await tester.pumpAndSettle();
    expect(await choice, isNull);
  });
}
