import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/format.dart';
import '../../data/app_store.dart';
import '../../data/split.dart';
import '../../theme/tokens.dart';
import '../../widgets/pf.dart';
import '../../widgets/store_sheets.dart';

String personName(AppStore store, String id) =>
    id == me ? 'You' : (store.friendById(id)?.name ?? 'Friend');

Color personColor(AppStore store, String id) => Color(
  id == me ? meColor : (store.friendById(id)?.colorValue ?? friendColors.first),
);

/// Round initial avatar for a person.
class PersonAvatar extends StatelessWidget {
  const PersonAvatar({
    super.key,
    required this.name,
    required this.color,
    this.size = 40,
    this.ring,
    this.border,
  });

  final String name;
  final Color color;
  final double size;

  /// Selection ring drawn outside the avatar.
  final Color? ring;

  /// Thin border in the card colour, for overlapping stacks.
  final Color? border;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: border == null ? null : Border.all(color: border!, width: 2),
        boxShadow: ring == null
            ? null
            : [BoxShadow(color: ring!, spreadRadius: 3)],
      ),
      child: Text(
        name.trim().isEmpty ? '?' : name.trim()[0].toUpperCase(),
        style: pfText(size * .36, weight: w900, color: Colors.white),
      ),
    );
  }
}

/// Up to three overlapping avatars (you first).
class AvatarStack extends StatelessWidget {
  const AvatarStack({super.key, required this.ids});

  final List<String> ids;

  @override
  Widget build(BuildContext context) {
    final store = AppScope.read(context);
    final c = context.pf;
    final shown = ids.take(3).toList();
    return SizedBox(
      width: 34 + (shown.length - 1) * 26,
      height: 34,
      child: Stack(
        children: [
          for (var i = 0; i < shown.length; i++)
            Positioned(
              left: i * 26,
              child: PersonAvatar(
                name: personName(store, shown[i]),
                color: personColor(store, shown[i]),
                size: 34,
                border: c.card,
              ),
            ),
        ],
      ),
    );
  }
}

/// Asks for a friend's name and adds them. Returns the new friend's id.
Future<String?> addFriendDialog(BuildContext context) async {
  final c = context.pf;
  final controller = TextEditingController();
  final name = await showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Add a friend', style: pfText(19, weight: w900)),
      content: TextField(
        controller: controller,
        autofocus: true,
        textCapitalization: TextCapitalization.words,
        onSubmitted: (value) => Navigator.pop(context, value),
        style: pfText(17, color: c.ink),
        decoration: InputDecoration(
          hintText: 'Name, e.g. Sita',
          hintStyle: pfText(17, color: c.mute),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel', style: pfText(14, color: c.sub)),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, controller.text),
          child: Text('Add', style: pfText(14, color: c.cashIn)),
        ),
      ],
    ),
  );
  controller.dispose();
  if (name == null || name.trim().isEmpty || !context.mounted) return null;
  final friend = await AppScope.read(context).addFriend(name);
  return friend.id;
}

/// Horizontal row of selectable avatars, with an "Add" button at the end.
class PeoplePicker extends StatelessWidget {
  const PeoplePicker({
    super.key,
    required this.ids,
    required this.isSelected,
    required this.onTap,
    this.onAdd,
  });

  final List<String> ids;
  final bool Function(String id) isSelected;
  final ValueChanged<String> onTap;
  final VoidCallback? onAdd;

