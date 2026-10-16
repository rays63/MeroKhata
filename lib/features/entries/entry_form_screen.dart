import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/format.dart';
import '../../data/app_store.dart';
import '../../data/models.dart';
import '../../l10n/l10n.dart';
import '../../theme/tokens.dart';
import '../../widgets/category_icons.dart';
import '../../widgets/pf.dart';
import '../../widgets/store_sheets.dart';

/// New cash in / cash out, or edit an existing entry.
class EntryFormScreen extends StatefulWidget {
  const EntryFormScreen({
    super.key,
    required this.bookId,
    required this.type,
    this.existing,
  });

  final String bookId;
  final TransactionType type;
  final LedgerTransaction? existing;

  @override
  State<EntryFormScreen> createState() => _EntryFormScreenState();
}

class _EntryFormScreenState extends State<EntryFormScreen> {
  late String bookId = widget.bookId;
  late TransactionType type = widget.existing?.type ?? widget.type;
  late final amount = TextEditingController(
    text: widget.existing == null ? '' : _plain(widget.existing!.amount),
  );
  late final title = TextEditingController(text: widget.existing?.title ?? '');
  late final notes = TextEditingController(text: widget.existing?.notes ?? '');
  late String category =
      widget.existing?.category ?? _defaultCategory(widget.type);
  late String mode = widget.existing?.paymentMode ?? 'Cash';
  late DateTime when = widget.existing?.occurredAt ?? DateTime.now();
  late String? goalId = _goal(widget.existing?.goalId);
  String? error;
  bool saving = false;

  bool get editing => widget.existing != null;
  bool get isIn => type == TransactionType.cashIn;

  static String _plain(double value) => value == value.roundToDouble()
      ? value.toStringAsFixed(0)
      : value.toStringAsFixed(2);

  static String? _goal(String? id) => id == null || id.isEmpty ? null : id;

  String _defaultCategory(TransactionType value) {
    final categories = AppScope.read(context).categories;
    final preferred = value == TransactionType.cashIn ? 'Salary' : 'Groceries';
    if (categories.contains(preferred)) return preferred;
    return categories.firstOrNull ?? 'General';
  }

  @override
  void dispose() {
    amount.dispose();
    title.dispose();
    notes.dispose();
    super.dispose();
  }

  void _setType(TransactionType value) {
    if (value == type) return;
    setState(() {
      // Swap the default category if the user hasn't chosen one.
      if (!editing && category == _defaultCategory(type)) {
        category = _defaultCategory(value);
      }
      type = value;
      if (value == TransactionType.cashOut) goalId = null;
      error = null;
    });
  }

  Future<void> _pickWhen() async {
    final date = await showDatePicker(
      context: context,
      initialDate: when,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(when),
    );
    if (!mounted) return;
    setState(() {
      when = DateTime(
        date.year,
        date.month,
        date.day,
        time?.hour ?? when.hour,
        time?.minute ?? when.minute,
      );
    });
  }

