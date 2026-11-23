import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

import '../../../../core/widgets/app_snack_bar.dart';
import '../../../onboarding/presentation/pages/welcome_screen.dart';
import '../../data/repositories/profile_repository_impl.dart';
import '../../domain/usecases/profile_usecases.dart';
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
import 'profile_tab/profile_preferences_menu_section.dart';
import 'profile_tab/profile_support_legal_menu_section.dart';

class ProfileTabView extends StatelessWidget {
  final VoidCallback? onVisitsTap;
  final VoidCallback? onTrackLiveQueue;

  const ProfileTabView({super.key, this.onVisitsTap, this.onTrackLiveQueue});

  @override
  Widget build(BuildContext context) {
    final consumer = BlocConsumer<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (state.isLoggedOut) {
          final isDelete =
              state.successMessage?.toLowerCase().contains('deleted') ?? false;
          AppSnackBar.showSuccess(
            context,
            title: isDelete ? 'Account Deleted' : 'Logged Out',
            message:
                state.successMessage ??
                (isDelete
                    ? 'Your account and personal data were permanently deleted.'
                    : 'You have been safely logged out.'),
          );
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const WelcomeScreen()),
            (route) => false,
          );
        } else if (state.successMessage != null) {
          AppSnackBar.showSuccess(context, message: state.successMessage!);
        } else if (state.error != null) {
          AppSnackBar.showError(context, message: state.error!);
        }
      },
      builder: (context, state) {
        final profile = state.profile;
        if (state.isLoading && profile == null) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }
        if (profile == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Failed to load profile',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () => context.read<ProfileBloc>().add(
                    const ProfileLoadRequested(),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                  ),
                  child: const Text(
                    'Retry',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          );
        }

        final bloc = context.read<ProfileBloc>();

        return RefreshIndicator(
          onRefresh: () async => bloc.add(const ProfileLoadRequested()),
          color: AppColors.primary,
          backgroundColor: context.colors.surfaceElevated,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 640),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ProfileHeroCard(
                      profile: profile,
                      onEditProfile: () => EditProfileScreen.open(
                        context,
                        profile: profile,
                        onSave:
                            ({
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
                    ),
                    ProfileStatsStrip(
                      visitsCount: profile.visitsCount,
                      favoritesCount: state.favoriteClinics.length,
                      onVisitsTap: () => onVisitsTap?.call(),
                      onFavoritesTap: () => FavoriteClinicsScreen.open(
                        context,
                        initialClinics: state.favoriteClinics,
                        onBookClinic: onVisitsTap != null
                            ? (_) => onVisitsTap?.call()
                            : null,
                        onQueueClinic: onTrackLiveQueue != null
                            ? (_) => onTrackLiveQueue?.call()
                            : null,
                      ),
                    ),
                    ProfileChipsRow(
                      bloodGroup: profile.bloodGroup,
                      age: profile.age,
                      gender: profile.gender,
                    ),
                    ProfileActivityMenuSection(
                      state: state,
                      onVisitsTap: onVisitsTap,
                      onTrackLiveQueue: onTrackLiveQueue,
                    ),
                    ProfilePreferencesMenuSection(state: state),
                    const ProfileSupportLegalMenuSection(),
                    const ProfileAccountMenuSection(),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );

    try {
      context.read<ProfileBloc>();
      return consumer;
    } catch (_) {
      final repo = ProfileRepositoryImpl();
      return BlocProvider(
        create: (_) => ProfileBloc(
          getProfileUseCase: GetProfileUseCase(repo),
          updateProfileUseCase: UpdateProfileUseCase(repo),
          toggleDarkModeUseCase: ToggleDarkModeUseCase(repo),
          getFavoriteClinicsUseCase: GetFavoriteClinicsUseCase(repo),
          getUserReviewsUseCase: GetUserReviewsUseCase(repo),
          addReviewUseCase: AddReviewUseCase(repo),
          deleteReviewUseCase: DeleteReviewUseCase(repo),
          getSupportTicketsUseCase: GetSupportTicketsUseCase(repo),
          createSupportTicketUseCase: CreateSupportTicketUseCase(repo),
          sendTicketReplyUseCase: SendTicketReplyUseCase(repo),
          logoutUseCase: LogoutUseCase(repo),
          deleteAccountUseCase: DeleteAccountUseCase(repo),
        )..add(const ProfileLoadRequested()),
        child: consumer,
      );
    }
  }
}
