import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../l10n/l10n.dart';
import '../theme/tokens.dart';
import 'pf.dart';

/// What the entry form records.
enum EntryKind { cashIn, cashOut, transfer }

/// Cash in · Cash out · Transfer switch at the top of the entry forms.
class EntryKindToggle extends StatelessWidget {
  const EntryKindToggle({
    super.key,
    required this.value,
    required this.onChanged,
    this.kinds = EntryKind.values,
  });

  final EntryKind value;
  final ValueChanged<EntryKind> onChanged;

  /// Kinds offered; editing can't turn an entry into a transfer or back.
  final List<EntryKind> kinds;

  @override
  Widget build(BuildContext context) {
    final c = context.pf;
    final l = context.l10n;
    Widget option(EntryKind kind) {
      final selected = value == kind;
      final (icon, label, fg, bg) = switch (kind) {
        EntryKind.cashIn => (
          LucideIcons.arrowDownLeft,
          l.cashIn,
          c.cashIn,
          c.soft,
        ),
        EntryKind.cashOut => (
          LucideIcons.arrowUpRight,
          l.cashOut,
          c.cashOut,
          c.outSoft,
        ),
        EntryKind.transfer => (
          LucideIcons.arrowLeftRight,
          l.transfer,
          c.blue,
          c.blueSoft,
        ),
      };
      final color = selected ? fg : c.sub;
      return Expanded(
        child: Semantics(
          selected: selected,
          button: true,
          child: Material(
            color: selected ? bg : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () => onChanged(kind),
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 44),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 6,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(icon, size: 16, color: color),
                      const SizedBox(width: 5),
                      Flexible(
                        child: Text(
                          label,
                          style: pfText(14, weight: w900, color: color),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          for (var i = 0; i < kinds.length; i++) ...[
            if (i > 0) const SizedBox(width: 4),
            option(kinds[i]),
          ],
        ],
      ),
    );
  }
}
