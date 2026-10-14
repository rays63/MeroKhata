import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../widgets/coming_soon.dart';

/// Placeholder until the Insights milestone (income, spending, trends,
/// category and payment-mode breakdowns).
class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context) => const ComingSoon(
    title: 'Insights',
    icon: LucideIcons.chartPie,
    heading: 'See where it all goes',
    body:
        'Income, spending and net flow, trends, and breakdowns by category and payment mode are on the way.',
  );
}
