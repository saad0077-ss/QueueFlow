import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:queueflow_ui/queueflow_ui.dart';
import 'package:patient_app/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:patient_app/features/profile/presentation/bloc/profile_event.dart';
import 'package:patient_app/features/profile/presentation/bloc/profile_state.dart';
import '../profile_menu_section.dart';

class ProfilePreferencesMenuSection extends StatelessWidget {
  final ProfileState state;

  const ProfilePreferencesMenuSection({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final profile = state.profile!;
    final bloc = context.read<ProfileBloc>();

    return ProfileMenuSection(
      title: 'Preferences',
      items: [
        ProfileMenuItem(
          icon: const Icon(Icons.dark_mode_rounded, size: 18, color: Color(0xFF7C3AED)),
          iconBgColor: const Color(0xFF7C3AED).withValues(alpha: 0.15),
          title: 'Dark mode',
          trailing: Switch.adaptive(
            value: (context.watch<ThemeBloc?>()?.state.isDark) ?? profile.darkMode,
            activeTrackColor: const Color(0xFF7C3AED),
            onChanged: (val) {
              context.read<ThemeBloc?>()?.add(ThemeModeChanged(val ? ThemeMode.dark : ThemeMode.light));
              bloc.add(ProfileDarkModeToggled(val));
            },
          ),
          onTap: () {
            final currentIsDark = (context.read<ThemeBloc?>()?.state.isDark) ?? profile.darkMode;
            final nextVal = !currentIsDark;
            context.read<ThemeBloc?>()?.add(ThemeModeChanged(nextVal ? ThemeMode.dark : ThemeMode.light));
            bloc.add(ProfileDarkModeToggled(nextVal));
          },
        ),
      ],
    );
  }
}
