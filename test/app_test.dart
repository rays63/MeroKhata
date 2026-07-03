import 'package:cashbook_pro/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('shows CashBook Pro app name', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const HissabKitabBootstrap());
    await tester.pumpAndSettle();

    expect(find.text('CashBook Pro'), findsWidgets);
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
