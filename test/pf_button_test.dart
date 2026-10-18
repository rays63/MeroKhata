import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:paisa_flow/theme/app_theme.dart';
import 'package:paisa_flow/widgets/pf.dart';

Widget _app(Widget bottom, {double textScale = 1}) => MaterialApp(
  theme: AppTheme.lightFor('en'),
  home: MediaQuery(
    data: MediaQueryData(
      size: const Size(400, 800),
      textScaler: TextScaler.linear(textScale),
    ),
    child: Scaffold(body: const SizedBox(), bottomNavigationBar: bottom),
  ),
);

void main() {
  testWidgets('a button in a bottom bar keeps its own height', (tester) async {
    await tester.pumpWidget(
      _app(PfButton(label: 'Import 26 entries', onPressed: () {})),
    );
    expect(tester.getSize(find.byType(PfButton)).height, 58);
  });

  testWidgets('large text grows the button instead of clipping', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(
        PfButton(label: 'नयाँ समूह', onPressed: () {}, height: 52),
        textScale: 3,
      ),
    );
    expect(tester.takeException(), isNull);
    expect(tester.getSize(find.byType(PfButton)).height, greaterThan(52));
    expect(tester.getSize(find.byType(PfButton)).height, lessThan(200));
  });
}
