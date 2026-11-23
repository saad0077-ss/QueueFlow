import 'package:flutter/material.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

import '../../domain/entities/patient_profile_entity.dart';
import 'profile_avatar.dart';

class ProfileHeroCard extends StatelessWidget {
  final PatientProfileEntity profile;
  final VoidCallback onEditProfile;

  const ProfileHeroCard({
    super.key,
    required this.profile,
    required this.onEditProfile,
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
      child: Stack(
        children: [
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
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 26, 16, 18),
            child: Column(
              children: [
                Center(
                  child: ProfileAvatar(
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
                ),
                const SizedBox(height: 10),
                Text(
                  profile.name,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: colors.textPrimary,
                    letterSpacing: -0.3,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  profile.email,
                  style: TextStyle(fontSize: 12.5, color: colors.textMuted),
                ),
                const SizedBox(height: 2),
                Text(
                  profile.phone,
                  style: TextStyle(fontSize: 12.5, color: colors.textMuted),
                ),
                if (_ageGender.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    _ageGender,
                    style: TextStyle(fontSize: 12.5, color: colors.textMuted),
                  ),
                ],
                const SizedBox(height: 16),
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
      ),
    );
  }
}
