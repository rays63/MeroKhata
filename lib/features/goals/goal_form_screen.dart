import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../data/app_store.dart';
import '../../data/models.dart';
import '../../theme/tokens.dart';
import '../../widgets/pf.dart';
import 'goals_screen.dart';

enum _Deadline {
  keep('Keep current'),
  threeMonths('3 months'),
  sixMonths('6 months'),
  year('1 year'),
  none('No deadline');

  const _Deadline(this.label);
  final String label;

  DateTime? resolve(DateTime now, DateTime? current) => switch (this) {
    _Deadline.keep => current,
    _Deadline.threeMonths => DateTime(now.year, now.month + 3, now.day),
    _Deadline.sixMonths => DateTime(now.year, now.month + 6, now.day),
    _Deadline.year => DateTime(now.year + 1, now.month, now.day),
    _Deadline.none => null,
  };
}

/// Create a goal, or edit / delete an existing one.
class GoalFormScreen extends StatefulWidget {
  const GoalFormScreen({super.key, this.goal});

  final SavingsGoal? goal;

  @override
  State<GoalFormScreen> createState() => _GoalFormScreenState();
}

class _GoalFormScreenState extends State<GoalFormScreen> {
  late final name = TextEditingController(text: widget.goal?.name ?? '');
  late final target = TextEditingController(
    text: widget.goal == null ? '' : widget.goal!.targetAmount.toStringAsFixed(0),
  );
  late _Deadline deadline = widget.goal == null
      ? _Deadline.sixMonths
      : (widget.goal!.deadline == null ? _Deadline.none : _Deadline.keep);
  String? error;
  bool saving = false;

  bool get editing => widget.goal != null;

  @override
  void dispose() {
    name.dispose();
    target.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (name.text.trim().isEmpty) {
      setState(() => error = 'Give your goal a name');
      return;
    }
    final amount = double.tryParse(target.text.replaceAll(',', ''));
    if (amount == null || amount <= 0) {
      setState(() => error = 'Target must be greater than zero');
      return;
    }
    if (saving) return;
    setState(() => saving = true);
    final store = AppScope.read(context);
    final goal = widget.goal;
    await store.saveGoal(
      id: goal?.id,
      name: name.text,
      targetAmount: amount,
      manualSaved: goal?.manualSaved ?? 0,
      deadline: deadline.resolve(DateTime.now(), goal?.deadline),
    );
    if (!mounted) return;
    showPfToast(
      context,
      editing ? 'Goal updated' : 'Goal “${name.text.trim()}” created',
    );
    Navigator.pop(context);
  }

  Future<void> _delete() async {
    final c = context.pf;
    final goal = widget.goal!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete “${goal.name}”?', style: pfText(19, weight: w900)),
        content: Text(
          'Linked entries stay in their books; they just stop counting toward this goal.',
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
    showPfToast(context, 'Goal deleted');
    Navigator.pop(context);
    await store.deleteGoal(goal.id);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.pf;
    final options = [
      if (editing && widget.goal!.deadline != null) _Deadline.keep,
      _Deadline.threeMonths,
      _Deadline.sixMonths,
      _Deadline.year,
      _Deadline.none,
    ];
    String label(_Deadline value) => value == _Deadline.keep
        ? deadlineLabel(widget.goal!.deadline)
        : value.label;
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: pagePadding,
          children: [
            PfHeader(title: editing ? 'Edit goal' : 'New goal', close: true),
            const SizedBox(height: 18),
            PfCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  PfField(
                    label: 'Goal name',
                    child: TextField(
                      controller: name,
                      autofocus: !editing,
                      textCapitalization: TextCapitalization.sentences,
                      onChanged: (_) => setState(() => error = null),
                      style: pfText(17, color: c.ink),
                      decoration: InputDecoration(
                        hintText: 'e.g. New scooter',
                        hintStyle: pfText(17, color: c.mute),
                      ),
                    ),
                  ),
                  const PfDivider(),
                  PfField(
                    label: 'Target amount',
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text('Rs', style: pfText(20, weight: w900, color: c.sub)),
                        const SizedBox(width: 6),
                        Expanded(
                          child: TextField(
                            controller: target,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            onChanged: (_) => setState(() => error = null),
                            style: pfText(28, weight: w900, color: c.ink),
                            decoration: InputDecoration(
                              hintText: '0',
                              hintStyle: pfText(28, weight: w900, color: c.mute),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            const PfSectionLabel('Deadline', optional: true),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final value in options)
                  PfChoiceChip(
                    label: label(value),
                    selected: deadline == value,
                    onTap: () => setState(() => deadline = value),
                  ),
              ],
            ),
            if (error != null) ...[
              const SizedBox(height: 18),
              PfErrorBanner(error!),
            ],
            const SizedBox(height: 18),
            PfButton(
              label: editing ? 'Save changes' : 'Create goal',
              onPressed: saving ? null : _save,
            ),
            if (editing) ...[
              const SizedBox(height: 12),
              PfButton(
                label: 'Delete goal',
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
