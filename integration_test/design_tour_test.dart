import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:paisa_flow/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Seeds the sample data used in the design file and visits each
/// screen, printing `SHOT:<name>` so a host script can screenshot the
/// simulator. Run with `--dart-define=THEME=dark` for the dark variants.
const _theme = String.fromEnvironment('THEME', defaultValue: 'light');
const _lang = String.fromEnvironment('LANG', defaultValue: 'en');

Map<String, Object?> _seed() {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  String at(int daysAgo, int hour, [int minute = 0]) => today
      .subtract(Duration(days: daysAgo))
      .add(Duration(hours: hour, minutes: minute))
      .toIso8601String();
  var n = 0;
  Map<String, Object?> txn(
    String book,
    String type,
    double amount,
    String title,
    String category,
    String mode,
    int daysAgo,
    int hour, {
    String notes = '',
    String? goal,
    String ref = '',
    List<String> tags = const [],
  }) => {
    'id': 't${n++}',
    'bookId': book,
    'title': title,
    'amount': amount,
    'type': type == 'in' ? 'cashIn' : 'cashOut',
    'occurredAt': at(daysAgo, hour),
    'createdAt': at(daysAgo, hour),
    'updatedAt': at(daysAgo, hour),
    'category': category,
    'paymentMode': mode,
    'notes': notes,
    'goalId': goal,
    'externalReference': ref,
    'tags': tags,
  };
  Map<String, Object?> book(
    String id,
    String name,
    String cur,
    int color,
    int days, {
    String type = 'bank',
  }) => {
    'id': id,
    'name': name,
    'description': '',
    'createdAt': at(30, 9),
    'updatedAt': at(days, 9),
    'currency': cur,
    'color': color,
    'type': type,
  };
  return {
    'books': [
      book('personal', 'Personal', 'NPR', 0xFF10A65A, 0),
      book('shop', 'Kirana Pasal', 'NPR', 0xFF3B7DD8, 1, type: 'other'),
      book('esewa', 'eSewa', 'NPR', 0xFF0E9AA7, 1, type: 'wallet'),
      book('visa', 'Nabil Visa', 'NPR', 0xFFE5484D, 2, type: 'card'),
      book('freelance', 'Freelance', 'USD', 0xFF8B5CF6, 3),
      book('trip', 'Japan Trip', 'JPY', 0xFFE39A2E, 8, type: 'cash'),
    ],
    'subcategories': {
      'Food': ['Lunch', 'Momo'],
    },
    'budgets': [
      {'id': 'bo', 'scope': 'currency:NPR', 'amount': 40000},
      {
        'id': 'bg',
        'scope': 'currency:NPR',
        'category': 'Groceries',
        'amount': 3000,
      },
    ],
    'templates': [
      {
        'id': 'tp1',
        'title': 'Momo',
        'type': 'cashOut',
        'amount': 450,
        'category': 'Food',
        'paymentMode': 'Cash',
        'bookId': 'personal',
        'subcategory': 'Momo',
      },
    ],
    'tags': ['dashain', 'japan-trip'],
    'transactions': [
      txn(
        'personal',
        'in',
        85000,
        'Salary — October',
        'Salary',
        'Bank transfer',
        0,
        9,
        ref: 'NEFT-88213',
      ),
      txn(
        'personal',
        'out',
        3460,
        'Bhatbhateni groceries',
        'Groceries',
        'eSewa',
        0,
        18,
        notes: 'Monthly stock-up',
      ),
      txn(
        'personal',
        'out',
        1840,
        'Electricity bill',
        'Utilities',
        'Khalti',
        1,
        8,
      ),
      txn('personal', 'out', 960, 'Momo with friends', 'Food', 'Cash', 1, 19),
      txn(
        'personal',
        'in',
        18500,
        'Logo design payment',
        'Freelance',
        'Bank transfer',
        2,
        14,
        goal: 'laptop',
      ),
      txn('personal', 'out', 320, 'Pathao ride', 'Transport', 'eSewa', 2, 9),
      txn(
        'personal',
        'out',
        22000,
        'House rent',
        'Rent',
        'Bank transfer',
        4,
        10,
      ),
      txn(
        'personal',
        'in',
        5000,
        'Dashain tika gift',
        'Gift',
        'Cash',
        5,
        16,
        goal: 'dashain',
        tags: ['dashain'],
      ),
      txn(
        'personal',
        'out',
        500,
        'Mobile recharge',
        'Utilities',
        'Khalti',
        6,
        11,
      ),
      txn('personal', 'out', 4200, 'Pharmacy', 'Health', 'Card', 8, 17),
      txn(
        'personal',
        'in',
        42000,
        'Opening balance',
        'Opening balance',
        'Cash',
        13,
        9,
      ),
      txn(
        'shop',
        'in',
        124000,
        'Counter sales — week 2',
        'Sales',
        'Cash',
        1,
        20,
      ),
      txn(
        'shop',
        'out',
        86500,
        'Wholesale stock',
        'Stock',
        'Bank transfer',
        3,
        11,
      ),
      txn(
        'freelance',
        'in',
        2400,
        'Website project',
        'Freelance',
        'Bank transfer',
        3,
        15,
      ),
      txn('freelance', 'out', 180, 'Design tools', 'Shopping', 'Card', 12, 13),
      txn(
        'trip',
        'in',
        120000,
        'Exchanged at airport',
        'Opening balance',
        'Cash',
        10,
        7,
      ),
      txn('trip', 'out', 46800, 'Ryokan in Kyoto', 'Travel', 'Card', 9, 18),
    ],
    'goals': [
      {
        'id': 'emergency',
        'name': 'Emergency fund',
        'targetAmount': 150000,
        'manualSaved': 92500,
        'savedAmount': 0,
        'deadline': null,
        'color': 0xFF10A65A,
      },
      {
        'id': 'laptop',
        'name': 'New laptop',
        'targetAmount': 120000,
        'manualSaved': 19500,
        'savedAmount': 0,
        'deadline': DateTime(now.year + 1, 3, 1).toIso8601String(),
        'color': 0xFF3B7DD8,
      },
      {
        'id': 'dashain',
        'name': 'Dashain gifts',
        'targetAmount': 25000,
        'manualSaved': 20000,
        'savedAmount': 0,
        'deadline': today.add(const Duration(days: 6)).toIso8601String(),
        'color': 0xFFE39A2E,
      },
    ],
    'logs': [],
    'profile': {'name': 'Aarav Shrestha', 'phone': '9841234567', 'email': ''},
    'friends': [
      {'id': 'sita', 'name': 'Sita', 'color': 0xFFE39A2E},
      {'id': 'bikash', 'name': 'Bikash', 'color': 0xFF8B5CF6},
      {'id': 'anu', 'name': 'Anu', 'color': 0xFFE5484D},
      {'id': 'rohan', 'name': 'Rohan', 'color': 0xFF3B7DD8},
    ],
    'groups': [
      {
        'id': 'pokhara',
        'name': 'Pokhara Trip',
        'memberIds': ['sita', 'bikash', 'anu'],
        'createdAt': at(6, 9),
        'expenses': [
          {
            'id': 'e1',
            'title': 'Hotel (2 nights)',
            'amount': 8400,
            'paidBy': 'me',
            'shares': {'me': 1, 'sita': 1, 'bikash': 1, 'anu': 1},
            'createdAt': at(6, 10),
          },
          {
            'id': 'e2',
            'title': 'Boating at Phewa',
            'amount': 1600,
            'paidBy': 'sita',
            'shares': {'me': 1, 'sita': 1, 'bikash': 1, 'anu': 1},
            'createdAt': at(5, 10),
          },
          {
            'id': 'e3',
            'title': 'Lakeside dinner',
            'amount': 4400,
            'paidBy': 'me',
            'shares': {'me': 1, 'sita': 1, 'bikash': 1, 'anu': 1},
            'createdAt': at(5, 20),
          },
        ],
        'settlements': [
          {'id': 's1', 'friendId': 'anu', 'amount': 3200, 'at': at(4, 9)},
        ],
      },
      {
        'id': 'flat',
        'name': 'Flat 3B',
        'memberIds': ['rohan', 'anu'],
        'createdAt': at(20, 9),
        'expenses': [
          {
            'id': 'e4',
            'title': 'Internet — October',
            'amount': 1500,
            'paidBy': 'rohan',
            'shares': {'me': 1, 'rohan': 1, 'anu': 1},
            'createdAt': at(3, 9),
          },
          {
            'id': 'e5',
            'title': 'Gas cylinder',
            'amount': 1950,
            'paidBy': 'rohan',
            'shares': {'me': 1, 'rohan': 1, 'anu': 1},
            'createdAt': at(2, 9),
          },
        ],
      },
    ],
    'bills': [
      {
        'id': 'b1',
        'title': 'Thakali dinner',
        'amount': 3600,
        'shares': {'me': 1, 'sita': 1, 'bikash': 1},
        'createdAt': at(1, 20),
      },
      {
        'id': 'b2',
        'title': 'Movie night',
        'amount': 1800,
        'shares': {'me': 1, 'sita': 1, 'anu': 1, 'rohan': 1},
        'createdAt': at(6, 21),
        'settlements': [
          {'id': 's2', 'friendId': 'sita', 'amount': 450, 'at': at(5, 9)},
          {'id': 's3', 'friendId': 'anu', 'amount': 450, 'at': at(5, 9)},
          {'id': 's4', 'friendId': 'rohan', 'amount': 450, 'at': at(5, 9)},
        ],
      },
    ],
    'onboarded': true,
  };
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('नेपाली tour ($_theme)', (tester) async {
    SharedPreferences.setMockInitialValues({
      'hissabkitab_data_v1': jsonEncode(_seed()),
      'hissabkitab_theme_mode': _theme,
      'paisaflow_language': 'ne',
    });

    Future<void> shot(String name) async {
      await tester.pumpAndSettle();
      // ignore: avoid_print
      print('SHOT:ne_${_theme}_$name');
      await tester.runAsync(() => Future.delayed(const Duration(seconds: 2)));
    }

    Future<void> tap(Finder finder) async {
      await tester.tap(finder);
      await tester.pumpAndSettle();
    }

    await tester.pumpWidget(const PaisaFlowBootstrap());
    await tester.pumpAndSettle();
    await shot('home');

    await tap(find.text('खाताहरू').last);
    await shot('books');
    await tap(find.text('Personal').first);
    await shot('detail');
    await tap(find.text('खर्च').last);
    await shot('add_out');
    await tap(find.byTooltip('बन्द गर्नुहोस्'));
    await tap(find.byTooltip('फर्कनुहोस्'));

    await tap(find.text('विश्लेषण').last);
    await shot('insights');
    await tester.scrollUntilVisible(
      find.text('Rent'),
      400,
      scrollable: find.byType(Scrollable).first,
    );
    await shot('insights_trends');

    await tap(find.text('बाँडफाँड').last);
    await shot('split');
    await tap(find.text('Pokhara Trip'));
    await shot('group');
    await tap(find.byTooltip('फर्कनुहोस्'));

    await tap(find.text('गृह').last);
    await tap(find.text('ट्रान्सफर').first);
    await shot('transfer');
    await tap(find.byTooltip('बन्द गर्नुहोस्'));
    await tap(find.text('AS'));
    await shot('settings');
    for (final (label, name) in [
      ('बजेट', 'budgets'),
      ('ब्याकअप र रिस्टोर', 'backup'),
      ('एप लक', 'app_lock'),
    ]) {
      await tester.scrollUntilVisible(
        find.text(label),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await tap(find.text(label));
      await shot(name);
      await tap(find.byTooltip('फर्कनुहोस्'));
    }
  }, skip: _lang != 'ne');

  testWidgets('design tour ($_theme)', (tester) async {
    SharedPreferences.setMockInitialValues({
      'hissabkitab_data_v1': jsonEncode(_seed()),
      'hissabkitab_theme_mode': _theme,
    });

    Future<void> shot(String name) async {
      await tester.pumpAndSettle();
      // ignore: avoid_print
      print('SHOT:${_theme}_$name');
      await tester.runAsync(() => Future.delayed(const Duration(seconds: 2)));
    }

    bool found(Finder finder) {
      try {
        return finder.evaluate().isNotEmpty;
      } catch (_) {
        return false;
      }
    }

    // At large text sizes a target can be outside a lazy list and not built
    // yet: scroll the page down, then up, until it is.
    Future<void> reveal(Finder finder) async {
      final page = find
          .byWidgetPredicate(
            (w) =>
                w is Scrollable &&
                axisDirectionToAxis(w.axisDirection) == Axis.vertical,
          )
          .hitTestable();
      for (final dy in const [-300.0, 300.0]) {
        for (var i = 0; i < 25 && !found(finder) && found(page); i++) {
          await tester.drag(page.first, Offset(0, dy));
          await tester.pumpAndSettle();
        }
      }
    }

    Future<void> tap(Finder finder) async {
      if (!found(finder)) await reveal(finder);
      // At large text sizes the target may be scrolled off-screen, where a
      // tap would land on whatever is drawn there instead.
      final screen = Offset.zero & tester.view.physicalSize;
      final at = tester.getCenter(finder.first) * tester.view.devicePixelRatio;
      if (!screen.deflate(60).contains(at)) {
        await tester.ensureVisible(finder);
        await tester.pumpAndSettle();
      }
      await tester.tap(finder);
      await tester.pumpAndSettle();
    }

    Future<void> back() async {
      // At large text sizes the header (and its Back button) can be
      // scrolled away; fall back to the system back action.
      if (find.byTooltip('Back').evaluate().isEmpty) {
        await tester.binding.handlePopRoute();
      } else {
        await tester.pageBack();
      }
      await tester.pumpAndSettle();
    }

    Future<void> scrollTo(Finder finder) async {
      await tester.scrollUntilVisible(
        finder,
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
    }

    await tester.pumpWidget(const PaisaFlowBootstrap());
    await tester.pumpAndSettle();
    await shot('home');

    await tap(find.byTooltip('Search'));
    await tester.enterText(find.byType(TextField), 'momo');
    await shot('search');
    await back();

    await tap(find.text('Accounts').last);
    await shot('accounts');
    await tap(find.byTooltip('Account actions').first);
    await shot('accounts_menu');
    await tester.fling(
      find.byType(Scrollable).first,
      const Offset(0, 2000),
      3000,
    );
    await tester.pumpAndSettle();
    await tap(find.byTooltip('Tags'));
    await shot('tags');
    await back();

    await tap(find.text('Personal').first);
    await shot('detail');

    await tap(find.byTooltip('Report'));
    await shot('report');
    await back();

    await tap(find.text('Category'));
    await shot('filter_category');
    await tap(find.text('All categories'));

    await tap(find.text('Bhatbhateni groceries'));
    await shot('entry_detail');
    await scrollTo(find.text('Split this bill with friends'));
    await tap(find.text('Split this bill with friends'));
    await shot('split_from_entry');
    await tap(find.byTooltip('Close'));
    await back();

    await tap(find.text('Cash out').last);
    await shot('add_out');
    await tap(find.text('Groceries'));
    await shot('category_sheet');
    await tap(find.text('Food'));
    await shot('subcategory_sheet');
    await tap(find.text('Lunch'));
    await scrollTo(find.text('Add tag'));
    await tap(find.text('Add tag'));
    await shot('tag_picker');
    await tap(find.text('Done'));
    await tap(find.text('Transfer').first);
    await shot('transfer');
    await tap(find.byTooltip('Close'));

    await tap(find.byTooltip('Import statement'));
    await shot('import_pick');
    await back();
    await back();

    await tap(find.text('Home').last);
    await scrollTo(find.text('See all'));
    await tap(find.text('See all'));
    await shot('all_entries');
    await back();

    await tap(find.text('Insights').last);
    await shot('insights_flow');
    await tap(find.text('Pace'));
    await shot('insights_pace');
    await tap(find.text('Calendar').last);
    await shot('insights_calendar');
    await tap(find.text('Flow'));
    await scrollTo(find.text('Where it went'));
    await shot('insights_boxes');
    await tester.scrollUntilVisible(
      find.text('Customize'),
      -300,
      scrollable: find.byType(Scrollable).first,
    );
    await tap(find.text('Customize'));
    await shot('customize');
    await back();

    await tap(find.text('Split').last);
    await shot('split_groups');
    await tap(find.text('Bills'));
    await shot('split_bills');
    await tap(find.text('Groups'));
    await tap(find.text('Pokhara Trip'));
    await shot('group');
    await back();

    await tap(find.text('Home').last);
    await tap(find.text('Goals'));
    await shot('goals');
    await back();

    await tester.scrollUntilVisible(
      find.text('AS'),
      -300,
      scrollable: find.byType(Scrollable).first,
    );
    await tap(find.text('AS'));
    await shot('settings');
    for (final (label, name) in [
      ('Categories', 'categories'),
      ('Tags', 'settings_tags'),
      ('Templates', 'templates'),
      ('Budgets', 'budgets'),
      ('Repeating entries', 'repeating'),
      ('Backup & restore', 'backup'),
      ('App lock', 'app_lock'),
    ]) {
      await scrollTo(find.text(label));
      await tap(find.text(label));
      await shot(name);
      await back();
    }
  }, skip: _lang == 'ne');
}
