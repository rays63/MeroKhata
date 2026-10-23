import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:paisa_flow/features/backup/restore_screen.dart';
import 'package:paisa_flow/data/backup.dart';
import 'package:paisa_flow/main.dart';
import 'package:paisa_flow/widgets/pf.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _key = 'hissabkitab_data_v1';

Map<String, Object?> _entry(String id, String book, double amount) => {
  'id': id,
  'bookId': book,
  'title': id,
  'amount': amount,
  'type': 'cashIn',
  'occurredAt': '2026-10-01T09:00:00.000',
  'createdAt': '2026-10-01T09:00:00.000',
  'updatedAt': '2026-10-01T09:00:00.000',
  'category': 'Salary',
  'paymentMode': 'Cash',
  'notes': '',
};

Map<String, Object?> _data(List<String> entryIds, {String book = 'nic'}) => {
  'onboarded': true,
  'defaultCurrency': 'NPR',
  'books': [
    {
      'id': book,
      'name': book,
      'createdAt': '2026-01-01T00:00:00.000',
      'updatedAt': '2026-01-01T00:00:00.000',
      'type': 'bank',
    },
  ],
  'transactions': [for (final id in entryIds) _entry(id, book, 1000)],
  'tags': ['wedding'],
};

Future<AppStore> _store(Map<String, Object?> data) async {
  SharedPreferences.setMockInitialValues({_key: jsonEncode(data)});
  final store = AppStore();
  await store.load();
  return store;
}

