import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:paisa_flow/main.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Folder holding the real statements, passed with
/// `--dart-define=STATEMENTS_DIR=...`. The simulator can read host paths.
const _statementsDir = String.fromEnvironment('STATEMENTS_DIR');

/// Stands in for the native document picker, which the test cannot tap.
class _QueuedFilePicker extends FilePicker with MockPlatformInterfaceMixin {
  final queue = <String>[];

  @override
  Future<FilePickerResult?> pickFiles({
    String? dialogTitle,
    String? initialDirectory,
    FileType type = FileType.any,
    List<String>? allowedExtensions,
    Function(FilePickerStatus)? onFileLoading,
    bool allowCompression = false,
    int compressionQuality = 0,
    bool allowMultiple = false,
    bool withData = false,
    bool withReadStream = false,
    bool lockParentWindow = false,
    bool readSequential = false,
  }) async {
    final file = File('$_statementsDir/${queue.removeAt(0)}');
    final bytes = await file.readAsBytes();
    return FilePickerResult([
      PlatformFile(
        name: file.uri.pathSegments.last,
        path: file.path,
        size: bytes.length,
        bytes: bytes,
      ),
    ]);
  }
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('import statements through the UI and catch duplicates', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final picker = _QueuedFilePicker();
    FilePicker.platform = picker;

    Future<void> shot(String name) async {
      await tester.pumpAndSettle();
      // ignore: avoid_print
      print('SHOT:$name');
      await tester.runAsync(() => Future.delayed(const Duration(seconds: 3)));
    }

    Future<void> pick(String button, String file) async {
      picker.queue.add(file);
      await tester.tap(find.text(button));
      // Parsing runs off the frame clock; let it finish in real time.
      for (
        var i = 0;
        i < 40 && find.text('Review import').evaluate().isEmpty;
        i++
      ) {
        await tester.runAsync(
          () => Future.delayed(const Duration(milliseconds: 250)),
        );
        await tester.pump();
      }
      await tester.pumpAndSettle();
    }

    Future<void> openImport() async {
      await tester.tap(find.byTooltip('Import statement'));
      await tester.pumpAndSettle();
    }

    Future<void> commit(int count) async {
      await tester.tap(find.text('Import $count entries'));
      await tester.pumpAndSettle();
    }

    void expectCounts(int ready, int duplicates) {
      expect(
        find.descendant(
          of: find
              .ancestor(
                of: find.text('Ready to import'),
                matching: find.byType(Column),
              )
              .first,
          matching: find.text('$ready'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find
              .ancestor(
                of: find.text('Duplicates skipped'),
                matching: find.byType(Column),
              )
              .first,
          matching: find.text('$duplicates'),
        ),
        findsOneWidget,
      );
    }

    await tester.pumpWidget(const PaisaFlowBootstrap());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Books').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Personal').first);
    await tester.pumpAndSettle();

    // 1. NIC December statement into an empty book.
    await openImport();
    await pick('Choose PDF →', 'Nic/DEC 2025.pdf');
    expectCounts(48, 0);
    await shot('1_dec_preview');
    await commit(48);
    await shot('2_book_after_dec');

    // 2. NIC January statement overlaps all of December.
    await openImport();
    await pick('Choose PDF →', 'Nic/Jan26.pdf');
    expectCounts(79, 48);
    await shot('3_jan_preview_overlap');
    await commit(79);

    // 3. Same January statement again: nothing new.
    await openImport();
    await pick('Choose PDF →', 'Nic/Jan26.pdf');
    expectCounts(0, 127);
    expect(find.text('Already up to date'), findsOneWidget);
    await shot('4_jan_reimport_all_duplicates');
    await tester.tap(find.text('Back to book'));
    await tester.pumpAndSettle();

    // 4. eSewa legacy .xls.
    await openImport();
    await pick('Choose XLS →', 'eSewa_statement_2026-02-24_2026-03-26.xls');
    expectCounts(54, 0);
    await shot('5_esewa_preview');
    await commit(54);

    // 5. eSewa again: all duplicates.
    await openImport();
    await pick('Choose XLS →', 'eSewa_statement_2026-02-24_2026-03-26.xls');
    expectCounts(0, 54);
    await shot('6_esewa_reimport');
    await tester.tap(find.text('Back to book'));
    await tester.pumpAndSettle();
    await shot('7_book_final');
  });
}
