import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:paisa_flow/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> _tapText(WidgetTester tester, String text) async {
  await tester.ensureVisible(find.text(text));
  await tester.pumpAndSettle();
  await tester.tap(find.text(text));
}

void main() {
  testWidgets('fresh install: splash, cards, profile, first book, home', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844) * 3;
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const PaisaFlowBootstrap());
    await tester.pump();
    expect(find.text('Every paisa, accounted for.'), findsOneWidget);

    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    expect(find.text('All your books, one pocket'), findsOneWidget);

    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(find.text('Import statements, skip the typing'), findsOneWidget);
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(find.text('Goals and splits that add up'), findsOneWidget);
    await tester.tap(find.text('Get started'));
    await tester.pumpAndSettle();

    // Step 1: validation, then valid details.
    expect(find.text('Tell us about you'), findsOneWidget);
    await _tapText(tester, 'Continue');
    await tester.pump();
    expect(find.text('Please tell us your name'), findsOneWidget);

    await tester.enterText(
      find.widgetWithText(TextField, 'e.g. Aarav Shrestha'),
      'Aarav Shrestha',
    );
    await tester.enterText(
      find.widgetWithText(TextField, '98XXXXXXXX'),
      '98412',
    );
    await _tapText(tester, 'Continue');
    await tester.pump();
    expect(
      find.text('Enter a 10-digit mobile number starting with 9'),
      findsOneWidget,
    );

    await tester.enterText(
      find.widgetWithText(TextField, '98412'),
      '9841234567',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'you@example.com'),
      'aarav@gmail',
    );
    await _tapText(tester, 'Continue');
    await tester.pump();
    expect(
      find.text('That email looks incomplete — fix it or leave it blank'),
      findsOneWidget,
    );
    await tester.enterText(find.widgetWithText(TextField, 'aarav@gmail'), '');
    await _tapText(tester, 'Continue');
    await tester.pumpAndSettle();

    // Step 2: first book.
    expect(find.text("Let's set up your first book"), findsOneWidget);
    await tester.enterText(
      find.widgetWithText(TextField, 'Personal'),
      'Ghar Kharcha',
    );
    await tester.enterText(find.widgetWithText(TextField, '0'), '5000');
    await _tapText(tester, 'Get started');
    await tester.pumpAndSettle();

    expect(find.text('Aarav Shrestha'), findsOneWidget);
    expect(find.text('Ghar Kharcha'), findsOneWidget);
    expect(find.text('Rs 5,000'), findsWidgets);

    final saved =
        jsonDecode(
              (await SharedPreferences.getInstance()).getString(
                'hissabkitab_data_v1',
              )!,
            )
            as Map<String, Object?>;
    expect(saved['onboarded'], isTrue);
    expect(
      (saved['books'] as List).single,
      containsPair('name', 'Ghar Kharcha'),
    );
    expect(saved['profile'], containsPair('phone', '9841234567'));
  });

  testWidgets('existing data skips onboarding', (tester) async {
    SharedPreferences.setMockInitialValues({
      'hissabkitab_data_v1': jsonEncode({
        'books': [
          {
            'id': 'b',
            'name': 'Main Book',
            'createdAt': '2026-01-01T00:00:00.000',
            'updatedAt': '2026-01-01T00:00:00.000',
          },
        ],
        'transactions': [],
      }),
    });
    await tester.pumpWidget(const PaisaFlowBootstrap());
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 2));

    expect(find.text('Recently updated'), findsOneWidget);
    expect(find.text('All your books, one pocket'), findsNothing);
  });

  testWidgets('intro cards fit a small phone at double text size', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(375, 667) * 2;
    tester.view.devicePixelRatio = 2;
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const PaisaFlowBootstrap());
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    expect(find.text('All your books, one pocket'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
