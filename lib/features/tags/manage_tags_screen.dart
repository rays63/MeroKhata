import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../app/nav.dart';
import '../../data/app_store.dart';
import '../../data/models.dart';
import '../../l10n/l10n.dart';
import '../../theme/tokens.dart';
import '../../widgets/option_sheet.dart';
import '../../widgets/pf.dart';
import '../../widgets/tags.dart';

/// Rename, merge and delete tags; renaming updates every entry.
class ManageTagsScreen extends StatefulWidget {
  const ManageTagsScreen({super.key});

  @override
  State<ManageTagsScreen> createState() => _ManageTagsScreenState();
}

class _ManageTagsScreenState extends State<ManageTagsScreen> {
  final newTag = TextEditingController();

  @override
  void dispose() {
    newTag.dispose();
    super.dispose();
  }

  Future<void> _add() async {
    final name = await AppScope.read(context).addTag(newTag.text);
    if (name.isEmpty || !mounted) return;
    newTag.clear();
    showPfToast(context, context.l10n.optionAdded(tagLabel(name)));
  }

  @override
  Widget build(BuildContext context) {
    final store = AppScope.watch(context);
    final c = context.pf;
    final l = context.l10n;
    final tags = store.allTags;
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: pagePadding,
          children: [
            PfHeader(title: l.tags),
            const SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                l.tagsHint,
                style: pfText(13.5, weight: w700, color: c.sub, height: 1.45),
              ),
            ),
            const SizedBox(height: 14),
            if (tags.isEmpty)
              PfEmptyCard(
                icon: LucideIcons.hash,
                title: l.tags,
                body: l.tagsEmpty,
              )
            else
              PfCard(
                child: Column(
                  children: [
                    for (var i = 0; i < tags.length; i++) ...[
                      if (i > 0) const PfDivider(),
                      _TagRow(
                        key: ValueKey(tags[i].$1),
                        tag: tags[i].$1,
                        count: tags[i].$2,
                      ),
                    ],
                  ],
                ),
              ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 50,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: c.card,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Icon(LucideIcons.hash, size: 18, color: c.tag),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: newTag,
                            onSubmitted: (_) => _add(),
                            style: pfText(15, weight: w800, color: c.ink),
                            decoration: InputDecoration(
                              hintText: l.tagNew,
                              hintStyle: pfText(
                                15,
                                weight: w800,
                                color: c.mute,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                PfSmallButton(
                  label: l.add,
                  height: 50,
                  radius: 16,
                  fontSize: 15,
                  onPressed: _add,
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _TagRow extends StatefulWidget {
  const _TagRow({super.key, required this.tag, required this.count});

  final String tag;
  final int count;

  @override
  State<_TagRow> createState() => _TagRowState();
}

class _TagRowState extends State<_TagRow> {
  late final name = TextEditingController(text: widget.tag);
  final focus = FocusNode();

  @override
  void initState() {
    super.initState();
    focus.addListener(() {
      if (!focus.hasFocus) _rename();
    });
  }

  @override
  void dispose() {
    name.dispose();
    focus.dispose();
    super.dispose();
  }

  Future<void> _rename() async {
    final to = normalizeTag(name.text);
    if (to.isEmpty || to == widget.tag) {
      name.text = widget.tag;
      return;
    }
    final messenger = context;
    await AppScope.read(context).renameTag(widget.tag, to);
    if (messenger.mounted) {
      showPfToast(messenger, messenger.l10n.tagRenamed(to));
    }
  }

  Future<void> _merge() async {
    final store = AppScope.read(context);
    final l = context.l10n;
    final into = await showOptionSheet<String>(
      context,
      title: l.tagMergeTitle(widget.tag),
      selected: null,
      options: () => [
        for (final (tag, _) in store.allTags)
          if (tag != widget.tag)
            SheetOption(tag, tagLabel(tag), LucideIcons.hash),
      ],
    );
    if (into == null || !mounted) return;
    await store.mergeTag(widget.tag, into);
    if (mounted) showPfToast(context, l.tagMerged(widget.tag, into));
  }

  Future<void> _delete() async {
    final store = AppScope.read(context);
    final c = context.pf;
    final l = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          l.tagDeleteTitle(widget.tag),
          style: pfText(19, weight: w900),
        ),
        content: Text(
          l.tagDeleteBody(widget.count),
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
    if (confirmed != true || !mounted) return;
    await store.deleteTag(widget.tag);
    if (mounted) showPfToast(context, l.tagDeleted(widget.tag));
  }

  @override
  Widget build(BuildContext context) {
    final c = context.pf;
    final l = context.l10n;
    final canMerge = AppScope.watch(context).allTags.length > 1;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
      child: Row(
        children: [
          Text(
            '#',
            style: pfText(18, weight: w900, color: c.tag),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: name,
                  focusNode: focus,
                  onSubmitted: (_) => focus.unfocus(),
                  style: pfText(15.5, weight: w800, color: c.ink),
                  decoration: const InputDecoration(isDense: true),
                ),
                Text(
                  l.entryCount(widget.count),
                  style: pfText(12, weight: w700, color: c.sub),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: l.tagOpenSummary(widget.tag),
            onPressed: () => openTag(context, widget.tag),
            icon: Icon(LucideIcons.chartNoAxesColumn, size: 18, color: c.sub),
          ),
          if (canMerge)
            IconButton(
              tooltip: l.tagMerge(widget.tag),
              onPressed: _merge,
              icon: Icon(LucideIcons.merge, size: 18, color: c.sub),
            ),
          IconButton(
            tooltip: l.tagDeleteAction(widget.tag),
            onPressed: _delete,
            icon: Icon(LucideIcons.trash2, size: 18, color: c.cashOut),
          ),
        ],
      ),
    );
  }
}

/// Asks for a new name; returns it once saved, or null.
Future<String?> renameTagDialog(BuildContext context, String tag) async {
  final name = await showDialog<String>(
    context: context,
    builder: (_) => _RenameDialog(tag: tag),
  );
  if (name == null || !context.mounted) return null;
  final to = normalizeTag(name);
  if (to.isEmpty || to == tag) return null;
  await AppScope.read(context).renameTag(tag, to);
  if (context.mounted) showPfToast(context, context.l10n.tagRenamed(to));
  return to;
}

class _RenameDialog extends StatefulWidget {
  const _RenameDialog({required this.tag});

  final String tag;

  @override
  State<_RenameDialog> createState() => _RenameDialogState();
}

class _RenameDialogState extends State<_RenameDialog> {
  late final name = TextEditingController(text: widget.tag);

  @override
  void dispose() {
    name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.pf;
    final l = context.l10n;
    return AlertDialog(
      title: Text(
        l.tagRenameTitle(widget.tag),
        style: pfText(19, weight: w900),
      ),
      content: TextField(
        controller: name,
        autofocus: true,
        onSubmitted: (value) => Navigator.pop(context, value),
        style: pfText(16, weight: w800, color: c.ink),
        decoration: InputDecoration(
          prefixText: '#',
          prefixStyle: pfText(16, weight: w900, color: c.tag),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l.cancel, style: pfText(14, color: c.sub)),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, name.text),
          child: Text(l.save, style: pfText(14, color: c.cashIn)),
        ),
      ],
    );
  }
}
