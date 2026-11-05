import 'package:flutter/material.dart';
import 'package:queueflow_ui/queueflow_ui.dart';
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
    final colors = context.colors;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: colors.border, width: 1),
      ),
      clipBehavior: Clip.antiAlias,
      child: dynamicCardContent(context, colors),
    );
  }

  Widget dynamicCardContent(BuildContext context, AppColorsExtension colors) {
    return Stack(
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
                      border: Border.all(color: colors.surface, width: 4),
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
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: colors.textPrimary,
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
                style: TextStyle(
                  fontSize: 12.5,
                  color: colors.textMuted,
                ),
              ),
              const SizedBox(height: 2),

              // Phone
              Text(
                profile.phone,
                style: TextStyle(
                  fontSize: 12.5,
                  color: colors.textMuted,
                ),
              ),
              if (_ageGender.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  _ageGender,
                  style: TextStyle(
                    fontSize: 12.5,
                    color: colors.textMuted,
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
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.qr_code_2_rounded,
                        size: 14,
                        color: Color(0xFF38BDF8),
                      ),
                      SizedBox(width: 6),
                      Text(
                        'DIGITAL HEALTH PASS',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.6,
                          color: Color(0xFF38BDF8),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Edit Profile Button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: onEditProfile,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: colors.border, width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    backgroundColor: Colors.transparent,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.edit_rounded,
                        size: 15,
                        color: colors.textPrimary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Edit profile',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: colors.textPrimary,
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
    );
  }
}
