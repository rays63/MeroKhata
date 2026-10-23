import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../data/app_store.dart';
import '../../l10n/l10n.dart';
import '../../theme/tokens.dart';
import '../../widgets/pf.dart';

/// Reorder the Insights cards with arrows and hide any with a switch.
/// Arrows rather than drag-and-drop: easier at large text and with TalkBack.
class InsightsLayoutScreen extends StatefulWidget {
  const InsightsLayoutScreen({super.key});

  @override
  State<InsightsLayoutScreen> createState() => _InsightsLayoutScreenState();
}

class _InsightsLayoutScreenState extends State<InsightsLayoutScreen> {
  late final store = AppScope.read(context);
  late List<String> order = [...store.insightsOrder];
  late Set<String> hidden = {...store.insightsHidden};

  (IconData, String) _card(AppLocalizations l, String id) => switch (id) {
    'charts' => (LucideIcons.chartSpline, l.cardCharts),
    'boxes' => (LucideIcons.layoutGrid, l.insightsWhereItWent),
    'places' => (LucideIcons.store, l.placesTitle),
    'trends' => (LucideIcons.chartColumn, l.cardTrends),
    'modes' => (LucideIcons.wallet, l.cardModes),
    _ => (LucideIcons.hash, l.tags),
  };

  void _move(int from, int to) => setState(() {
    final id = order.removeAt(from);
    order.insert(to, id);
  });

  @override
  Widget build(BuildContext context) {
    final c = context.pf;
    final l = context.l10n;
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: pagePadding,
          children: [
            PfHeader(title: l.layoutTitle),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                l.layoutIntro,
                style: pfText(13.5, weight: w700, color: c.sub, height: 1.45),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(LucideIcons.pin, size: 15, color: c.sub),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l.layoutPinned,
                    style: pfText(12.5, weight: w800, color: c.sub),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            PfCard(
              child: Column(
                children: [
                  for (var i = 0; i < order.length; i++) ...[
                    if (i > 0) const PfDivider(),
                    Builder(
                      builder: (context) {
                        final (icon, name) = _card(l, order[i]);
                        final shown = !hidden.contains(order[i]);
                        return Padding(
                          padding: const EdgeInsets.fromLTRB(14, 6, 6, 6),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 22,
                                child: Text(
                                  '${i + 1}',
                                  style: pfText(13, weight: w900, color: c.sub),
                                ),
                              ),
                              Icon(
                                icon,
                                size: 18,
                                color: shown ? c.ink : c.mute,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  name,
                                  style: pfText(
                                    14.5,
                                    weight: w800,
                                    color: shown ? c.ink : c.mute,
                                  ),
                                ),
                              ),
                              IconButton(
                                tooltip: l.layoutUp(name),
                                onPressed: i == 0
                                    ? null
                                    : () => _move(i, i - 1),
                                icon: const Icon(
                                  LucideIcons.chevronUp,
                                  size: 18,
                                ),
                              ),
                              IconButton(
                                tooltip: l.layoutDown(name),
                                onPressed: i == order.length - 1
                                    ? null
                                    : () => _move(i, i + 1),
                                icon: const Icon(
                                  LucideIcons.chevronDown,
                                  size: 18,
                                ),
                              ),
                              Semantics(
                                label: l.layoutShow(name),
                                child: Switch(
                                  value: shown,
                                  onChanged: (v) => setState(() {
                                    v
                                        ? hidden.remove(order[i])
                                        : hidden.add(order[i]);
                                  }),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: PfButton(
                    label: l.layoutReset,
                    icon: LucideIcons.rotateCcw,
                    style: PfButtonStyle.neutral,
                    fontSize: 14,
                    onPressed: () => setState(() {
                      order = [...AppStore.insightsCards];
                      hidden = {};
                    }),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: PfButton(
                    label: l.done,
                    icon: LucideIcons.check,
                    onPressed: () async {
                      await store.saveInsightsLayout(order, hidden);
                      if (context.mounted) Navigator.pop(context);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
