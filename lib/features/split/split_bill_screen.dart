import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/amount_input.dart';
import '../../core/format.dart';
import '../../data/app_store.dart';
import '../../data/split.dart';
import '../../l10n/l10n.dart';
import '../../theme/tokens.dart';
import '../../widgets/pf.dart';
import 'split_widgets.dart';

/// Split one bill you paid between you and friends, equally or by shares.
class SplitBillScreen extends StatefulWidget {
  const SplitBillScreen({
    super.key,
    this.title,
    this.amount,
    this.linkedEntryId,
  });

  /// Prefill from an existing entry ("Split this bill with friends").
  final String? title;
  final double? amount;

  /// The entry already holds the cost, so nothing new is recorded.
  final String? linkedEntryId;

  @override
  State<SplitBillScreen> createState() => _SplitBillScreenState();
}

class _SplitBillScreenState extends State<SplitBillScreen> {
  late final title = TextEditingController(text: widget.title ?? '');
  late final amountField = TextEditingController(
    text: widget.amount == null ? '' : _plain(widget.amount!),
  );
  final Shares weights = {me: 1};
  bool byShares = false;

  /// Bills are kept in the home currency at the time they're made.
  late final String currency = AppScope.read(context).defaultCurrency;
  bool saving = false;

  static String _plain(double v) =>
      v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(2);

  double get amount =>
      double.tryParse(amountField.text.replaceAll(',', '').trim()) ?? 0;

  @override
  void dispose() {
    title.dispose();
    amountField.dispose();
    super.dispose();
  }

  void _toggle(String id) {
    if (id == me) return; // You paid, so you're always part of the bill.
    setState(() => weights[id] = (weights[id] ?? 0) > 0 ? 0 : 1);
  }

  Future<void> _addFriend() async {
    final id = await addFriendDialog(context);
    if (id != null) setState(() => weights[id] = 1);
  }

  Future<void> _save(int friends, double owed) async {
    if (saving) return;
    // You paid the bill: ask which book records it, unless it was split
    // from an entry that is already in a book.
    RecordChoice? record;
    if (widget.linkedEntryId == null) {
      final l = context.l10n;
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
    final store = AppScope.read(context);
    await store.saveBill(
      title: title.text,
      amount: amount,
      shares: SharesEditor.effective(weights, byShares),
      recordInBookId: record?.bookId,
      linkedEntryId: widget.linkedEntryId,
    );
    if (!mounted) return;
    showPfToast(
      context,
      context.l10n.splitBillSavedToast(friends, money(owed, currency)),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final store = AppScope.watch(context);
    final l = context.l10n;
    final c = context.pf;
    final ids = [me, ...store.friends.map((f) => f.id)];
    final shares = SharesEditor.effective(weights, byShares);
    final friends = shares.keys.where((id) => id != me).length;
    final owed = balancesFor(
      amount,
      me,
      shares,
    ).values.fold(0.0, (a, b) => a + b);
    final ready = amount > 0 && friends > 0;
    final cta = amount <= 0
        ? l.splitEnterTotal
        : friends == 0
        ? l.splitPickFriend
        : l.splitSaveCta(friends, money(owed, currency));

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: pagePadding,
          children: [
            PfHeader(title: l.splitABill, close: true),
            const SizedBox(height: 16),
            PfCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  PfField(
                    label: l.splitWhatFor,
                    child: TextField(
                      controller: title,
                      autofocus: widget.title == null,
                      textCapitalization: TextCapitalization.sentences,
                      style: pfText(17, color: c.ink),
                      decoration: InputDecoration(
                        hintText: l.splitBillHint,
                        hintStyle: pfText(17, color: c.mute),
                      ),
                    ),
                  ),
                  const PfDivider(),
                  PfField(
                    label: l.splitTotalPaidByYou,
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
                            onChanged: (_) => setState(() {}),
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
            PfSectionLabel(l.splitBetween),
            const SizedBox(height: 10),
            PeoplePicker(
              ids: ids,
              isSelected: (id) => (weights[id] ?? 0) > 0,
              onTap: _toggle,
              onAdd: _addFriend,
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
            const SizedBox(height: 16),
            if (widget.linkedEntryId != null) ...[
              PfNote(icon: LucideIcons.link, text: l.splitLinkedNote),
              const SizedBox(height: 16),
            ],
            PfButton(
              label: cta,
              fontSize: 16,
              onPressed: ready && !saving ? () => _save(friends, owed) : null,
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
