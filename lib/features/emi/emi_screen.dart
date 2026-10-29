import 'dart:math';

import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/amount_input.dart';
import '../../core/format.dart';
import '../../data/app_store.dart';
import '../../data/models.dart';
import '../../l10n/l10n.dart';
import '../../theme/tokens.dart';
import '../../widgets/account_type.dart';
import '../../widgets/option_sheet.dart';
import '../../widgets/pf.dart';

/// Monthly instalment (EMI) on a reducing balance: [principal] over
/// [months] at [yearlyRate] percent a year.
double emiFor(double principal, double yearlyRate, int months) {
  if (months <= 0) return 0;
  final i = yearlyRate / 1200;
  if (i == 0) return principal / months;
  final f = pow(1 + i, months);
  return principal * i * f / (f - 1);
}

/// One month of a repayment schedule.
typedef EmiMonth = ({
  int month,
  double principal,
  double interest,
  double balance,
});

List<EmiMonth> emiSchedule(double principal, double yearlyRate, int months) {
  final emi = emiFor(principal, yearlyRate, months);
  final i = yearlyRate / 1200;
  var balance = principal;
  return [
    for (var m = 1; m <= months; m++)
      () {
        final interest = balance * i;
        // The last payment clears what rounding left over.
        final paid = m == months ? balance : emi - interest;
        balance = max(0, balance - paid);
        return (
          month: m,
          principal: paid,
          interest: interest,
          balance: balance,
        );
      }(),
  ];
}

/// EMI calculator for a Loan account; can set the EMI up as a monthly
/// transfer the user confirms each time.
class EmiScreen extends StatefulWidget {
  const EmiScreen({super.key, required this.loanId});

  final String loanId;

  @override
  State<EmiScreen> createState() => _EmiScreenState();
}

class _EmiScreenState extends State<EmiScreen> {
  late final store = AppScope.read(context);
  late final owed = max(0.0, -store.balanceFor(widget.loanId));
  late final principal = TextEditingController(
    text: owed > 0 ? _plain(owed) : '',
  );
  final rate = TextEditingController(text: '12');
  final years = TextEditingController(text: '2');
  late String? fromId = _defaultFrom();
  bool repeat = true;

  static String _plain(double v) =>
      v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(2);

  static double _num(TextEditingController c) =>
      double.tryParse(c.text.replaceAll(',', '').trim()) ?? 0;

  String? _defaultFrom() {
    final loan = store.bookById(widget.loanId);
    final options = _payFromOptions(loan?.currency);
    final bank = options.where((b) => b.accountType == AccountType.bank);
    return (bank.firstOrNull ?? options.firstOrNull)?.id;
  }

  List<LedgerBook> _payFromOptions(String? currency) => [
    for (final b in store.booksByRecent)
      if (b.id != widget.loanId && !b.isLiability && b.currency == currency) b,
  ];

  @override
  void dispose() {
    principal.dispose();
    rate.dispose();
    years.dispose();
    super.dispose();
  }

  Future<void> _pickFrom() async {
    final loan = store.bookById(widget.loanId);
    final picked = await showOptionSheet<String>(
      context,
      title: context.l10n.transferFrom,
      selected: fromId,
      options: () => [
        for (final b in _payFromOptions(loan?.currency))
          SheetOption(b.id, b.name, accountTypeIcon(b.accountType)),
      ],
    );
    if (picked != null) setState(() => fromId = picked);
  }

