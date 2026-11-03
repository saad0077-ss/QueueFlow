import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/clinic_dept_chip.dart';
import '../../../../core/widgets/clinic_photo.dart';
import '../../domain/entities/clinic_entity.dart';

class HomeClinicCard extends StatelessWidget {
  final ClinicEntity clinic;
  final VoidCallback? onTap;

  const HomeClinicCard({
    super.key,
    required this.clinic,
    this.onTap,
  });

  Color get _categoryColor {
    final cat = clinic.category.toLowerCase();
    if (cat.contains('dent')) return const Color(0xFF2DD4BF);
    if (cat.contains('derm')) return const Color(0xFFF59E0B);
    if (cat.contains('diag')) return const Color(0xFF8B5CF6);
    if (cat.contains('pedi')) return const Color(0xFFF43F5E);
    return const Color(0xFF38BDF8);
  }

  Color get _categoryBgColor {
    final cat = clinic.category.toLowerCase();
    if (cat.contains('dent')) return const Color(0xFF10302C);
    if (cat.contains('derm')) return const Color(0xFF302410);
    if (cat.contains('diag')) return const Color(0xFF251B3D);
    if (cat.contains('pedi')) return const Color(0xFF351319);
    return const Color(0xFF16233F);
  }

  IconData get _categoryIcon {
    final cat = clinic.category.toLowerCase();
    if (cat.contains('dent')) return Icons.health_and_safety_rounded;
    if (cat.contains('derm')) return Icons.water_drop_rounded;
    if (cat.contains('diag')) return Icons.biotech_rounded;
    if (cat.contains('pedi')) return Icons.child_care_rounded;
    return Icons.medical_services_rounded;
  }

  Widget _buildThumbnail() {
    final startingLetter = clinic.name.trim().isNotEmpty
        ? clinic.name.trim().substring(0, 1).toUpperCase()
        : 'C';

    if (clinic.imageVersion > 0 || (clinic.imageUrl?.trim().isNotEmpty ?? false)) {
      return Container(
        width: 66,
        height: 66,
        decoration: BoxDecoration(
          color: _categoryBgColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.darkBorder),
        ),
        clipBehavior: Clip.antiAlias,
        child: ClinicPhoto(
          clinicId: clinic.id,
          imageVersion: clinic.imageVersion,
          imageUrl: clinic.imageUrl,
          placeholder: _buildFallbackThumbnail(startingLetter),
        ),
      );
    }

    return _buildFallbackThumbnail(startingLetter);
  }

  Widget _buildFallbackThumbnail(String startingLetter) {
    return Container(
      width: 66,
      height: 66,
      decoration: BoxDecoration(
        color: _categoryBgColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.darkBorder),
      ),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _categoryIcon,
            color: _categoryColor,
            size: 24,
          ),
          const SizedBox(height: 2),
          Text(
            startingLetter,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: _categoryColor.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusPill() {
    final isOpen = clinic.isOpen;
    final color = isOpen ? const Color(0xFF16A34A) : const Color(0xFFDC2626);
    final bgColor = isOpen ? const Color(0xFF123022) : const Color(0xFF351319);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(9999),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            isOpen ? 'OPEN' : 'CLOSED',
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              color: color,
              letterSpacing: 0.2,
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
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.darkBorder),
        boxShadow: const [
          BoxShadow(
            color: Color(0x140F172A),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Thumbnail (66x66)
                _buildThumbnail(),
                const SizedBox(width: 14),

                // 2. Body
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top Row: Name + Status Pill
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
                                fontSize: 14.5,
                                fontWeight: FontWeight.w700,
                                color: AppColors.darkInk,
                                letterSpacing: -0.1,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          _buildStatusPill(),
                        ],
                      ),
                      const SizedBox(height: 5),

                      // Meta Row: Star + Rating + (ReviewCount) · Category
                      Row(
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            size: 14,
                            color: Color(0xFFF59E0B),
                          ),
                          const SizedBox(width: 3),
                          Text(
                            clinic.hasRatings ? clinic.rating.toStringAsFixed(1) : 'New',
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: AppColors.darkInk,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    clinic.hasRatings
                                        ? '(${clinic.reviewCount}) · ${clinic.primaryCategory}'
                                        : clinic.primaryCategory,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.darkInkMuted,
                                    ),
                                  ),
                                ),
                                ClinicDeptChip(clinic: clinic),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),

                      // Location: Pin + Distance · City
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            size: 13,
                            color: AppColors.darkInkFaint,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              '${clinic.distance} · ${clinic.city}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w500,
                                color: AppColors.darkInkFaint,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),

                      // CTA row: View details > and waiting count
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Text(
                                'View details',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF38BDF8),
                                ),
                              ),
                              SizedBox(width: 3),
                              Icon(
                                Icons.chevron_right_rounded,
                                size: 14,
                                color: Color(0xFF38BDF8),
                              ),
                            ],
                          ),
                          if (clinic.hasLiveQueue)
                            Text(
                              '${clinic.waitingCount} in live queue',
                              style: GoogleFonts.jetBrainsMono(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF38BDF8),
                              ),
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
