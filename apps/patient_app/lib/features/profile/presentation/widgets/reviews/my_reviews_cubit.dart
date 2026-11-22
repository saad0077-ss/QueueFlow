import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/patient_review_entity.dart';
import '../../../domain/repositories/profile_repository.dart';

class MyReviewsState extends Equatable {
  final bool isLoading;
  final List<PatientReviewEntity> allReviews;
  final String activeFilter; // 'all', 'doctors', 'clinics', '5star'

  const MyReviewsState({
    required this.isLoading,
    required this.allReviews,
    this.activeFilter = 'all',
  });

  // Doctor Reviews
  List<PatientReviewEntity> get doctorReviews =>
      allReviews.where((r) => r.doctorName.isNotEmpty).toList();

  // 5-Star Reviews
  List<PatientReviewEntity> get fiveStarReviews =>
      allReviews.where((r) => r.doctorRating == 5 || r.rating == 5).toList();

  // Average Ratings
  double get avgDoctorRating {
    final docs = doctorReviews;
    if (docs.isEmpty) return 5.0;
    return docs.fold(0.0, (sum, r) => sum + r.doctorRating) / docs.length;
  }

  double get avgClinicRating {
    if (allReviews.isEmpty) return 5.0;
    return allReviews.fold(0.0, (sum, r) => sum + r.clinicRating) / allReviews.length;
  }

  // Filtered List
  List<PatientReviewEntity> get reviews => allReviews;

  List<PatientReviewEntity> get filteredReviews {
    switch (activeFilter) {
      case 'doctors':
        return doctorReviews;
      case 'clinics':
        return allReviews;
      case '5star':
        return fiveStarReviews;
      case 'all':
      default:
        return allReviews;
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

class MyReviewsCubit extends Cubit<MyReviewsState> {
  final ProfileRepository repository;
  final void Function(String id)? onDeleteCallback;

  MyReviewsCubit({
    required this.repository,
    List<PatientReviewEntity>? initialReviews,
    this.onDeleteCallback,
  }) : super(MyReviewsState(
          isLoading: initialReviews == null,
          allReviews: initialReviews ?? [],
        )) {
    if (initialReviews == null) {
      load();
    }
  }

  Future<void> load() async {
    emit(state.copyWith(isLoading: true));
    try {
      final items = await repository.getUserReviews();
      if (isClosed) return;
      emit(state.copyWith(isLoading: false, allReviews: items));
    } catch (_) {
      if (isClosed) return;
      emit(state.copyWith(isLoading: false));
    }
  }

  void setFilter(String filter) {
    emit(state.copyWith(activeFilter: filter));
  }

  Future<void> delete(String id) async {
    onDeleteCallback?.call(id);
    final updated = state.allReviews.where((r) => r.id != id).toList();
    emit(state.copyWith(allReviews: updated));
    try {
      await repository.deleteReview(id);
    } catch (_) {}
  }

  Future<void> addReview({
    required String clinicId,
    required String clinicName,
    required String doctorName,
    required String service,
    required int rating,
    required List<String> tags,
    required String comment,
    required bool isAnonymous,
  }) async {
    try {
      final newReview = await repository.addReview(
        clinicId: clinicId,
        clinicName: clinicName,
        doctorName: doctorName,
        rating: rating,
        tags: tags,
        comment: comment,
        isAnonymous: isAnonymous,
      );
      final updated = [newReview, ...state.allReviews];
      emit(state.copyWith(allReviews: updated));
    } catch (_) {}
  }
}
