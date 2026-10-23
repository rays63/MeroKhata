import 'models.dart';

/// The user's account an imported statement row probably moved money to (or,
/// for cash in, from): loading eSewa, an ATM withdrawal, paying the card.
/// Null when nothing fits; the user decides whether to make it a transfer.
String? transferCounterpart(
  LedgerTransaction row,
  List<LedgerBook> books, {
  required String currency,
}) {
  final text = '${row.title} ${row.notes}'.toLowerCase();
  final out = row.type == TransactionType.cashOut;
  final candidates = books
      .where((book) => book.id != row.bookId && book.currency == currency)
      .toList();

  String? named(String name) {
    for (final book in candidates) {
      if (book.accountType == AccountType.wallet &&
          book.name.toLowerCase().contains(name)) {
        return book.id;
      }
    }
    return null;
  }

  String? ofType(AccountType type) {
    final matches = candidates.where((book) => book.accountType == type);
    // Only when it is unambiguous which account was meant.
    return matches.length == 1 ? matches.single.id : null;
  }

  if (out && RegExp(r'\b(load ?esewa|esewa load)').hasMatch(text)) {
    return named('esewa');
  }
  if (out && RegExp(r'\b(khalti load|load wallet khalti)').hasMatch(text)) {
    return named('khalti');
  }
  if (!out && text.contains('esewa withdrawal')) return named('esewa');
  if (out && RegExp(r'\b(atm withdrawal|atm wdl|cwdr/)').hasMatch(text)) {
    return ofType(AccountType.cash);
  }
  if (out &&
      RegExp(
        r'\b(card (pmt|payment)|credit ?card (pmt|payment|bill)|cc (pmt|payment))',
      ).hasMatch(text)) {
    return ofType(AccountType.card);
  }
  return null;
}
