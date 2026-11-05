import 'package:flutter/material.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

/// Rounded card with a thick colored stripe on the left edge.
///
/// Flutter cannot paint a [BoxDecoration] that combines a borderRadius with
/// non-uniform border widths (it throws during paint and blanks the screen),
/// so the stripe is drawn by an inner box clipped by the rounded outer one.
class AccentBorderCard extends StatelessWidget {
  final Color accent;
  final Color? color;
  final double radius;
  final EdgeInsetsGeometry padding;
  final Widget child;

  const AccentBorderCard({
    super.key,
    required this.accent,
    required this.child,
    this.color,
    this.radius = 14,
    this.padding = const EdgeInsets.all(18),
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: color ?? colors.surface,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: colors.border),
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
