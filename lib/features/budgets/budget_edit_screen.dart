import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/amount_input.dart';
import '../../core/format.dart';
import '../../data/app_store.dart';
import '../../data/models.dart';
import '../../l10n/l10n.dart';
import '../../theme/tokens.dart';
import '../../widgets/category_icons.dart';
import '../../widgets/pf.dart';
import 'budgets_screen.dart';

/// Add or edit one monthly budget: what it covers, the limit (with a hint
/// from the last 3 months) and its scope.
class BudgetEditScreen extends StatefulWidget {
  const BudgetEditScreen({
    super.key,
    required this.scope,
    this.category,
    this.overall = false,
    this.existing,
  });

  final String scope;
  final String? category;

  /// Starts on "Overall" instead of a category.
  final bool overall;
  final Budget? existing;

  @override
  State<BudgetEditScreen> createState() => _BudgetEditScreenState();
}

class _BudgetEditScreenState extends State<BudgetEditScreen> {
  late final store = AppScope.read(context);
  late String scope = widget.scope;
  late String? category = widget.overall
      ? null
      : widget.category ?? _firstFree();
  late final amount = TextEditingController(
    text: widget.existing == null
        ? ''
        : widget.existing!.amount.toStringAsFixed(0),
  );
  String? error;

  bool get editing => widget.existing != null;

  /// The category with the most recent spending that has no budget yet
  /// (so it doesn't start on an income category like Salary).
  String? _firstFree() {
    final now = DateTime.now();
    double recent(String c) =>
        store.budgetSpent(widget.scope, c, DateTime(now.year, now.month)) +
        store.budgetHint(widget.scope, c, DateTime(now.year, now.month));
    final free = [
      for (final c in store.categories)
        if (store.budgetFor(widget.scope, c) == null) c,
    ]..sort((a, b) => recent(b).compareTo(recent(a)));
    return free.firstOrNull ?? store.categories.firstOrNull;
  }

  @override
  void dispose() {
    amount.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final l = context.l10n;
    final value = double.tryParse(amount.text.replaceAll(',', '').trim()) ?? 0;
    if (value <= 0) {
      setState(() => error = l.budgetErrAmount);
      return;
    }
    await store.saveBudget(
      scope: scope,
      category: category,
      amount: value,
      replacing: widget.existing?.id,
    );
    if (!mounted) return;
    showPfToast(context, l.budgetSaved);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final store = AppScope.watch(context);
    final c = context.pf;
    final l = context.l10n;
    final now = DateTime.now();
    final month = DateTime(now.year, now.month);
    final cur = store.scopeCurrency(scope);
    final hint = store.budgetHint(scope, category, month);
    final spent = store.budgetSpent(scope, category, month);
    final options = <String?>[null, ...store.categories];
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: pagePadding,
          children: [
            PfHeader(title: editing ? l.budgetEdit : l.budgetNew),
            const SizedBox(height: 14),
            PfSectionLabel(l.budgetCategoryLabel),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final option in options)
                  PfChoiceChip(
                    label: [
                      option ?? l.budgetOverall,
                      if (store.budgetFor(scope, option) != null &&
                          option != widget.existing?.category)
                        '· ${l.budgetHas}',
                    ].join(' '),
                    icon: option == null
                        ? LucideIcons.gauge
                        : categoryIcon(option),
                    selected: option == category,
                    onTap: () => setState(() {
                      category = option;
                      final existing = store.budgetFor(scope, option);
                      if (existing != null && !editing) {
                        amount.text = existing.amount.toStringAsFixed(0);
                      }
                    }),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            PfCard(
              child: PfField(
                label: l.budgetLimit,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      Currency.of(cur).symbol,
                      style: pfText(20, weight: w900, color: c.sub),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: amount,
                        autofocus: !editing,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          const AmountInputFormatter(decimals: false),
                        ],
                        onChanged: (_) => setState(() => error = null),
                        style: pfText(26, weight: w900, color: c.ink),
                        decoration: InputDecoration(
                          hintText: '0',
                          hintStyle: pfText(26, weight: w900, color: c.mute),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (error != null) ...[
              const SizedBox(height: 10),
              PfErrorBanner(error!),
            ],
            if (hint > 0) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: c.soft,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  children: [
                    Icon(LucideIcons.history, size: 18, color: c.cashIn),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l.budgetHint(money(hint.roundToDouble(), cur)),
                            style: pfText(13.5, weight: w900),
                          ),
                          Text(
                            l.budgetHintSub,
                            style: pfText(12, weight: w700, color: c.sub),
                          ),
                        ],
                      ),
                    ),
                    PfSmallButton(
                      label: l.budgetUseIt,
                      height: 36,
                      radius: 12,
                      fontSize: 13,
                      onPressed: () => setState(() {
                        amount.text = hint.round().toString();
                        error = null;
                      }),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(LucideIcons.receipt, size: 15, color: c.sub),
                const SizedBox(width: 8),
                Text(
                  l.budgetSpentSoFar(money(spent, cur)),
                  style: pfText(12.5, weight: w800, color: c.sub),
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
                Icon(LucideIcons.calendarSync, size: 15, color: c.sub),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l.budgetNoCarry,
                    style: pfText(12.5, weight: w700, color: c.sub),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            PfButton(label: l.save, icon: LucideIcons.check, onPressed: _save),
            if (editing) ...[
              const SizedBox(height: 10),
              PfButton(
                label: l.budgetDelete,
                icon: LucideIcons.trash2,
                style: PfButtonStyle.outlineDanger,
                height: 50,
                onPressed: () async {
                  await store.deleteBudget(widget.existing!.id);
                  if (!context.mounted) return;
                  showPfToast(context, l.budgetDeleted);
                  Navigator.pop(context);
                },
              ),
            ],
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
