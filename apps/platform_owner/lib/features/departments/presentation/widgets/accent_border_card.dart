import 'package:flutter/material.dart';

/// Rounded card with a thick colored stripe on the left edge.
///
/// Flutter cannot paint a [BoxDecoration] that combines a borderRadius with
/// non-uniform border widths (it throws during paint and blanks the screen),
/// so the stripe is drawn by an inner box clipped by the rounded outer one.
class AccentBorderCard extends StatelessWidget {
  final Color accent;
  final Color color;
  final double radius;
  final EdgeInsetsGeometry padding;
  final Widget child;

  const AccentBorderCard({
    super.key,
    required this.accent,
    required this.child,
    this.color = const Color(0xFF0D1526),
    this.radius = 14,
    this.padding = const EdgeInsets.all(18),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: const Color(0xFF1E293B)),
      ),
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          border: Border(left: BorderSide(color: accent, width: 4)),
        ),
        child: child,
      ),
    );
  }
}
