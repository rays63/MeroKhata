import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../core/format.dart';
import '../data/app_store.dart';
import 'category_icons.dart';
import 'option_sheet.dart';

/// Category picker with "Edit list"; renames apply to existing entries.
///
/// Returns the picked value, or — when the sheet is dismissed after the
/// current value was renamed in "Edit list" — its new name, so callers never
/// keep (and later save) the old one.
Future<String?> pickCategory(
  BuildContext context, {
  String? selected,
  bool manageOnly = false,
}) {
  final store = AppScope.read(context);
  return _pickEditable(
    context,
    title: 'Category',
    selected: selected,
    manageOnly: manageOnly,
    items: () => store.categories,
    icon: categoryIcon,
    rename: store.renameCategory,
    add: store.addCategory,
  );
}

Future<String?> pickPaymentMode(
  BuildContext context, {
  String? selected,
  bool manageOnly = false,
}) {
  final store = AppScope.read(context);
  return _pickEditable(
    context,
    title: 'Payment mode',
    selected: selected,
    manageOnly: manageOnly,
    items: () => store.paymentModes,
    icon: (_) => LucideIcons.wallet,
    rename: store.renamePaymentMode,
    add: store.addPaymentMode,
  );
}

Future<String?> _pickEditable(
  BuildContext context, {
  required String title,
  required String? selected,
  required bool manageOnly,
  required List<String> Function() items,
  required IconData Function(String) icon,
  required Future<void> Function(String, String) rename,
  required Future<void> Function(String) add,
}) async {
  var current = selected;
  final picked = await showOptionSheet<String>(
    context,
    title: title,
    selected: selected,
    startInManage: manageOnly,
    options: () => [
      for (final item in items()) SheetOption(item, item, icon(item)),
    ],
    editable: EditableList(
      items: items,
      onRename: (from, to) async {
        await rename(from, to);
        if (from == current) current = to.trim();
      },
      onAdd: add,
    ),
  );
  return picked ?? (current == selected ? null : current);
}

Future<String?> pickCurrency(
  BuildContext context, {
  required String selected,
  String title = 'Book currency',
}) {
  return showOptionSheet<String>(
    context,
    title: title,
    selected: selected,
    options: () => [
      for (final currency in Currency.all)
        SheetOption(currency.code, currency.label, LucideIcons.coins),
    ],
  );
}

/// Book picker; [onlyCurrency] limits it to books in that currency.
Future<String?> pickBook(
  BuildContext context, {
  required String selected,
  String? onlyCurrency,
}) {
  final store = AppScope.read(context);
  return showOptionSheet<String>(
    context,
    title: 'Book',
    selected: selected,
    options: () => [
      for (final book in store.booksByRecent)
        if (onlyCurrency == null || book.currency == onlyCurrency)
          SheetOption(
            book.id,
            '${book.name} · ${book.currency}',
            LucideIcons.bookOpen,
          ),
    ],
  );
}
