import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import 'profile_avatar.dart';
import '../../domain/entities/patient_profile_entity.dart';

class ProfileHeroCard extends StatelessWidget {
  final PatientProfileEntity profile;
  final VoidCallback onEditProfile;
  final VoidCallback onDigitalHealthPass;

  const ProfileHeroCard({
    super.key,
    required this.profile,
    required this.onEditProfile,
    required this.onDigitalHealthPass,
  });

  String get _ageGender => [
        if (profile.age != null) '${profile.age} yrs',
        if (profile.gender != null && profile.gender!.isNotEmpty) profile.gender!,
      ].join(' · ');

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: AppColors.darkBorder, width: 1),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Background Gradient Glow at top
          Container(
            height: 96,
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF2563EB), Color(0xFF14B8A6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          // Hero Body Content
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 26, 16, 18),
            child: Column(
              children: [
                // Avatar with Camera Edit Badge
                Center(
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      ProfileAvatar(
                        name: profile.name,
                        photoBase64: profile.photoBase64,
                        size: 84,
                        fontSize: 30,
                        border: Border.all(color: AppColors.darkSurface, width: 4),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.35),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),

                // Name Row with Verified Badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text(
                        profile.name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: AppColors.darkInk,
                          letterSpacing: -0.3,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),

                // Email
                Text(
                  profile.email,
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: AppColors.darkInkMuted,
                  ),
                ),
                const SizedBox(height: 2),

                // Phone
                Text(
                  profile.phone,
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: AppColors.darkInkMuted,
                  ),
                ),
                if (_ageGender.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    _ageGender,
                    style: const TextStyle(
                      fontSize: 12.5,
                      color: AppColors.darkInkMuted,
                    ),
                  ),
                ],
                const SizedBox(height: 12),

                // Digital Health Pass Chip Button
                InkWell(
                  onTap: onDigitalHealthPass,
                  borderRadius: BorderRadius.circular(999),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2563EB).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: const Color(0xFF2563EB).withValues(alpha: 0.35),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.badge_rounded,
                          size: 16,
                          color: Color(0xFF38BDF8),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          profile.healthId,
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF38BDF8),
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'QR Pass →',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.darkInkMuted,
                          ),
                        ),
                      ], 
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // Edit Profile Button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: onEditProfile,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.darkBorder, width: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      backgroundColor: Colors.transparent,
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.edit_rounded,
                          size: 15,
                          color: AppColors.darkInk,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Edit profile',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.darkInk,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
