import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../widgets/coming_soon.dart';

/// Placeholder until the Split milestone (groups, bills, settle-up).
class SplitScreen extends StatelessWidget {
  const SplitScreen({super.key});

  @override
  Widget build(BuildContext context) => const ComingSoon(
    title: 'Split',
    icon: LucideIcons.split,
    heading: 'Split bills, settle in one tap',
    body:
        'Split a bill equally or by shares, keep group balances, and record settle-ups in your book.',
  );
}
