import 'dart:math';

import 'package:flutter/material.dart';

import '../../core/format.dart';
import '../../data/insights.dart';
import '../../theme/tokens.dart';
import '../../widgets/category_icons.dart';
import '../../widgets/pf.dart';

/// Short money for chart labels: "Rs 85k", "Rs 1.2k".
String chartMoney(double v, String currency) {
  final abs = v.abs();
  if (abs >= 1000) {
    final k = abs / 1000;
    final text = k >= 100 ? k.toStringAsFixed(0) : k.toStringAsFixed(1);
    return '${Currency.of(currency).symbol} ${text.replaceAll('.0', '')}k';
  }
  return money(v.roundToDouble(), currency);
}

/// Groups categories under [minShare] of the total into one "Others" item.
List<Breakdown> groupSmall(
  List<Breakdown> items,
  String othersLabel, {
  double minShare = .03,
  int max = 7,
}) {
  final total = items.fold(0.0, (s, b) => s + b.amount);
  if (total <= 0) return const [];
  final kept = <Breakdown>[];
  var rest = 0.0;
  for (final b in items) {
    if (b.amount / total >= minShare && kept.length < max) {
      kept.add(b);
    } else {
      rest += b.amount;
    }
  }
  if (rest > 0) kept.add(Breakdown(othersLabel, rest, rest / total));
  return kept;
}

// ---------------------------------------------------------------------------
// Flow (Sankey)
// ---------------------------------------------------------------------------

class FlowNode {
  const FlowNode(this.label, this.amount, this.color);

  final String label;
  final double amount;
  final Color color;
}

/// Income on the left flows through the month in the middle into spending
/// (and what was saved) on the right. Band widths are to scale.
class FlowChart extends StatelessWidget {
  const FlowChart({
    super.key,
    required this.left,
    required this.right,
    required this.middleColor,
    required this.currency,
    required this.semanticLabel,
  });

  final List<FlowNode> left;
  final List<FlowNode> right;
  final Color middleColor;
  final String currency;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    final c = context.pf;
    final rows = max(left.length, right.length);
    final height = max(200.0, rows * 34.0 + 20);
    return Semantics(
      label: semanticLabel,
      excludeSemantics: true,
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: CustomPaint(
          painter: _FlowPainter(
            left: left,
            right: right,
            middleColor: middleColor,
            currency: currency,
            textColor: c.ink,
            subColor: c.sub,
            textScaler: MediaQuery.textScalerOf(context),
          ),
        ),
      ),
    );
  }
}

class _FlowPainter extends CustomPainter {
  _FlowPainter({
    required this.left,
    required this.right,
    required this.middleColor,
    required this.currency,
    required this.textColor,
    required this.subColor,
    required this.textScaler,
  });

  final List<FlowNode> left;
  final List<FlowNode> right;
  final Color middleColor;
  final String currency;
  final Color textColor;
  final Color subColor;
  final TextScaler textScaler;

  static const nodeW = 9.0;
  static const gap = 7.0;

