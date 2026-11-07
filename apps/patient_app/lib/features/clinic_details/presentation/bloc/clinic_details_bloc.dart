import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/clinic_details_repository.dart';
import 'clinic_details_event.dart';
import 'clinic_details_state.dart';

class ClinicDetailsBloc extends Bloc<ClinicDetailsEvent, ClinicDetailsState> {
  final ClinicDetailsRepository repository;

  ClinicDetailsBloc({
    required this.repository,
  }) : super(const ClinicDetailsState()) {
    on<LoadClinicDetails>(_onLoadClinicDetails);
    on<SelectClinicTab>(_onSelectClinicTab);
    on<ToggleClinicFavorite>(_onToggleClinicFavorite);
    on<MarkReviewHelpfulEvent>(_onMarkReviewHelpful);
    on<SubmitClinicReviewEvent>(_onSubmitClinicReview);
    on<SubmitDoctorReviewEvent>(_onSubmitDoctorReview);
  }

  Future<void> _onSubmitDoctorReview(
    SubmitDoctorReviewEvent event,
    Emitter<ClinicDetailsState> emit,
  ) async {
    final details = state.details;
    if (details == null) return;
    try {
      await repository.submitDoctorReview(
        clinicId: details.clinic.id,
        doctorId: event.doctorId,
        rating: event.rating,
        comment: event.comment,
      );
      final reloaded = await repository.getClinicDetails(details.clinic.id, details.clinic);
      emit(state.copyWith(details: reloaded));
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Failed to submit rating: $e'));
    }
  }

  Future<void> _onLoadClinicDetails(
    LoadClinicDetails event,
    Emitter<ClinicDetailsState> emit,
  ) async {
    emit(state.copyWith(status: ClinicDetailsStatus.loading));
    try {
      final details = await repository.getClinicDetails(
        event.clinicId,
        event.initialClinic,
      );
      final fav = await repository.isClinicFavorite(event.clinicId);
      emit(state.copyWith(
        status: ClinicDetailsStatus.loaded,
        details: details,
        isFavorite: fav,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ClinicDetailsStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  void _onSelectClinicTab(
    SelectClinicTab event,
    Emitter<ClinicDetailsState> emit,
  ) {
    emit(state.copyWith(selectedTabIndex: event.tabIndex));
  }

  Future<void> _onToggleClinicFavorite(
    ToggleClinicFavorite event,
    Emitter<ClinicDetailsState> emit,
  ) async {
    final details = state.details;
    if (details == null) return;
    final prev = state.isFavorite;
    emit(state.copyWith(isFavorite: !prev));
    try {
      await repository.setClinicFavorite(details.clinic, !prev);
    } catch (e) {
      emit(state.copyWith(isFavorite: prev, errorMessage: 'Could not update favorites: $e'));
    }
  }

  Future<void> _onMarkReviewHelpful(
    MarkReviewHelpfulEvent event,
    Emitter<ClinicDetailsState> emit,
  ) async {
    if (state.details == null) return;
    final currentReviews = state.details!.reviews;
    final updated = currentReviews.map((r) {
      if (r.id == event.reviewId) {
        return r.copyWith(helpfulCount: r.helpfulCount + 1);
      }
      return r;
    }).toList();

    emit(state.copyWith(
      details: state.details!.copyWith(reviews: updated),
    ));

    await repository.markReviewHelpful(event.reviewId);
  }

  Future<void> _onSubmitClinicReview(
    SubmitClinicReviewEvent event,
    Emitter<ClinicDetailsState> emit,
  ) async {
    if (state.details == null) return;
    emit(state.copyWith(isSubmittingReview: true));
    try {
      await repository.submitReview(
        clinicId: state.details!.clinic.id,
        rating: event.rating,
        comment: event.comment,
        tags: event.tags,
      );

      final reloaded = await repository.getClinicDetails(
        state.details!.clinic.id,
        state.details!.clinic,
      );

      emit(state.copyWith(
        isSubmittingReview: false,
        reviewSubmittedSuccessfully: true,
        details: reloaded,
      ));
    } catch (e) {
      emit(state.copyWith(
        isSubmittingReview: false,
        errorMessage: 'Failed to submit review: $e',
      ));
    }
  }
}
