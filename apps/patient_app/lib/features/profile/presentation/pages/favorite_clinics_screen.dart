import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

import '../../data/repositories/profile_repository_impl.dart';
import '../../domain/entities/favorite_clinic_entity.dart';
import '../../domain/repositories/profile_repository.dart';
import '../bloc/favorite_clinics_bloc.dart';
import '../widgets/favorite_clinics/favorite_clinics_empty_state.dart';
import '../widgets/favorite_clinics/favorite_clinics_header.dart';
import '../widgets/favorite_clinics/favorite_clinics_hero_banner.dart';
import '../widgets/favorite_clinics/favorite_clinics_list.dart';
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
      create: (_) => FavoriteClinicsBloc(
        repository ?? ProfileRepositoryImpl(),
        initialFavorites: initialClinics,
      ),
      child: Scaffold(
        backgroundColor: colors.background,
        body: SafeArea(
          bottom: false,
          child: BlocBuilder<FavoriteClinicsBloc, FavoriteClinicsState>(
            builder: (context, state) {
              final bloc = context.read<FavoriteClinicsBloc>();
              final filtered = state.filteredFavorites;

              return Column(
                children: [
                  FavoriteClinicsHeader(
                    onRefresh: () => bloc.load(),
                    onBack: () => Navigator.of(context).pop(),
                  ),
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: () async => bloc.load(),
                      color: colors.primary,
                      backgroundColor: colors.surfaceElevated,
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 640),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                FavoriteClinicsHeroBanner(
                                  count: state.allFavorites.length,
                                ),
                                const SizedBox(height: 14),
                                FavoriteClinicsSearchBar(
                                  query: state.searchQuery,
                                  onChanged: bloc.setSearchQuery,
                                  onClear: () => bloc.setSearchQuery(''),
                                ),
                                const SizedBox(height: 14),
                                if (state.isLoading) ...[
                                  const SizedBox(height: 60),
                                  Center(
                                    child: CircularProgressIndicator(
                                      color: colors.primary,
                                    ),
                                  ),
                                ] else if (filtered.isEmpty) ...[
                                  FavoriteClinicsEmptyState(
                                    hasQuery: state.searchQuery.isNotEmpty,
                                    onExplore: () =>
                                        Navigator.of(context).pop(),
                                  ),
                                ] else ...[
                                  FavoriteClinicsList(
                                    clinics: filtered,
                                    onUnfavorite: bloc.removeFavorite,
                                    onBookClinic: onBookClinic,
                                    onQueueClinic: onQueueClinic,
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
