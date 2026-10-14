import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:paisa_flow/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Fresh install through onboarding, printing `SHOT:<name>` at each step so
/// a host script can screenshot the simulator.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('onboarding tour', (tester) async {
    SharedPreferences.setMockInitialValues({});

    Future<void> shot(String name, {bool settle = true}) async {
      if (settle) await tester.pumpAndSettle();
      // ignore: avoid_print
      print('SHOT:onboarding_$name');
      await tester.runAsync(() => Future.delayed(const Duration(seconds: 2)));
    }

    Future<void> tap(String text) async {
      await tester.ensureVisible(find.text(text));
      await tester.pumpAndSettle();
      await tester.tap(find.text(text));
      await tester.pumpAndSettle();
    }

    await tester.pumpWidget(const PaisaFlowBootstrap());
    await tester.pump(const Duration(milliseconds: 300));
    await shot('splash', settle: false);
    await tester.pumpAndSettle();
    await tester.runAsync(() => Future.delayed(const Duration(seconds: 2)));
    await tester.pumpAndSettle();
    await shot('card1');
    await tap('Next');
    await shot('card2');
    await tap('Next');
    await shot('card3');
    await tap('Get started');
    await shot('profile_empty');

    await tester.enterText(
      find.widgetWithText(TextField, 'e.g. Aarav Shrestha'),
      'Aarav Shrestha',
    );
    await tester.enterText(
      find.widgetWithText(TextField, '98XXXXXXXX'),
      '98412',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'you@example.com'),
      'aarav@gmail',
    );
    await tap('Continue');
    FocusManager.instance.primaryFocus?.unfocus();
    await shot('profile_error');

    await tester.enterText(
      find.widgetWithText(TextField, '98412'),
      '9841234567',
    );
    await tester.enterText(find.widgetWithText(TextField, 'aarav@gmail'), '');
    await tap('Continue');
    FocusManager.instance.primaryFocus?.unfocus();
    await shot('setup');
    await tap('Get started');
    await shot('home');
  });
}
