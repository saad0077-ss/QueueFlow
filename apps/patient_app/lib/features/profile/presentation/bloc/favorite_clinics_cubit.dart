import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/favorite_clinic_entity.dart';
import '../../domain/repositories/profile_repository.dart';

class FavoriteClinicsState extends Equatable {
  final bool isLoading;
  final List<FavoriteClinicEntity> allFavorites;
  final String searchQuery;

  const FavoriteClinicsState({
    required this.isLoading,
    required this.allFavorites,
    this.searchQuery = '',
  });

  List<FavoriteClinicEntity> get filteredFavorites {
    final q = searchQuery.trim().toLowerCase();
    if (q.isEmpty) return allFavorites;

    return allFavorites.where((c) {
      return c.name.toLowerCase().contains(q) ||
          c.department.toLowerCase().contains(q) ||
          c.address.toLowerCase().contains(q) ||
          c.topDoctor.toLowerCase().contains(q);
    }).toList();
  }

  FavoriteClinicsState copyWith({
    bool? isLoading,
    List<FavoriteClinicEntity>? allFavorites,
    String? searchQuery,
  }) {
    return FavoriteClinicsState(
      isLoading: isLoading ?? this.isLoading,
      allFavorites: allFavorites ?? this.allFavorites,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  @override
  List<Object?> get props => [isLoading, allFavorites, searchQuery];
}

class FavoriteClinicsCubit extends Cubit<FavoriteClinicsState> {
  final ProfileRepository repository;

  FavoriteClinicsCubit(this.repository, {List<FavoriteClinicEntity>? initialFavorites})
      : super(FavoriteClinicsState(
          isLoading: initialFavorites == null,
          allFavorites: initialFavorites ?? const [],
        )) {
    if (initialFavorites == null) {
      load();
    }
  }

  Future<void> load() async {
    emit(state.copyWith(isLoading: true));
    try {
      final items = await repository.getFavoriteClinics();
      if (isClosed) return;
      emit(state.copyWith(isLoading: false, allFavorites: items));
    } catch (_) {
      if (isClosed) return;
      emit(state.copyWith(isLoading: false));
    }
  }

  void setSearchQuery(String query) {
    emit(state.copyWith(searchQuery: query));
  }

  Future<void> removeFavorite(String clinicId) async {
    final updated = state.allFavorites.where((c) => c.id != clinicId).toList();
    emit(state.copyWith(allFavorites: updated));
    // Persist removal in repository if user is logged in
    try {
      await repository.toggleFavorite(clinicId, isFavorite: false);
    } catch (_) {}
  }
}
