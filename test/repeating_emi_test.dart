import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:paisa_flow/features/emi/emi_screen.dart';
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

RecurringEntry _rent({
  required DateTime next,
  Repeat repeat = Repeat.monthly,
}) => RecurringEntry(
  id: 'rent',
  repeat: repeat,
  nextDue: next,
  title: 'Rent',
  type: TransactionType.cashOut,
  amount: 20000,
  category: 'Rent',
  paymentMode: 'Bank transfer',
  bookId: 'NIC',
  anchorDay: next.day,
);

Future<AppStore> _store({List<RecurringEntry> recurring = const []}) async {
  SharedPreferences.setMockInitialValues({
    _key: jsonEncode({
      'onboarded': true,
      'defaultCurrency': 'NPR',
      'books': [_account('NIC', 'bank'), _account('Scooter', 'loan')],
      'transactions': [],
      'recurring': [for (final r in recurring) r.toJson()],
    }),
  });
  final store = AppStore();
  await store.load();
  return store;
}

void main() {
  group('EMI', () {
    test('reducing-balance EMI matches the standard formula', () {
      // Rs 1,80,000 at 12% a year over 24 months.
      expect(emiFor(180000, 12, 24), closeTo(8473.22, .01));
      // 0% interest is a straight split.
      expect(emiFor(120000, 0, 12), 10000);
    });

    test('the schedule pays the loan off exactly', () {
      final rows = emiSchedule(180000, 12, 24);
      expect(rows, hasLength(24));
      expect(rows.last.balance, 0);
      final repaid = rows.fold(0.0, (s, r) => s + r.principal);
      expect(repaid, closeTo(180000, .01));
      expect(rows.first.interest, closeTo(1800, .01));
    });
  });

  group('repeating entries', () {
    test('monthly keeps its day, clamped to short months', () {
      final r = _rent(next: DateTime(2026, 1, 31, 9));
      expect(r.following(DateTime(2026, 1, 31, 9)), DateTime(2026, 2, 28, 9));
      expect(r.following(DateTime(2026, 2, 28, 9)), DateTime(2026, 3, 31, 9));
      final weekly = _rent(next: DateTime(2026, 10, 1), repeat: Repeat.weekly);
      expect(weekly.following(DateTime(2026, 10, 1)), DateTime(2026, 10, 8));
    });

    test('everything due up to today is listed, oldest first', () async {
      final store = await _store(
        recurring: [_rent(next: DateTime(2026, 8, 5, 10))],
      );
      final due = store.dueEntries(now: DateTime(2026, 10, 23));
      expect(due.map((d) => d.due), [
        DateTime(2026, 8, 5, 10),
        DateTime(2026, 9, 5, 10),
        DateTime(2026, 10, 5, 10),
      ]);
    });

    test(
      'confirming adds ticked ones; unticked are skipped to next cycle',
      () async {
        final store = await _store(
          recurring: [_rent(next: DateTime(2026, 9, 5, 10))],
        );
        final due = store.dueEntries(now: DateTime(2026, 10, 23));
        final added = await store.confirmDue(shown: due, add: [due.last]);
        expect(added, 1);
        expect(store.transactions.single.occurredAt, DateTime(2026, 10, 5, 10));
        expect(store.balanceFor('NIC'), -20000);
        expect(store.recurring.single.nextDue, DateTime(2026, 11, 5, 10));
        expect(store.dueEntries(now: DateTime(2026, 10, 23)), isEmpty);
      },
    );

    test('an EMI is added as a transfer that reduces what is owed', () async {
      final store = await _store(
        recurring: [
          RecurringEntry(
            id: 'emi',
            repeat: Repeat.monthly,
            nextDue: DateTime(2026, 10, 5, 10),
            title: 'EMI · Scooter',
            type: TransactionType.cashOut,
            amount: 8473.25,
            category: 'Transfer',
            paymentMode: '',
            bookId: 'NIC',
            toBookId: 'Scooter',
          ),
        ],
      );
      final due = store.dueEntries(now: DateTime(2026, 10, 23));
      await store.confirmDue(shown: due, add: due);
      expect(store.balanceFor('Scooter'), 8473.25);
      expect(store.transactions.every((e) => e.isTransferLeg), isTrue);
    });

    test('repeating entries are kept in backups', () async {
      final store = await _store(
        recurring: [_rent(next: DateTime(2026, 11, 5))],
      );
      final read = AppStore.readBackupData(store.snapshot());
      expect(read.recurring.single.title, 'Rent');
    });

    testWidgets('Home asks about due entries and adds the ticked ones', (
      tester,
    ) async {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      await _store(recurring: [_rent(next: yesterday)]);
      tester.view.physicalSize = const Size(1170, 2532);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(const PaisaFlowBootstrap());
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      expect(find.text('1 entry is due'), findsOneWidget);
      expect(find.text('Due yesterday'), findsOneWidget);
      await tester.tap(find.text('Add 1 entry'));
      await tester.pumpAndSettle();
      final store = AppScope.read(tester.element(find.byType(Scaffold).first));
      expect(store.transactions.single.title, 'Rent');
      expect(find.text('1 entry is due'), findsNothing);
      expect(tester.takeException(), isNull);
    });
  });
}
