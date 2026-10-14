import 'dart:math';

import 'package:flutter/material.dart';

/// The "Paisa drop" mark: a drop of flow with a coin at its heart.
///
/// Built like the design: a square with radii 50% / 14% / 50% / 50% rotated
/// −45° so the tight corner points up.
class PaisaDrop extends StatelessWidget {
  const PaisaDrop({
    super.key,
    required this.size,
    required this.color,
    this.coin,
    this.coinFraction = 28 / 72,
    this.semanticLabel = 'Paisa Flow',
  });

  final double size;
  final Color color;

  /// Colour of the centre coin; null draws a solid drop.
  final Color? coin;
  final double coinFraction;

  /// Null when the name is already written next to the mark.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final round = Radius.circular(size / 2);
    return Semantics(
      label: semanticLabel,
      image: semanticLabel != null,
      excludeSemantics: semanticLabel == null,
      child: SizedBox.square(
        // The rotated square's diagonal needs room; 88 / 72 as in the design.
        dimension: size * 88 / 72,
        child: Center(
          child: Transform.rotate(
            angle: -pi / 4,
            child: Container(
              width: size,
              height: size,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.only(
                  topLeft: round,
                  topRight: Radius.circular(size * .14),
                  bottomRight: round,
                  bottomLeft: round,
                ),
              ),
              child: coin == null
                  ? null
                  : Container(
                      width: size * coinFraction,
                      height: size * coinFraction,
                      decoration: BoxDecoration(
                        color: coin,
                        shape: BoxShape.circle,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
