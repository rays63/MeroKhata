import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/amount_input.dart';
import '../../app/nav.dart';
import '../../core/format.dart';
import '../../data/app_store.dart';
import '../../data/models.dart';
import '../../l10n/l10n.dart';
import '../../theme/tokens.dart';
import '../../widgets/category_icons.dart';
import '../../widgets/entry_kind_toggle.dart';
import '../../widgets/option_sheet.dart';
import '../../widgets/pf.dart';
import '../../widgets/tags.dart';
import '../../widgets/store_sheets.dart';
import 'transfer_form_screen.dart';

/// New cash in / cash out, or edit an existing entry.
class EntryFormScreen extends StatefulWidget {
  const EntryFormScreen({
    super.key,
    required this.bookId,
    required this.type,
    this.existing,
    this.initialAmount = '',
    this.initialNotes = '',
    this.initialWhen,
    this.template,
  });

  final String bookId;
  final TransactionType type;
  final LedgerTransaction? existing;

  /// Starts the form filled from a template.
  final EntryTemplate? template;

  /// Carried over when switching here from the transfer form.
  final String initialAmount;
  final String initialNotes;
  final DateTime? initialWhen;

  @override
  State<EntryFormScreen> createState() => _EntryFormScreenState();
}

class _EntryFormScreenState extends State<EntryFormScreen> {
  late String bookId = widget.bookId;
  late TransactionType type =
      widget.existing?.type ?? widget.template?.type ?? widget.type;
  late final amount = TextEditingController(
    text: widget.existing != null
        ? _plain(widget.existing!.amount)
        : widget.template != null
        ? _plain(widget.template!.amount)
        : widget.initialAmount,
  );
  late final title = TextEditingController(
    text: widget.existing?.title ?? widget.template?.title ?? '',
  );
  final amountFocus = FocusNode();

  /// Past titles matching what's typed; hidden once one is picked.
  bool suggest = false;
  late final notes = TextEditingController(
    text: widget.existing?.notes ?? widget.initialNotes,
  );
  late String category =
      widget.existing?.category ??
      widget.template?.category ??
      _defaultCategory(type);
  late String subcategory =
      widget.existing?.subcategory ?? widget.template?.subcategory ?? '';
  late String mode =
      widget.existing?.paymentMode ?? widget.template?.paymentMode ?? 'Cash';
  late DateTime when =
      widget.existing?.occurredAt ?? widget.initialWhen ?? DateTime.now();
  late String? goalId = _goal(widget.existing?.goalId);

