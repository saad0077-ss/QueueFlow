import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

import '../../../../core/layout/patient_breakpoints.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';
import '../pages/edit_profile_screen.dart';
import '../pages/favorite_clinics_screen.dart';
import 'profile_chips_row.dart';
import 'profile_hero_card.dart';
import 'profile_stats_strip.dart';
import 'profile_tab/profile_account_menu_section.dart';
import 'profile_tab/profile_activity_menu_section.dart';
import 'profile_tab/profile_fallback_provider.dart';
import 'profile_tab/profile_laptop_layout.dart';
import 'profile_tab/profile_mobile_layout.dart';
import 'profile_tab/profile_preferences_menu_section.dart';
import 'profile_tab/profile_support_legal_menu_section.dart';
import 'profile_tab/profile_tab_listener.dart';

class ProfileTabView extends StatelessWidget {
  final VoidCallback? onVisitsTap;
  final VoidCallback? onTrackLiveQueue;

  const ProfileTabView({super.key, this.onVisitsTap, this.onTrackLiveQueue});

  @override
  Widget build(BuildContext context) {
    return ProfileFallbackProvider(
      child: BlocConsumer<ProfileBloc, ProfileState>(
        listener: ProfileTabListener.handle,
        builder: (context, state) {
          final profile = state.profile;
          if (state.isLoading && profile == null) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }
          final bloc = context.read<ProfileBloc>();
          if (profile == null) {
            return ProfileTabListener.buildErrorState(
              context,
              () => bloc.add(const ProfileLoadRequested()),
            );
          }

          final isLaptop = PatientBreakpoints.isLaptop(context);

          final heroCard = ProfileHeroCard(
            profile: profile,
            onEditProfile: () => EditProfileScreen.open(
              context,
              profile: profile,
              onSave: ({
                required name,
                required email,
                required phone,
                required initials,
                age,
                gender,
                bloodGroup,
                photoBase64,
              }) {
                bloc.add(
                  ProfileUpdated(
                    name: name,
                    email: email,
                    phone: phone,
                    initials: initials,
                    age: age,
                    gender: gender,
                    bloodGroup: bloodGroup,
                    photoBase64: photoBase64,
                  ),
                );
              },
            ),
          );

          final statsStrip = ProfileStatsStrip(
            visitsCount: profile.visitsCount,
            favoritesCount: state.favoriteClinics.length,
            onVisitsTap: () => onVisitsTap?.call(),
            onFavoritesTap: () => FavoriteClinicsScreen.open(
              context,
              initialClinics: state.favoriteClinics,
              onBookClinic: onVisitsTap != null ? (_) => onVisitsTap!() : null,
              onQueueClinic: onTrackLiveQueue != null
                  ? (_) => onTrackLiveQueue!()
                  : null,
            ),
          );

          final healthChips = ProfileChipsRow(
            bloodGroup: profile.bloodGroup,
            age: profile.age,
            gender: profile.gender,
          );

          final activityMenu = ProfileActivityMenuSection(
            state: state,
            onVisitsTap: onVisitsTap,
            onTrackLiveQueue: onTrackLiveQueue,
          );

          final preferencesMenu = ProfilePreferencesMenuSection(state: state);

          return RefreshIndicator(
            onRefresh: () async => bloc.add(const ProfileLoadRequested()),
            color: AppColors.primary,
            backgroundColor: context.colors.surfaceElevated,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.symmetric(
                horizontal: isLaptop ? 24 : 16,
                vertical: isLaptop ? 20 : 12,
              ),
              child: isLaptop
                  ? ProfileLaptopLayout(
                      heroCard: heroCard,
                      statsStrip: statsStrip,
                      healthChips: healthChips,
                      activityMenu: activityMenu,
                      preferencesMenu: preferencesMenu,
                      supportLegalMenu: const ProfileSupportLegalMenuSection(),
                      accountMenu: const ProfileAccountMenuSection(),
                    )
                  : ProfileMobileLayout(
                      heroCard: heroCard,
                      statsStrip: statsStrip,
                      healthChips: healthChips,
                      activityMenu: activityMenu,
                      preferencesMenu: preferencesMenu,
                      supportLegalMenu: const ProfileSupportLegalMenuSection(),
                      accountMenu: const ProfileAccountMenuSection(),
                    ),
            ),
          );
        },
      ),
    );
  }
}
