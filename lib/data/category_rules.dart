import 'models.dart';

/// Suggests a category for an imported row from words in its description.
/// To add a rule, add a line to [categoryRules]; the first match wins.
class CategoryRule {
  const CategoryRule(this.category, this.keywords, {this.type});

  final String category;

  /// Whole words, matched case-insensitively. "topup" also matches
  /// "top up" and "top-up".
  final List<String> keywords;

  /// Only rows of this type match; null for both.
  final TransactionType? type;
}

const categoryRules = [
  CategoryRule('Salary', ['salary'], type: TransactionType.cashIn),
  CategoryRule('Utilities', [
    'NEA',
    'Khanepani',
  ], type: TransactionType.cashOut),
  CategoryRule('Cellular topup', [
    'NTC',
    'Ncell',
    'topup',
  ], type: TransactionType.cashOut),
  CategoryRule('Shopping', ['Daraz'], type: TransactionType.cashOut),
  CategoryRule('Cafe', ['cafe'], type: TransactionType.cashOut),
  CategoryRule('Food', ['momo', 'restaurant'], type: TransactionType.cashOut),
];

/// The category of the first rule matching [text], or null.
String? suggestCategory(
  String text,
  TransactionType type, {
  List<CategoryRule> rules = categoryRules,
}) {
  final words = text
      .toLowerCase()
      .split(RegExp(r'[^a-z0-9]+'))
      .where((word) => word.isNotEmpty)
      .toList();
  // Two neighbouring words written together ("top up" → "topup").
  final joined = {
    for (var i = 0; i + 1 < words.length; i++) words[i] + words[i + 1],
  };
  final present = {...words, ...joined};
  for (final rule in rules) {
    if (rule.type != null && rule.type != type) continue;
    for (final keyword in rule.keywords) {
      if (present.contains(keyword.toLowerCase().replaceAll(' ', ''))) {
        return rule.category;
      }
    }
  }
  return null;
}
