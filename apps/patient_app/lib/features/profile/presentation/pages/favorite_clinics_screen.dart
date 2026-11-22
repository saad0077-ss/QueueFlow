import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:queueflow_ui/queueflow_ui.dart';
import '../../../../core/widgets/app_snack_bar.dart';
import '../../data/repositories/profile_repository_impl.dart';
import '../../domain/entities/favorite_clinic_entity.dart';
import '../../domain/repositories/profile_repository.dart';
import '../bloc/favorite_clinics_cubit.dart';
import '../widgets/favorite_clinics/favorite_clinic_card.dart';
import '../widgets/favorite_clinics/favorite_clinics_empty_state.dart';
import '../widgets/favorite_clinics/favorite_clinics_header.dart';
import '../widgets/favorite_clinics/favorite_clinics_hero_banner.dart';
import '../widgets/favorite_clinics/favorite_clinics_search_bar.dart';

class FavoriteClinicsScreen extends StatelessWidget {
  final ProfileRepository? repository;
  final List<FavoriteClinicEntity>? initialClinics;
  final ValueChanged<String>? onBookClinic;
  final ValueChanged<String>? onQueueClinic;

  const FavoriteClinicsScreen({
    super.key,
    this.repository,
    this.initialClinics,
    this.onBookClinic,
    this.onQueueClinic,
  });

  static Future<void> open(
    BuildContext context, {
    ProfileRepository? repository,
    List<FavoriteClinicEntity>? initialClinics,
    ValueChanged<String>? onBookClinic,
    ValueChanged<String>? onQueueClinic,
  }) {
    return Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => FavoriteClinicsScreen(
          repository: repository,
          initialClinics: initialClinics,
          onBookClinic: onBookClinic,
          onQueueClinic: onQueueClinic,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return BlocProvider(
      create: (_) => FavoriteClinicsCubit(
        repository ?? ProfileRepositoryImpl(),
        initialFavorites: initialClinics,
      ),
      child: Scaffold(
        backgroundColor: colors.background,
        body: SafeArea(
          bottom: false,
          child: BlocBuilder<FavoriteClinicsCubit, FavoriteClinicsState>(
            builder: (context, state) {
              final cubit = context.read<FavoriteClinicsCubit>();
              final filtered = state.filteredFavorites;

              return Column(
                children: [
                  FavoriteClinicsHeader(
                    onRefresh: () => cubit.load(),
                    onBack: () => Navigator.of(context).pop(),
                  ),
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: () => cubit.load(),
                      color: colors.primary,
                      backgroundColor: colors.surfaceElevated,
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 640),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // 1. Hero KPI Banner
                                FavoriteClinicsHeroBanner(
                                  count: state.allFavorites.length,
                                ),
                                const SizedBox(height: 14),

                                // 2. Search Bar
                                FavoriteClinicsSearchBar(
                                  query: state.searchQuery,
                                  onChanged: (q) => cubit.setSearchQuery(q),
                                  onClear: () => cubit.setSearchQuery(''),
                                ),
                                const SizedBox(height: 14),

                                // 3. Clinic Cards List
                                if (state.isLoading) ...[
                                  const SizedBox(height: 60),
                                  Center(child: CircularProgressIndicator(color: colors.primary)),
                                ] else if (filtered.isEmpty) ...[
                                  FavoriteClinicsEmptyState(
                                    hasQuery: state.searchQuery.isNotEmpty,
                                    onExplore: () => Navigator.of(context).pop(),
                                  ),
                                ] else ...[
                                  ListView.separated(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    itemCount: filtered.length,
                                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                                    itemBuilder: (context, index) {
                                      final clinic = filtered[index];
                                      return FavoriteClinicCard(
                                        clinic: clinic,
                                        onUnfavorite: () {
                                          cubit.removeFavorite(clinic.id);
                                          AppSnackBar.showSuccess(
                                            context,
                                            message: 'Removed ${clinic.name} from favorites',
                                          );
                                        },
                                        onBook: () {
                                          if (onBookClinic != null) {
                                            Navigator.of(context).pop();
                                            onBookClinic!(clinic.id);
                                          } else {
                                            AppSnackBar.showSuccess(
                                              context,
                                              message: 'Selected ${clinic.name} for booking',
                                            );
                                          }
                                        },
                                        onLiveQueue: () {
                                          if (onQueueClinic != null) {
                                            Navigator.of(context).pop();
                                            onQueueClinic!(clinic.id);
                                          } else {
                                            AppSnackBar.showSuccess(
                                              context,
                                              message: 'Opening Live Queue for ${clinic.name}',
                                            );
                                          }
                                        },
                                        onCall: () {
                                          AppSnackBar.showSuccess(
                                            context,
                                            message: 'Dialing ${clinic.name} (${clinic.phone})...',
                                          );
                                        },
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 24),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