  Future<void> _save() async {
    final l = context.l10n;
    final value = double.tryParse(amount.text.replaceAll(',', '').trim());
    if (value == null || value <= 0) {
      setState(() => error = l.entryErrorAmount);
      return;
    }
    if (title.text.trim().isEmpty) {
      setState(() => error = l.entryErrorTitle);
      return;
    }
    if (saving) return;
    setState(() => saving = true);
    final store = AppScope.read(context);
    final now = DateTime.now();
    final existing = widget.existing;
    final entry = LedgerTransaction(
      id: existing?.id ?? AppStore.newId('txn'),
      bookId: bookId,
      title: title.text.trim(),
      amount: value,
      type: type,
      occurredAt: when,
      createdAt: existing?.createdAt ?? now,
      updatedAt: now,
      category: category,
      paymentMode: mode,
      notes: notes.text.trim(),
      goalId: isIn && store.bookById(bookId)?.currency == 'NPR' ? goalId : null,
      runningBalance: 0,
      externalReference: existing?.externalReference ?? '',
      statementBalance: existing?.statementBalance,
      sequence: existing?.sequence ?? 0,
      importSource: existing?.importSource ?? '',
    );
    await store.saveTransaction(entry);
    if (!mounted) return;
    showPfToast(
      context,
      [
        editing ? l.entryChangesSaved : l.entrySaved,
        l.entryBalanceUpdated,
        if (isIn && goalId != null) l.entryGoalUpdated,
      ].join(' · '),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final store = AppScope.watch(context);
    final c = context.pf;
    final l = context.l10n;
    final book = store.bookById(bookId);
    final currency = Currency.of(book?.currency ?? 'NPR');
    final heading = editing
        ? l.entryEditTitle
        : (isIn ? l.entryNewCashIn : l.entryNewCashOut);
    final amountColor = c.amount(isIn);
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: pagePadding,
          children: [
            Row(
              children: [
                PfIconButton(
                  icon: LucideIcons.x,
                  tooltip: l.close,
                  onPressed: () => Navigator.maybePop(context),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        heading,
                        style: pfText(20, weight: w900),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      InkWell(
                        onTap: editing
                            ? null
                            : () async {
                                final picked = await pickBook(
                                  context,
                                  selected: bookId,
                                );
                                if (picked != null) {
                                  setState(() => bookId = picked);
                                }
                              },
                        child: Row(
                          children: [
                            Flexible(
                              child: Text(
                                '${book?.name ?? ''} · ${currency.code}',
                                style: pfText(12, color: c.sub),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (!editing && store.books.length > 1)
                              Icon(
                                LucideIcons.chevronDown,
                                size: 13,
                                color: c.sub,
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _TypeToggle(value: type, onChanged: _setType),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.fromLTRB(4, 8, 4, 8),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: c.line, width: 2)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    currency.symbol,
                    style: pfText(24, weight: w900, color: c.sub),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: amount,
                      autofocus: !editing,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[\d.,]')),
                      ],
                      onChanged: (_) {
                        if (error != null) setState(() => error = null);
                      },
                      style: pfText(
                        44,
                        weight: w900,
                        color: amountColor,
                        letterSpacing: -1,
                      ),
                      decoration: InputDecoration(
                        hintText: '0',
                        hintStyle: pfText(44, weight: w900, color: c.mute),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            PfCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  PfField(
                    label: l.entryTitleLabel,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 13,
                    ),
                    child: TextField(
                      controller: title,
                      textCapitalization: TextCapitalization.sentences,
                      onChanged: (_) {
                        if (error != null) setState(() => error = null);
                      },
                      style: pfText(16, color: c.ink),
                      decoration: InputDecoration(
                        hintText: l.entryTitleHint,
                        hintStyle: pfText(16, color: c.mute),
                      ),
                    ),
                  ),
                  const PfDivider(),
                  PfPickerRow(
                    icon: categoryIcon(category),
                    label: l.category,
                    value: category,
                    onTap: () async {
                      final picked = await pickCategory(
                        context,
                        selected: category,
                      );
                      if (picked != null) setState(() => category = picked);
                    },
                  ),
                  const PfDivider(),
                  PfPickerRow(
                    icon: LucideIcons.wallet,
                    label: l.paymentMode,
                    value: mode,
                    onTap: () async {
                      final picked = await pickPaymentMode(
                        context,
                        selected: mode,
                      );
                      if (picked != null) setState(() => mode = picked);
                    },
                  ),
                  const PfDivider(),
                  PfPickerRow(
                    icon: LucideIcons.clock,
                    label: l.entryDateTime,
                    value: _whenLabel(l, when),
                    chevron: false,
                    onTap: _pickWhen,
                  ),
                  const PfDivider(),
                  PfField(
                    label: l.entryNotes,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 13,
                    ),
                    child: TextField(
                      controller: notes,
                      textCapitalization: TextCapitalization.sentences,
                      style: pfText(15, weight: w700, color: c.ink),
                      decoration: InputDecoration(
                        hintText: l.optional,
                        hintStyle: pfText(15, weight: w700, color: c.mute),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Goals are tracked in NPR; linking other currencies would mix
            // amounts without conversion.
            if (isIn && store.goals.isNotEmpty && currency.code == 'NPR') ...[
              const SizedBox(height: 16),
              PfSectionLabel(l.entryAddToGoal, optional: true),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final goal in store.goals)
                    PfChoiceChip(
                      label: goal.name,
                      icon: LucideIcons.target,
                      selected: goalId == goal.id,
                      onTap: () => setState(
                        () => goalId = goalId == goal.id ? null : goal.id,
                      ),
                    ),
                ],
              ),
            ],
            if (error != null) ...[
              const SizedBox(height: 16),
              PfErrorBanner(error!),
            ],
            const SizedBox(height: 16),
            PfButton(
              label: l.entrySave,
              icon: LucideIcons.check,
              onPressed: saving ? null : _save,
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  static String _whenLabel(AppLocalizations l, DateTime value) {
    final now = DateTime.now();
    final day = sameDay(value, now)
        ? l.entryWhenToday(DateFormat('d MMM').format(value))
        : DateFormat(
            value.year == now.year ? 'EEE, d MMM' : 'd MMM y',
          ).format(value);
    return '$day · ${timeLabel(value)}';
  }
}

class _TypeToggle extends StatelessWidget {
  const _TypeToggle({required this.value, required this.onChanged});

  final TransactionType value;
  final ValueChanged<TransactionType> onChanged;

  @override
  Widget build(BuildContext context) {
    final c = context.pf;
    final l = context.l10n;
    Widget option(TransactionType type, IconData icon, String label) {
      final selected = value == type;
      final isIn = type == TransactionType.cashIn;
      final fg = selected ? c.amount(isIn) : c.sub;
      return Expanded(
        child: Semantics(
          selected: selected,
          button: true,
          child: Material(
            color: selected ? c.amountSoft(isIn) : Colors.transparent,
            borderRadius: BorderRadius.circular(15),
            child: InkWell(
              borderRadius: BorderRadius.circular(15),
              onTap: () => onChanged(type),
              child: SizedBox(
                height: 46,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon, size: 16, color: fg),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        label,
                        style: pfText(15, weight: w900, color: fg),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          option(TransactionType.cashIn, LucideIcons.arrowDownLeft, l.cashIn),
          const SizedBox(width: 6),
          option(TransactionType.cashOut, LucideIcons.arrowUpRight, l.cashOut),
        ],
      ),
    );
  }
}
