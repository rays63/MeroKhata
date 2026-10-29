import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:paisa_flow/features/lock/pin_screen.dart';
import 'package:paisa_flow/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _key = 'hissabkitab_data_v1';

Map<String, Object?> _data() => {
  'onboarded': true,
  'defaultCurrency': 'NPR',
  'books': [
    {
      'id': 'nic',
      'name': 'NIC Asia',
      'createdAt': '2026-01-01T00:00:00.000',
      'updatedAt': '2026-01-01T00:00:00.000',
      'type': 'bank',
    },
  ],
  'transactions': [],
};

Future<AppStore> _store({Map<String, Object> prefs = const {}}) async {
  SharedPreferences.setMockInitialValues({_key: jsonEncode(_data()), ...prefs});
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

Future<void> _type(WidgetTester tester, String pin) async {
  for (final digit in pin.split('')) {
    await tester.tap(find.bySemanticsLabel(digit).last);
    await tester.pump();
  }
  await tester.pumpAndSettle();
}

void main() {
  test('only a salted hash of the PIN is stored', () async {
    final store = await _store();
    await store.setPin('2580');
    final saved = (await SharedPreferences.getInstance()).getString(
      'paisaflow_app_lock',
    )!;
    expect(saved.contains('2580'), isFalse);
    final reloaded = AppStore();
    await reloaded.load();
    expect(reloaded.appLockEnabled, isTrue);
    expect(await reloaded.checkPin('2580'), PinCheck.ok);
  });

  test(
    'five wrong PINs lock the keypad for 30 seconds, even after a restart',
    () async {
      final store = await _store();
      await store.setPin('2580');
      final now = DateTime(2026, 10, 23, 9);
      for (var i = 0; i < 4; i++) {
        expect(await store.checkPin('1111', now: now), PinCheck.wrong);
      }
      expect(await store.checkPin('1111', now: now), PinCheck.lockedOut);
      final reloaded = AppStore();
      await reloaded.load();
      // Even the right PIN waits out the lockout.
      expect(
        await reloaded.checkPin(
          '2580',
          now: now.add(const Duration(seconds: 10)),
        ),
        PinCheck.lockedOut,
      );
      expect(
        await reloaded.checkPin(
          '2580',
          now: now.add(const Duration(seconds: 31)),
        ),
        PinCheck.ok,
      );
      expect(reloaded.failedPinAttempts, 0);
    },
  );

  test('turning the lock off clears the PIN and settings', () async {
    final store = await _store();
    await store.setPin('2580');
    await store.setLockAfter(const Duration(minutes: 5));
    await store.setLockBiometrics(true);
    await store.disableAppLock();
    final reloaded = AppStore();
    await reloaded.load();
    expect(reloaded.appLockEnabled, isFalse);
    expect(reloaded.lockAfter, Duration.zero);
    expect(reloaded.lockBiometrics, isFalse);
  });

  testWidgets('setting a PIN asks twice and a mismatch starts over', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await _store();
    await _pump(tester);
    final nav = tester.state<NavigatorState>(find.byType(Navigator).first);
    nav.push(
      MaterialPageRoute(builder: (_) => const PinScreen(flow: PinFlow.set)),
    );
    await tester.pumpAndSettle();
    expect(find.text('STEP 1 OF 2'), findsOneWidget);
    await _type(tester, '2580');
    expect(find.text('STEP 2 OF 2'), findsOneWidget);
    await _type(tester, '1111');
    expect(find.text("PINs don't match. Try again."), findsOneWidget);
    await _type(tester, '2580');
    await _type(tester, '2580');
    final store = AppScope.read(tester.element(find.byType(Scaffold).first));
    expect(store.appLockEnabled, isTrue);
    expect(await store.checkPin('2580'), PinCheck.ok);
    handle.dispose();
  });

  testWidgets(
    'a locked app opens on the lock screen and unlocks with the PIN',
    (tester) async {
      final handle = tester.ensureSemantics();
      final store = await _store();
      await store.setPin('2580');
      await _pump(tester);
      expect(find.text('Enter your PIN'), findsOneWidget);

      await _type(tester, '1234');
      expect(find.text('Wrong PIN · 4 attempts left'), findsOneWidget);
      await _type(tester, '2580');
      expect(find.text('Enter your PIN'), findsNothing);

      // Going to the background and back locks again ("Immediately").
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      await tester.pump();
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pumpAndSettle();
      expect(find.text('Enter your PIN'), findsOneWidget);
      expect(tester.takeException(), isNull);
      handle.dispose();
    },
  );
}
