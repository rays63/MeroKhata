import 'package:flutter/material.dart';

import 'tokens.dart';

/// Material theme wired to the Paisa Flow tokens. Built once (static final)
/// so AnimatedTheme never lerps between freshly built text styles.
class AppTheme {
  const AppTheme._();

  static final ThemeData light = _build(PfColors.light, Brightness.light);
  static final ThemeData dark = _build(PfColors.dark, Brightness.dark);

  /// नेपाली UI: Mukta for everything (it covers Latin too), as in the design.
  static final ThemeData lightNe = _build(
    PfColors.light,
    Brightness.light,
    nepali: true,
  );
  static final ThemeData darkNe = _build(
    PfColors.dark,
    Brightness.dark,
    nepali: true,
  );

  static ThemeData lightFor(String language) =>
      language == 'ne' ? lightNe : light;
  static ThemeData darkFor(String language) => language == 'ne' ? darkNe : dark;

  static ThemeData _build(
    PfColors c,
    Brightness brightness, {
    bool nepali = false,
  }) {
    final base = ThemeData(
      useMaterial3: true,
      // Bundled in pubspec as one family with weights 400–900, so any
      // fontWeight on a TextStyle picks the matching file.
      fontFamily: nepali ? 'Mukta' : 'Nunito',
      // Nunito has no Devanagari glyphs; नेपाली text falls back to Mukta.
      fontFamilyFallback: nepali ? const ['Nunito'] : const ['Mukta'],
      brightness: brightness,
      colorScheme: ColorScheme.fromSeed(
        seedColor: c.btn,
        brightness: brightness,
        primary: c.btn,
        onPrimary: c.onBtn,
        surface: c.card,
        onSurface: c.ink,
        error: c.cashOut,
      ),
    );
    final text = base.textTheme.apply(
      bodyColor: c.ink,
      displayColor: c.ink,
    );
    return base.copyWith(
      extensions: [c],
      scaffoldBackgroundColor: c.bg,
      canvasColor: c.bg,
      dividerColor: c.line,
      textTheme: text,
      primaryTextTheme: text,
      splashFactory: InkSparkle.splashFactory,
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: c.pri,
        selectionColor: c.pri.withValues(alpha: .25),
        selectionHandleColor: c.pri,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: c.bg,
        surfaceTintColor: Colors.transparent,
        foregroundColor: c.ink,
        elevation: 0,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: c.card,
        surfaceTintColor: Colors.transparent,
        modalBarrierColor: c.scrim,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: c.card,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        border: InputBorder.none,
        isDense: true,
        contentPadding: EdgeInsets.zero,
      ),
      datePickerTheme: DatePickerThemeData(
        backgroundColor: c.card,
        surfaceTintColor: Colors.transparent,
      ),
      timePickerTheme: TimePickerThemeData(
        backgroundColor: c.card,
      ),
    );
  }
}
