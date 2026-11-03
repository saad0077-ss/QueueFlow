import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../domain/entities/doctor_plan_entity.dart';
import 'doctor_ui_kit.dart';

class DoctorSlotCard extends StatelessWidget {
  final DoctorPlanEntity plan;
  final int currentCount;
  final VoidCallback onAdd;
  final VoidCallback onUpgrade;

  const DoctorSlotCard({
    super.key,
    required this.plan,
    required this.currentCount,
    required this.onAdd,
    required this.onUpgrade,
  });

  @override
  Widget build(BuildContext context) {
    final isUnlimited = plan.isUnlimited;
    final docLimit = plan.doctorsLimit;
    final isAvailable = isUnlimited || currentCount < docLimit;
    final remaining = isUnlimited ? 999 : (docLimit - currentCount).clamp(0, 999);

    return CustomPaint(
      painter: const _DashedRRectPainter(
        color: Color(0xFF334155),
        strokeWidth: 1.5,
        radius: 14,
        dashLength: 7,
        dashGap: 5,
      ),
      child: Container(
        constraints: const BoxConstraints(minHeight: 310),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.015),
          borderRadius: BorderRadius.circular(14),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 44,
              height: 44,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF1E293B),
              ),
              child: Icon(
                isAvailable ? Icons.add : Icons.lock_outline_rounded,
                size: 22,
                color: isAvailable ? DoctorColors.cyan : DoctorColors.amber,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              isAvailable ? 'Available Doctor Slot' : 'Doctor Limit Reached',
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              isAvailable
                  ? (isUnlimited
                      ? 'Your plan supports unlimited practicing doctors.'
                      : 'You have $remaining open doctor slot${remaining == 1 ? '' : 's'} remaining on your current plan.')
                  : 'Your ${plan.planName} covers $docLimit doctor${docLimit == 1 ? '' : 's'}. Upgrade to add more doctors.',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: DoctorColors.muted,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 18),
            ElevatedButton(
              onPressed: isAvailable ? onAdd : onUpgrade,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0284C7),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                elevation: 0,
              ),
              child: Text(
                isAvailable ? '+ Add Practicing Doctor' : 'Upgrade Plan for More Doctors →',
                style: GoogleFonts.inter(fontSize: 12.5, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashedRRectPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double radius;
  final double dashLength;
  final double dashGap;

  const _DashedRRectPainter({
    required this.color,
    this.strokeWidth = 1.5,
    this.radius = 14,
    this.dashLength = 7,
    this.dashGap = 5,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        strokeWidth / 2,
        strokeWidth / 2,
        size.width - strokeWidth,
        size.height - strokeWidth,
      ),
      Radius.circular(radius),
    );

    final path = Path()..addRRect(rrect);
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final length = (distance + dashLength < metric.length)
            ? dashLength
            : metric.length - distance;
        canvas.drawPath(metric.extractPath(distance, distance + length), paint);
        distance += dashLength + dashGap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedRRectPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.radius != radius;
  }
}