  @override
  Widget build(BuildContext context) {
    final store = AppScope.watch(context);
    final c = context.pf;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      clipBehavior: Clip.none,
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final id in ids) ...[
            Semantics(
              selected: isSelected(id),
              button: true,
              label: personName(store, id),
              excludeSemantics: true,
              onTap: () => onTap(id),
              child: GestureDetector(
                onTap: () => onTap(id),
                child: Opacity(
                  opacity: isSelected(id) ? 1 : .45,
                  child: Column(
                    children: [
                      PersonAvatar(
                        name: personName(store, id),
                        color: personColor(store, id),
                        size: 54,
                        ring: isSelected(id) ? c.pri : null,
                      ),
                      const SizedBox(height: 6),
                      SizedBox(
                        width: 64,
                        child: Text(
                          personName(store, id),
                          textAlign: TextAlign.center,
                          style: pfText(12.5),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          if (onAdd != null)
            Semantics(
              button: true,
              label: 'Add a friend',
              excludeSemantics: true,
              onTap: onAdd,
              child: GestureDetector(
                onTap: onAdd,
                child: Column(
                  children: [
                    Container(
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: c.line, width: 1.5),
                      ),
                      child: Icon(LucideIcons.userPlus, size: 22, color: c.sub),
                    ),
                    const SizedBox(height: 6),
                    Text('Add', style: pfText(12.5, color: c.sub)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Equal / Shares toggle plus each participant's part, with − / + steppers
/// in shares mode. [weights] maps participant id → share (0 = left out).
class SharesEditor extends StatelessWidget {
  const SharesEditor({
    super.key,
    required this.amount,
    required this.currency,
    required this.weights,
    required this.byShares,
    required this.onMethod,
    required this.onWeight,
  });

  final double amount;
  final String currency;
  final Shares weights;
  final bool byShares;
  final ValueChanged<bool> onMethod;
  final void Function(String id, int weight) onWeight;

  /// What the split actually uses: everyone selected at weight 1 for Equal.
  static Shares effective(Shares weights, bool byShares) => {
    for (final e in weights.entries)
      if (e.value > 0) e.key: byShares ? e.value : 1,
  };

  @override
  Widget build(BuildContext context) {
    final store = AppScope.watch(context);
    final c = context.pf;
    final shares = effective(weights, byShares);
    final parts = splitAmount(amount, shares);
    // 30pt visual inside a 44pt tap target.
    Widget stepper(IconData icon, String label, VoidCallback? onTap) =>
        Semantics(
          button: true,
          enabled: onTap != null,
          label: label,
          excludeSemantics: true,
          onTap: onTap,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(7),
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: c.card2,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  size: 14,
                  color: onTap == null ? c.mute : c.ink,
                ),
              ),
            ),
          ),
        );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PfSegment<bool>(
          value: byShares,
          onChanged: onMethod,
          items: const [(false, 'Equal', null), (true, 'Shares', null)],
        ),
        const SizedBox(height: 16),
        if (shares.isNotEmpty)
          PfCard(
            radius: 22,
            child: Column(
              children: [
                for (final id in shares.keys) ...[
                  if (id != shares.keys.first) const PfDivider(),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Row(
                      children: [
                        PersonAvatar(
                          name: personName(store, id),
                          color: personColor(store, id),
                          size: 36,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            personName(store, id),
                            style: pfText(15),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (byShares) ...[
                          stepper(
                            LucideIcons.minus,
                            'Fewer shares for ${personName(store, id)}',
                            weights[id]! > 1
                                ? () => onWeight(id, weights[id]! - 1)
                                : null,
                          ),
                          SizedBox(
                            width: 26,
                            child: Text(
                              '${weights[id]}',
                              textAlign: TextAlign.center,
                              style: pfText(15, weight: w900),
                            ),
                          ),
                          stepper(
                            LucideIcons.plus,
                            'More shares for ${personName(store, id)}',
                            () => onWeight(id, weights[id]! + 1),
                          ),
                        ],
                        SizedBox(
                          width: 92,
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerRight,
                            child: Text(
                              money(parts[id] ?? 0, currency),
                              style: pfText(15, weight: w900),
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
      ],
    );
  }
}

/// "Record Rs 3,600 as cash out in [Personal ▾]" switch.
class RecordToggle extends StatelessWidget {
  const RecordToggle({
    super.key,
    required this.on,
    required this.amount,
    required this.currency,
    required this.bookId,
    required this.onChanged,
    required this.onBook,
  });

  final bool on;
  final double amount;
  final String currency;
  final String? bookId;
  final ValueChanged<bool> onChanged;
  final ValueChanged<String> onBook;

  @override
  Widget build(BuildContext context) {
    final store = AppScope.watch(context);
    final c = context.pf;
    final book = bookId == null ? null : store.bookById(bookId!);
    if (book == null) return const SizedBox.shrink();
    return Material(
      color: c.card2,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => onChanged(!on),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Switch.adaptive(
                value: on,
                onChanged: onChanged,
                activeTrackColor: c.pri,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      'Record ${money(amount, currency)} as cash out in ',
                      style: pfText(13.5, weight: w700, height: 1.4),
                    ),
                    _BookLink(
                      name: book.name,
                      onTap: () async {
                        final picked = await pickSplitBook(
                          context,
                          book.id,
                          currency,
                        );
                        if (picked != null) onBook(picked);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BookLink extends StatelessWidget {
  const _BookLink({required this.name, required this.onTap});

  final String name;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.pf;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              name,
              style: pfText(13.5, weight: w900, color: c.cashIn),
            ),
            Icon(LucideIcons.chevronDown, size: 14, color: c.cashIn),
          ],
        ),
      ),
    );
  }
}

/// Book picker limited to books in the split's [currency].
Future<String?> pickSplitBook(
  BuildContext context,
  String selected,
  String currency,
) => pickBook(context, selected: selected, onlyCurrency: currency);

/// Confirms a settle-up and picks the book to record it in. Returns the
/// book id, or null if cancelled.
Future<String?> showSettleSheet(
  BuildContext context, {
  required String friendName,
  required double amount,
  required String currency,
}) {
  return showModalBottomSheet<String>(
    context: context,
    useSafeArea: true,
    builder: (_) => _SettleSheet(
      friendName: friendName,
      amount: amount,
      currency: currency,
    ),
  );
}

class _SettleSheet extends StatefulWidget {
  const _SettleSheet({
    required this.friendName,
    required this.amount,
    required this.currency,
  });

  final String friendName;
  final double amount;
  final String currency;

  @override
  State<_SettleSheet> createState() => _SettleSheetState();
}

class _SettleSheetState extends State<_SettleSheet> {
  late String? bookId = AppScope.read(
    context,
  ).defaultSplitBookId(widget.currency);

  @override
  Widget build(BuildContext context) {
    final store = AppScope.watch(context);
    final c = context.pf;
    final theyPay = widget.amount > 0;
    final book = bookId == null ? null : store.bookById(bookId!);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 5,
              margin: const EdgeInsets.only(bottom: 14),
              decoration: BoxDecoration(
                color: c.line,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
          Text(
            theyPay
                ? 'Settle up with ${widget.friendName}'
                : 'Pay ${widget.friendName}',
            style: pfText(19, weight: w900),
          ),
          const SizedBox(height: 6),
          Text(
            theyPay
                ? '${widget.friendName} pays you ${money(widget.amount, widget.currency)}.'
                : 'You pay ${widget.friendName} ${money(widget.amount, widget.currency)}.',
            style: pfText(15, weight: w600, color: c.sub),
          ),
          const SizedBox(height: 16),
          if (book == null)
            const PfNote(
              icon: LucideIcons.info,
              text: 'Add a book in this currency to record settlements.',
            )
          else
            PfCard(
              color: c.card2,
              radius: 18,
              onTap: () async {
                final picked = await pickSplitBook(
                  context,
                  book.id,
                  widget.currency,
                );
                if (picked != null) setState(() => bookId = picked);
              },
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Icon(
                    theyPay
                        ? LucideIcons.arrowDownLeft
                        : LucideIcons.arrowUpRight,
                    size: 18,
                    color: c.amount(theyPay),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Add as ${theyPay ? 'cash in' : 'cash out'} to ${book.name}',
                      style: pfText(14, weight: w700),
                    ),
                  ),
                  Icon(LucideIcons.chevronDown, size: 16, color: c.sub),
                ],
              ),
            ),
          const SizedBox(height: 16),
          PfButton(
            label: theyPay
                ? 'Settle ${money(widget.amount, widget.currency)}'
                : 'Pay ${money(widget.amount.abs(), widget.currency)}',
            onPressed: book == null
                ? null
                : () => Navigator.pop(context, book.id),
          ),
        ],
      ),
    );
  }
}
