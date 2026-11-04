import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_snack_bar.dart';
import '../../../onboarding/presentation/pages/welcome_screen.dart';
import '../../data/repositories/profile_repository_impl.dart';
import '../../domain/usecases/profile_usecases.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';
import 'digital_health_pass_sheet.dart';
import '../pages/edit_profile_screen.dart';
import 'favorite_clinics_sheet.dart';
import 'my_reviews_sheet.dart';
import 'profile_chips_row.dart';
import 'profile_hero_card.dart';
import 'profile_menu_section.dart';
import 'profile_stats_strip.dart';

class ProfileTabView extends StatelessWidget {
  final VoidCallback? onVisitsTap;

  const ProfileTabView({
    super.key,
    this.onVisitsTap,
  });

  @override
  Widget build(BuildContext context) {
    // If a ProfileBloc is already provided by a parent, use it; otherwise provide a fresh one.
    try {
      final existingBloc = context.read<ProfileBloc?>();
      if (existingBloc != null) {
        return _ProfileTabConsumer(onVisitsTap: onVisitsTap);
      }
    } catch (_) {}

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
      child: _ProfileTabConsumer(onVisitsTap: onVisitsTap),
    );
  }
}

class _ProfileTabConsumer extends StatelessWidget {
  final VoidCallback? onVisitsTap;

