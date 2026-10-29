import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../app/nav.dart';
import '../../core/format.dart';
import '../../data/app_store.dart';
import '../../data/models.dart';
import '../../l10n/l10n.dart';
import '../../theme/tokens.dart';
import '../../widgets/account_type.dart';
import '../../widgets/category_icons.dart';
import '../../widgets/option_sheet.dart';
import '../../widgets/pf.dart';
import 'budget_bar.dart';
import 'budget_edit_screen.dart';

/// The words for a budget scope: "All NPR accounts" or the account name.
String scopeLabel(AppLocalizations l, AppStore store, String scope) =>
    scope.startsWith('account:')
    ? store.bookById(scope.substring('account:'.length))?.name ??
          l.transferDeletedAccount
    : l.budgetScopeAll(scope.substring('currency:'.length));

/// Picks "All NPR accounts" (any currency in use) or one account.
Future<String?> pickBudgetScope(BuildContext context, String selected) {
  final store = AppScope.read(context);
  final l = context.l10n;
  final currencies = {store.defaultCurrency, ...store.accountCurrencies};
  return showOptionSheet<String>(
    context,
    title: l.budgetScope,
    selected: selected,
    options: () => [
      for (final cur in currencies)
        SheetOption('currency:$cur', l.budgetScopeAll(cur), LucideIcons.layers),
      for (final b in store.booksByRecent)
        SheetOption(
          'account:${b.id}',
          '${b.name} · ${b.currency}',
          accountTypeIcon(b.accountType),
        ),
    ],
  );
}

/// Settings → Budgets: an overall limit and per-category limits for one
/// scope, this month.
class BudgetsScreen extends StatefulWidget {
  const BudgetsScreen({super.key, this.scope});

  final String? scope;

  @override
  State<BudgetsScreen> createState() => _BudgetsScreenState();
}

class _BudgetsScreenState extends State<BudgetsScreen> {
  late String scope =
      widget.scope ?? 'currency:${AppScope.read(context).defaultCurrency}';

  Future<void> _edit({
    String? category,
    Budget? budget,
    bool overall = false,
  }) => Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => BudgetEditScreen(
        scope: scope,
        category: budget?.category ?? category,
        overall: overall || (budget != null && budget.category == null),
        existing: budget,
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final store = AppScope.watch(context);
    final c = context.pf;
    final l = context.l10n;
    final now = DateTime.now();
    final month = DateTime(now.year, now.month);
    final cur = store.scopeCurrency(scope);
    final noAccounts = store.scopeAccounts(scope).isEmpty;
    final all = store.budgetsFor(scope);
    final overall = all.where((b) => b.category == null).firstOrNull;
    final byCat = all.where((b) => b.category != null).toList()
      ..sort((a, b) => a.category!.compareTo(b.category!));
    double spent(Budget b) => store.budgetSpent(scope, b.category, month);
    final alerts = [
      for (final b in [?overall, ...byCat])
        if (spent(b) > b.amount)
          (
            LucideIcons.circleAlert,
            c.cashOut,
            l.budgetOverNote(
              b.category ?? l.budgetOverall,
              money(spent(b) - b.amount, cur),
            ),
          )
        else if (spent(b) >= b.amount * .8)
          (
            LucideIcons.triangleAlert,
            c.gold,
            l.budgetNear(
              b.category ?? l.budgetOverall,
              (spent(b) / b.amount * 100).round(),
            ),
          ),
    ];
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: pagePadding,
          children: [
            PfHeader(
              title: l.budgetsTitle,
              actions: [
                if (all.isNotEmpty)
                  PfIconButton(
                    icon: LucideIcons.plus,
                    tooltip: l.budgetAddCategory,
                    onPressed: () => _edit(),
                  ),
              ],
            ),
            const SizedBox(height: 14),
            PfCard(
              child: PfPickerRow(
                icon: LucideIcons.layers,
                label: l.budgetScope,
                value: scopeLabel(l, store, scope),
                onTap: () async {
                  final picked = await pickBudgetScope(context, scope);
                  if (picked != null) setState(() => scope = picked);
                },
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(LucideIcons.calendarDays, size: 15, color: c.sub),
                const SizedBox(width: 8),
                Text(
                  l.budgetMonth(DateFormat('MMMM y').format(month)),
                  style: pfText(12.5, weight: w800, color: c.sub),
                ),
              ],
            ),
            const SizedBox(height: 14),
            if (noAccounts)
              PfEmptyCard(
                icon: LucideIcons.coins,
                title: l.budgetNoAccountsTitle(cur),
                body: l.budgetNoAccountsBody,
                actionLabel: l.budgetAddAccount,
                onAction: () => openNewBook(context),
              )
            else if (all.isEmpty)
              ..._empty(c, l, cur)
            else ...[
              if (overall != null)
                _OverallCard(
                  budget: overall,
                  spent: spent(overall),
                  currency: cur,
                  onTap: () => _edit(budget: overall),
                )
              else
                PfButton(
                  label: l.budgetAddOverall,
                  icon: LucideIcons.gauge,
                  style: PfButtonStyle.neutral,
                  onPressed: () => _edit(overall: true),
                ),
              const SizedBox(height: 12),
              if (alerts.isEmpty)
                _Note(
                  icon: LucideIcons.circleCheck,
                  color: c.cashIn,
                  text: l.budgetAllOk,
                )
              else
                for (final (icon, color, text) in alerts)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: _Note(icon: icon, color: color, text: text),
                  ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      l.budgetByCategory,
                      style: pfText(15, weight: w900),
                    ),
                  ),
                  Text(
                    '${byCat.length}',
                    style: pfText(13, weight: w800, color: c.sub),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (byCat.isNotEmpty)
                PfCard(
                  child: Column(
                    children: [
                      for (final (i, b) in byCat.indexed) ...[
                        if (i > 0) const PfDivider(),
                        _CategoryRow(
                          budget: b,
                          spent: spent(b),
                          currency: cur,
                          onTap: () => _edit(budget: b),
                        ),
                      ],
                    ],
                  ),
                ),
              const SizedBox(height: 10),
              PfButton(
                label: l.budgetAddCategory,
                icon: LucideIcons.plus,
                style: PfButtonStyle.soft,
                onPressed: () => _edit(),
              ),
            ],
            const SizedBox(height: 14),
            PfNote(icon: LucideIcons.info, text: l.budgetRule),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  List<Widget> _empty(PfColors c, AppLocalizations l, String cur) => [
    PfCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PfIconTile(
            icon: LucideIcons.gauge,
            background: c.soft,
            foreground: c.cashIn,
            size: 52,
            radius: 18,
            iconSize: 24,
          ),
          const SizedBox(height: 10),
          Text(l.budgetEmptyTitle, style: pfText(17, weight: w900)),
          const SizedBox(height: 4),
          Text(
            l.budgetEmptyBody,
            style: pfText(14, weight: w600, color: c.sub, height: 1.45),
          ),
          const SizedBox(height: 14),
          Text(
            l.budgetExample,
            style: pfText(11.5, weight: w900, color: c.sub, letterSpacing: .4),
          ),
          const SizedBox(height: 6),
          // A worked example so the bar and its words make sense up front.
          _BudgetLine(
            icon: LucideIcons.utensils,
            name: 'Food',
            spent: 8700,
            limit: 11000,
            currency: cur,
          ),
        ],
      ),
    ),
    const SizedBox(height: 14),
    PfButton(
      label: l.budgetFirst,
      icon: LucideIcons.plus,
      onPressed: () => _edit(),
    ),
    const SizedBox(height: 6),
    Center(
      child: TextButton(
        onPressed: () => _edit(overall: true),
        child: Text(
          l.budgetAddOverall,
          style: pfText(14, weight: w800, color: c.cashIn),
        ),
      ),
    ),
  ];
}

