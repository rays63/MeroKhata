import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../l10n/l10n.dart';
import '../../theme/tokens.dart';
import '../../widgets/pf.dart';

const pinLength = 4;

/// Four PIN dots, filled as digits are typed.
class PinDots extends StatelessWidget {
  const PinDots({super.key, required this.filled, this.error = false});

  final int filled;
  final bool error;

  @override
  Widget build(BuildContext context) {
    final c = context.pf;
    return Semantics(
      label: '$filled / $pinLength',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < pinLength; i++) ...[
            if (i > 0) const SizedBox(width: 18),
            AnimatedContainer(
              duration: const Duration(milliseconds: 120),
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: i < filled
                    ? (error ? c.cashOut : c.pri)
                    : Colors.transparent,
                border: Border.all(
                  color: error ? c.cashOut : (i < filled ? c.pri : c.mute),
                  width: 2,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// 1–9, then fingerprint (or blank), 0 and delete.
class PinKeypad extends StatelessWidget {
  const PinKeypad({
    super.key,
    required this.onDigit,
    required this.onDelete,
    this.onBiometric,
    this.enabled = true,
  });

  final ValueChanged<String> onDigit;
  final VoidCallback onDelete;
  final VoidCallback? onBiometric;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final c = context.pf;
    final l = context.l10n;
    Widget key({
      String? digit,
      IconData? icon,
      String? label,
      VoidCallback? onTap,
      bool quiet = false,
    }) => Expanded(
      child: Padding(
        padding: const EdgeInsets.all(7),
        child: Semantics(
          button: true,
          label: label ?? digit,
          excludeSemantics: true,
          onTap: enabled ? onTap : null,
          child: Material(
            color: quiet ? Colors.transparent : c.card,
            borderRadius: BorderRadius.circular(24),
            child: InkWell(
              borderRadius: BorderRadius.circular(24),
              onTap: enabled ? onTap : null,
              child: SizedBox(
                height: 66,
                child: Center(
                  child: digit != null
                      ? Text(digit, style: pfText(27, weight: w900))
                      : Icon(icon, size: 26, color: c.ink),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    Widget row(List<Widget> keys) => Row(children: keys);
    String d(int n) => '$n';
    return Opacity(
      opacity: enabled ? 1 : .4,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 320),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final r in const [
              [1, 2, 3],
              [4, 5, 6],
              [7, 8, 9],
            ])
              row([
                for (final n in r) key(digit: d(n), onTap: () => onDigit(d(n))),
              ]),
            row([
              if (onBiometric != null)
                key(
                  icon: LucideIcons.fingerprint,
                  label: l.lockUseBiometrics,
                  onTap: onBiometric,
                  quiet: true,
                )
              else
                const Expanded(child: SizedBox(height: 80)),
              key(digit: '0', onTap: () => onDigit('0')),
              key(
                icon: LucideIcons.delete,
                label: l.lockDeleteDigit,
                onTap: onDelete,
                quiet: true,
              ),
            ]),
          ],
        ),
      ),
    );
  }
}
