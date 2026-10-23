import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../core/format.dart';
import '../data/app_store.dart';
import 'category_icons.dart';
import 'account_type.dart';
import 'option_sheet.dart';
import '../l10n/l10n.dart';

/// Category picker with "Edit list"; renames apply to existing entries.
///
/// Returns the picked value, or — when the sheet is dismissed after the
/// current value was renamed in "Edit list" — its new name, so callers never
/// keep (and later save) the old one.
Future<String?> pickCategory(
  BuildContext context, {
  String? selected,
  bool manageOnly = false,
  bool markSubcategories = false,
}) {
  final store = AppScope.read(context);
  return _pickEditable(
    hasMore: markSubcategories
        ? (c) => store.subcategoriesOf(c).isNotEmpty
        : null,
    context,
    title: context.l10n.category,
    selected: selected,
    manageOnly: manageOnly,
    items: () => store.categories,
    icon: categoryIcon,
    rename: store.renameCategory,
    add: store.addCategory,
    remove: store.removeCategory,
  );
}

/// Category, then (for one with subcategories) "Just Food" or a
/// subcategory. Returns (category, subcategory or ''), or null if dismissed.
Future<(String, String)?> pickCategoryAndSub(
  BuildContext context, {
  String? category,
  String subcategory = '',
}) async {
  final store = AppScope.read(context);
  final l = context.l10n;
  final picked = await pickCategory(
    context,
    selected: category,
    markSubcategories: true,
  );
  if (picked == null || !context.mounted) return null;
  if (store.subcategoriesOf(picked).isEmpty) return (picked, '');
  const just = '\u0000just';
  final sub = await showOptionSheet<String>(
    context,
    title: picked,
    selected: picked == category
        ? (subcategory.isEmpty ? just : subcategory)
        : null,
    options: () => [
      SheetOption(just, l.subJust(picked), categoryIcon(picked)),
      for (final s in store.subcategoriesOf(picked))
        SheetOption(s, s, LucideIcons.cornerDownRight),
    ],
    editable: EditableList(
      items: () => store.subcategoriesOf(picked),
      onRename: (from, to) => store.renameSubcategory(picked, from, to),
      onAdd: (name) => store.addSubcategory(picked, name),
      onRemove: (name) => store.deleteSubcategory(picked, name),
    ),
  );
  if (sub == null) return null;
  return (picked, sub == just ? '' : sub);
}

Future<String?> pickPaymentMode(
  BuildContext context, {
  String? selected,
  bool manageOnly = false,
}) {
  final store = AppScope.read(context);
  return _pickEditable(
    context,
    title: context.l10n.paymentMode,
    selected: selected,
    manageOnly: manageOnly,
    items: () => store.paymentModes,
    icon: (_) => LucideIcons.wallet,
    rename: store.renamePaymentMode,
    add: store.addPaymentMode,
    remove: store.removePaymentMode,
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
  required Future<void> Function(String) remove,
  bool Function(String)? hasMore,
}) async {
  var current = selected;
  final picked = await showOptionSheet<String>(
    context,
    title: title,
    selected: selected,
    startInManage: manageOnly,
    options: () => [
      for (final item in items())
        SheetOption(item, item, icon(item), more: hasMore?.call(item) ?? false),
    ],
    editable: EditableList(
      items: items,
      onRename: (from, to) async {
        await rename(from, to);
        if (from == current) current = to.trim();
      },
      onAdd: add,
      onRemove: remove,
    ),
  );
  return picked ?? (current == selected ? null : current);
}

Future<String?> pickCurrency(
  BuildContext context, {
  required String selected,
  String? title,
}) {
  return showOptionSheet<String>(
    context,
    title: title ?? context.l10n.bookCurrency,
    selected: selected,
    options: () => [
      for (final currency in Currency.all)
        SheetOption(currency.code, currency.label, LucideIcons.coins),
    ],
  );
}

/// Account picker; [onlyCurrency] limits it to books in that currency.
Future<String?> pickBook(
  BuildContext context, {
  required String selected,
  String? onlyCurrency,
}) {
  final store = AppScope.read(context);
  return showOptionSheet<String>(
    context,
    title: context.l10n.book,
    selected: selected,
    options: () => [
      for (final book in store.booksByRecent)
        if (onlyCurrency == null || book.currency == onlyCurrency)
          SheetOption(
            book.id,
            '${book.name} · ${book.currency}',
            accountTypeIcon(book.accountType),
          ),
    ],
  );
}
