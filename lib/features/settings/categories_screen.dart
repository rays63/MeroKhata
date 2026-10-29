import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../data/app_store.dart';
import '../../l10n/l10n.dart';
import '../../theme/tokens.dart';
import '../../widgets/category_icons.dart';
import '../../widgets/pf.dart';
import '../../widgets/store_sheets.dart';

/// Settings → Categories: each category opens to its subcategories, which
/// can be added, renamed (every entry follows), reordered and deleted
/// (entries move up to the parent).
class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  String? open;

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
            PfHeader(
              title: l.subTitle,
              actions: [
                PfIconButton(
                  icon: LucideIcons.pencil,
                  size: 18,
                  tooltip: l.editList,
                  onPressed: () => pickCategory(context, manageOnly: true),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                l.subIntro,
                style: pfText(13.5, weight: w700, color: c.sub, height: 1.45),
              ),
            ),
            const SizedBox(height: 14),
            for (final category in store.categories) ...[
              PfCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    InkWell(
                      onTap: () => setState(
                        () => open = open == category ? null : category,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        child: Row(
                          children: [
                            PfIconTile(
                              icon: categoryIcon(category),
                              background: c.card2,
                              foreground: c.ink,
                              size: 38,
                              iconSize: 17,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    category,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: pfText(15, weight: w800),
                                  ),
                                  Text(
                                    l.subCount(
                                      store.subcategoriesOf(category).length,
                                    ),
                                    style: pfText(
                                      12,
                                      weight: w700,
                                      color: c.sub,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              open == category
                                  ? LucideIcons.chevronUp
                                  : LucideIcons.chevronDown,
                              size: 19,
                              color: c.sub,
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (open == category) _SubList(category: category),
                  ],
                ),
              ),
              const SizedBox(height: 10),
            ],
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _SubList extends StatefulWidget {
  const _SubList({required this.category});

  final String category;

  @override
  State<_SubList> createState() => _SubListState();
}

class _SubListState extends State<_SubList> {
  final newSub = TextEditingController();

  @override
  void dispose() {
    newSub.dispose();
    super.dispose();
  }

  Future<void> _add() async {
    final store = AppScope.read(context);
    final name = newSub.text.trim();
    if (name.isEmpty) return;
    await store.addSubcategory(widget.category, name);
    newSub.clear();
    if (mounted) showPfToast(context, context.l10n.optionAdded(name));
  }

  Future<void> _rename(String from) async {
    final to = await showDialog<String>(
      context: context,
      builder: (_) => _RenameDialog(name: from),
    );
    if (to == null || !mounted) return;
    await AppScope.read(context).renameSubcategory(widget.category, from, to);
  }

  Future<void> _delete(String name) async {
    final store = AppScope.read(context);
    final c = context.pf;
    final l = context.l10n;
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l.subDeleteTitle(name), style: pfText(19, weight: w900)),
        content: Text(
          l.subDeleteBody(
            store.subcategoryCount(widget.category, name),
            widget.category,
          ),
          style: pfText(14, weight: w600, color: c.sub),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l.cancel, style: pfText(14, color: c.sub)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l.delete, style: pfText(14, color: c.cashOut)),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await store.deleteSubcategory(widget.category, name);
    if (mounted) showPfToast(context, l.optionRemoved(name));
  }

  @override
  Widget build(BuildContext context) {
    final store = AppScope.watch(context);
    final c = context.pf;
    final l = context.l10n;
    final subs = store.subcategoriesOf(widget.category);
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const PfDivider(),
          if (subs.isEmpty)
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l.subNoneTitle, style: pfText(14, weight: w900)),
                  Text(
                    l.subNoneBody,
                    style: pfText(12.5, weight: w700, color: c.sub),
                  ),
                ],
              ),
            ),
          for (final (i, sub) in subs.indexed)
            Row(
              children: [
                IconButton(
                  tooltip: l.subMoveUp(sub),
                  visualDensity: VisualDensity.compact,
                  onPressed: i == 0
                      ? null
                      : () => store.moveSubcategory(widget.category, i, i - 1),
                  icon: const Icon(LucideIcons.chevronUp, size: 16),
                ),
                IconButton(
                  tooltip: l.subMoveDown(sub),
                  visualDensity: VisualDensity.compact,
                  onPressed: i == subs.length - 1
                      ? null
                      : () => store.moveSubcategory(widget.category, i, i + 1),
                  icon: const Icon(LucideIcons.chevronDown, size: 16),
                ),
                Text(
                  '› ',
                  style: pfText(15, weight: w900, color: c.sub),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        sub,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: pfText(14.5, weight: w800),
                      ),
                      Text(
                        l.subEntryUses(
                          store.subcategoryCount(widget.category, sub),
                        ),
                        style: pfText(11.5, weight: w700, color: c.sub),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: l.subRename(sub),
                  onPressed: () => _rename(sub),
                  icon: Icon(LucideIcons.pencil, size: 16, color: c.sub),
                ),
                IconButton(
                  tooltip: l.deleteOption(sub),
                  onPressed: () => _delete(sub),
                  icon: Icon(LucideIcons.trash2, size: 16, color: c.cashOut),
                ),
              ],
            ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 46,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  alignment: Alignment.centerLeft,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: c.line, width: 1.5),
                  ),
                  child: TextField(
                    controller: newSub,
                    textCapitalization: TextCapitalization.sentences,
                    onSubmitted: (_) => _add(),
                    style: pfText(14.5, weight: w800, color: c.ink),
                    decoration: InputDecoration(
                      hintText: l.subNewHint(widget.category),
                      hintStyle: pfText(14.5, weight: w800, color: c.mute),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              PfSmallButton(
                label: l.add,
                height: 46,
                radius: 14,
                onPressed: _add,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(LucideIcons.info, size: 14, color: c.sub),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  l.subDeleteNote(widget.category),
                  style: pfText(12, weight: w700, color: c.sub),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RenameDialog extends StatefulWidget {
  const _RenameDialog({required this.name});

  final String name;

  @override
  State<_RenameDialog> createState() => _RenameDialogState();
}

class _RenameDialogState extends State<_RenameDialog> {
  late final controller = TextEditingController(text: widget.name);

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.pf;
    final l = context.l10n;
    return AlertDialog(
      title: Text(l.subRename(widget.name), style: pfText(19, weight: w900)),
      content: TextField(
        controller: controller,
        autofocus: true,
        onSubmitted: (v) => Navigator.pop(context, v),
        style: pfText(16, weight: w800, color: c.ink),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l.cancel, style: pfText(14, color: c.sub)),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, controller.text),
          child: Text(l.save, style: pfText(14, color: c.cashIn)),
        ),
      ],
    );
  }
}
