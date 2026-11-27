import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

/// Single connected milestone column inside [ConcernDetailStepper].
class ConcernDetailStepNode extends StatelessWidget {
  final String label;
  final String sub;
  final bool done;
  final bool active;
  final IconData icon;
  final bool showLeftLine;
  final bool showRightLine;
  final bool leftDone;
  final bool rightDone;

  const ConcernDetailStepNode({
    super.key,
    required this.label,
    required this.sub,
    required this.done,
    required this.active,
    required this.icon,
    required this.showLeftLine,
    required this.showRightLine,
    required this.leftDone,
    required this.rightDone,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    const doneColor = Color(0xFF10B981);
    const activeColor = Color(0xFF2563EB);
    final nodeColor =
        done ? doneColor : (active ? activeColor : colors.surfaceSecondary);

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Container(
                height: 2.5,
                color: !showLeftLine
                    ? Colors.transparent
                    : (leftDone ? doneColor : colors.border),
              ),
            ),
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: nodeColor,
                border: (!done && !active)
                    ? Border.all(color: colors.border, width: 1.5)
                    : (active
                        ? Border.all(
                            color: activeColor.withValues(alpha: 0.35),
                            width: 3,
                          )
                        : null),
                boxShadow: (done || active)
                    ? [
                        BoxShadow(
                          color: (done ? doneColor : activeColor)
                              .withValues(alpha: 0.25),
                          blurRadius: 6,
                        ),
                      ]
                    : null,
              ),
              child: Icon(
                done ? Icons.check_rounded : icon,
                size: 14,
                color: (done || active) ? Colors.white : colors.textMuted,
              ),
            ),
            Expanded(
              child: Container(
                height: 2.5,
                color: !showRightLine
                    ? Colors.transparent
                    : (rightDone ? doneColor : colors.border),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: (done || active) ? colors.textPrimary : colors.textMuted,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          sub,
          style: GoogleFonts.inter(fontSize: 8.5, color: colors.textMuted),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
