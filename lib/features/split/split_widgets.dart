import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/format.dart';
import '../../data/app_store.dart';
import '../../data/split.dart';
import '../../l10n/l10n.dart';
import '../../theme/tokens.dart';
import '../../widgets/pf.dart';
import '../books/book_form_screen.dart';

/// Display name for a split participant: "You" (localised) for the current
/// user, otherwise the friend's stored name.
String personName(AppLocalizations l, AppStore store, String id) => id == me
    ? l.splitYou
    : (store.friendById(id)?.name ?? l.splitFriendFallback);

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
    final l = context.l10n;
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
                name: personName(l, store, shown[i]),
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
  final name = await showDialog<String>(
    context: context,
    builder: (_) => const _AddFriendDialog(),
  );
  if (name == null || name.trim().isEmpty || !context.mounted) return null;
  final friend = await AppScope.read(context).addFriend(name);
  return friend.id;
}

/// Owns its controller so it is disposed with the dialog, after the closing
/// animation, not while the field is still on screen.
class _AddFriendDialog extends StatefulWidget {
  const _AddFriendDialog();

  @override
  State<_AddFriendDialog> createState() => _AddFriendDialogState();
}

class _AddFriendDialogState extends State<_AddFriendDialog> {
  final controller = TextEditingController();

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
      title: Text(l.splitAddFriendTitle, style: pfText(19, weight: w900)),
      content: TextField(
        controller: controller,
        autofocus: true,
        textCapitalization: TextCapitalization.words,
        onSubmitted: (value) => Navigator.pop(context, value),
        style: pfText(17, color: c.ink),
        decoration: InputDecoration(
          hintText: l.splitAddFriendHint,
          hintStyle: pfText(17, color: c.mute),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l.cancel, style: pfText(14, color: c.sub)),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, controller.text),
          child: Text(l.add, style: pfText(14, color: c.cashIn)),
        ),
      ],
    );
  }
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
    final l = context.l10n;
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
              label: personName(l, store, id),
              excludeSemantics: true,
              onTap: () => onTap(id),
              child: GestureDetector(
                onTap: () => onTap(id),
                child: Opacity(
                  opacity: isSelected(id) ? 1 : .45,
                  child: Column(
                    children: [
                      PersonAvatar(
                        name: personName(l, store, id),
                        color: personColor(store, id),
                        size: 54,
                        ring: isSelected(id) ? c.pri : null,
                      ),
                      const SizedBox(height: 6),
                      SizedBox(
                        width: 64,
                        child: Text(
                          personName(l, store, id),
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
              label: l.splitAddFriendTitle,
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
                    Text(l.add, style: pfText(12.5, color: c.sub)),
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
    final l = context.l10n;
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
          items: [(false, l.splitEqual, null), (true, l.splitShares, null)],
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
                          name: personName(l, store, id),
                          color: personColor(store, id),
                          size: 36,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            personName(l, store, id),
                            style: pfText(15),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (byShares) ...[
                          stepper(
                            LucideIcons.minus,
                            l.splitFewerShares(personName(l, store, id)),
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
                            l.splitMoreShares(personName(l, store, id)),
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

/// Where money that changed hands is recorded: a book, or nowhere
/// ([bookId] null).
class RecordChoice {
  const RecordChoice(this.bookId);

  final String? bookId;
}

/// Confirms a settle-up and asks which book to record it in. Null when
/// dismissed.
Future<RecordChoice?> showSettleSheet(
  BuildContext context, {
  required String friendName,
  required double amount,
  required String currency,
}) {
  final l = context.l10n;
  final theyPay = amount > 0;
  return showRecordBookSheet(
    context,
    title: theyPay
        ? l.splitSettleUpWith(friendName)
        : l.splitPayName(friendName),
    message: theyPay
        ? l.splitTheyPayYou(friendName, money(amount, currency))
        : l.splitYouPayThem(friendName, money(amount.abs(), currency)),
    currency: currency,
    cashIn: theyPay,
  );
}

/// Asks where to record money that moved: one of the books in [currency]
/// (one tap), a new book in that currency, or no book. Null when dismissed.
Future<RecordChoice?> showRecordBookSheet(
  BuildContext context, {
  required String title,
  required String message,
  required String currency,
  required bool cashIn,
}) => showModalBottomSheet<RecordChoice>(
  context: context,
  useSafeArea: true,
  isScrollControlled: true,
  builder: (_) => _RecordBookSheet(
    title: title,
    message: message,
    currency: currency,
    cashIn: cashIn,
  ),
);

class _RecordBookSheet extends StatelessWidget {
  const _RecordBookSheet({
    required this.title,
    required this.message,
    required this.currency,
    required this.cashIn,
  });

  final String title;
  final String message;
  final String currency;
  final bool cashIn;

  Future<void> _createBook(BuildContext context) async {
    final navigator = Navigator.of(context);
    final id = await navigator.push<String>(
      MaterialPageRoute(
        builder: (_) =>
            BookFormScreen(initialCurrency: currency, popWithId: true),
      ),
    );
    if (id != null) navigator.pop(RecordChoice(id));
  }

  @override
  Widget build(BuildContext context) {
    final store = AppScope.watch(context);
    final l = context.l10n;
    final c = context.pf;
    final books = store.splitBooks(currency);
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * .8,
      ),
      child: SingleChildScrollView(
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
            Text(title, style: pfText(19, weight: w900)),
            const SizedBox(height: 6),
            Text(
              message,
              style: pfText(15, weight: w600, color: c.sub),
            ),
            const SizedBox(height: 16),
            for (final book in books) ...[
              _ChoiceRow(
                icon: cashIn
                    ? LucideIcons.arrowDownLeft
                    : LucideIcons.arrowUpRight,
                color: c.amount(cashIn),
                label: cashIn
                    ? l.splitAddAsCashIn(book.name)
                    : l.splitAddAsCashOut(book.name),
                onTap: () => Navigator.pop(context, RecordChoice(book.id)),
              ),
              const SizedBox(height: 8),
            ],
            if (books.isEmpty) ...[
              PfNote(
                icon: LucideIcons.info,
                text: l.splitNoBookInCurrency(currency),
              ),
              const SizedBox(height: 8),
              _ChoiceRow(
                icon: LucideIcons.plus,
                color: c.cashIn,
                label: l.splitCreateBookIn(currency),
                onTap: () => _createBook(context),
              ),
              const SizedBox(height: 8),
            ],
            _ChoiceRow(
              icon: LucideIcons.ban,
              color: c.sub,
              label: l.splitDontRecord,
              onTap: () => Navigator.pop(context, const RecordChoice(null)),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChoiceRow extends StatelessWidget {
  const _ChoiceRow({
    required this.icon,
    required this.color,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.pf;
    return PfCard(
      color: c.card2,
      radius: 18,
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Text(label, style: pfText(14, weight: w700)),
          ),
          Icon(LucideIcons.chevronRight, size: 16, color: c.sub),
        ],
      ),
    );
  }
}
