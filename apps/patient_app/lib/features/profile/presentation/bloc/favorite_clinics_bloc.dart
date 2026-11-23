import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/favorite_clinic_entity.dart';
import '../../domain/repositories/profile_repository.dart';

abstract class FavoriteClinicsEvent extends Equatable {
  const FavoriteClinicsEvent();
  @override
  List<Object?> get props => [];
}

class LoadFavoriteClinicsEvent extends FavoriteClinicsEvent {
  const LoadFavoriteClinicsEvent();
}

class SetFavoriteClinicsSearchEvent extends FavoriteClinicsEvent {
  final String query;
  const SetFavoriteClinicsSearchEvent(this.query);
  @override
  List<Object?> get props => [query];
}

class RemoveFavoriteClinicEvent extends FavoriteClinicsEvent {
  final String clinicId;
  const RemoveFavoriteClinicEvent(this.clinicId);
  @override
  List<Object?> get props => [clinicId];
}

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

class FavoriteClinicsBloc
    extends Bloc<FavoriteClinicsEvent, FavoriteClinicsState> {
  final ProfileRepository repository;

  FavoriteClinicsBloc(
    this.repository, {
    List<FavoriteClinicEntity>? initialFavorites,
  }) : super(
         FavoriteClinicsState(
           isLoading: initialFavorites == null,
           allFavorites: initialFavorites ?? const [],
         ),
       ) {
    on<LoadFavoriteClinicsEvent>(_onLoad);
    on<SetFavoriteClinicsSearchEvent>((event, emit) {
      emit(state.copyWith(searchQuery: event.query));
    });
    on<RemoveFavoriteClinicEvent>(_onRemoveFavorite);

    if (initialFavorites == null) {
      add(const LoadFavoriteClinicsEvent());
    }
  }

  Future<void> _onLoad(
    LoadFavoriteClinicsEvent event,
    Emitter<FavoriteClinicsState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));
    try {
      final items = await repository.getFavoriteClinics();
      if (!isClosed) {
        emit(state.copyWith(isLoading: false, allFavorites: items));
      }
    } catch (_) {
      if (!isClosed) emit(state.copyWith(isLoading: false));
    }
  }

  Future<void> _onRemoveFavorite(
    RemoveFavoriteClinicEvent event,
    Emitter<FavoriteClinicsState> emit,
  ) async {
    final updated = state.allFavorites
        .where((c) => c.id != event.clinicId)
        .toList();
    emit(state.copyWith(allFavorites: updated));
    try {
      await repository.toggleFavorite(event.clinicId, isFavorite: false);
    } catch (_) {}
  }

  void load() => add(const LoadFavoriteClinicsEvent());
  void setSearchQuery(String query) =>
      add(SetFavoriteClinicsSearchEvent(query));
  void removeFavorite(String clinicId) =>
      add(RemoveFavoriteClinicEvent(clinicId));
}
