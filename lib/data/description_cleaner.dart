/// Turns a bank's raw transaction description into a short, readable title
/// that starts with how the money moved, e.g.
/// `QR PAYMENT-2308…ue2W, MEGA MART NAGAUN` → `QR · Mega Mart Nagaun`.
/// Unknown descriptions only get their spacing tidied.
String cleanDescription(String raw) {
  final text = raw
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim()
      .replaceAll(RegExp(r'[\s,|]+$'), '');
  for (final rule in _rules) {
    final match = rule.pattern.firstMatch(text);
    if (match != null) {
      final title = rule.title(match).trim();
      if (title.isNotEmpty) return title;
    }
  }
  return text;
}

class _Rule {
  const _Rule(this.pattern, this.title);

  final RegExp pattern;
  final String Function(RegExpMatch match) title;
}

RegExp _re(String pattern) => RegExp(pattern, caseSensitive: false);

/// "Channel · part · part", leaving out empty parts.
String _join(String channel, List<String?> parts) {
  final kept = [
    for (final part in parts)
      if (part != null && _tidy(part).isNotEmpty) _tidy(part),
  ];
  return kept.isEmpty ? '' : [channel, ...kept].join(' · ');
}

/// Collapses spacing and drops stray separators and trailing terminal
/// numbers ("ALKA CANTEEN 2" → "Alka Canteen").
String _tidy(String value) => _nice(
  value
      .replaceAll(RegExp(r'\s+'), ' ')
      .replaceAll(RegExp(r'^[\s,/:|-]+|[\s,/:|-]+$'), '')
      .replaceAll(RegExp(r'\s+\d{1,3}$'), ''),
);

/// Capitalises SHOUTED words longer than three letters; short ones
/// (NTC, PVT., L.N.) are usually abbreviations and stay as they are.
String _nice(String value) => value
    .split(' ')
    .map((word) {
      final letters = word.replaceAll(RegExp(r'[^A-Za-z]'), '');
      if (letters.length <= 3 || letters != letters.toUpperCase()) {
        return word;
      }
      return word[0] + word.substring(1).toLowerCase();
    })
    .join(' ');

final _rules = <_Rule>[
  // NIC Asia QR: "QR PAYMENT-<id>, MERCHANT".
  _Rule(_re(r'^QR PAYMENT-\S*?,\s*(.*)$'), (m) => _join('QR', [m[1]])),
  _Rule(_re(r'^QR PAYMENT'), (_) => 'QR payment'),
  // Nabil Fonepay QR: "MPAYFPQR,<id>,MERCHANT,remark".
  _Rule(
    _re(r'^MPAY ?FPQR,?([^,]*),?([^,]*),?(.*)$'),
    (m) => _join('QR', [m[2], m[3]]).ifEmpty('QR payment'),
  ),
  _Rule(
    _re(r'^NQR-[^,]*,?(.*)$'),
    (m) => _join('QR', [m[1]]).ifEmpty('QR payment'),
  ),
  // Wallet loads and withdrawals.
  _Rule(_re(r'^(Load ?eSewa|eSewa Load)'), (_) => 'eSewa load'),
  _Rule(_re(r'^(Khalti Load|Load Wallet Khalti)'), (_) => 'Khalti load'),
  _Rule(_re(r'^ESWWD:'), (_) => 'eSewa withdrawal'),
  // connectIPS account transfers: "CIPS//ACCOUNTFT:Name/remark".
  _Rule(
    _re(r'^(?:c?IPS/+(?:CIPS-?)?)?ACCOUNTFT:([^/]*)/?(.*)$'),
    (m) => _join('IPS', [m[1], m[2]]).ifEmpty('IPS transfer'),
  ),
  _Rule(
    _re(r'^c?IPS/+CIPS-?(.*)$'),
    (m) => _join('IPS', [m[1]]).ifEmpty('IPS transfer'),
  ),
  // IPS credits: "IPS/NMB/12.5%CBBLDIV8182043547" is a CBBL dividend.
  _Rule(
    _re(r'^IPS/[A-Z]*/.*?(\d+(?:\.\d+)?%)\s*([A-Z]+?)\s*DIV'),
    (m) => 'IPS · ${m[1]} ${m[2]!.toUpperCase()} dividend',
  ),
  _Rule(_re(r'^IPS/([A-Z]*)/(.*)$'), (m) => _join('IPS', [m[1], m[2]])),
  // Fonepay interbank transfers: "FPY:IBFT:<id>:<n>:<bank>:<bank>:NAME".
  _Rule(
    _re(r'^(?:FPY|FON):IBFT:(?:[^:]*:){4}([^:]*)$'),
    (m) => _join('Fonepay', [m[1]]).ifEmpty('Fonepay transfer'),
  ),
  _Rule(_re(r'^(?:FPY|FON):IBFT'), (_) => 'Fonepay transfer'),
  // Mobile banking: "MoBank, remark ,TraceID-<id>", "MPAY NABIL,".
  _Rule(
    _re(r'^MoBank,\s*(.*?)\s*,?\s*TraceID'),
    (m) => _join('Mobile banking', [m[1]]).ifEmpty('Mobile banking'),
  ),
  _Rule(_re(r'^MPAY ?([A-Z0-9]+)'), (m) => _join('Mobile banking', [m[1]])),
  // Topups.
  _Rule(_re(r'^NT Prepaid Topup'), (_) => 'Topup · NT prepaid'),
  _Rule(_re(r'^Ncell Topup'), (_) => 'Topup · Ncell'),
  // Cash withdrawals.
  _Rule(_re(r'^(ATM WDL|CWDR/)'), (_) => 'ATM withdrawal'),
  // Remittances: "NPS/URP…#REMI…", "CEMT / <ref> / JPN".
  _Rule(_re(r'^NPS/.*REMI'), (_) => 'Remittance'),
  _Rule(
    _re(r'^CEMT\s*/\s*\d+\s*/\s*([A-Z]{3})$'),
    (m) => 'Remittance (${m[1]!.toUpperCase()})',
  ),
  // Share applications: "Fund transfer for CASBA : ECOLP" (a stock symbol,
  // so it stays in capitals).
  _Rule(
    _re(r'^Fund transfer for C?ASBA\s*:\s*(\S.*)$'),
    (m) => 'ASBA · ${m[1]!.trim().toUpperCase()}',
  ),
  // Standard Chartered: "<id> NAME| IBFTCHARGES|", "<id> NAME|<id>|IBFT|<n>".
  _Rule(_re(r'^\d+ [^|]*\|\s*IBFT ?CHARGES'), (_) => 'IBFT charges'),
  _Rule(_re(r'^\d+ ([^|]*)\|[^|]*\|\s*IBFT\b'), (m) => _join('IBFT', [m[1]])),
];

extension on String {
  String ifEmpty(String fallback) => isEmpty ? fallback : this;
}
