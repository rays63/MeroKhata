import 'package:flutter/services.dart';

/// The largest amount the app accepts: 99,99,99,99,999.99. Big enough for
/// any personal or shop ledger, and far below where totals lose precision
/// or overflow when formatted.
const maxAmount = 99999999999.99;

/// Digits before the decimal point allowed by [maxAmount].
const maxAmountDigits = 11;

/// Keeps an amount field to a valid number while typing: digits, one ".",
/// at most 2 decimals and [maxAmountDigits] digits before the point.
/// Commas (from pasting "1,250") are dropped. An edit that would break these
/// rules is ignored, so "1.1.1" can't be typed.
class AmountInputFormatter extends TextInputFormatter {
  const AmountInputFormatter({this.decimals = true});

  /// False for whole numbers only (e.g. a budget or a goal target).
  final bool decimals;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll(',', '');
    final pattern = decimals
        ? RegExp('^\\d{0,$maxAmountDigits}(\\.\\d{0,2})?\$')
        : RegExp('^\\d{0,$maxAmountDigits}\$');
    if (!pattern.hasMatch(text)) return oldValue;
    if (text == newValue.text) return newValue;
    final removed = newValue.text.length - text.length;
    final offset = (newValue.selection.baseOffset - removed).clamp(
      0,
      text.length,
    );
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: offset),
    );
  }
}

/// Why an amount can't be saved.
enum AmountProblem { empty, invalid, zero, tooLarge }

/// Reads a typed amount: the value, or what's wrong with it.
({double? value, AmountProblem? problem}) readAmount(
  String text, {
  bool allowZero = false,
}) {
  final clean = text.replaceAll(',', '').trim();
  if (clean.isEmpty) return (value: null, problem: AmountProblem.empty);
  if (!RegExp(r'^\d+(\.\d{1,2})?$').hasMatch(clean)) {
    return (value: null, problem: AmountProblem.invalid);
  }
  final value = double.parse(clean);
  if (value > maxAmount) return (value: null, problem: AmountProblem.tooLarge);
  if (value <= 0 && !allowZero) {
    return (value: null, problem: AmountProblem.zero);
  }
  return (value: value, problem: null);
}
