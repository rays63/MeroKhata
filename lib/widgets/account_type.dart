import 'package:flutter/widgets.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../data/models.dart';
import '../l10n/app_localizations.dart';

IconData accountTypeIcon(AccountType type) => switch (type) {
  AccountType.cash => LucideIcons.banknote,
  AccountType.bank => LucideIcons.landmark,
  AccountType.wallet => LucideIcons.smartphone,
  AccountType.card => LucideIcons.creditCard,
  AccountType.loan => LucideIcons.handCoins,
  AccountType.savings => LucideIcons.piggyBank,
  AccountType.other => LucideIcons.folder,
};

String accountTypeLabel(AppLocalizations l, AccountType type) => switch (type) {
  AccountType.cash => l.accountTypeCash,
  AccountType.bank => l.accountTypeBank,
  AccountType.wallet => l.accountTypeWallet,
  AccountType.card => l.accountTypeCard,
  AccountType.loan => l.accountTypeLoan,
  AccountType.savings => l.accountTypeSavings,
  AccountType.other => l.accountTypeOther,
};