  @override
  void paint(Canvas canvas, Size size) {
    final total = max(
      left.fold(0.0, (s, n) => s + n.amount),
      right.fold(0.0, (s, n) => s + n.amount),
    );
    if (total <= 0) return;
    final labelW = size.width * .31;
    final leftX = labelW;
    final rightX = size.width - labelW - nodeW;
    final midX = (size.width - nodeW) / 2;
    final rows = max(left.length, right.length);
    final k = (size.height - gap * (rows - 1) - 8) / total;

    List<Rect> stack(List<FlowNode> nodes, double x) {
      final h =
          nodes.fold(0.0, (s, n) => s + n.amount * k) +
          gap * (nodes.length - 1);
      var y = (size.height - h) / 2;
      return [
        for (final n in nodes)
          () {
            final r = Rect.fromLTWH(x, y, nodeW, max(1.5, n.amount * k));
            y += n.amount * k + gap;
            return r;
          }(),
      ];
    }

    final leftRects = stack(left, leftX);
    final rightRects = stack(right, rightX);
    final midH = total * k;
    final mid = Rect.fromLTWH(midX, (size.height - midH) / 2, nodeW, midH);

    void band(
      Rect from,
      double fromY,
      Rect to,
      double toY,
      double h,
      Color color,
    ) {
      final x0 = from.right, x1 = to.left, mx = (x0 + x1) / 2;
      final path = Path()
        ..moveTo(x0, fromY)
        ..cubicTo(mx, fromY, mx, toY, x1, toY)
        ..lineTo(x1, toY + h)
        ..cubicTo(mx, toY + h, mx, fromY + h, x0, fromY + h)
        ..close();
      canvas.drawPath(path, Paint()..color = color.withValues(alpha: .26));
    }

    var midIn = mid.top;
    for (var i = 0; i < left.length; i++) {
      final h = left[i].amount * k;
      band(leftRects[i], leftRects[i].top, mid, midIn, h, left[i].color);
      midIn += h;
    }
    var midOut = mid.top;
    for (var i = 0; i < right.length; i++) {
      final h = right[i].amount * k;
      band(mid, midOut, rightRects[i], rightRects[i].top, h, right[i].color);
      midOut += h;
    }

    final radius = const Radius.circular(3);
    for (var i = 0; i < left.length; i++) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(leftRects[i], radius),
        Paint()..color = left[i].color,
      );
    }
    for (var i = 0; i < right.length; i++) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(rightRects[i], radius),
        Paint()..color = right[i].color,
      );
    }
    canvas.drawRRect(
      RRect.fromRectAndRadius(mid, radius),
      Paint()..color = middleColor,
    );

    // Labels sit beside their node; small nodes are close together, so
    // overlapping labels are pushed apart, and when two lines each don't fit
    // they become one line ("Health · Rs 4.2k").
    void labels(
      List<FlowNode> nodes,
      List<Rect> rects, {
      required bool onLeft,
    }) {
      TextPainter painter(FlowNode n, {required bool twoLines}) => TextPainter(
        text: TextSpan(
          children: [
            TextSpan(
              text: twoLines ? '${n.label}\n' : '${n.label} · ',
              style: pfText(11, weight: w800, color: textColor),
            ),
            TextSpan(
              text: chartMoney(n.amount, currency),
              style: pfText(10.5, weight: w700, color: subColor),
            ),
          ],
        ),
        textDirection: TextDirection.ltr,
        textAlign: onLeft ? TextAlign.right : TextAlign.left,
        maxLines: twoLines ? 2 : 1,
        ellipsis: '…',
        textScaler: textScaler.clamp(maxScaleFactor: 1.2),
      )..layout(maxWidth: labelW - 8);
      var painters = [for (final n in nodes) painter(n, twoLines: true)];
      if (painters.fold(0.0, (s, p) => s + p.height) > size.height) {
        painters = [for (final n in nodes) painter(n, twoLines: false)];
      }
      final ys = [
        for (var i = 0; i < nodes.length; i++)
          rects[i].center.dy - painters[i].height / 2,
      ];
      // Down from the top, then back up from the bottom.
      var floor = 0.0;
      for (var i = 0; i < ys.length; i++) {
        ys[i] = max(ys[i], floor);
        floor = ys[i] + painters[i].height;
      }
      var ceiling = size.height;
      for (var i = ys.length - 1; i >= 0; i--) {
        ys[i] = min(ys[i], ceiling - painters[i].height);
        ceiling = ys[i];
      }
      for (var i = 0; i < nodes.length; i++) {
        final p = painters[i];
        final x = onLeft ? rects[i].left - 6 - p.width : rects[i].right + 6;
        p.paint(canvas, Offset(x, ys[i]));
      }
    }

    labels(left, leftRects, onLeft: true);
    labels(right, rightRects, onLeft: false);
  }

  @override
  bool shouldRepaint(_FlowPainter old) =>
      old.left != left || old.right != right || old.textColor != textColor;
}

// ---------------------------------------------------------------------------
// Pace
// ---------------------------------------------------------------------------

/// Cumulative spending this month (solid), where it's heading (dashed), and
/// last month (grey) for comparison.
class PaceChart extends StatelessWidget {
  const PaceChart({
    super.key,
    required this.pace,
    required this.currency,
    required this.semanticLabel,
    this.budget,
  });

