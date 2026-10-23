import 'package:flutter/widgets.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

const _categoryIcons = <String, IconData>{
  'Salary': LucideIcons.briefcase,
  'Freelance': LucideIcons.laptop,
  'Gift': LucideIcons.gift,
  'Groceries': LucideIcons.shoppingBasket,
  'Food': LucideIcons.utensils,
  'Rent': LucideIcons.house,
  'Utilities': LucideIcons.zap,
  'Transport': LucideIcons.bike,
  'Shopping': LucideIcons.shoppingBag,
  'Health': LucideIcons.heartPulse,
  'Cellular topup': LucideIcons.smartphone,
  'Cafe': LucideIcons.coffee,
  'Bank fees': LucideIcons.receiptText,
  'Transfer': LucideIcons.arrowLeftRight,
  'Opening balance': LucideIcons.wallet,
  'Sales': LucideIcons.store,
  'Stock': LucideIcons.package,
  'Travel': LucideIcons.plane,
  'Settlement': LucideIcons.handshake,
  'Imported': LucideIcons.fileDown,
};

IconData categoryIcon(String category) =>
    _categoryIcons[category] ?? LucideIcons.tag;

/// Icon for an entry row; unknown categories get a neutral dot.
IconData entryIcon(String category) =>
    _categoryIcons[category] ?? LucideIcons.circleDot;
