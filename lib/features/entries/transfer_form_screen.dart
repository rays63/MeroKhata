import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/amount_input.dart';
import '../../core/format.dart';
import '../../data/app_store.dart';
import '../../data/models.dart';
import '../../l10n/l10n.dart';
import '../../theme/tokens.dart';
import '../../widgets/account_type.dart';
import '../../widgets/entry_kind_toggle.dart';
import '../../widgets/pf.dart';
import '../../widgets/tags.dart';
import '../../widgets/store_sheets.dart';
import 'entry_form_screen.dart';

/// Money moving between two of the user's accounts: new, or editing an
/// existing transfer.
class TransferFormScreen extends StatefulWidget {
  const TransferFormScreen({
    super.key,
    this.fromId,
    this.transferId,
    this.initialAmount = '',
    this.initialNotes = '',
    this.initialWhen,
  });

  final String? fromId;

  /// Set when editing.
  final String? transferId;

  /// Carried over when switching here from the cash in / out form.
  final String initialAmount;
  final String initialNotes;
  final DateTime? initialWhen;

  @override
  State<TransferFormScreen> createState() => _TransferFormScreenState();
}

class _TransferFormScreenState extends State<TransferFormScreen> {
  late final TransferLegs? existing = widget.transferId == null
      ? null
      : AppScope.read(context).transferLegs(widget.transferId!);
  late String fromId = existing?.fromId ?? _defaultFrom();
  late String toId = existing?.toId ?? _defaultTo(fromId);
  late final amount = TextEditingController(
    text: existing == null
        ? widget.initialAmount
        : _plain(existing!.out.amount),
  );
  late final received = TextEditingController(
    text: existing == null ? '' : _plain(existing!.into.amount),
  );
  late final fee = TextEditingController(
    text: existing?.fee == null ? '' : _plain(existing!.fee!.amount),
  );
  late final notes = TextEditingController(
    text: existing?.out.notes ?? widget.initialNotes,
  );
  late DateTime when =
      existing?.out.occurredAt ?? widget.initialWhen ?? DateTime.now();
  late List<String> tags = [...?existing?.out.tags];
  String? error;
  bool saving = false;

  bool get editing => existing != null;

  static String _plain(double value) => value == value.roundToDouble()
      ? value.toStringAsFixed(0)
      : value.toStringAsFixed(2);

  static double _parse(String text) =>
      double.tryParse(text.replaceAll(',', '').trim()) ?? 0;

  String _defaultFrom() {
    final store = AppScope.read(context);
    if (widget.fromId != null && store.bookById(widget.fromId!) != null) {
      return widget.fromId!;
    }
    final bank = store.booksByRecent.where(
      (book) => book.accountType == AccountType.bank,
    );
    return (bank.firstOrNull ?? store.booksByRecent.first).id;
  }

  /// A likely destination: a wallet or cash account in the same currency.
  String _defaultTo(String from) {
    final store = AppScope.read(context);
    final currency = store.bookById(from)?.currency;
    final others = store.booksByRecent.where((book) => book.id != from);
    for (final type in [AccountType.wallet, AccountType.cash]) {
      final match = others.where(
        (book) => book.accountType == type && book.currency == currency,
      );
      if (match.isNotEmpty) return match.first.id;
    }
    return (others.where((b) => b.currency == currency).firstOrNull ??
                others.firstOrNull)
            ?.id ??
        from;
  }

  @override
  void dispose() {
    amount.dispose();
    received.dispose();
    fee.dispose();
    notes.dispose();
    super.dispose();
  }

  void _toEntry(TransactionType type) {
    Navigator.of(context).pushReplacement(
      instantRoute(
        EntryFormScreen(
          bookId: fromId,
          type: type,
          initialAmount: amount.text,
          initialNotes: notes.text,
          initialWhen: when,
        ),
      ),
    );
  }

  Future<void> _pick({required bool from}) async {
    final picked = await pickBook(context, selected: from ? fromId : toId);
    if (picked == null || !mounted) return;
    setState(() {
      if (from) {
        fromId = picked;
      } else {
        toId = picked;
      }
      error = null;
    });
  }

