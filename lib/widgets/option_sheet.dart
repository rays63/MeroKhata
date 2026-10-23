import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../theme/tokens.dart';
import 'pf.dart';
import '../l10n/l10n.dart';

/// One choice in an [showOptionSheet].
class SheetOption<T> {
  const SheetOption(this.value, this.label, this.icon, {this.more = false});

  final T value;
  final String label;
  final IconData icon;

  /// Shows a "›": picking it opens a further list (e.g. subcategories).
  final bool more;
}

/// Callbacks that make a sheet's list editable ("Edit list").
class EditableList {
  const EditableList({
    required this.items,
    required this.onRename,
    required this.onAdd,
    required this.onRemove,
  });

  final List<String> Function() items;
  final Future<void> Function(String from, String to) onRename;
  final Future<void> Function(String value) onAdd;
  final Future<void> Function(String value) onRemove;
}

/// Bottom sheet listing options with the current one checked. When
/// [editable] is given, "Edit list" switches to rename/add/delete mode.
Future<T?> showOptionSheet<T>(
  BuildContext context, {
  required String title,
  required List<SheetOption<T>> Function() options,
  required T? selected,
  EditableList? editable,
  bool startInManage = false,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => _OptionSheet<T>(
      title: title,
      options: options,
      selected: selected,
      editable: editable,
      startInManage: startInManage,
    ),
  );
}

class _OptionSheet<T> extends StatefulWidget {
  const _OptionSheet({
    required this.title,
    required this.options,
    required this.selected,
    required this.editable,
    required this.startInManage,
  });

  final String title;
  final List<SheetOption<T>> Function() options;
  final T? selected;
  final EditableList? editable;
  final bool startInManage;

  @override
  State<_OptionSheet<T>> createState() => _OptionSheetState<T>();
}

class _OptionSheetState<T> extends State<_OptionSheet<T>> {
  late bool manage = widget.startInManage;
  final newOption = TextEditingController();

  @override
  void dispose() {
    newOption.dispose();
    super.dispose();
  }

  Future<void> _add() async {
    final value = newOption.text.trim();
    if (value.isEmpty) return;
    await widget.editable!.onAdd(value);
    newOption.clear();
    if (!mounted) return;
    setState(() {});
    showPfToastOverlay(context, context.l10n.optionAdded(value));
  }

  @override
  Widget build(BuildContext context) {
    final c = context.pf;
    final title = manage
        ? context.l10n.editListTitle(widget.title.toLowerCase())
        : widget.title;
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * .78,
      ),
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 36),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 5,
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: c.line,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(title, style: pfText(19, weight: w900)),
                    ),
                    if (widget.editable != null)
                      PfSmallButton(
                        label: manage
                            ? context.l10n.done
                            : context.l10n.editList,
                        icon: manage ? LucideIcons.check : LucideIcons.pencil,
                        onPressed: () => setState(() => manage = !manage),
                        height: 36,
                        radius: 12,
                        fontSize: 13,
                        background: c.card2,
                        foreground: c.ink,
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              if (!manage)
                for (final option in widget.options())
                  _OptionRow(
                    label: option.label,
                    icon: option.icon,
                    more: option.more,
                    selected: option.value == widget.selected,
                    onTap: () => Navigator.pop(context, option.value),
                  )
              else
                ..._manageRows(c),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _manageRows(PfColors c) {
    final editable = widget.editable!;
    final items = editable.items();
    return [
      for (final item in items)
        Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: _EditableRow(
            key: ValueKey(item),
            value: item,
            onRename: (to) async {
              await editable.onRename(item, to);
              if (mounted) setState(() {});
            },
            // Keep at least one option so the picker is never empty.
            onRemove: items.length < 2
                ? null
                : () async {
                    await editable.onRemove(item);
                    if (!mounted) return;
                    setState(() {});
                    showPfToastOverlay(
                      context,
                      context.l10n.optionRemoved(item),
                    );
                  },
          ),
        ),
      const SizedBox(height: 6),
      Row(
        children: [
          Expanded(
            child: Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              alignment: Alignment.centerLeft,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: c.line, width: 1.5),
              ),
              child: TextField(
                controller: newOption,
                textCapitalization: TextCapitalization.sentences,
                onSubmitted: (_) => _add(),
                style: pfText(15, weight: w800, color: c.ink),
                decoration: InputDecoration(
                  hintText: context.l10n.addNew,
                  hintStyle: pfText(15, weight: w800, color: c.mute),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          PfSmallButton(
            label: context.l10n.add,
            onPressed: _add,
            height: 48,
            radius: 14,
            fontSize: 15,
          ),
        ],
      ),
    ];
  }
}

class _OptionRow extends StatelessWidget {
  const _OptionRow({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
    this.more = false,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final bool more;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.pf;
    final fg = selected ? c.cashIn : c.ink;
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Semantics(
        selected: selected,
        child: Material(
          color: selected ? c.soft : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: onTap,
            child: Container(
              height: 50,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Row(
                children: [
                  Icon(icon, size: 18, color: fg),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      label,
                      style: pfText(15.5, weight: w800, color: fg),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (selected) Icon(LucideIcons.check, size: 19, color: fg),
                  if (more) ...[
                    const SizedBox(width: 4),
                    Icon(LucideIcons.chevronRight, size: 18, color: fg),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _EditableRow extends StatefulWidget {
  const _EditableRow({
    super.key,
    required this.value,
    required this.onRename,
    required this.onRemove,
  });

  final String value;
  final ValueChanged<String> onRename;
  final VoidCallback? onRemove;

  @override
  State<_EditableRow> createState() => _EditableRowState();
}

class _EditableRowState extends State<_EditableRow> {
  late final controller = TextEditingController(text: widget.value);
  final focus = FocusNode();

  @override
  void initState() {
    super.initState();
    // Commit the rename when the field loses focus.
    focus.addListener(() {
      if (!focus.hasFocus) _commit();
    });
  }

  void _commit() {
    final value = controller.text.trim();
    if (value.isEmpty) {
      controller.text = widget.value;
    } else if (value != widget.value) {
      widget.onRename(value);
    }
  }

  @override
  void dispose() {
    controller.dispose();
    focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.pf;
    return Container(
      height: 48,
      padding: const EdgeInsets.only(left: 14, right: 4),
      decoration: BoxDecoration(
        color: c.card2,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(LucideIcons.gripVertical, size: 16, color: c.mute),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focus,
              onSubmitted: (_) => _commit(),
              style: pfText(15, weight: w800, color: c.ink),
            ),
          ),
          Icon(LucideIcons.pencil, size: 15, color: c.mute),
          if (widget.onRemove != null)
            IconButton(
              onPressed: widget.onRemove,
              tooltip: context.l10n.deleteOption(widget.value),
              icon: Icon(LucideIcons.trash2, size: 17, color: c.cashOut),
              visualDensity: VisualDensity.compact,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
            ),
        ],
      ),
    );
  }
}
