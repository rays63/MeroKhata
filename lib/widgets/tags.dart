import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../app/nav.dart';
import '../data/app_store.dart';
import '../data/models.dart';
import '../l10n/l10n.dart';
import '../theme/tokens.dart';
import 'pf.dart';

String tagLabel(String tag) => '#$tag';

/// "#japan-trip" or "#japan-trip +1" for a row's subtitle.
String? rowTagLabel(List<String> tags) => tags.isEmpty
    ? null
    : tags.length == 1
    ? tagLabel(tags.first)
    : '${tagLabel(tags.first)} +${tags.length - 1}';

/// A purple tag pill; tappable when [onTap] is set, removable with
/// [onRemove].
class TagChip extends StatelessWidget {
  const TagChip({super.key, required this.tag, this.onTap, this.onRemove});

  final String tag;
  final VoidCallback? onTap;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final c = context.pf;
    final removable = onRemove != null;
    return Material(
      color: c.tagSoft,
      borderRadius: BorderRadius.circular(99),
      child: InkWell(
        borderRadius: BorderRadius.circular(99),
        onTap: onTap,
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: removable ? 36 : 30),
          child: Padding(
            padding: EdgeInsets.fromLTRB(12, 4, removable ? 4 : 12, 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    tagLabel(tag),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: pfText(13, weight: w800, color: c.tag),
                  ),
                ),
                if (removable)
                  IconButton(
                    onPressed: onRemove,
                    tooltip: context.l10n.tagRemove(tag),
                    visualDensity: VisualDensity.compact,
                    constraints: const BoxConstraints(
                      minWidth: 28,
                      minHeight: 28,
                    ),
                    padding: EdgeInsets.zero,
                    icon: Icon(LucideIcons.x, size: 14, color: c.tag),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// "Tags · optional" with the chosen tags and an "Add tag" button, for the
/// entry and transfer forms.
class TagField extends StatelessWidget {
  const TagField({super.key, required this.tags, required this.onChanged});

  final List<String> tags;
  final ValueChanged<List<String>> onChanged;

  @override
  Widget build(BuildContext context) {
    final c = context.pf;
    final l = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PfSectionLabel(l.tags, optional: true),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final tag in tags)
              TagChip(
                tag: tag,
                onRemove: () => onChanged([...tags]..remove(tag)),
              ),
            Semantics(
              container: true,
              button: true,
              child: Material(
                color: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(99),
                  side: BorderSide(color: c.line, width: 1.5),
                ),
                child: InkWell(
                  customBorder: const StadiumBorder(),
                  onTap: () async {
                    // Otherwise the keyboard reopens on the last field when
                    // the sheet closes.
                    FocusScope.of(context).unfocus();
                    final picked = await showTagPicker(context, selected: tags);
                    if (picked != null) onChanged(picked);
                  },
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(minHeight: 36),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(LucideIcons.hash, size: 14, color: c.sub),
                          const SizedBox(width: 6),
                          Text(
                            l.tagAdd,
                            style: pfText(13, weight: w800, color: c.sub),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Pick several tags: search, create a new one, or tick ones used before.
/// Returns the new selection, or null if dismissed.
Future<List<String>?> showTagPicker(
  BuildContext context, {
  required List<String> selected,
}) => showModalBottomSheet<List<String>>(
  context: context,
  isScrollControlled: true,
  useSafeArea: true,
  builder: (_) => _TagPicker(selected: selected),
);

class _TagPicker extends StatefulWidget {
  const _TagPicker({required this.selected});

  final List<String> selected;

  @override
  State<_TagPicker> createState() => _TagPickerState();
}

class _TagPickerState extends State<_TagPicker> {
  late final List<String> chosen = [...widget.selected];
  final query = TextEditingController();

  @override
  void dispose() {
    query.dispose();
    super.dispose();
  }

  void _toggle(String tag) => setState(() {
    if (!chosen.remove(tag)) chosen.add(tag);
  });

  void _create(String name) => setState(() {
    if (!chosen.contains(name)) chosen.add(name);
    query.clear();
  });

  @override
  Widget build(BuildContext context) {
    final store = AppScope.watch(context);
    final c = context.pf;
    final l = context.l10n;
    final typed = normalizeTag(query.text);
    final all = store.allTags;
    final known = {for (final (tag, _) in all) tag, ...chosen};
    final matches = [
      for (final (tag, count) in all)
        if (typed.isEmpty || tag.contains(typed)) (tag, count),
      for (final tag in chosen)
        if (!all.any((e) => e.$1 == tag) &&
            (typed.isEmpty || tag.contains(typed)))
          (tag, 0),
    ];
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * .8,
      ),
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 10),
            Center(
              child: Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: c.line,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
              child: Text(l.tags, style: pfText(19, weight: w900)),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                height: 50,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: c.card2,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Icon(LucideIcons.hash, size: 18, color: c.tag),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: query,
                        autofocus: all.isEmpty,
                        onChanged: (_) => setState(() {}),
                        onSubmitted: (_) {
                          if (typed.isNotEmpty) _create(typed);
                        },
                        style: pfText(15.5, weight: w800, color: c.ink),
                        decoration: InputDecoration(
                          hintText: l.tagSearchHint,
                          hintStyle: pfText(15.5, weight: w800, color: c.mute),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (typed.isNotEmpty && !known.contains(typed))
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                child: Material(
                  color: c.tagSoft,
                  borderRadius: BorderRadius.circular(14),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () => _create(typed),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 13,
                      ),
                      child: Row(
                        children: [
                          Icon(LucideIcons.plus, size: 18, color: c.tag),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              l.tagCreate(typed),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: pfText(15, weight: w900, color: c.tag),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 14, 24, 4),
              child: Text(
                l.tagUsedBefore,
                style: pfText(12.5, weight: w800, color: c.sub),
              ),
            ),
            Flexible(
              child: matches.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.fromLTRB(24, 6, 24, 6),
                      child: Text(
                        l.tagNoneYet,
                        style: pfText(14, weight: w700, color: c.sub),
                      ),
                    )
                  : ListView(
                      shrinkWrap: true,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      children: [
                        for (final (tag, count) in matches)
                          _TagOption(
                            tag: tag,
                            meta: l.entryCount(count),
                            selected: chosen.contains(tag),
                            onTap: () => _toggle(tag),
                          ),
                      ],
                    ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
              child: Row(
                children: [
                  Expanded(
                    child: PfButton(
                      label: l.editList,
                      style: PfButtonStyle.neutral,
                      height: 50,
                      radius: 16,
                      fontSize: 15,
                      onPressed: () => openManageTags(context),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: PfButton(
                      label: l.done,
                      height: 50,
                      radius: 16,
                      fontSize: 15,
                      onPressed: () {
                        final pending =
                            typed.isNotEmpty && !known.contains(typed)
                            ? [...chosen, typed]
                            : chosen;
                        Navigator.pop(context, pending);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TagOption extends StatelessWidget {
  const _TagOption({
    required this.tag,
    required this.meta,
    required this.selected,
    required this.onTap,
  });

  final String tag;
  final String meta;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.pf;
    return Semantics(
      selected: selected,
      button: true,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tagLabel(tag),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: pfText(15, weight: w800, color: c.tag),
                    ),
                    Text(
                      meta,
                      style: pfText(12, weight: w700, color: c.sub),
                    ),
                  ],
                ),
              ),
              if (selected) Icon(LucideIcons.check, size: 20, color: c.tag),
            ],
          ),
        ),
      ),
    );
  }
}
