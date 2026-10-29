import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../app/nav.dart';
import '../../core/format.dart';
import '../../data/app_store.dart';
import '../../data/models.dart';
import '../../l10n/l10n.dart';
import '../../theme/tokens.dart';
import '../../widgets/category_icons.dart';
import '../../widgets/pf.dart';
import '../../widgets/tags.dart';

/// Saved entries: rename, use (opens a filled form) or delete.
class TemplatesScreen extends StatelessWidget {
  const TemplatesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = AppScope.watch(context);
    final c = context.pf;
    final l = context.l10n;
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: pagePadding,
          children: [
            PfHeader(title: l.templates),
            const SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                l.templatesHint,
                style: pfText(13.5, weight: w700, color: c.sub, height: 1.45),
              ),
            ),
            const SizedBox(height: 14),
            if (store.templates.isEmpty)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 26,
                ),
                decoration: BoxDecoration(
                  color: c.card,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    PfIconTile(
                      icon: LucideIcons.star,
                      background: c.goldSoft,
                      foreground: c.gold,
                      size: 52,
                      radius: 18,
                      iconSize: 24,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      l.templatesEmptyTitle,
                      style: pfText(17, weight: w900),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      l.templatesEmptyBody,
                      style: pfText(
                        14,
                        weight: w600,
                        color: c.sub,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 12),
                    PfSmallButton(
                      label: l.templatesNewCashOut,
                      height: 42,
                      radius: 14,
                      background: c.soft,
                      foreground: c.cashIn,
                      onPressed: () =>
                          openNewEntry(context, type: TransactionType.cashOut),
                    ),
                  ],
                ),
              )
            else
              PfCard(
                child: Column(
                  children: [
                    for (var i = 0; i < store.templates.length; i++) ...[
                      if (i > 0) const PfDivider(),
                      _TemplateTile(
                        key: ValueKey(store.templates[i].id),
                        template: store.templates[i],
                        currency:
                            store
                                .bookById(store.templates[i].bookId)
                                ?.currency ??
                            store.defaultCurrency,
                      ),
                    ],
                  ],
                ),
              ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _TemplateTile extends StatefulWidget {
  const _TemplateTile({
    super.key,
    required this.template,
    required this.currency,
  });

  final EntryTemplate template;
  final String currency;

  @override
  State<_TemplateTile> createState() => _TemplateTileState();
}

class _TemplateTileState extends State<_TemplateTile> {
  late final title = TextEditingController(text: widget.template.title);
  final focus = FocusNode();

  @override
  void initState() {
    super.initState();
    focus.addListener(() {
      if (!focus.hasFocus) {
        AppScope.read(context).renameTemplate(widget.template.id, title.text);
      }
    });
  }

  @override
  void dispose() {
    title.dispose();
    focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final store = AppScope.watch(context);
    final c = context.pf;
    final l = context.l10n;
    final t = widget.template;
    final isIn = t.type == TransactionType.cashIn;
    final color = c.amount(isIn);
    final meta = [
      t.category,
      if (t.paymentMode.isNotEmpty) t.paymentMode,
      ?store.bookById(t.bookId)?.name,
      ...t.tags.map(tagLabel),
    ].join(' · ');
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
      child: Row(
        children: [
          PfIconTile(
            icon: entryIcon(t.category),
            background: c.amountSoft(isIn),
            foreground: color,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: title,
                  focusNode: focus,
                  onSubmitted: (_) => focus.unfocus(),
                  style: pfText(15.5, weight: w800, color: c.ink),
                  decoration: const InputDecoration(isDense: true),
                ),
                Text(
                  meta,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: pfText(12, weight: w700, color: c.sub),
                ),
                Text(
                  signedMoney(isIn ? t.amount : -t.amount, widget.currency),
                  style: pfText(13.5, weight: w900, color: color),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          PfSmallButton(
            label: l.templateUse,
            height: 38,
            radius: 12,
            fontSize: 13,
            background: c.soft,
            foreground: c.cashIn,
            onPressed: () => openTemplate(context, t),
          ),
          const SizedBox(width: 6),
          PfIconButton(
            icon: LucideIcons.trash2,
            tooltip: l.templateDelete(t.title),
            size: 16,
            background: c.outSoft,
            foreground: c.cashOut,
            onPressed: () async {
              await store.deleteTemplate(t.id);
              if (context.mounted) showPfToast(context, l.templateDeleted);
            },
          ),
        ],
      ),
    );
  }
}