void main() {
  final when = DateTime(2026, 10, 23, 9);

  group('backup file', () {
    test('round-trips without a password', () async {
      final bytes = await BackupCodec.encode(
        _data(['a']),
        appVersion: '1.0.0',
        now: when,
      );
      expect(ascii.decode(bytes.sublist(0, 5)), 'PFBAK');
      // Nothing readable about the money inside.
      expect(latin1.decode(bytes).contains('Salary'), isFalse);
      final info = BackupCodec.readInfo(bytes);
      expect(info.protected, isFalse);
      expect(info.createdAt, when);
      final data = await BackupCodec.decode(bytes);
      expect((data['transactions'] as List).single['id'], 'a');
    });

    test('a password is needed to open a protected file', () async {
      final bytes = await BackupCodec.encode(
        _data(['a']),
        password: 'dashain2026',
        appVersion: '1.0.0',
      );
      expect(BackupCodec.readInfo(bytes).protected, isTrue);
      await expectLater(
        BackupCodec.decode(bytes, password: 'tihar2026'),
        throwsA(
          isA<BackupException>().having(
            (e) => e.problem,
            'problem',
            BackupProblem.wrongPassword,
          ),
        ),
      );
      final data = await BackupCodec.decode(bytes, password: 'dashain2026');
      expect(data['tags'], ['wedding']);
    });

    BackupProblem problemOf(void Function() read) {
      try {
        read();
      } on BackupException catch (e) {
        return e.problem;
      }
      fail('no BackupException');
    }

    test(
      'other files, damaged files and newer versions are told apart',
      () async {
        final pdf = Uint8List.fromList(utf8.encode('%PDF-1.7 statement'));
        expect(
          problemOf(() => BackupCodec.readInfo(pdf)),
          BackupProblem.notBackup,
        );

        final bytes = await BackupCodec.encode(
          _data(['a']),
          appVersion: '1.0.0',
        );
        final cut = bytes.sublist(0, 20);
        expect(
          problemOf(() => BackupCodec.readInfo(cut)),
          BackupProblem.damaged,
        );

        final tampered = Uint8List.fromList(bytes);
        tampered[tampered.length - 20] ^= 0xff;
        await expectLater(
          BackupCodec.decode(tampered),
          throwsA(
            isA<BackupException>().having(
              (e) => e.problem,
              'problem',
              BackupProblem.damaged,
            ),
          ),
        );

        final newer = Uint8List.fromList(bytes)..[5] = 9;
        expect(
          problemOf(() => BackupCodec.readInfo(newer)),
          BackupProblem.newerVersion,
        );
      },
    );
  });

  group('restore', () {
    test('merge adds only what is missing and changes nothing else', () async {
      final store = await _store(_data(['a', 'b']));
      final other = AppStore.readBackupData(_data(['b', 'c']));
      expect(store.mergePreview(other), (entries: 1, alreadyHere: 1));
      final added = await store.restoreMerge(other);
      expect(added, 1);
      expect(store.transactions.map((e) => e.id), ['a', 'b', 'c']);
      expect(store.books, hasLength(1));
      expect(store.balanceFor('nic'), 3000);
    });

    test('replace swaps everything for the backup', () async {
      final store = await _store(_data(['a', 'b']));
      final other = AppStore.readBackupData(_data(['z'], book: 'esewa'));
      await store.restoreReplace(other);
      expect(store.transactions.map((e) => e.id), ['z']);
      expect(store.books.single.id, 'esewa');
      final reloaded = AppStore();
      await reloaded.load();
      expect(reloaded.transactions.single.id, 'z');
    });

    test('unreadable backup data is rejected before anything changes', () {
      expect(
        () => AppStore.readBackupData({'transactions': 'nonsense'}),
        throwsA(anything),
      );
    });

    test('the store snapshot round-trips through a backup', () async {
      final store = await _store(_data(['a']));
      final bytes = await BackupCodec.encode(
        store.snapshot(),
        appVersion: '1.0.0',
      );
      final read = AppStore.readBackupData(await BackupCodec.decode(bytes));
      expect(read.transactions.single.id, 'a');
      expect(read.tags, ['wedding']);
    });
  });

  group('reminder', () {
    test('after 30 days without a backup, until snoozed', () async {
      final store = await _store(_data(['a']));
      final now = DateTime(2026, 11, 5);
      // Never backed up: counted from the oldest entry (1 Oct).
      expect(store.backupReminderDays(now: now), 34);
      await store.recordBackup(at: DateTime(2026, 11, 1));
      expect(store.backupReminderDays(now: now), isNull);
      expect(store.backupReminderDays(now: DateTime(2026, 12, 2)), 31);
      await store.snoozeBackupReminder(now: DateTime(2026, 12, 2));
      expect(store.backupReminderDays(now: DateTime(2026, 12, 3)), isNull);
    });
  });

  group('restore screen', () {
    Future<AppStore> open(WidgetTester tester, Uint8List bytes) async {
      await _store(_data(['a']));
      tester.view.physicalSize = const Size(1170, 2532);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(const PaisaFlowBootstrap());
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 2));
      final nav = tester.state<NavigatorState>(find.byType(Navigator).first);
      nav.push(
        MaterialPageRoute(
          builder: (_) => RestoreScreen(
            bytes: bytes,
            fileName: 'Paisa Flow 2026-10-23.pfbak',
          ),
        ),
      );
      await tester.pumpAndSettle();
      return AppScope.read(tester.element(find.byType(RestoreScreen)));
    }

    testWidgets('a PDF is not a backup and nothing changes', (tester) async {
      await open(tester, Uint8List.fromList(utf8.encode('%PDF-1.7')));
      expect(find.text("This isn't a Paisa Flow backup"), findsOneWidget);
      expect(
        find.text('Your data on this phone was not changed.'),
        findsOneWidget,
      );
    });

    testWidgets('protected backup: wrong, then right password, then merge', (
      tester,
    ) async {
      final bytes = await tester.runAsync(
        () => BackupCodec.encode(
          _data(['a', 'b']),
          password: 'dashain2026',
          appVersion: '1.0.0',
        ),
      );
      final store = await open(tester, bytes!);
      expect(find.text('This backup is password-protected'), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'wrong-one');
      await tester.runAsync(() async {
        await tester.tap(find.text('Unlock backup'));
        await Future<void>.delayed(const Duration(seconds: 3));
      });
      await tester.pumpAndSettle();
      expect(
        find.text('Wrong password. Check caps and try again.'),
        findsOneWidget,
      );

      await tester.enterText(find.byType(TextField), 'dashain2026');
      await tester.runAsync(() async {
        await tester.tap(find.text('Unlock backup'));
        await Future<void>.delayed(const Duration(seconds: 3));
      });
      await tester.pumpAndSettle();
      expect(find.text("What's in this file"), findsOneWidget);

      final scrollable = find.byType(Scrollable).first;
      await tester.scrollUntilVisible(
        find.text('Continue'),
        300,
        scrollable: scrollable,
      );
      await tester.ensureVisible(find.text('Continue'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Continue'));
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();
      expect(find.text('Restore complete'), findsOneWidget);
      expect(store.transactions.map((e) => e.id), ['a', 'b']);
      expect(tester.takeException(), isNull);
    });

    testWidgets('replace needs the confirmation ticked', (tester) async {
      final bytes = await tester.runAsync(
        () => BackupCodec.encode(_data(['z']), appVersion: '1.0.0'),
      );
      final store = await open(tester, bytes!);
      final scrollable = find.byType(Scrollable).first;
      await tester.scrollUntilVisible(
        find.text('Replace everything'),
        300,
        scrollable: scrollable,
      );
      await tester.ensureVisible(find.text('Replace everything'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Replace everything'));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.text('Continue'),
        300,
        scrollable: scrollable,
      );
      await tester.ensureVisible(find.text('Continue'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();
      expect(find.text('This cannot be undone'), findsOneWidget);

      final replace = find.widgetWithText(PfButton, 'Replace everything');
      expect(tester.widget<PfButton>(replace).onPressed, isNull);
      await tester.ensureVisible(
        find.text('I understand. Delete and replace my data.'),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('I understand. Delete and replace my data.'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(replace);
      await tester.pumpAndSettle();
      await tester.tap(replace);
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();
      expect(find.text('Restore complete'), findsOneWidget);
      expect(store.transactions.single.id, 'z');
    });
  });
}
