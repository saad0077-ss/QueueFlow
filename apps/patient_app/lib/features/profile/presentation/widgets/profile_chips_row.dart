import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class ProfileChipsRow extends StatelessWidget {
  final String? bloodGroup;
  final int? age;
  final String? gender;

  const ProfileChipsRow({
    super.key,
    this.bloodGroup,
    this.age,
    this.gender,
  });

  String get _ageGender => [
        if (age != null) '$age Yrs',
        if (gender != null && gender!.isNotEmpty) gender!,
      ].join(' • ');

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Row(
        children: [
          // Chip 1: Blood Group
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.darkSurface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.darkBorder, width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'BLOOD',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                      color: AppColors.darkInkMuted,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    (bloodGroup == null || bloodGroup!.isEmpty) ? '—' : bloodGroup!,
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                      color: AppColors.darkInk,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Chip 2: Age • Gender
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.darkSurface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.darkBorder, width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'AGE • GENDER',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                      color: AppColors.darkInkMuted,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    _ageGender.isEmpty ? '—' : _ageGender,
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                      color: AppColors.darkInk,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