  /// Set on a new entry to repeat it; the user confirms each one when due.
  Repeat? repeat;
  late List<String> tags = [...?widget.existing?.tags ?? widget.template?.tags];
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
    amountFocus.dispose();
    super.dispose();
  }

  void _applyTemplate(EntryTemplate template) {
    final store = AppScope.read(context);
    setState(() {
      if (store.bookById(template.bookId) != null) bookId = template.bookId;
      type = template.type;
      amount.text = _plain(template.amount);
      title.text = template.title;
      category = template.category;
      subcategory = template.subcategory;
      mode = template.paymentMode;
      tags = [...template.tags];
      if (type == TransactionType.cashOut) goalId = null;
      suggest = false;
      error = null;
    });
  }

  /// Fills category, mode and tags from a past entry with this title.
  void _applySuggestion(LedgerTransaction past) {
    setState(() {
      title.text = past.title;
      title.selection = TextSelection.collapsed(offset: past.title.length);
      category = past.category;
      subcategory = past.subcategory;
      if (past.paymentMode.isNotEmpty) mode = past.paymentMode;
      tags = [...past.tags];
      suggest = false;
    });
  }

  Future<void> _star() async {
    FocusScope.of(context).unfocus();
    final l = context.l10n;
    final value = double.tryParse(amount.text.replaceAll(',', '').trim());
    if (value == null || value <= 0 || title.text.trim().isEmpty) {
      showPfToast(context, l.templateNeedsFields);
      return;
    }
    final store = AppScope.read(context);
    final saved = await store.addTemplate(
      EntryTemplate(
        id: '',
        title: title.text,
        type: type,
        amount: value,
        category: category,
        paymentMode: mode,
        bookId: bookId,
        tags: tags,
        subcategory: subcategory,
      ),
    );
    if (!mounted) return;
    final currency = store.bookById(bookId)?.currency ?? 'NPR';
    showPfToast(context, l.templateSaved(saved.title, money(value, currency)));
  }

  void _setType(TransactionType value) {
    if (value == type) return;
    setState(() {
      // Swap the default category if the user hasn't chosen one.
      if (!editing && category == _defaultCategory(type)) {
        category = _defaultCategory(value);
        subcategory = '';
      }
      type = value;
      if (value == TransactionType.cashOut) goalId = null;
      error = null;
    });
  }

  /// Same form, now as a transfer; what was typed carries over.
  void _toTransfer() {
    Navigator.of(context).pushReplacement(
      instantRoute(
        TransferFormScreen(
          fromId: bookId,
          initialAmount: amount.text,
          initialNotes: notes.text,
          initialWhen: when,
        ),
      ),
    );
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

  Future<void> _save({bool another = false}) async {
    final l = context.l10n;
    final read = readAmount(amount.text);
    if (read.problem case final problem?) {
      final currency =
          AppScope.read(context).bookById(bookId)?.currency ?? 'NPR';
      setState(() => error = amountErrorText(l, problem, currency));
      return;
    }
    final value = read.value!;
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
      transferId: existing?.transferId,
      transferFee: existing?.transferFee ?? false,
      tags: tags,
      subcategory: subcategory,
    );
    await store.saveTransaction(entry);
    if (repeat != null) {
      final repeating = RecurringEntry(
        id: '',
        repeat: repeat!,
        nextDue: when,
        title: entry.title,
        type: type,
        amount: value,
        category: category,
        paymentMode: mode,
        bookId: bookId,
        notes: entry.notes,
        tags: tags,
        anchorDay: when.day,
        subcategory: subcategory,
      );
      // This entry is the first one; the next is due one period later.
      await store.addRecurring(
        repeating.copyWith(nextDue: repeating.following(when)),
      );
    }
    if (!mounted) return;
    if (another) {
      // Keep account, type, date, mode and tags for the next entry.
      setState(() {
        amount.clear();
        title.clear();
        notes.clear();
        goalId = null;
        category = _defaultCategory(type);
        subcategory = '';
        suggest = false;
        saving = false;
      });
      repeat = null;
      showPfToast(context, l.entrySavedKeepGoing);
      amountFocus.requestFocus();
      return;
    }
    showPfToast(
      context,
      [
        if (repeat != null)
          l.repeatSaved(repeatLabel(l, repeat).toLowerCase())
        else
          editing ? l.entryChangesSaved : l.entrySaved,
        l.entryBalanceUpdated,
        if (isIn && goalId != null) l.entryGoalUpdated,
      ].join(' · '),
    );
    Navigator.pop(context, true);
  }

  Future<void> _pickRepeat() async {
    final l = context.l10n;
    const never = Object();
    final picked = await showOptionSheet<Object>(
      context,
      title: l.repeatLabel,
      selected: repeat ?? never,
      options: () => [
        for (final option in [null, ...Repeat.values])
          SheetOption<Object>(
            option ?? never,
            repeatLabel(l, option),
            option == null ? LucideIcons.circleSlash : LucideIcons.repeat,
          ),
      ],
    );
    if (picked == null) return;
    setState(() => repeat = identical(picked, never) ? null : picked as Repeat);
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
                const SizedBox(width: 8),
                Tooltip(
                  message: l.templateStarHint,
                  child: PfSmallButton(
                    label: l.templateStar,
                    icon: LucideIcons.star,
                    background: c.card,
                    foreground: c.gold,
                    fontSize: 13,
                    radius: 16,
                    onPressed: _star,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            EntryKindToggle(
              value: isIn ? EntryKind.cashIn : EntryKind.cashOut,
              kinds: editing
                  ? const [EntryKind.cashIn, EntryKind.cashOut]
                  : EntryKind.values,
              onChanged: (kind) => switch (kind) {
                EntryKind.cashIn => _setType(TransactionType.cashIn),
                EntryKind.cashOut => _setType(TransactionType.cashOut),
                EntryKind.transfer => _toTransfer(),
              },
            ),
            if (!editing && store.templates.isNotEmpty) ...[
              const SizedBox(height: 12),
              _TemplateRow(
                templates: store.templates,
                currencyOf: (t) =>
                    store.bookById(t.bookId)?.currency ?? currency.code,
                onPick: _applyTemplate,
                onManage: () => openTemplates(context),
              ),
            ],
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
                      focusNode: amountFocus,
                      autofocus: !editing && widget.template == null,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [const AmountInputFormatter()],
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
                      onChanged: (_) => setState(() {
                        error = null;
                        suggest = !editing;
                      }),
                      style: pfText(16, color: c.ink),
                      decoration: InputDecoration(
                        hintText: l.entryTitleHint,
                        hintStyle: pfText(16, color: c.mute),
                      ),
                    ),
                  ),
                  if (suggest)
                    for (final past in store.titleSuggestions(title.text))
                      _Suggestion(
                        entry: past,
                        typed: title.text,
                        onTap: () => _applySuggestion(past),
                      ),
                  const PfDivider(),
                  PfPickerRow(
                    icon: categoryIcon(category),
                    label: l.category,
                    value: subcategoryLabel(category, subcategory),
                    onTap: () async {
                      final picked = await pickCategoryAndSub(
                        context,
                        category: category,
                        subcategory: subcategory,
                      );
                      if (picked != null) {
                        setState(() {
                          category = picked.$1;
                          subcategory = picked.$2;
                        });
                      }
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
                    value: entryWhenLabel(l, when),
                    chevron: false,
                    onTap: _pickWhen,
                  ),
                  if (!editing) ...[
                    const PfDivider(),
                    PfPickerRow(
                      icon: LucideIcons.repeat,
                      label: l.repeatLabel,
                      value: repeatLabel(l, repeat),
                      hint: repeat == null ? null : l.repeatConfirmEach,
                      onTap: _pickRepeat,
                    ),
                  ],
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
            const SizedBox(height: 16),
            TagField(
              tags: tags,
              onChanged: (value) => setState(() => tags = value),
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
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!editing) ...[
                  Expanded(
                    child: PfButton(
                      label: l.entrySaveAnother,
                      style: PfButtonStyle.soft,
                      fontSize: 14.5,
                      onPressed: saving ? null : () => _save(another: true),
                    ),
                  ),
                  const SizedBox(width: 10),
                ],
                Expanded(
                  child: PfButton(
                    label: l.entrySave,
                    icon: LucideIcons.check,
                    onPressed: saving ? null : _save,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

/// "Today, 22 Oct · 4:05 PM" style label for an entry's date and time.
String entryWhenLabel(AppLocalizations l, DateTime value) {
  final now = DateTime.now();
  final day = sameDay(value, now)
      ? l.entryWhenToday(DateFormat('d MMM').format(value))
      : DateFormat(
          value.year == now.year ? 'EEE, d MMM' : 'd MMM y',
        ).format(value);
  return '$day · ${timeLabel(value)}';
}

/// "★ Momo · Rs 450" chips that fill the form, and "Manage".
class _TemplateRow extends StatelessWidget {
  const _TemplateRow({
    required this.templates,
    required this.currencyOf,
    required this.onPick,
    required this.onManage,
  });

  final List<EntryTemplate> templates;
  final String Function(EntryTemplate) currencyOf;
  final ValueChanged<EntryTemplate> onPick;
  final VoidCallback onManage;

  @override
  Widget build(BuildContext context) {
    final c = context.pf;
    final l = context.l10n;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      clipBehavior: Clip.none,
      child: Row(
        children: [
          for (final t in templates) ...[
            Material(
              color: c.card,
              shape: StadiumBorder(side: BorderSide(color: c.line, width: 1.5)),
              child: InkWell(
                customBorder: const StadiumBorder(),
                onTap: () => onPick(t),
                child: Container(
                  constraints: const BoxConstraints(minHeight: 36),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(LucideIcons.star, size: 13, color: c.gold),
                      const SizedBox(width: 6),
                      Text(
                        '${t.title} · ${money(t.amount, currencyOf(t))}',
                        style: pfText(12.5, weight: w800, color: c.ink),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          TextButton(
            onPressed: onManage,
            child: Text(
              l.templatesManage,
              style: pfText(12.5, weight: w900, color: c.cashIn),
            ),
          ),
        ],
      ),
    );
  }
}

/// A past entry offered while typing the title.
class _Suggestion extends StatelessWidget {
  const _Suggestion({
    required this.entry,
    required this.typed,
    required this.onTap,
  });

  final LedgerTransaction entry;
  final String typed;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.pf;
    final l = context.l10n;
    final title = entry.title;
    final at = title.toLowerCase().indexOf(typed.trim().toLowerCase());
    final end = at < 0 ? 0 : at + typed.trim().length;
    final meta = [
      entry.category,
      if (entry.paymentMode.isNotEmpty) entry.paymentMode,
      ...entry.tags.map(tagLabel),
    ].join(' · ');
    return Semantics(
      container: true,
      button: true,
      label: l.entrySuggestion(title),
      onTap: onTap,
      excludeSemantics: true,
      child: Material(
        color: c.card2,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            child: Row(
              children: [
                Icon(LucideIcons.history, size: 16, color: c.mute),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text.rich(
                        at < 0
                            ? TextSpan(text: title)
                            : TextSpan(
                                children: [
                                  TextSpan(text: title.substring(0, at)),
                                  TextSpan(
                                    text: title.substring(at, end),
                                    style: TextStyle(
                                      backgroundColor: c.highlight,
                                    ),
                                  ),
                                  TextSpan(text: title.substring(end)),
                                ],
                              ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: pfText(14.5, weight: w800, color: c.ink),
                      ),
                      Text(
                        meta,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: pfText(12, weight: w700, color: c.sub),
                      ),
                    ],
                  ),
                ),
                Icon(LucideIcons.arrowUpLeft, size: 15, color: c.mute),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

String repeatLabel(AppLocalizations l, Repeat? repeat) => switch (repeat) {
  null => l.repeatNever,
  Repeat.daily => l.repeatDaily,
  Repeat.weekly => l.repeatWeekly,
  Repeat.monthly => l.repeatMonthly,
  Repeat.yearly => l.repeatYearly,
};

/// The message for an amount that can't be saved, in the account's currency.
String amountErrorText(
  AppLocalizations l,
  AmountProblem problem,
  String currency,
) => switch (problem) {
  AmountProblem.invalid => l.amountInvalid,
  AmountProblem.tooLarge => l.amountTooLarge(money(maxAmount, currency)),
  _ => l.entryErrorAmount,
};
