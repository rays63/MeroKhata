import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:paisa_flow/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Seeds the sample data used in the Claude Design file and visits each
/// screen, printing `SHOT:<name>` so a host script can screenshot the
/// simulator. Run with `--dart-define=THEME=dark` for the dark variants.
const _theme = String.fromEnvironment('THEME', defaultValue: 'light');

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
  };
  Map<String, Object?> book(
    String id,
    String name,
    String cur,
    int color,
    int days,
  ) => {
    'id': id,
    'name': name,
    'description': '',
    'createdAt': at(30, 9),
    'updatedAt': at(days, 9),
    'currency': cur,
    'color': color,
  };
  return {
    'books': [
      book('personal', 'Personal', 'NPR', 0xFF10A65A, 0),
      book('shop', 'Kirana Pasal', 'NPR', 0xFF3B7DD8, 1),
      book('freelance', 'Freelance', 'USD', 0xFF8B5CF6, 3),
      book('trip', 'Japan Trip', 'JPY', 0xFFE39A2E, 8),
    ],
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
    'onboarded': true,
  };
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

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

    Future<void> tap(Finder finder) async {
      await tester.tap(finder);
      await tester.pumpAndSettle();
    }

    Future<void> back() async {
      await tester.pageBack();
      await tester.pumpAndSettle();
    }

    await tester.pumpWidget(const PaisaFlowBootstrap());
    await tester.pumpAndSettle();
    await shot('home');

    await tap(find.text('Books').last);
    await tap(find.byTooltip('Book actions').at(1));
    await shot('books_menu');

    await tap(find.text('Personal').first);
    await shot('detail');

    await tap(find.text('Category'));
    await shot('filter_category');
    await tap(find.text('All categories'));

    await tap(find.text('Bhatbhateni groceries'));
    await shot('entry_detail');
    await back();

    await tap(find.text('Cash out').last);
    await shot('add_out');
    await tap(find.text('Groceries'));
    await shot('category_sheet');
    await tap(find.text('Edit list'));
    await shot('category_manage');
    await tester.tapAt(const Offset(200, 60));
    await tester.pumpAndSettle();
    await tap(find.text('Cash in').first);
    await shot('add_in');
    await tap(find.byTooltip('Close'));

    await tap(find.byTooltip('Import statement'));
    await shot('import_pick');
    await back();
    await back();

    await tap(find.text('Home').last);
    await tap(find.text('Goals'));
    await shot('goals');
    await tap(find.text('New goal'));
    await shot('goal_new');
    await tap(find.byTooltip('Close'));
    await back();

    await tap(find.byTooltip('Calendar'));
    await shot('calendar');
    await back();

    await tap(find.text('AS'));
    await shot('settings');
  });
}