class _Note extends StatelessWidget {
  const _Note({required this.icon, required this.color, required this.text});

  final IconData icon;
  final Color color;
  final String text;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Icon(icon, size: 16, color: color),
      const SizedBox(width: 8),
      Expanded(
        child: Text(
          text,
          style: pfText(13, weight: w800, color: color),
        ),
      ),
    ],
  );
}

class _OverallCard extends StatelessWidget {
  const _OverallCard({
    required this.budget,
    required this.spent,
    required this.currency,
    required this.onTap,
  });

  final Budget budget;
  final double spent;
  final String currency;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.pf;
    final l = context.l10n;
    final color = budgetColor(c, spent, budget.amount);
    final pct = budget.amount <= 0 ? 0 : (spent / budget.amount * 100).round();
    return PfCard(
      padding: const EdgeInsets.all(18),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l.budgetOverall,
                  style: pfText(13, weight: w800, color: c.sub),
                ),
              ),
              PfBadge(
                label: '$pct%',
                pill: true,
                background: color.withValues(alpha: .14),
                foreground: color,
              ),
            ],
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              budgetStatus(l, spent, budget.amount, currency),
              style: pfText(24, weight: w900, color: color),
            ),
          ),
          const SizedBox(height: 10),
          BudgetBar(spent: spent, limit: budget.amount, thick: true),
          const SizedBox(height: 6),
          Text(
            l.budgetOf(money(spent, currency), money(budget.amount, currency)),
            style: pfText(12.5, weight: w700, color: c.sub),
          ),
        ],
      ),
    );
  }
}

class _CategoryRow extends StatelessWidget {
  const _CategoryRow({
    required this.budget,
    required this.spent,
    required this.currency,
    required this.onTap,
  });

  final Budget budget;
  final double spent;
  final String currency;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: _BudgetLine(
        icon: categoryIcon(budget.category!),
        name: budget.category!,
        spent: spent,
        limit: budget.amount,
        currency: currency,
      ),
    ),
  );
}

class _BudgetLine extends StatelessWidget {
  const _BudgetLine({
    required this.icon,
    required this.name,
    required this.spent,
    required this.limit,
    required this.currency,
  });

  final IconData icon;
  final String name;
  final double spent;
  final double limit;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final c = context.pf;
    final l = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Icon(icon, size: 17, color: c.ink),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: pfText(14.5, weight: w800),
              ),
            ),
            Text(
              budgetStatus(l, spent, limit, currency),
              style: pfText(
                13,
                weight: w900,
                color: budgetColor(c, spent, limit),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        BudgetBar(spent: spent, limit: limit),
        const SizedBox(height: 4),
        Text(
          l.budgetOf(money(spent, currency), money(limit, currency)),
          style: pfText(11.5, weight: w700, color: c.sub),
        ),
      ],
    );
  }
}
