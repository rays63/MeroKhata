import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/format.dart';
import '../../data/app_store.dart';
import '../../data/split.dart';
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
  bool record = true;
  late String? bookId = AppScope.read(
    context,
  ).defaultSplitBookId(_group?.currency);
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
    final shares = SharesEditor.effective(weights, byShares);
    final problem = amount <= 0
        ? 'Enter an amount greater than zero'
        : shares.isEmpty
        ? 'Pick who shares this expense'
        : (shares.length == 1 && shares.containsKey(paidBy))
        ? 'Add someone besides the payer to split with'
        : null;
    if (problem != null) {
      setState(() => error = problem);
      return;
    }
    if (saving) return;
    setState(() => saving = true);
    await AppScope.read(context).addGroupExpense(
      groupId: widget.groupId,
      title: title.text,
      amount: amount,
      paidBy: paidBy,
      shares: shares,
      recordInBookId: paidBy == me && record ? bookId : null,
    );
    if (!mounted) return;
    showPfToast(context, 'Expense added · balances updated');
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final store = AppScope.watch(context);
    final c = context.pf;
    final group = store.groups.where((g) => g.id == widget.groupId).firstOrNull;
    if (group == null) {
      return const Scaffold(
        body: SafeArea(
          child: Padding(
            padding: pagePadding,
            child: PfHeader(title: 'Add expense', close: true),
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
            PfHeader(title: 'Add expense', subtitle: group.name, close: true),
            const SizedBox(height: 16),
            PfCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  PfField(
                    label: "What's it for?",
                    child: TextField(
                      controller: title,
                      autofocus: true,
                      textCapitalization: TextCapitalization.sentences,
                      style: pfText(17, color: c.ink),
                      decoration: InputDecoration(
                        hintText: 'e.g. Hotel (2 nights)',
                        hintStyle: pfText(17, color: c.mute),
                      ),
                    ),
                  ),
                  const PfDivider(),
                  PfField(
                    label: 'Amount',
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
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'[\d.]'),
                              ),
                            ],
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
            const PfSectionLabel('Paid by'),
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
            const PfSectionLabel('Split between'),
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
            if (paidBy == me) ...[
              const SizedBox(height: 16),
              RecordToggle(
                on: record,
                amount: amount,
                currency: currency,
                bookId: bookId,
                onChanged: (value) => setState(() => record = value),
                onBook: (value) => setState(() => bookId = value),
              ),
            ],
            if (error != null) ...[
              const SizedBox(height: 16),
              PfErrorBanner(error!),
            ],
            const SizedBox(height: 16),
            PfButton(label: 'Add expense', onPressed: saving ? null : _save),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
