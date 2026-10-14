import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../data/app_store.dart';
import '../../data/split.dart';
import '../../theme/tokens.dart';
import '../../widgets/pf.dart';
import 'group_screen.dart';
import 'split_widgets.dart';

/// Create a group (name + members) or edit / delete an existing one.
class GroupFormScreen extends StatefulWidget {
  const GroupFormScreen({super.key, this.group});

  final SplitGroup? group;

  @override
  State<GroupFormScreen> createState() => _GroupFormScreenState();
}

class _GroupFormScreenState extends State<GroupFormScreen> {
  late final name = TextEditingController(text: widget.group?.name ?? '');
  late final Set<String> members = {...?widget.group?.memberIds};
  String? error;
  bool saving = false;

  bool get editing => widget.group != null;

  @override
  void dispose() {
    name.dispose();
    super.dispose();
  }

  /// Members who appear in an expense or settlement can't be removed.
  Set<String> get _locked => {
    for (final e in widget.group?.expenses ?? const <GroupExpense>[]) ...[
      e.paidBy,
      ...e.shares.keys,
    ],
    for (final s in widget.group?.settlements ?? const <Settlement>[])
      s.friendId,
  };

  Future<void> _save() async {
    if (name.text.trim().isEmpty) {
      setState(() => error = 'Give the group a name');
      return;
    }
    if (members.isEmpty) {
      setState(() => error = 'Add at least one friend');
      return;
    }
    if (saving) return;
    setState(() => saving = true);
    final store = AppScope.read(context);
    final navigator = Navigator.of(context);
    final id = await store.saveGroup(
      id: widget.group?.id,
      name: name.text,
      memberIds: store.friends
          .map((f) => f.id)
          .where(members.contains)
          .toList(),
    );
    if (!mounted) return;
    if (editing) {
      showPfToast(context, 'Group updated');
      navigator.pop();
    } else {
      showPfToast(context, 'Group “${name.text.trim()}” created');
      navigator.pushReplacement(
        MaterialPageRoute(builder: (_) => GroupScreen(groupId: id)),
      );
    }
  }

  Future<void> _delete() async {
    final c = context.pf;
    final group = widget.group!;
    final open = group.balances.values.any((v) => v.abs() >= .005);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete “${group.name}”?', style: pfText(19, weight: w900)),
        content: Text(
          open
              ? 'Some balances aren’t settled yet. Entries already recorded in your books stay.'
              : 'Entries already recorded in your books stay.',
          style: pfText(14, weight: w600, color: c.sub),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: pfText(14, color: c.sub)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Delete', style: pfText(14, color: c.cashOut)),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    final store = AppScope.read(context);
    final navigator = Navigator.of(context);
    showPfToast(context, 'Group deleted');
    navigator
      ..pop()
      ..pop();
    await store.deleteGroup(group.id);
  }

  @override
  Widget build(BuildContext context) {
    final store = AppScope.watch(context);
    final c = context.pf;
    final locked = _locked;
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: pagePadding,
          children: [
            PfHeader(title: editing ? 'Edit group' : 'New group', close: true),
            const SizedBox(height: 18),
            PfCard(
              child: PfField(
                label: 'Group name',
                child: TextField(
                  controller: name,
                  autofocus: !editing,
                  textCapitalization: TextCapitalization.words,
                  onChanged: (_) => setState(() => error = null),
                  style: pfText(17, color: c.ink),
                  decoration: InputDecoration(
                    hintText: 'e.g. Pokhara Trip, Flat 3B',
                    hintStyle: pfText(17, color: c.mute),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 18),
            const PfSectionLabel('Members'),
            const SizedBox(height: 10),
            PeoplePicker(
              ids: [me, ...store.friends.map((f) => f.id)],
              isSelected: (id) => id == me || members.contains(id),
              onTap: (id) {
                if (id == me) return;
                if (locked.contains(id) && members.contains(id)) {
                  showPfToast(
                    context,
                    '${personName(store, id)} is part of an expense in this group',
                  );
                  return;
                }
                setState(() {
                  if (!members.remove(id)) members.add(id);
                  error = null;
                });
              },
              onAdd: () async {
                final id = await addFriendDialog(context);
                if (id != null) setState(() => members.add(id));
              },
            ),
            if (store.friends.isEmpty) ...[
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  'Tap Add to add the friends you share costs with.',
                  style: pfText(13, weight: w700, color: c.sub),
                ),
              ),
            ],
            if (error != null) ...[
              const SizedBox(height: 18),
              PfErrorBanner(error!),
            ],
            const SizedBox(height: 18),
            PfButton(
              label: editing ? 'Save changes' : 'Create group',
              onPressed: saving ? null : _save,
            ),
            if (editing) ...[
              const SizedBox(height: 12),
              PfButton(
                label: 'Delete group',
                icon: LucideIcons.trash2,
                style: PfButtonStyle.outlineDanger,
                height: 50,
                radius: 18,
                fontSize: 15,
                onPressed: _delete,
              ),
            ],
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
