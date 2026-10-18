import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/clinic_entity.dart';

/// Stethoscope vector painter matching the QueueFlow design specification.
class StethoscopeIcon extends StatelessWidget {
  final double size;
  final Color color;

  const StethoscopeIcon({
    super.key,
    this.size = 24,
    this.color = const Color(0xFF38BDF8),
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _StethoscopePainter(color: color),
    );
  }
}

class _StethoscopePainter extends CustomPainter {
  final Color color;

  const _StethoscopePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 24.0;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.7 * scale
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Binaural tubes (U-shaped loop)
    final path1 = Path()
      ..moveTo(6 * scale, 3 * scale)
      ..lineTo(6 * scale, 9 * scale)
      ..arcToPoint(
        Offset(14 * scale, 9 * scale),
        radius: Radius.circular(4 * scale),
        clockwise: false,
      )
      ..lineTo(14 * scale, 3 * scale);
    canvas.drawPath(path1, paint);

    // Flexible tube (lower connecting loop)
    final path2 = Path()
      ..moveTo(10 * scale, 13 * scale)
      ..lineTo(10 * scale, 15 * scale)
      ..arcToPoint(
        Offset(20 * scale, 12.5 * scale),
        radius: Radius.circular(5 * scale),
        clockwise: false,
      );
    canvas.drawPath(path2, paint);

    // Chest piece (bell/diaphragm circle)
    canvas.drawCircle(Offset(20 * scale, 10 * scale), 1.8 * scale, paint);
  }

  @override
  bool shouldRepaint(covariant _StethoscopePainter oldDelegate) =>
      oldDelegate.color != color;
}

/// Clinic Card matching exact QueueFlow mobile design (Image 2).
class HomeClinicCard extends StatelessWidget {
  final ClinicEntity clinic;
  final VoidCallback? onTap;

  const HomeClinicCard({
    super.key,
    required this.clinic,
    this.onTap,
  });

  Widget _buildCategoryIcon() {
    final cat = clinic.category.toLowerCase();
    if (cat.contains('dental')) {
      return const Icon(
        Icons.health_and_safety_outlined,
        color: Color(0xFF2DD4BF),
        size: 26,
      );
    } else if (cat.contains('derma')) {
      return const Icon(
        Icons.water_drop_outlined,
        color: Color(0xFFF59E0B),
        size: 26,
      );
    } else if (cat.contains('diag')) {
      return const Icon(
        Icons.biotech_outlined,
        color: Color(0xFF8B5CF6),
        size: 26,
      );
    }
    return const StethoscopeIcon(size: 26, color: Color(0xFF38BDF8));
  }

  Widget _buildStatusPill() {
    final isOpen = clinic.isOpen;
    final color = isOpen ? const Color(0xFF22C55E) : const Color(0xFF94A3B8);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isOpen ? const Color(0x1F22C55E) : const Color(0x1A94A3B8),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: isOpen ? const Color(0x4022C55E) : const Color(0x2694A3B8),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5.5,
            height: 5.5,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4.5),
          Text(
            isOpen ? 'OPEN' : 'CLOSED',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: color,
              letterSpacing: 0.4,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.darkBorder),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Left Thumbnail
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: const Color(0xFF101C30),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFF1E2E4A)),
                  ),
                  alignment: Alignment.center,
                  child: _buildCategoryIcon(),
                ),
                const SizedBox(width: 14),

                // 2. Right Body
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Clinic Name + Status Pill
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              clinic.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 15.5,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: -0.2,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          _buildStatusPill(),
                        ],
                      ),
                      const SizedBox(height: 5),

                      // Rating & Category
                      Row(
                        children: [
                          const Text(
                            '★',
                            style: TextStyle(
                              fontSize: 12.5,
                              color: Color(0xFF94A3B8),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${clinic.rating}',
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Text(
                              '(${clinic.reviewCount}) · ${clinic.category}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF94A3B8),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),

                      // Location & City
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            size: 13.5,
                            color: Color(0xFF64748B),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              '${clinic.distance} · ${clinic.city}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF64748B),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 7),

                      // View Details CTA Link
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Text(
                            'View details',
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF2563EB),
                            ),
                          ),
                          SizedBox(width: 2),
                          Icon(
                            Icons.chevron_right_rounded,
                            size: 15,
                            color: Color(0xFF2563EB),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