  Future<void> _save(double emi, int day) async {
    final l = context.l10n;
    final loan = store.bookById(widget.loanId)!;
    if (!repeat || fromId == null) {
      Navigator.pop(context);
      return;
    }
    final now = DateTime.now();
    final first = DateTime(now.year, now.month + 1, 1);
    final last = DateTime(first.year, first.month + 1, 0).day;
    await store.addRecurring(
      RecurringEntry(
        id: '',
        repeat: Repeat.monthly,
        nextDue: DateTime(first.year, first.month, min(day, last), 10),
        title: 'EMI · ${loan.name}',
        type: TransactionType.cashOut,
        amount: (emi * 100).roundToDouble() / 100,
        category: 'Transfer',
        paymentMode: '',
        bookId: fromId!,
        toBookId: loan.id,
        anchorDay: day,
      ),
    );
    if (!mounted) return;
    showPfToast(context, l.emiSaved);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.pf;
    final l = context.l10n;
    final loan = store.bookById(widget.loanId);
    if (loan == null) return const Scaffold();
    final cur = loan.currency;
    final p = _num(principal);
    final r = _num(rate);
    final months = (_num(years) * 12).round();
    final error = p <= 0
        ? l.emiErrAmount
        : months < 1
        ? l.emiErrTenure
        : r < 0 || r > 60
        ? l.emiErrRate
        : null;
    final emi = error == null ? emiFor(p, r, months) : 0.0;
    final schedule = error == null ? emiSchedule(p, r, months) : <EmiMonth>[];
    final interest = schedule.fold(0.0, (s, m) => s + m.interest);
    final shownRows = schedule.length <= 5
        ? schedule
        : [...schedule.take(3), ...schedule.skip(schedule.length - 2)];
    final from = fromId == null ? null : store.bookById(fromId!);
    final day = DateTime.now().day;

    Widget chips(List<(String, VoidCallback)> items) => Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        for (final (label, onTap) in items)
          ActionChip(
            label: Text(
              label,
              style: pfText(12.5, weight: w800, color: c.ink),
            ),
            backgroundColor: c.card2,
            side: BorderSide.none,
            shape: const StadiumBorder(),
            onPressed: onTap,
          ),
      ],
    );

    Widget numberField(TextEditingController ctl, {String? suffix}) => Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Expanded(
          child: TextField(
            controller: ctl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [const AmountInputFormatter()],
            onChanged: (_) => setState(() {}),
            style: pfText(18, weight: w900, color: c.ink),
            decoration: InputDecoration(
              hintText: '0',
              hintStyle: pfText(18, weight: w900, color: c.mute),
            ),
          ),
        ),
        if (suffix != null)
          Text(
            suffix,
            style: pfText(13, weight: w800, color: c.sub),
          ),
      ],
    );

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: pagePadding,
          children: [
            PfHeader(
              title: l.emiTitle,
              subtitle: l.emiOutstanding(loan.name, money(owed, cur)),
            ),
            const SizedBox(height: 16),
            PfCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  PfField(
                    label: l.emiPrincipal,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        numberField(principal),
                        if (owed > 0)
                          chips([
                            (
                              l.emiUseOutstanding(money(owed, cur)),
                              () =>
                                  setState(() => principal.text = _plain(owed)),
                            ),
                          ]),
                      ],
                    ),
                  ),
                  const PfDivider(),
                  PfField(
                    label: l.emiRate,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        numberField(rate, suffix: '%'),
                        chips([
                          for (final v in ['9.5', '12', '14.5'])
                            ('$v%', () => setState(() => rate.text = v)),
                        ]),
                      ],
                    ),
                  ),
                  const PfDivider(),
                  PfField(
                    label: l.emiTenure,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        numberField(years, suffix: l.emiYears(months)),
                        chips([
                          for (final v in [1, 2, 3, 5])
                            (
                              l.emiYearsChip(v),
                              () => setState(() => years.text = '$v'),
                            ),
                        ]),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            if (error != null)
              PfErrorBanner(error)
            else ...[
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: c.hero,
                  borderRadius: BorderRadius.circular(26),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l.emiMonthly(months),
                      style: pfText(
                        13,
                        weight: w800,
                        color: PfColors.heroLabel,
                      ),
                    ),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        money(emi, cur),
                        style: pfText(34, weight: w900, color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        for (final (label, value) in [
                          (l.emiTotalInterest, interest),
                          (l.emiTotalPayable, p + interest),
                        ])
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  label,
                                  style: pfText(
                                    12,
                                    weight: w800,
                                    color: PfColors.heroLabel,
                                  ),
                                ),
                                Text(
                                  money(value, cur),
                                  style: pfText(
                                    15.5,
                                    weight: w900,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              PfCard(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
                child: Column(
                  children: [
                    _ScheduleRow(
                      cells: [
                        l.emiMonth,
                        l.emiPrincipalCol,
                        l.emiInterestCol,
                        l.emiBalanceCol,
                      ],
                      header: true,
                    ),
                    for (var i = 0; i < shownRows.length; i++) ...[
                      if (i == 3 && schedule.length > 5)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Text('⋯', style: pfText(14, color: c.mute)),
                        ),
                      _ScheduleRow(
                        cells: [
                          '${shownRows[i].month}',
                          money(shownRows[i].principal, cur),
                          money(shownRows[i].interest, cur),
                          money(shownRows[i].balance, cur),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 14),
              PfCard(
                child: Column(
                  children: [
                    if (from == null)
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          l.emiNoFrom,
                          style: pfText(13.5, weight: w700, color: c.sub),
                        ),
                      )
                    else
                      PfPickerRow(
                        icon: accountTypeIcon(from.accountType),
                        label: l.emiPayFrom(day),
                        value: from.name,
                        onTap: _pickFrom,
                      ),
                    const PfDivider(),
                    SwitchListTile(
                      value: repeat && from != null,
                      onChanged: from == null
                          ? null
                          : (v) => setState(() => repeat = v),
                      secondary: Icon(LucideIcons.repeat, color: c.ink),
                      title: Text(
                        l.emiRepeat,
                        style: pfText(14.5, weight: w800),
                      ),
                      subtitle: Text(
                        l.emiRepeatBody,
                        style: pfText(12, weight: w700, color: c.sub),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              PfButton(
                label: repeat && from != null
                    ? l.emiSetUp(money(emi, cur))
                    : l.emiDone,
                icon: LucideIcons.calendarCheck,
                onPressed: () => _save(emi, day),
              ),
              const SizedBox(height: 10),
              Text(
                l.emiNote,
                style: pfText(12, weight: w700, color: c.mute, height: 1.45),
              ),
            ],
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _ScheduleRow extends StatelessWidget {
  const _ScheduleRow({required this.cells, this.header = false});

  final List<String> cells;
  final bool header;

  @override
  Widget build(BuildContext context) {
    final c = context.pf;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          for (var i = 0; i < cells.length; i++)
            Expanded(
              flex: i == 0 ? 2 : 4,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: i == 0
                    ? Alignment.centerLeft
                    : Alignment.centerRight,
                child: Text(
                  cells[i],
                  style: header
                      ? pfText(
                          10.5,
                          weight: w900,
                          color: c.sub,
                          letterSpacing: .4,
                        )
                      : pfText(12.5, weight: w800),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
