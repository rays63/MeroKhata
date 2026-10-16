import 'package:flutter/material.dart';

/// Paisa Flow design tokens. Values mirror the `TH` table in
/// "Paisa Flow App.dc.html" (Claude Design), light and dark.
@immutable
class PfColors extends ThemeExtension<PfColors> {
  const PfColors({
    required this.bg,
    required this.card,
    required this.card2,
    required this.ink,
    required this.sub,
    required this.mute,
    required this.line,
    required this.pri,
    required this.btn,
    required this.onBtn,
    required this.soft,
    required this.cashIn,
    required this.cashOut,
    required this.outSoft,
    required this.hero,
    required this.hero2,
    required this.tab,
    required this.gold,
    required this.goldSoft,
    required this.blue,
    required this.blueSoft,
    required this.scrim,
  });

  final Color bg;
  final Color card;
  final Color card2;
  final Color ink;
  final Color sub;
  final Color mute;
  final Color line;

  /// Accent for icons, active tabs, selected states.
  final Color pri;

  /// Primary button fill.
  final Color btn;
  final Color onBtn;

  /// Tinted background for cash-in / selected chips.
  final Color soft;
  final Color cashIn;
  final Color cashOut;
  final Color outSoft;
  final Color hero;
  final Color hero2;
  final Color tab;
  final Color gold;
  final Color goldSoft;
  final Color blue;
  final Color blueSoft;
  final Color scrim;

  /// Toast background (same in both themes).
  static const toast = Color(0xFF122435);

  /// Avatar button on Home (same in both themes).
  static const avatar = Color(0xFF122435);

  /// Label tints on the green hero cards.
  static const heroLabel = Color(0xFFD6F5E3);
  static const heroInLabel = Color(0xFFB9EBCF);
  static const heroOutLabel = Color(0xFFFFC9C9);
  static const toastIcon = Color(0xFF5BE39A);

  static const light = PfColors(
    bg: Color(0xFFF3F6F4),
    card: Color(0xFFFFFFFF),
    card2: Color(0xFFEBF0ED),
    ink: Color(0xFF101418),
    sub: Color(0xFF5B6870),
    mute: Color(0xFF9AA5AB),
    line: Color(0xFFE3E9E6),
    pri: Color(0xFF10A65A),
    btn: Color(0xFF0F7A4A),
    onBtn: Color(0xFFFFFFFF),
    soft: Color(0xFFE2F4E9),
    cashIn: Color(0xFF0E8A4F),
    cashOut: Color(0xFFD33A3F),
    outSoft: Color(0xFFFCE9E9),
    hero: Color(0xFF0F7A4A),
    hero2: Color(0xFF13955C),
    tab: Color(0xFFFFFFFF),
    gold: Color(0xFFB87412),
    goldSoft: Color(0xFFFBF0DE),
    blue: Color(0xFF2F6FC9),
    blueSoft: Color(0xFFE4EEFA),
    scrim: Color(0x73101418),
  );

  static const dark = PfColors(
    bg: Color(0xFF0E1117),
    card: Color(0xFF161D27),
    card2: Color(0xFF1D2636),
    ink: Color(0xFFE6EBF1),
    sub: Color(0xFF93A3B6),
    mute: Color(0xFF5F6E80),
    line: Color(0xFF252F40),
    pri: Color(0xFF2ECC71),
    btn: Color(0xFF2ECC71),
    onBtn: Color(0xFF07170E),
    soft: Color(0xFF14301F),
    cashIn: Color(0xFF3FD883),
    cashOut: Color(0xFFFF7B7B),
    outSoft: Color(0xFF3A1D22),
    hero: Color(0xFF0F5C3A),
    hero2: Color(0xFF137247),
    tab: Color(0xFF121821),
    gold: Color(0xFFF0B04B),
    goldSoft: Color(0xFF3A2E19),
    blue: Color(0xFF7AB0F5),
    blueSoft: Color(0xFF1B2A40),
    scrim: Color(0x99000000),
  );

  Color amount(bool isIn) => isIn ? cashIn : cashOut;
  Color amountSoft(bool isIn) => isIn ? soft : outSoft;

  @override
  PfColors copyWith() => this;

  @override
  PfColors lerp(ThemeExtension<PfColors>? other, double t) {
    if (other is! PfColors) return this;
    Color l(Color a, Color b) => Color.lerp(a, b, t)!;
    return PfColors(
      bg: l(bg, other.bg),
      card: l(card, other.card),
      card2: l(card2, other.card2),
      ink: l(ink, other.ink),
      sub: l(sub, other.sub),
      mute: l(mute, other.mute),
      line: l(line, other.line),
      pri: l(pri, other.pri),
      btn: l(btn, other.btn),
      onBtn: l(onBtn, other.onBtn),
      soft: l(soft, other.soft),
      cashIn: l(cashIn, other.cashIn),
      cashOut: l(cashOut, other.cashOut),
      outSoft: l(outSoft, other.outSoft),
      hero: l(hero, other.hero),
      hero2: l(hero2, other.hero2),
      tab: l(tab, other.tab),
      gold: l(gold, other.gold),
      goldSoft: l(goldSoft, other.goldSoft),
      blue: l(blue, other.blue),
      blueSoft: l(blueSoft, other.blueSoft),
      scrim: l(scrim, other.scrim),
    );
  }
}

/// Categorical colors for charts and breakdowns.
const chartColors = [
  Color(0xFF10A65A),
  Color(0xFF3B7DD8),
  Color(0xFFE39A2E),
  Color(0xFF8B5CF6),
  Color(0xFFE5484D),
  Color(0xFF0E9AA7),
  Color(0xFF9AA5AB),
];

extension PfContext on BuildContext {
  PfColors get pf => Theme.of(this).extension<PfColors>()!;
}
