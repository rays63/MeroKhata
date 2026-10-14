import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/format.dart';
import '../../data/app_store.dart';
import '../../data/models.dart';
import '../../theme/tokens.dart';
import '../../widgets/pf.dart';
import '../../widgets/store_sheets.dart';
import 'book_detail_screen.dart';

/// New book (name, currency, opening balance) or rename an existing one.
class BookFormScreen extends StatefulWidget {
  const BookFormScreen({super.key, this.book});

  final LedgerBook? book;

  @override
  State<BookFormScreen> createState() => _BookFormScreenState();
}

class _BookFormScreenState extends State<BookFormScreen> {
  late final name = TextEditingController(text: widget.book?.name ?? '');
  final opening = TextEditingController();
  late String currency =
      widget.book?.currency ?? AppScope.read(context).defaultCurrency;
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
      showPfToast(context, 'Currency is fixed once a book has entries');
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
    );
    if (!mounted) return;
    final title = name.text.trim().isEmpty ? 'Untitled book' : name.text.trim();
    if (editing) {
      showPfToast(context, 'Book renamed');
      navigator.pop();
    } else {
      showPfToast(context, '“$title” created in $currency');
      navigator.pushReplacement(BookDetailScreen.route(id));
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.pf;
    final store = AppScope.watch(context);
    final info = Currency.of(currency);
    final locked = editing && store.entryCount(widget.book!.id) > 0;
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: pagePadding,
          children: [
            PfHeader(title: editing ? 'Rename book' : 'New book'),
            const SizedBox(height: 18),
            PfCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  PfField(
                    label: 'Book name',
                    child: TextField(
                      controller: name,
                      autofocus: !editing,
                      textCapitalization: TextCapitalization.words,
                      style: pfText(17, weight: w800, color: c.ink),
                      decoration: InputDecoration(
                        hintText: 'e.g. Kirana Pasal',
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
                                  'Currency',
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
                      label: 'Opening balance',
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
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                  RegExp(r'[\d.]'),
                                ),
                              ],
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
            const SizedBox(height: 18),
            const PfNote(
              icon: LucideIcons.info,
              text:
                  "A book's currency is fixed once it has entries. Use a separate book for each currency.",
            ),
            const SizedBox(height: 18),
            PfButton(
              label: editing ? 'Save changes' : 'Create book',
              onPressed: saving ? null : _save,
            ),
          ],
        ),
      ),
    );
  }
}
