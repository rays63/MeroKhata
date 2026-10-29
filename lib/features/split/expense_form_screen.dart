import 'package:flutter/material.dart';

import '../../core/amount_input.dart';
import '../../core/format.dart';
import '../../data/app_store.dart';
import '../../data/split.dart';
import '../../l10n/l10n.dart';
import '../../theme/tokens.dart';
import '../../widgets/pf.dart';
import 'split_widgets.dart';

/// Add an expense to a group: what, how much, who paid, and how it's split.
class ExpenseFormScreen extends StatefulWidget {
  const ExpenseFormScreen({super.key, required this.groupId});

  final String groupId;

  @override
  State<ExpenseFormScreen> createState() => _ExpenseFormScreenState();
}

class _ExpenseFormScreenState extends State<ExpenseFormScreen> {
  final title = TextEditingController();
  final amountField = TextEditingController();
  String paidBy = me;
  late final Shares weights = {
    me: 1,
    for (final id in _group?.memberIds ?? const <String>[]) id: 1,
  };
  bool byShares = false;
  String? error;
  bool saving = false;

  SplitGroup? get _group => AppScope.read(
    context,
  ).groups.where((g) => g.id == widget.groupId).firstOrNull;

  double get amount =>
      double.tryParse(amountField.text.replaceAll(',', '').trim()) ?? 0;

  @override
  void dispose() {
    title.dispose();
    amountField.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final l = context.l10n;
    final shares = SharesEditor.effective(weights, byShares);
    final problem = amount <= 0
        ? l.expenseAmountRequired
        : shares.isEmpty
        ? l.expensePickSharers
        : (shares.length == 1 && shares.containsKey(paidBy))
        ? l.expenseNeedOther
        : null;
    if (problem != null) {
      setState(() => error = problem);
      return;
    }
    if (saving) return;
    // Money left your pocket: ask which book records it.
    RecordChoice? record;
    if (paidBy == me) {
      final currency =
          _group?.currency ?? AppScope.read(context).defaultCurrency;
      record = await showRecordBookSheet(
        context,
        title: l.splitRecordTitle,
        message: l.splitRecordPaidMessage(money(amount, currency)),
        currency: currency,
        cashIn: false,
      );
      if (record == null || !mounted) return;
    }
    setState(() => saving = true);
    await AppScope.read(context).addGroupExpense(
      groupId: widget.groupId,
      title: title.text,
      amount: amount,
      paidBy: paidBy,
      shares: shares,
      recordInBookId: record?.bookId,
    );
    if (!mounted) return;
    showPfToast(context, context.l10n.expenseAddedToast);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final store = AppScope.watch(context);
    final l = context.l10n;
    final c = context.pf;
    final group = store.groups.where((g) => g.id == widget.groupId).firstOrNull;
    if (group == null) {
      return Scaffold(
        body: SafeArea(
          child: Padding(
            padding: pagePadding,
            child: PfHeader(title: l.expenseAdd, close: true),
          ),
        ),
      );
    }
    final people = [me, ...group.memberIds];
    final currency = group.currency;
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: pagePadding,
          children: [
            PfHeader(title: l.expenseAdd, subtitle: group.name, close: true),
            const SizedBox(height: 16),
            PfCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  PfField(
                    label: l.splitWhatFor,
                    child: TextField(
                      controller: title,
                      autofocus: true,
                      textCapitalization: TextCapitalization.sentences,
                      style: pfText(17, color: c.ink),
                      decoration: InputDecoration(
                        hintText: l.expenseHint,
                        hintStyle: pfText(17, color: c.mute),
                      ),
                    ),
                  ),
                  const PfDivider(),
                  PfField(
                    label: l.expenseAmount,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          Currency.of(currency).symbol,
                          style: pfText(20, weight: w900, color: c.sub),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: TextField(
                            controller: amountField,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            inputFormatters: [const AmountInputFormatter()],
                            onChanged: (_) => setState(() => error = null),
                            style: pfText(30, weight: w900, color: c.ink),
                            decoration: InputDecoration(
                              hintText: '0',
                              hintStyle: pfText(
                                30,
                                weight: w900,
                                color: c.mute,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            PfSectionLabel(l.expensePaidBy),
            const SizedBox(height: 10),
            PeoplePicker(
              ids: people,
              isSelected: (id) => id == paidBy,
              onTap: (id) => setState(() {
                paidBy = id;
                error = null;
              }),
            ),
            const SizedBox(height: 16),
            PfSectionLabel(l.splitBetween),
            const SizedBox(height: 10),
            PeoplePicker(
              ids: people,
              isSelected: (id) => (weights[id] ?? 0) > 0,
              onTap: (id) => setState(() {
                weights[id] = (weights[id] ?? 0) > 0 ? 0 : 1;
                error = null;
              }),
            ),
            const SizedBox(height: 16),
            SharesEditor(
              amount: amount,
              currency: currency,
              weights: weights,
              byShares: byShares,
              onMethod: (value) => setState(() => byShares = value),
              onWeight: (id, weight) => setState(() => weights[id] = weight),
            ),
            if (error != null) ...[
              const SizedBox(height: 16),
              PfErrorBanner(error!),
            ],
            const SizedBox(height: 16),
            PfButton(label: l.expenseAdd, onPressed: saving ? null : _save),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
