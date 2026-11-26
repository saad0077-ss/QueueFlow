import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

import '../../pages/privacy_policy_screen.dart';
import '../../pages/terms_conditions_screen.dart';
import 'about_app_info_row.dart';

class AboutAppInfoCard extends StatelessWidget {
  const AboutAppInfoCard({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final divider = Divider(height: 1, color: colors.border, indent: 60);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 10),
          child: Text(
            'APP & LEGAL',
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.7,
              color: colors.textSubtle,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: colors.border),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              AboutAppInfoRow(
                icon: Icons.layers_outlined,
                accent: colors.primary,
                title: 'App Version',
                subtitle: 'Latest installed release',
                trailingValue: '0.1.0 (Build 1)',
              ),
              divider,
              const AboutAppInfoRow(
                icon: Icons.verified_user_outlined,
                accent: Color(0xFF14B8A6),
                title: 'Edition',
                subtitle: 'QueueFlow health suite',
                trailingValue: 'Patient App',
              ),
              divider,
              AboutAppInfoRow(
                icon: Icons.shield_outlined,
                accent: const Color(0xFF3B82F6),
                title: 'Privacy Policy',
                subtitle: 'How your records are protected',
                onTap: () => PrivacyPolicyScreen.open(context),
              ),
              divider,
              AboutAppInfoRow(
                icon: Icons.description_outlined,
                accent: const Color(0xFF8B5CF6),
                title: 'Terms & Conditions',
                subtitle: 'Bookings, queues & refund rules',
                onTap: () => TermsConditionsScreen.open(context),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
