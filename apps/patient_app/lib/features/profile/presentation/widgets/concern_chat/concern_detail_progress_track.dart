import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

/// Animated gradient progress header & track rendered above concern milestones.
class ConcernDetailProgressTrack extends StatelessWidget {
  final int activeStep;
  final int totalSteps;
  final String stageLabel;
  final bool isResolved;

  const ConcernDetailProgressTrack({
    super.key,
    required this.activeStep,
    this.totalSteps = 4,
    required this.stageLabel,
    required this.isResolved,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final ratio = (activeStep / totalSteps).clamp(0.0, 1.0);
    final pct = (ratio * 100).round();
    final accent = isResolved ? const Color(0xFF10B981) : const Color(0xFF3B82F6);
    final gradient = isResolved
        ? const LinearGradient(colors: [Color(0xFF059669), Color(0xFF34D399)])
        : const LinearGradient(colors: [Color(0xFF2563EB), Color(0xFF06B6D4)]);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                color: accent,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: accent.withValues(alpha: 0.45), blurRadius: 6),
                ],
              ),
            ),
            const SizedBox(width: 7),
            Expanded(
              child: Text(
                'Step $activeStep of $totalSteps • $stageLabel',
                style: GoogleFonts.inter(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: colors.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: accent.withValues(alpha: 0.3)),
              ),
              child: Text(
                '$pct%',
                style: GoogleFonts.inter(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                  color: accent,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(99),
          child: SizedBox(
            height: 8,
            child: Stack(
              children: [
                Positioned.fill(
                  child: Container(color: colors.border.withValues(alpha: 0.45)),
                ),
                FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: ratio,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 350),
                    curve: Curves.easeOutCubic,
                    decoration: BoxDecoration(
                      gradient: gradient,
                      borderRadius: BorderRadius.circular(99),
                      boxShadow: [
                        BoxShadow(
                          color: accent.withValues(alpha: 0.35),
                          blurRadius: 8,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
