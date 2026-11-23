import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/patient_review_entity.dart';
import '../../../domain/repositories/profile_repository.dart';
import 'my_reviews_event.dart';

export 'my_reviews_event.dart';

class MyReviewsState extends Equatable {
  final bool isLoading;
  final List<PatientReviewEntity> allReviews;
  final String activeFilter; // 'all', 'doctors', 'clinics', '5star'

  const MyReviewsState({
    required this.isLoading,
    required this.allReviews,
    this.activeFilter = 'all',
  });

  List<PatientReviewEntity> get doctorReviews =>
      allReviews.where((r) => r.doctorName.isNotEmpty).toList();
  List<PatientReviewEntity> get fiveStarReviews =>
      allReviews.where((r) => r.doctorRating == 5 || r.rating == 5).toList();

  double get avgDoctorRating {
    final docs = doctorReviews;
    if (docs.isEmpty) return 5.0;
    return docs.fold(0.0, (sum, r) => sum + r.doctorRating) / docs.length;
  }

  double get avgClinicRating {
    if (allReviews.isEmpty) return 5.0;
    return allReviews.fold(0.0, (sum, r) => sum + r.clinicRating) /
        allReviews.length;
  }

  List<PatientReviewEntity> get reviews => allReviews;

  List<PatientReviewEntity> get filteredReviews {
    switch (activeFilter) {
      case 'doctors':
        return doctorReviews;
      case 'clinics':
      case 'all':
      default:
        return activeFilter == '5star' ? fiveStarReviews : allReviews;
    }
  }

  MyReviewsState copyWith({
    bool? isLoading,
    List<PatientReviewEntity>? allReviews,
    String? activeFilter,
  }) {
    return MyReviewsState(
      isLoading: isLoading ?? this.isLoading,
      allReviews: allReviews ?? this.allReviews,
      activeFilter: activeFilter ?? this.activeFilter,
    );
  }

  @override
  List<Object?> get props => [isLoading, allReviews, activeFilter];
}

class MyReviewsBloc extends Bloc<MyReviewsEvent, MyReviewsState> {
  final ProfileRepository repository;
  final void Function(String id)? onDeleteCallback;

  MyReviewsBloc({
    required this.repository,
    List<PatientReviewEntity>? initialReviews,
    this.onDeleteCallback,
  }) : super(
         MyReviewsState(
           isLoading: initialReviews == null,
           allReviews: initialReviews ?? [],
         ),
       ) {
    on<LoadMyReviewsEvent>(_onLoad);
    on<SetMyReviewsFilterEvent>(
      (e, emit) => emit(state.copyWith(activeFilter: e.filter)),
    );
    on<DeleteMyReviewEvent>(_onDelete);
    on<AddMyReviewEvent>(_onAddReview);

    if (initialReviews == null) add(const LoadMyReviewsEvent());
  }

  Future<void> _onLoad(
    LoadMyReviewsEvent event,
    Emitter<MyReviewsState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));
    try {
      final items = await repository.getUserReviews();
      if (!isClosed) emit(state.copyWith(isLoading: false, allReviews: items));
    } catch (_) {
      if (!isClosed) emit(state.copyWith(isLoading: false));
    }
  }

  Future<void> _onDelete(
    DeleteMyReviewEvent event,
    Emitter<MyReviewsState> emit,
  ) async {
    onDeleteCallback?.call(event.id);
    final updated = state.allReviews.where((r) => r.id != event.id).toList();
    emit(state.copyWith(allReviews: updated));
    try {
      await repository.deleteReview(event.id);
    } catch (_) {}
  }

  Future<void> _onAddReview(
    AddMyReviewEvent event,
    Emitter<MyReviewsState> emit,
  ) async {
    try {
      final newReview = await repository.addReview(
        clinicId: event.clinicId,
        clinicName: event.clinicName,
        doctorName: event.doctorName,
        rating: event.rating,
        tags: event.tags,
        comment: event.comment,
        isAnonymous: event.isAnonymous,
      );
      emit(state.copyWith(allReviews: [newReview, ...state.allReviews]));
    } catch (_) {}
  }

  void load() => add(const LoadMyReviewsEvent());
  void setFilter(String filter) => add(SetMyReviewsFilterEvent(filter));
  void delete(String id) => add(DeleteMyReviewEvent(id));
}