  void _swap() => setState(() {
    final was = fromId;
    fromId = toId;
    toId = was;
    received.clear();
    error = null;
  });

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
    final store = AppScope.read(context);
    final from = store.bookById(fromId);
    final to = store.bookById(toId);
    final read = readAmount(amount.text);
    if (read.problem case final problem?) {
      setState(
        () => error = amountErrorText(l, problem, from?.currency ?? 'NPR'),
      );
      return;
    }
    final value = read.value!;
    if (from == null || to == null || fromId == toId) {
      setState(() => error = l.transferErrorSame);
      return;
    }
    final cross = from.currency != to.currency;
    final arrived = _parse(received.text);
    if (cross && arrived <= 0) {
      setState(() => error = l.transferErrorReceived);
      return;
    }
    if (saving) return;
    setState(() => saving = true);
    await store.saveTransfer(
      transferId: widget.transferId,
      fromId: fromId,
      toId: toId,
      amount: value,
      toAmount: cross ? arrived : null,
      fee: _parse(fee.text),
      when: when,
      notes: notes.text,
      tags: tags,
    );
    if (!mounted) return;
    showPfToast(context, l.transferSaved);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final store = AppScope.watch(context);
    final c = context.pf;
    final l = context.l10n;
    final from = store.bookById(fromId);
    final to = store.bookById(toId);
    if (from == null || to == null) return const Scaffold();
    final fromCurrency = Currency.of(from.currency);
    final toCurrency = Currency.of(to.currency);
    final cross = from.currency != to.currency;
    final single = store.books.length < 2;
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
                  child: Text(
                    editing ? l.transferEditTitle : l.transfer,
                    style: pfText(20, weight: w900),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            if (!editing) ...[
              const SizedBox(height: 14),
              EntryKindToggle(
                value: EntryKind.transfer,
                onChanged: (kind) => switch (kind) {
                  EntryKind.cashIn => _toEntry(TransactionType.cashIn),
                  EntryKind.cashOut => _toEntry(TransactionType.cashOut),
                  EntryKind.transfer => null,
                },
              ),
            ],
            const SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                l.transferAmountIn(from.currency),
                style: pfText(12, weight: w800, color: c.sub),
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(4, 4, 4, 8),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: c.line, width: 2)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    fromCurrency.symbol,
                    style: pfText(24, weight: w900, color: c.sub),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: amount,
                      autofocus: !editing && amount.text.isEmpty,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [const AmountInputFormatter()],
                      onChanged: (_) => setState(() => error = null),
                      style: pfText(
                        42,
                        weight: w900,
                        color: c.blue,
                        letterSpacing: -1,
                      ),
                      decoration: InputDecoration(
                        hintText: '0',
                        hintStyle: pfText(42, weight: w900, color: c.mute),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            _AccountsCard(
              from: from,
              to: to,
              store: store,
              onPickFrom: () => _pick(from: true),
              onPickTo: () => _pick(from: false),
              onSwap: _swap,
            ),
            if (single) ...[
              const SizedBox(height: 14),
              PfNote(icon: LucideIcons.info, text: l.transferNeedTwo),
            ] else if (cross) ...[
              const SizedBox(height: 14),
              _CrossCurrencyCard(
                from: fromCurrency,
                to: toCurrency,
                controller: received,
                sent: _parse(amount.text),
                onChanged: () => setState(() => error = null),
              ),
            ] else if (fromId != toId)
              ..._casePreview(store, l, c, from, to),
            const SizedBox(height: 14),
            PfCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _FeeField(
                    controller: fee,
                    symbol: fromCurrency.symbol,
                    // The balance preview includes the fee.
                    onChanged: () => setState(() => error = null),
                  ),
                  const PfDivider(),
                  PfPickerRow(
                    icon: LucideIcons.clock,
                    label: l.entryDateTime,
                    value: entryWhenLabel(l, when),
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
                        hintText: l.transferNotesHint,
                        hintStyle: pfText(15, weight: w700, color: c.mute),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            TagField(
              tags: tags,
              onChanged: (value) => setState(() => tags = value),
            ),
            const SizedBox(height: 14),
            PfNote(icon: LucideIcons.info, text: l.transferExplain),
            if (error != null) ...[
              const SizedBox(height: 14),
              PfErrorBanner(error!),
            ],
            const SizedBox(height: 14),
            PfButton(
              label: l.entrySave,
              icon: LucideIcons.check,
              onPressed: saving || single ? null : _save,
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  /// "Wallet top-up · NIC Rs 50,000 → Rs 45,000 · eSewa Rs 0 → Rs 5,000".
  List<Widget> _casePreview(
    AppStore store,
    AppLocalizations l,
    PfColors c,
    LedgerBook from,
    LedgerBook to,
  ) {
    final value = _parse(amount.text);
    final title = switch (to.accountType) {
      AccountType.card => l.transferCardPay,
      AccountType.wallet => l.transferWalletLoad,
      AccountType.loan => l.transferLoanRepayment,
      AccountType.cash when from.accountType == AccountType.bank =>
        l.transferCashWithdrawal,
      _ => null,
    };
    if (title == null) return const [];
    // When editing, preview from the balances before this transfer.
    final undoOut = existing?.out.amount ?? 0;
    final undoIn = existing?.into.amount ?? 0;
    final undoFee = existing?.fee?.amount ?? 0;
    final fromBefore =
        store.balanceFor(from.id) +
        (existing?.fromId == from.id ? undoOut + undoFee : 0);
    final toBefore =
        store.balanceFor(to.id) - (existing?.toId == to.id ? undoIn : 0);
    final String text;
    if (to.isLiability) {
      final owed = -toBefore;
      text = l.transferOwedChange(
        to.name,
        money(owed, to.currency),
        money(owed - value < 0 ? 0 : owed - value, to.currency),
      );
    } else {
      text = [
        l.transferBalanceChange(
          from.name,
          balanceMoney(fromBefore, from.currency),
          balanceMoney(fromBefore - value - _parse(fee.text), from.currency),
        ),
        l.transferBalanceChange(
          to.name,
          balanceMoney(toBefore, to.currency),
          balanceMoney(toBefore + value, to.currency),
        ),
      ].join(' · ');
    }
    return [
      const SizedBox(height: 14),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
        decoration: BoxDecoration(
          color: c.soft,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(accountTypeIcon(to.accountType), size: 18, color: c.cashIn),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: pfText(12.5, weight: w900, color: c.cashIn),
                  ),
                  Text(
                    text,
                    style: pfText(
                      12.5,
                      weight: w700,
                      color: c.sub,
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ];
  }
}

/// From and To rows with a swap button between them.
class _AccountsCard extends StatelessWidget {
  const _AccountsCard({
    required this.from,
    required this.to,
    required this.store,
    required this.onPickFrom,
    required this.onPickTo,
    required this.onSwap,
  });

  final LedgerBook from;
  final LedgerBook to;
  final AppStore store;
  final VoidCallback onPickFrom;
  final VoidCallback onPickTo;
  final VoidCallback onSwap;

  @override
  Widget build(BuildContext context) {
    final c = context.pf;
    final l = context.l10n;
    return Stack(
      children: [
        PfCard(
          child: Column(
            children: [
              _AccountRow(
                label: l.transferFrom,
                book: from,
                store: store,
                onTap: onPickFrom,
              ),
              const PfDivider(),
              _AccountRow(
                label: l.transferTo,
                book: to,
                store: store,
                onTap: onPickTo,
              ),
            ],
          ),
        ),
        Positioned.fill(
          right: 46,
          child: Align(
            alignment: Alignment.centerRight,
            child: Material(
              color: c.blueSoft,
              shape: CircleBorder(side: BorderSide(color: c.card, width: 3)),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: onSwap,
                child: Tooltip(
                  message: l.transferSwap,
                  child: SizedBox(
                    width: 36,
                    height: 36,
                    child: Icon(
                      LucideIcons.arrowUpDown,
                      size: 15,
                      color: c.blue,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _AccountRow extends StatelessWidget {
  const _AccountRow({
    required this.label,
    required this.book,
    required this.store,
    required this.onTap,
  });

  final String label;
  final LedgerBook book;
  final AppStore store;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.pf;
    final l = context.l10n;
    final balance = store.balanceFor(book.id);
    final meta = [
      accountTypeLabel(l, book.accountType),
      book.isLiability
          ? '${l.accountOutstanding} ${money(-balance, book.currency)}'
          : balanceMoney(balance, book.currency),
    ].join(' · ');
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        child: Row(
          children: [
            PfIconTile(
              icon: accountTypeIcon(book.accountType),
              background: Color(book.colorValue),
              foreground: Colors.white,
              size: 40,
              iconSize: 18,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Padding(
                // Leaves room for the swap button over the divider.
                padding: const EdgeInsets.only(right: 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: pfText(12, weight: w800, color: c.sub),
                    ),
                    Text(
                      book.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: pfText(16, weight: w800, color: c.ink),
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
            ),
            Icon(LucideIcons.chevronDown, size: 19, color: c.sub),
          ],
        ),
      ),
    );
  }
}

/// Both amounts for a transfer between currencies; nothing is converted.
class _CrossCurrencyCard extends StatelessWidget {
  const _CrossCurrencyCard({
    required this.from,
    required this.to,
    required this.controller,
    required this.sent,
    required this.onChanged,
  });

  final Currency from;
  final Currency to;
  final TextEditingController controller;
  final double sent;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final c = context.pf;
    final l = context.l10n;
    final arrived = _TransferFormScreenState._parse(controller.text);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: c.blue, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(LucideIcons.coins, size: 15, color: c.blue),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l.transferCrossTitle(from.code, to.code),
                  style: pfText(12.5, weight: w900, color: c.blue),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            l.transferCrossBody,
            style: pfText(12.5, weight: w700, color: c.sub, height: 1.45),
          ),
          const SizedBox(height: 10),
          Text(
            l.transferReceived(to.code),
            style: pfText(12, weight: w800, color: c.sub),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                to.symbol,
                style: pfText(20, weight: w900, color: c.sub),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [const AmountInputFormatter()],
                  onChanged: (_) => onChanged(),
                  style: pfText(26, weight: w900, color: c.blue),
                  decoration: InputDecoration(
                    hintText: '0',
                    hintStyle: pfText(26, weight: w900, color: c.mute),
                  ),
                ),
              ),
            ],
          ),
          Text(
            sent > 0 && arrived > 0
                ? l.transferRate(
                    from.code,
                    (arrived / sent).toStringAsFixed(2),
                    to.code,
                  )
                : l.transferRateNeeded,
            style: pfText(12, weight: w800, color: c.sub),
          ),
        ],
      ),
    );
  }
}

class _FeeField extends StatelessWidget {
  const _FeeField({
    required this.controller,
    required this.symbol,
    required this.onChanged,
  });

  final TextEditingController controller;
  final String symbol;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final c = context.pf;
    final l = context.l10n;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
      child: Row(
        children: [
          PfIconTile(
            icon: LucideIcons.receiptText,
            background: c.card2,
            foreground: c.ink,
            size: 36,
            radius: 12,
            iconSize: 17,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(text: l.transferFee),
                      TextSpan(
                        text: ' · ${l.optional}',
                        style: TextStyle(color: c.mute),
                      ),
                    ],
                  ),
                  style: pfText(12, weight: w800, color: c.sub),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      symbol,
                      style: pfText(16, weight: w800, color: c.sub),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: TextField(
                        controller: controller,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        inputFormatters: [const AmountInputFormatter()],
                        onChanged: (_) => onChanged(),
                        style: pfText(16, weight: w800, color: c.ink),
                        decoration: InputDecoration(
                          hintText: '0',
                          hintStyle: pfText(16, weight: w800, color: c.mute),
                        ),
                      ),
                    ),
                  ],
                ),
                Text(
                  l.transferFeeHint,
                  style: pfText(
                    11.5,
                    weight: w700,
                    color: c.mute,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
