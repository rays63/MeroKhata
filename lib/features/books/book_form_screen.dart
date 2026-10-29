import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/amount_input.dart';
import '../../core/format.dart';
import '../../data/app_store.dart';
import '../../l10n/l10n.dart';
import '../../data/models.dart';
import '../../theme/tokens.dart';
import '../../widgets/account_type.dart';
import '../../widgets/pf.dart';
import '../../widgets/store_sheets.dart';
import 'book_detail_screen.dart';

/// New account (name, currency, opening balance, type) or edit an existing
/// one.
class BookFormScreen extends StatefulWidget {
  const BookFormScreen({
    super.key,
    this.book,
    this.initialCurrency,
    this.popWithId = false,
  });

  final LedgerBook? book;

  /// Currency a new book starts with (default: the app's default currency).
  final String? initialCurrency;

  /// Return the new book's id to the caller instead of opening the book.
  final bool popWithId;

  @override
  State<BookFormScreen> createState() => _BookFormScreenState();
}

class _BookFormScreenState extends State<BookFormScreen> {
  late final name = TextEditingController(text: widget.book?.name ?? '');
  final opening = TextEditingController();
  late String currency =
      widget.book?.currency ??
      widget.initialCurrency ??
      AppScope.read(context).defaultCurrency;
  late AccountType type = widget.book?.accountType ?? AccountType.cash;
  bool saving = false;

  bool get editing => widget.book != null;

  @override
  void dispose() {
    name.dispose();
    opening.dispose();
    super.dispose();
  }

  Future<void> _pickCurrency(bool locked) async {
    if (locked) {
      showPfToast(context, context.l10n.bookCurrencyLocked);
      return;
    }
    final picked = await pickCurrency(context, selected: currency);
    if (picked != null) setState(() => currency = picked);
  }

  Future<void> _save() async {
    if (saving) return;
    setState(() => saving = true);
    final store = AppScope.read(context);
    final navigator = Navigator.of(context);
    final id = await store.saveBook(
      id: widget.book?.id,
      name: name.text,
      currency: currency,
      openingBalance:
          double.tryParse(opening.text.replaceAll(',', '').trim()) ?? 0,
      type: type,
    );
    if (!mounted) return;
    final l = context.l10n;
    final title = name.text.trim().isEmpty ? l.bookUntitled : name.text.trim();
    if (editing) {
      showPfToast(context, l.bookRenamed);
      navigator.pop();
    } else {
      showPfToast(context, l.bookCreated(title, currency));
      if (widget.popWithId) {
        navigator.pop(id);
      } else {
        navigator.pushReplacement(BookDetailScreen.route(id));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.pf;
    final l = context.l10n;
    final store = AppScope.watch(context);
    final info = Currency.of(currency);
    final locked = editing && store.entryCount(widget.book!.id) > 0;
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: pagePadding,
          children: [
            PfHeader(title: editing ? l.bookRenameTitle : l.bookNew),
            const SizedBox(height: 18),
            if (editing && widget.book!.type == null) ...[
              _LegacyNote(text: l.accountLegacyNote),
              const SizedBox(height: 16),
            ],
            PfCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  PfField(
                    label: l.bookNameLabel,
                    child: TextField(
                      controller: name,
                      autofocus: !editing,
                      textCapitalization: TextCapitalization.words,
                      style: pfText(17, weight: w800, color: c.ink),
                      decoration: InputDecoration(
                        hintText: l.bookNameHint,
                        hintStyle: pfText(17, weight: w800, color: c.mute),
                      ),
                    ),
                  ),
                  const PfDivider(),
                  InkWell(
                    onTap: () => _pickCurrency(locked),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 14,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l.bookCurrencyLabel,
                                  style: pfText(12, color: c.sub),
                                ),
                                const SizedBox(height: 4),
                                Text(info.label, style: pfText(17)),
                              ],
                            ),
                          ),
                          Icon(
                            locked ? LucideIcons.lock : LucideIcons.chevronDown,
                            size: 20,
                            color: c.sub,
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (!editing) ...[
                    const PfDivider(),
                    PfField(
                      label: type.isLiability
                          ? l.accountAmountOwed
                          : l.bookOpeningBalance,
                      optional: true,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(info.symbol, style: pfText(17, color: c.sub)),
                          const SizedBox(width: 6),
                          Expanded(
                            child: TextField(
                              controller: opening,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              inputFormatters: [const AmountInputFormatter()],
                              style: pfText(17, color: c.ink),
                              decoration: InputDecoration(
                                hintText: '0',
                                hintStyle: pfText(17, color: c.mute),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                l.accountTypeLabel,
                style: pfText(13, weight: w800, color: c.sub),
              ),
            ),
            const SizedBox(height: 8),
            _TypeGrid(
              selected: type,
              onPick: (picked) => setState(() => type = picked),
            ),
            if (type.isLiability) ...[
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  l.accountLiabilityNote,
                  style: pfText(
                    12.5,
                    weight: w800,
                    color: c.cashOut,
                    height: 1.4,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 16),
            PfNote(icon: LucideIcons.info, text: l.bookCurrencyNote),
            const SizedBox(height: 18),
            PfButton(
              label: editing ? l.saveChanges : l.bookCreate,
              onPressed: saving ? null : _save,
            ),
          ],
        ),
      ),
    );
  }
}

class _TypeGrid extends StatelessWidget {
  const _TypeGrid({required this.selected, required this.onPick});

  final AccountType selected;
  final ValueChanged<AccountType> onPick;

  @override
  Widget build(BuildContext context) {
    final c = context.pf;
    final l = context.l10n;
    const columns = 4;
    const types = AccountType.values;
    final rows = <Widget>[];
    for (var start = 0; start < types.length; start += columns) {
      if (start > 0) rows.add(const SizedBox(height: 8));
      rows.add(
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = start; i < start + columns; i++) ...[
                if (i > start) const SizedBox(width: 8),
                Expanded(
                  child: i < types.length
                      ? _TypeTile(
                          type: types[i],
                          label: accountTypeLabel(l, types[i]),
                          selected: types[i] == selected,
                          colors: c,
                          onTap: () => onPick(types[i]),
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ],
          ),
        ),
      );
    }
    return Column(children: rows);
  }
}

class _TypeTile extends StatelessWidget {
  const _TypeTile({
    required this.type,
    required this.label,
    required this.selected,
    required this.colors,
    required this.onTap,
  });

  final AccountType type;
  final String label;
  final bool selected;
  final PfColors colors;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = colors;
    final fg = selected ? c.cashIn : c.ink;
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      onTap: onTap,
      excludeSemantics: true,
      child: Material(
        color: selected ? c.soft : c.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: selected ? c.btn : c.line, width: 1.5),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 74),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(accountTypeIcon(type), size: 22, color: fg),
                  const SizedBox(height: 6),
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: pfText(12, weight: w800, color: fg),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LegacyNote extends StatelessWidget {
  const _LegacyNote({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final c = context.pf;
    final l = context.l10n;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: c.goldSoft,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(LucideIcons.shapes, size: 18, color: c.gold),
          const SizedBox(width: 10),
          Expanded(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: '${l.accountTypePrompt}. ',
                    style: pfText(13, weight: w900, color: c.ink),
                  ),
                  TextSpan(text: text),
                ],
              ),
              style: pfText(13, weight: w700, color: c.ink, height: 1.45),
            ),
          ),
        ],
      ),
    );
  }
}
