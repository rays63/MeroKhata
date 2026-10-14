import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../app/nav.dart';
import '../../core/format.dart';
import '../../data/app_store.dart';
import '../../data/models.dart';
import '../../theme/tokens.dart';
import '../../widgets/pf.dart';
import 'goal_form_screen.dart';

String deadlineLabel(DateTime? deadline, {DateTime? now}) {
  if (deadline == null) return 'No deadline';
  final soon = deadline.difference(now ?? DateTime.now()).inDays < 60;
  return 'By ${DateFormat(soon ? 'd MMM y' : 'MMM y').format(deadline)}';
}

class GoalsScreen extends StatelessWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = AppScope.watch(context);
    final c = context.pf;
    final saved = store.goals.fold(
      0.0,
      (sum, goal) => sum + min(goal.savedAmount, goal.targetAmount),
    );
    final target = store.goals.fold(0.0, (sum, goal) => sum + goal.targetAmount);
    final progress = target <= 0 ? 0.0 : saved / target;
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: pagePadding,
          children: [
            PfHeader(
              title: 'Goals',
              actions: [
                PfSmallButton(
                  label: 'New goal',
                  icon: LucideIcons.plus,
                  onPressed: () => openNewGoal(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: c.hero,
                borderRadius: BorderRadius.circular(28),
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 84,
                    height: 84,
                    child: CustomPaint(
                      painter: _RingPainter(progress),
                      child: Center(
                        child: Text(
                          '${(progress * 100).round()}%',
                          style: pfText(17, weight: w900, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 18),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Saved across all books',
                          style: pfText(13, color: PfColors.heroLabel),
                        ),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            money(saved),
                            style: pfText(26, weight: w900, color: Colors.white),
                          ),
                        ),
                        Text(
                          'of ${money(target)}',
                          style: pfText(12.5, weight: w700, color: PfColors.heroLabel),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (store.goals.isEmpty)
              PfEmptyCard(
                icon: LucideIcons.target,
                title: 'No goals yet',
                body: 'Set a savings target — an emergency fund, a laptop, Dashain gifts.',
                actionLabel: 'New goal',
                onAction: () => openNewGoal(context),
              ),
            for (final goal in store.goals) ...[
              _GoalCard(goal: goal, linked: store.linkedEntries(goal.id)),
              const SizedBox(height: 16),
            ],
            const PfNote(
              icon: LucideIcons.sparkles,
              text:
                  'Tag any cash-in entry with a goal and progress updates automatically.',
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

class _GoalCard extends StatelessWidget {
  const _GoalCard({required this.goal, required this.linked});

  final SavingsGoal goal;
  final int linked;

  @override
  Widget build(BuildContext context) {
    final c = context.pf;
    final reached = goal.reached;
    return PfCard(
      padding: const EdgeInsets.all(18),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => GoalFormScreen(goal: goal)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(goal.name, style: pfText(17, weight: w900)),
                    Text(
                      deadlineLabel(goal.deadline),
                      style: pfText(12.5, weight: w700, color: c.sub),
                    ),
                  ],
                ),
              ),
              PfBadge(
                label: reached ? 'REACHED' : '${(goal.progress * 100).round()}%',
                pill: true,
                fontSize: 11.5,
                background: reached ? c.soft : c.card2,
                foreground: reached ? c.cashIn : c.sub,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text.rich(
            TextSpan(
              text: money(min(goal.savedAmount, goal.targetAmount)),
              style: pfText(22, weight: w900),
              children: [
                TextSpan(
                  text: '  / ${money(goal.targetAmount)}',
                  style: pfText(13, weight: w700, color: c.sub),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: LinearProgressIndicator(
              value: goal.progress,
              minHeight: 10,
              backgroundColor: c.card2,
              color: Color(goal.colorValue),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Text(
                  reached ? 'Goal reached' : '${money(goal.remaining)} to go',
                  style: pfText(12.5, color: c.sub),
                ),
              ),
              Text(
                linked == 0
                    ? 'No linked entries'
                    : '$linked linked ${linked == 1 ? 'entry' : 'entries'}',
                style: pfText(12.5, color: c.sub),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter(this.progress);

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = size.width * (10 / 84);
    final rect = (Offset.zero & size).deflate(stroke / 2);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke;
    canvas.drawArc(
      rect,
      0,
      2 * pi,
      false,
      paint..color = Colors.white.withValues(alpha: .18),
    );
    canvas.drawArc(
      rect,
      -pi / 2,
      2 * pi * progress.clamp(0, 1),
      false,
      paint..color = PfColors.toastIcon,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.progress != progress;
}