  const _ProfileTabConsumer({this.onVisitsTap});

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: AppColors.darkSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.darkBorder, width: 1),
        ),
        title: const Text(
          'Log out',
          style: TextStyle(color: AppColors.darkInk, fontWeight: FontWeight.w800),
        ),
        content: const Text(
          'Are you sure you want to log out of your QueueFlow account?',
          style: TextStyle(color: AppColors.darkInkMuted, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: const Text('Cancel', style: TextStyle(color: AppColors.darkInkMuted)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogCtx).pop();
              context.read<ProfileBloc>().add(const ProfileLogoutRequested());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Log out', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: AppColors.darkSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.darkBorder, width: 1),
        ),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppColors.error, size: 22),
            SizedBox(width: 8),
            Text(
              'Delete Account',
              style: TextStyle(color: AppColors.darkInk, fontWeight: FontWeight.w800),
            ),
          ],
        ),
        content: const Text(
          'Are you sure you want to permanently delete your account? All your queue history and tokens will be reset.',
          style: TextStyle(color: AppColors.darkInkMuted, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: const Text('Cancel', style: TextStyle(color: AppColors.darkInkMuted)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogCtx).pop();
              context.read<ProfileBloc>().add(const ProfileDeleteAccountRequested());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Delete Permanently', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  void _showComingSoon(BuildContext context, String feature) {
    AppSnackBar.showInfo(context, message: '$feature is coming soon');
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (state.successMessage != null) {
          AppSnackBar.showSuccess(context, message: state.successMessage!);
        }
        if (state.errorMessage != null) {
          AppSnackBar.showError(context, message: state.errorMessage!);
        }
        if (state.isLoggedOut) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const WelcomeScreen()),
            (route) => false,
          );
        }
      },
      builder: (context, state) {
        final profile = state.profile;
        if (state.status == ProfileStatus.loading && profile == null) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        if (profile == null) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Could not load profile',
                  style: TextStyle(color: AppColors.darkInk, fontSize: 15, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () => context.read<ProfileBloc>().add(const ProfileLoadRequested()),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                  child: const Text('Retry', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          );
        }

        final bloc = context.read<ProfileBloc>();

        return RefreshIndicator(
          onRefresh: () async {
            bloc.add(const ProfileLoadRequested());
          },
          color: AppColors.primary,
          backgroundColor: AppColors.darkSurface,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 640),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Hero Card
                    ProfileHeroCard(
                      profile: profile,
                      onEditProfile: () {
                        EditProfileScreen.open(
                          context,
                          profile: profile,
                          onSave: ({required name, required email, required phone, required initials, age, gender, bloodGroup, photoBase64}) {
                            bloc.add(ProfileUpdated(
                              name: name,
                              email: email,
                              phone: phone,
                              initials: initials,
                              age: age,
                              gender: gender,
                              bloodGroup: bloodGroup,
                              photoBase64: photoBase64,
                            ));
                          },
                        );
                      },
                      onDigitalHealthPass: () {
                        DigitalHealthPassSheet.show(context, profile: profile);
                      },
                    ),

                    // Stats Strip
                    ProfileStatsStrip(
                      visitsCount: profile.visitsCount,
                      favoritesCount: state.favoriteClinics.length,
                      onVisitsTap: () => onVisitsTap?.call(),
                      onFavoritesTap: () {
                        FavoriteClinicsSheet.show(
                          context,
                          clinics: state.favoriteClinics,
                          onBookClinic: (_) => onVisitsTap?.call(),
                        );
                      },
                    ),

                    // Health Snapshot Chips
                    ProfileChipsRow(
                      bloodGroup: profile.bloodGroup,
                      age: profile.age,
                      gender: profile.gender,
                    ),

                    // Activity Section
                    ProfileMenuSection(
                      title: 'Activity',
                      items: [
                        ProfileMenuItem(
                          icon: const Text('⭐', style: TextStyle(fontSize: 16)),
                          iconBgColor: const Color(0xFFF59E0B).withValues(alpha: 0.15),
                          title: 'My Ratings & Reviews',
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF59E0B).withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  '${state.userReviews.length} Reviews',
                                  style: const TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFFF59E0B),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.chevron_right_rounded,
                                size: 18,
                                color: AppColors.darkInkFaint,
                              ),
                            ],
                          ),
                          onTap: () {
                            MyReviewsSheet.show(
                              context,
                              reviews: state.userReviews,
                              onDeleteReview: (id) => bloc.add(ProfileReviewDeleted(id)),
                            );
                          },
                        ),
                        ProfileMenuItem(
                          icon: const Icon(Icons.favorite_rounded, size: 18, color: Color(0xFF14B8A6)),
                          iconBgColor: const Color(0xFF14B8A6).withValues(alpha: 0.15),
                          title: 'Favorite clinics',
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${state.favoriteClinics.length} Clinics',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.darkInkMuted,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.chevron_right_rounded,
                                size: 18,
                                color: AppColors.darkInkFaint,
                              ),
                            ],
                          ),
                          onTap: () {
                            FavoriteClinicsSheet.show(
                              context,
                              clinics: state.favoriteClinics,
                              onBookClinic: (_) => onVisitsTap?.call(),
                            );
                          },
                        ),
                      ],
                    ),

                    // Preferences Section
                    ProfileMenuSection(
                      title: 'Preferences',
                      items: [
                        ProfileMenuItem(
                          icon: const Icon(Icons.dark_mode_rounded, size: 18, color: Color(0xFF7C3AED)),
                          iconBgColor: const Color(0xFF7C3AED).withValues(alpha: 0.15),
                          title: 'Dark mode',
                          trailing: Switch.adaptive(
                            value: profile.darkMode,
                            activeTrackColor: const Color(0xFF7C3AED),
                            onChanged: (val) => bloc.add(ProfileDarkModeToggled(val)),
                          ),
                          onTap: () => bloc.add(ProfileDarkModeToggled(!profile.darkMode)),
                        ),
                      ],
                    ),

                    // Support & Legal Section
                    ProfileMenuSection(
                      title: 'Support & Legal',
                      items: [
                        ProfileMenuItem(
                          icon: const Icon(Icons.headset_mic_rounded, size: 18, color: Color(0xFF10B981)),
                          iconBgColor: const Color(0xFF10B981).withValues(alpha: 0.15),
                          title: 'Help & Support',
                          onTap: () => _showComingSoon(context, 'Help & Support'),
                        ),
                        ProfileMenuItem(
                          icon: const Icon(Icons.shield_outlined, size: 18, color: Color(0xFF3B82F6)),
                          iconBgColor: const Color(0xFF3B82F6).withValues(alpha: 0.15),
                          title: 'Privacy Policy',
                          onTap: () => _showComingSoon(context, 'Privacy Policy'),
                        ),
                        ProfileMenuItem(
                          icon: const Icon(Icons.description_outlined, size: 18, color: Color(0xFF94A3B8)),
                          iconBgColor: const Color(0xFF64748B).withValues(alpha: 0.15),
                          title: 'Terms of Service',
                          onTap: () => _showComingSoon(context, 'Terms of Service'),
                        ),
                      ],
                    ),

                    // Account Section
                    ProfileMenuSection(
                      bottomMargin: 28,
                      items: [
                        ProfileMenuItem(
                          icon: const Icon(Icons.logout_rounded, size: 18, color: AppColors.error),
                          iconBgColor: AppColors.error.withValues(alpha: 0.12),
                          title: 'Log out',
                          titleColor: AppColors.error,
                          onTap: () => _showLogoutDialog(context),
                        ),
                        ProfileMenuItem(
                          icon: Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.error.withValues(alpha: 0.85)),
                          iconBgColor: AppColors.error.withValues(alpha: 0.06),
                          title: 'Delete account',
                          titleColor: AppColors.error.withValues(alpha: 0.85),
                          onTap: () => _showDeleteAccountDialog(context),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
