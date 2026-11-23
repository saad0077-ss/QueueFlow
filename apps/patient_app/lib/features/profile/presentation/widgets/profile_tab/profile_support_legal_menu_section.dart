import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/profile_bloc.dart';
import '../../pages/help_support/help_support_screen.dart';
import '../profile_menu_section.dart';
import 'profile_dialogs.dart';

class ProfileSupportLegalMenuSection extends StatelessWidget {
  const ProfileSupportLegalMenuSection({super.key});

  @override
  Widget build(BuildContext context) {
    return ProfileMenuSection(
      title: 'Support & Legal',
      items: [
        ProfileMenuItem(
          icon: const Icon(
            Icons.headset_mic_rounded,
            size: 18,
            color: Color(0xFF10B981),
          ),
          iconBgColor: const Color(0xFF10B981).withValues(alpha: 0.15),
          title: 'Help & Support',
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => BlocProvider.value(
                  value: context.read<ProfileBloc>(),
                  child: const HelpSupportScreen(),
                ),
              ),
            );
          },
        ),
        ProfileMenuItem(
          icon: const Icon(
            Icons.shield_outlined,
            size: 18,
            color: Color(0xFF3B82F6),
          ),
          iconBgColor: const Color(0xFF3B82F6).withValues(alpha: 0.15),
          title: 'Privacy Policy',
          onTap: () => ProfileDialogs.showComingSoon(context, 'Privacy Policy'),
        ),
        ProfileMenuItem(
          icon: const Icon(
            Icons.description_outlined,
            size: 18,
            color: Color(0xFF94A3B8),
          ),
          iconBgColor: const Color(0xFF64748B).withValues(alpha: 0.15),
          title: 'Terms of Service',
          onTap: () =>
              ProfileDialogs.showComingSoon(context, 'Terms of Service'),
        ),
      ],
    );
  }
}
