import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../l10n/l10n.dart';
import '../../theme/tokens.dart';
import '../../widgets/brand.dart';
import '../../widgets/pf.dart';

/// Brand splash shown while saved data loads (and briefly on first launch).
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  static const green = Color(0xFF0F7A4A);

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Material(
        color: green,
        child: Stack(
          fit: StackFit.expand,
          clipBehavior: Clip.hardEdge,
          children: [
            const Positioned(
              left: -160,
              top: -230,
              child: _Circle(size: 520, color: Color(0xFF12915A)),
            ),
            const Positioned(
              right: -110,
              bottom: -60,
              child: _Circle(size: 300, color: Color(0xFF0D6B41)),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              // A brand screen: at very large text sizes it shrinks to fit
              // rather than clipping.
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const PaisaDrop(size: 72, color: Colors.white, coin: green),
                    const SizedBox(height: 22),
                    Text(
                      'Paisa Flow',
                      style: pfText(
                        44,
                        weight: w900,
                        color: Colors.white,
                        letterSpacing: -1,
                        height: 1,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'हरेक पैसाको हिसाब',
                      style: pfText(
                        20,
                        weight: w600,
                        color: PfColors.heroLabel,
                      ).copyWith(fontFamily: 'Mukta'),
                    ),
                    // The Nepali tagline above already says it in नेपाली.
                    if (Localizations.localeOf(context).languageCode !=
                        'ne') ...[
                      const SizedBox(height: 2),
                      Text(
                        l.splashSubtitle,
                        style: pfText(
                          16,
                          weight: w700,
                          color: PfColors.heroLabel,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            Positioned(
              left: 40,
              right: 40,
              bottom: 64,
              child: Row(
                children: [
                  const Icon(
                    LucideIcons.lock,
                    size: 16,
                    color: PfColors.heroLabel,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      l.splashOffline,
                      style: pfText(
                        13,
                        weight: w700,
                        color: PfColors.heroLabel,
                      ),
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

class _Circle extends StatelessWidget {
  const _Circle({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
  );
}
