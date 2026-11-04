import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/favorite_clinic_entity.dart';

class FavoriteClinicsSheet extends StatelessWidget {
  final List<FavoriteClinicEntity> clinics;
  final ValueChanged<FavoriteClinicEntity>? onBookClinic;

  const FavoriteClinicsSheet({
    super.key,
    required this.clinics,
    this.onBookClinic,
  });

  static Future<void> show(
    BuildContext context, {
    required List<FavoriteClinicEntity> clinics,
    ValueChanged<FavoriteClinicEntity>? onBookClinic,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => FavoriteClinicsSheet(
        clinics: clinics,
        onBookClinic: onBookClinic,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      decoration: const BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Favorite Clinics',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.darkInk,
                    ),
                  ),
                  SizedBox(height: 3),
                  Text(
                    'Quick access to your trusted doctors',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.darkInkMuted,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded, color: AppColors.darkInkMuted, size: 20),
                onPressed: () => Navigator.of(context).pop(),
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.darkBorder.withValues(alpha: 0.5),
                  shape: const CircleBorder(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Clinics List
          Expanded(
            child: ListView.separated(
              itemCount: clinics.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final clinic = clinics[index];
                return Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.darkBgApp,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.darkBorder, width: 1),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Clinic initials box
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: Color(clinic.accentColorHex).withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              clinic.initials,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: Color(clinic.accentColorHex),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),

                          // Name & department
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  clinic.name,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.darkInk,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  clinic.department,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.darkInkMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Rating pill
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF59E0B).withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.star_rounded, size: 13, color: Color(0xFFF59E0B)),
                                const SizedBox(width: 3),
                                Text(
                                  clinic.rating.toStringAsFixed(1),
                                  style: const TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFFF59E0B),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Location text
                      Row(
                        children: [
                          const Icon(Icons.location_on_outlined, size: 14, color: AppColors.darkInkFaint),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              clinic.address,
                              style: const TextStyle(
                                fontSize: 11.5,
                                color: AppColors.darkInkFaint,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Actions row
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                                onBookClinic?.call(clinic);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 9),
                                elevation: 0,
                              ),
                              child: const Text(
                                'Book Appointment',
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
