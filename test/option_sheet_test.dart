import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:paisa_flow/l10n/app_localizations.dart';
import 'package:paisa_flow/theme/app_theme.dart';
import 'package:paisa_flow/widgets/option_sheet.dart';

Future<List<String>> _openEditList(
  WidgetTester tester,
  List<String> items,
) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.lightFor('en'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: Scaffold(
        body: Builder(
          builder: (context) => TextButton(
            onPressed: () => showOptionSheet<String>(
              context,
              title: 'Category',
              selected: null,
              startInManage: true,
              options: () => [
                for (final item in items)
                  SheetOption(item, item, Icons.label_outline),
              ],
              editable: EditableList(
                items: () => items,
                onRename: (from, to) async {},
                onAdd: (value) async => items.add(value),
                onRemove: (value) async => items.remove(value),
              ),
            ),
            child: const Text('open'),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
  return items;
}

void main() {
  testWidgets('Edit list deletes an option', (tester) async {
    final items = await _openEditList(tester, ['Food', 'Bills', 'Chiya']);

    await tester.tap(find.byTooltip('Delete Chiya'));
    await tester.pumpAndSettle();

    expect(items, ['Food', 'Bills']);
    expect(find.byTooltip('Delete Chiya'), findsNothing);
    expect(find.textContaining('“Chiya” removed'), findsOneWidget);
  });

  testWidgets('the last option cannot be deleted', (tester) async {
    await _openEditList(tester, ['Food']);

    expect(find.byTooltip('Delete Food'), findsNothing);
  });
}
