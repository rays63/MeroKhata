import 'package:flutter/material.dart';

import '../theme/tokens.dart';
import 'pf.dart';

/// Tab content for features that land in a later milestone.
class ComingSoon extends StatelessWidget {
  const ComingSoon({
    super.key,
    required this.title,
    required this.icon,
    required this.heading,
    required this.body,
  });

  final String title;
  final IconData icon;
  final String heading;
  final String body;

  @override
  Widget build(BuildContext context) {
    final c = context.pf;
    return Padding(
      padding: pagePadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: pfText(30, weight: w900, letterSpacing: -.6)),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PfIconTile(
                    icon: icon,
                    background: c.goldSoft,
                    foreground: c.gold,
                    size: 96,
                    radius: 32,
                    iconSize: 42,
                  ),
                  const SizedBox(height: 18),
                  PfBadge(label: 'COMING SOON', pill: true, fontSize: 11),
                  const SizedBox(height: 12),
                  Text(
                    heading,
                    style: pfText(26, weight: w900, letterSpacing: -.4, height: 1.15),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    body,
                    style: pfText(15, weight: w600, color: c.sub, height: 1.5),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
