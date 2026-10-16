import 'package:paisa_flow/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('shows Paisa Flow app name', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const PaisaFlowBootstrap());
    await tester.pumpAndSettle();

    expect(find.text('Paisa Flow'), findsWidgets);
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
