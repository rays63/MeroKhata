import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:paisa_flow/features/split/split_widgets.dart';
import 'package:paisa_flow/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('adding a friend closes the dialog cleanly', (tester) async {
    SharedPreferences.setMockInitialValues({
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
    await tester.pumpAndSettle(const Duration(seconds: 3));
    final context = tester.element(find.byType(IndexedStack));
    final store = AppScope.read(context);

    final added = addFriendDialog(context);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Sita');
    await tester.tap(find.text('Add'));
    // Runs the closing animation, which used to rebuild the field after its
    // controller had been disposed.
    await tester.pumpAndSettle();

    final id = await added;
    expect(tester.takeException(), isNull);
    expect(find.byType(AlertDialog), findsNothing);
    expect(store.friends.single.id, id);
    expect(store.friends.single.name, 'Sita');
  });
}