  final PaceSummary pace;
  final String currency;
  final String semanticLabel;

  /// The month's overall budget, drawn as a gold line.
  final double? budget;

  @override
  Widget build(BuildContext context) {
    final c = context.pf;
    return Semantics(
      label: semanticLabel,
      excludeSemantics: true,
      child: SizedBox(
        height: 190,
        width: double.infinity,
        child: CustomPaint(
          painter: _PacePainter(
            pace: pace,
            budget: budget,
            budgetColor: c.gold,
            currency: currency,
            line: c.cashOut,
            last: c.mute,
            grid: c.line,
            text: c.sub,
          ),
        ),
      ),
    );
  }
}

class _PacePainter extends CustomPainter {
  _PacePainter({
    required this.pace,
    required this.budget,
    required this.budgetColor,
    required this.currency,
    required this.line,
    required this.last,
    required this.grid,
    required this.text,
  });

  final PaceSummary pace;
  final double? budget;
  final Color budgetColor;
  final String currency;
  final Color line;
  final Color last;
  final Color grid;
  final Color text;

  @override
  void paint(Canvas canvas, Size size) {
    const left = 40.0, bottom = 20.0, top = 8.0, right = 8.0;
    final top0 = [
      pace.spent,
      pace.projected ?? 0,
      if (pace.lastMonth.isNotEmpty) pace.lastMonth.last,
      budget ?? 0,
    ].reduce(max);
    final peak = top0 <= 0 ? 1.0 : top0 * 1.1;
    final w = size.width - left - right;
    final h = size.height - top - bottom;
    double x(num day) => left + (day - 1) / max(1, pace.days - 1) * w;
    double y(double v) => top + h * (1 - v / peak);

    void label(String s, Offset at, {TextAlign align = TextAlign.left}) {
      final p = TextPainter(
        text: TextSpan(
          text: s,
          style: pfText(9.5, weight: w700, color: text),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      final dx = switch (align) {
        TextAlign.right => at.dx - p.width,
        TextAlign.center => at.dx - p.width / 2,
        _ => at.dx,
      };
      p.paint(canvas, Offset(dx, at.dy - p.height / 2));
    }

    final gridPaint = Paint()
      ..color = grid
      ..strokeWidth = 1;
    for (var i = 0; i <= 2; i++) {
      final v = peak / 1.1 * i / 2;
      canvas.drawLine(
        Offset(left, y(v)),
        Offset(size.width - right, y(v)),
        gridPaint,
      );
      label(
        chartMoney(v, currency),
        Offset(left - 6, y(v)),
        align: TextAlign.right,
      );
    }
    for (final d in {1, 10, 20, pace.days}) {
      label('$d', Offset(x(d), size.height - 8), align: TextAlign.center);
    }

    Path pathOf(List<double> values) {
      final p = Path();
      for (var i = 0; i < values.length; i++) {
        final day = min(i + 1, pace.days);
        final point = Offset(x(day), y(values[i]));
        i == 0 ? p.moveTo(point.dx, point.dy) : p.lineTo(point.dx, point.dy);
      }
      return p;
    }

    void dashed(Path path, Paint paint) {
      for (final metric in path.computeMetrics()) {
        var d = 0.0;
        while (d < metric.length) {
          canvas.drawPath(metric.extractPath(d, d + 5), paint);
          d += 9;
        }
      }
    }

    if (budget case final b?) {
      dashed(
        Path()
          ..moveTo(left, y(b))
          ..lineTo(size.width - right, y(b)),
        Paint()
          ..color = budgetColor
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke,
      );
    }
    if (pace.lastMonth.isNotEmpty) {
      dashed(
        pathOf(pace.lastMonth.take(pace.days).toList()),
        Paint()
          ..color = last
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke,
      );
    }
    if (pace.thisMonth.isNotEmpty) {
      final p = pathOf(pace.thisMonth);
      final fill = Path.from(p)
        ..lineTo(x(pace.thisMonth.length), y(0))
        ..lineTo(x(1), y(0))
        ..close();
      canvas.drawPath(fill, Paint()..color = line.withValues(alpha: .12));
      canvas.drawPath(
        p,
        Paint()
          ..color = line
          ..strokeWidth = 2.5
          ..style = PaintingStyle.stroke
          ..strokeJoin = StrokeJoin.round,
      );
      final end = Offset(x(pace.thisMonth.length), y(pace.spent));
      if (pace.projected case final projected?) {
        dashed(
          Path()
            ..moveTo(end.dx, end.dy)
            ..lineTo(x(pace.days), y(projected)),
          Paint()
            ..color = line.withValues(alpha: .55)
            ..strokeWidth = 2
            ..style = PaintingStyle.stroke,
        );
      }
      canvas.drawCircle(end, 4, Paint()..color = line);
    }
  }

  @override
  bool shouldRepaint(_PacePainter old) =>
      old.pace != pace || old.line != line || old.budget != budget;
}

// ---------------------------------------------------------------------------
// Category boxes (treemap)
// ---------------------------------------------------------------------------

/// Spending by category as boxes sized to scale; tap one to open it.
class CategoryBoxes extends StatelessWidget {
  const CategoryBoxes({
    super.key,
    required this.items,
    required this.currency,
    required this.onOpen,
    this.othersLabel,
    this.badge,
  });

  final List<Breakdown> items;
  final String currency;
  final ValueChanged<String> onOpen;

  /// "90%" or "Over" for a category at 80% of its budget or more.
  final String? Function(String category)? badge;

  /// The grouped "Others" box opens nothing.
  final String? othersLabel;

  static List<(Breakdown, Rect)> layout(List<Breakdown> items, Rect area) {
    final out = <(Breakdown, Rect)>[];
    void split(List<Breakdown> list, Rect r) {
      if (list.isEmpty) return;
      if (list.length == 1) {
        out.add((list.single, r));
        return;
      }
      final total = list.fold(0.0, (s, b) => s + b.amount);
      var acc = 0.0, cut = 1;
      for (var i = 0; i < list.length - 1; i++) {
        acc += list[i].amount;
        cut = i + 1;
        if (acc >= total / 2) break;
      }
      final a = list.take(cut).toList(), b = list.skip(cut).toList();
      final share = a.fold(0.0, (s, x) => s + x.amount) / total;
      if (r.width >= r.height) {
        final w = r.width * share;
        split(a, Rect.fromLTWH(r.left, r.top, w, r.height));
        split(b, Rect.fromLTWH(r.left + w, r.top, r.width - w, r.height));
      } else {
        final h = r.height * share;
        split(a, Rect.fromLTWH(r.left, r.top, r.width, h));
        split(b, Rect.fromLTWH(r.left, r.top + h, r.width, r.height - h));
      }
    }

    split(items, area);
    return out;
  }

  @override
  Widget build(BuildContext context) {
    final c = context.pf;
    return LayoutBuilder(
      builder: (context, box) {
        const height = 240.0;
        final tiles = layout(items, Rect.fromLTWH(0, 0, box.maxWidth, height));
        return SizedBox(
          height: height,
          child: Stack(
            children: [
              for (final (i, (b, r)) in tiles.indexed)
                Positioned.fromRect(
                  rect: r.deflate(2),
                  child: _Box(
                    item: b,
                    badge: badge?.call(b.name),
                    color: b.name == othersLabel
                        ? c.mute
                        : chartColors[i % chartColors.length],
                    currency: currency,
                    onTap: b.name == othersLabel ? null : () => onOpen(b.name),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _Box extends StatelessWidget {
  const _Box({
    required this.item,
    required this.color,
    required this.currency,
    required this.onTap,
    this.badge,
  });

  final Breakdown item;
  final String? badge;
  final Color color;
  final String currency;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final pct = '${(item.share * 100).round()}%';
    return Semantics(
      button: onTap != null,
      label: [item.name, money(item.amount, currency), pct, ?badge].join(', '),
      excludeSemantics: true,
      child: Material(
        color: color,
        borderRadius: BorderRadius.circular(10),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: LayoutBuilder(
            builder: (context, box) {
              final roomy = box.maxWidth > 70 && box.maxHeight > 48;
              final tiny = box.maxWidth < 34 || box.maxHeight < 26;
              return Padding(
                padding: const EdgeInsets.all(7),
                child: tiny
                    ? const SizedBox.shrink()
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              if (roomy) ...[
                                Icon(
                                  categoryIcon(item.name),
                                  size: 13,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 4),
                              ],
                              Flexible(
                                child: Text(
                                  item.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: pfText(
                                    11.5,
                                    weight: w900,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (badge != null && roomy)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 1,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(99),
                              ),
                              child: Text(
                                badge!,
                                style: pfText(
                                  10,
                                  weight: w900,
                                  color: context.pf.cashOut,
                                ),
                              ),
                            ),
                          if (roomy)
                            Text(
                              '${chartMoney(item.amount, currency)} · $pct',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: pfText(
                                10.5,
                                weight: w700,
                                color: Colors.white.withValues(alpha: .9),
                              ),
                            ),
                        ],
                      ),
              );
            },
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Six months of one category
// ---------------------------------------------------------------------------

class MonthBars extends StatelessWidget {
  const MonthBars({
    super.key,
    required this.months,
    required this.average,
    required this.color,
    required this.currency,
    required this.semanticLabel,
    this.budget,
  });

  final List<(String, double)> months;
  final double average;

  /// The category's monthly budget, drawn as a gold line.
  final double? budget;
  final Color color;
  final String currency;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    final c = context.pf;
    return Semantics(
      label: semanticLabel,
      excludeSemantics: true,
      child: SizedBox(
        height: 170,
        width: double.infinity,
        child: CustomPaint(
          painter: _BarsPainter(
            months: months,
            average: average,
            budget: budget,
            budgetColor: c.gold,
            color: color,
            ink: c.ink,
            sub: c.sub,
            grid: c.line,
            currency: currency,
          ),
        ),
      ),
    );
  }
}

class _BarsPainter extends CustomPainter {
  _BarsPainter({
    required this.months,
    required this.average,
    required this.budget,
    required this.budgetColor,
    required this.color,
    required this.ink,
    required this.sub,
    required this.grid,
    required this.currency,
  });

  final List<(String, double)> months;
  final double average;
  final double? budget;
  final Color budgetColor;
  final Color color;
  final Color ink;
  final Color sub;
  final Color grid;
  final String currency;

  @override
  void paint(Canvas canvas, Size size) {
    const bottom = 20.0, top = 16.0;
    final peak = max(
      1.0,
      months.map((m) => m.$2).fold(max(average, budget ?? 0), max) * 1.1,
    );
    final h = size.height - top - bottom;
    final step = size.width / months.length;
    final barW = min(30.0, step * .55);
    double y(double v) => top + h * (1 - v / peak);
    canvas.drawLine(
      Offset(0, y(0)),
      Offset(size.width, y(0)),
      Paint()..color = grid,
    );
    for (var i = 0; i < months.length; i++) {
      final (label, value) = months[i];
      final last = i == months.length - 1;
      final cx = step * i + step / 2;
      final rect = Rect.fromLTRB(cx - barW / 2, y(value), cx + barW / 2, y(0));
      canvas.drawRRect(
        RRect.fromRectAndCorners(
          rect,
          topLeft: const Radius.circular(5),
          topRight: const Radius.circular(5),
        ),
        Paint()..color = last ? color : color.withValues(alpha: .4),
      );
      final p = TextPainter(
        text: TextSpan(
          text: label,
          style: pfText(
            10,
            weight: last ? w900 : w700,
            color: last ? ink : sub,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      p.paint(canvas, Offset(cx - p.width / 2, size.height - p.height));
    }
    if (budget case final b?) {
      canvas.drawLine(
        Offset(0, y(b)),
        Offset(size.width, y(b)),
        Paint()
          ..color = budgetColor
          ..strokeWidth = 2,
      );
    }
    if (average > 0) {
      final avgY = y(average);
      for (var x = 0.0; x < size.width; x += 9) {
        canvas.drawLine(
          Offset(x, avgY),
          Offset(min(x + 5, size.width), avgY),
          Paint()
            ..color = ink
            ..strokeWidth = 1.2,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_BarsPainter old) =>
      old.months != months || old.color != color;
}
