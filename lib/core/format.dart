import 'package:intl/intl.dart';

/// Currencies a book can be kept in. Order is the order shown in pickers.
class Currency {
  const Currency(
    this.code,
    this.symbol,
    this.name, {
    this.indianGrouping = false,
    this.cents = false,
  });

  final String code;
  final String symbol;
  final String name;

  /// Lakh/crore grouping (1,54,720) instead of thousands (154,720).
  final bool indianGrouping;

  /// Always show two decimals (dollars, euros…). Rupee and yen amounts only
  /// show them when there is a fractional part.
  final bool cents;

  String get label => '$symbol  $code · $name';

  static const npr = Currency(
    'NPR',
    'Rs',
    'Nepalese Rupee',
    indianGrouping: true,
  );

  static const all = [
    npr,
    Currency('INR', '₹', 'Indian Rupee', indianGrouping: true),
    Currency('USD', r'$', 'US Dollar', cents: true),
    Currency('EUR', '€', 'Euro', cents: true),
    Currency('GBP', '£', 'British Pound', cents: true),
    Currency('AUD', r'A$', 'Australian Dollar', cents: true),
    Currency('JPY', '¥', 'Japanese Yen'),
  ];

  static Currency of(String code) =>
      all.firstWhere((currency) => currency.code == code, orElse: () => npr);
}

final _formats = {
  for (final indian in [true, false])
    for (final whole in [true, false])
      (indian, whole): NumberFormat(
        '${indian ? '#,##,##0' : '#,##0'}${whole ? '' : '.00'}',
        'en_US',
      ),
};

/// Formats an absolute amount with the currency symbol, e.g. `Rs 1,54,720`.
///
/// Whole rupee/yen amounts drop the decimals; amounts with paisa keep two
/// places so imported statements still reconcile to the last paisa.
String money(num value, [String currency = 'NPR']) {
  final info = Currency.of(currency);
  final amount = (value.abs() * 100).round() / 100;
  final whole = !info.cents && amount == amount.roundToDouble();
  return '${info.symbol} ${_formats[(info.indianGrouping, whole)]!.format(amount)}';
}

/// `+ Rs 85,000` / `− Rs 3,460`. Uses a true minus sign as in the design.
String signedMoney(num value, [String currency = 'NPR']) =>
    '${value < 0 ? '−' : '+'} ${money(value, currency)}';

/// Balance style: no sign when positive, `− Rs 500` when negative.
String balanceMoney(num value, [String currency = 'NPR']) =>
    value < 0 ? '− ${money(value, currency)}' : money(value, currency);

String timeLabel(DateTime date) => DateFormat('h:mm a').format(date);

String initials(String name) {
  final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
  if (parts.isEmpty) return 'PF';
  return parts.take(2).map((p) => p[0].toUpperCase()).join();
}

bool sameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;
