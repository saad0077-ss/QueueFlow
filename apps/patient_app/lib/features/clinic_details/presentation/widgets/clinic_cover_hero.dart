import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/clinic_photo.dart';

class ClinicCoverHero extends StatelessWidget {
  final String clinicName;
  final String clinicId;
  final int imageVersion;
  final String? imageUrl;
  final bool isFavorite;
  final VoidCallback onBack;
  final VoidCallback onToggleFavorite;

  const ClinicCoverHero({
    super.key,
    required this.clinicName,
    required this.clinicId,
    this.imageVersion = 0,
    this.imageUrl,
    required this.isFavorite,
    required this.onBack,
    required this.onToggleFavorite,
  });

  @override
  Widget build(BuildContext context) {
    final letter = clinicName.trim().isNotEmpty
        ? clinicName.trim().substring(0, 1).toUpperCase()
        : 'C';

    return Container(
      margin: const EdgeInsets.only(bottom: 34),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            height: 130,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(AppColors.radiusLg),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _actionButton(
                    icon: Icons.arrow_back_rounded,
                    onTap: onBack,
                  ),
                  _actionButton(
                    icon: isFavorite
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    color: isFavorite ? Colors.redAccent : Colors.white,
                    onTap: onToggleFavorite,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: -22,
            left: 16,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: AppColors.darkSurface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.darkBorder, width: 2),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: ClinicPhoto(
                clinicId: clinicId,
                imageVersion: imageVersion,
                imageUrl: imageUrl,
                placeholder: _initialBadge(letter),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionButton({
    required IconData icon,
    required VoidCallback onTap,
    Color color = Colors.white,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.22),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 19),
        ),
      ),
    );
  }

  Widget _initialBadge(String letter) {
    return Center(
      child: Text(
        letter,
        style: const TextStyle(
          color: AppColors.primaryLight,
          fontSize: 24,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
