import 'package:equatable/equatable.dart';
import '../../domain/entities/clinic_details_entity.dart';

enum ClinicDetailsStatus { initial, loading, loaded, failure }

class ClinicDetailsState extends Equatable {
  final ClinicDetailsStatus status;
  final ClinicDetailsEntity? details;
  final int selectedTabIndex;
  final bool isFavorite;
  final String? errorMessage;
  final bool isSubmittingReview;
  final bool reviewSubmittedSuccessfully;

  const ClinicDetailsState({
    this.status = ClinicDetailsStatus.initial,
    this.details,
    this.selectedTabIndex = 0,
    this.isFavorite = false,
    this.errorMessage,
    this.isSubmittingReview = false,
    this.reviewSubmittedSuccessfully = false,
  });

  ClinicDetailsState copyWith({
    ClinicDetailsStatus? status,
    ClinicDetailsEntity? details,
    int? selectedTabIndex,
    bool? isFavorite,
    String? errorMessage,
    bool? isSubmittingReview,
    bool? reviewSubmittedSuccessfully,
  }) {
    return ClinicDetailsState(
      status: status ?? this.status,
      details: details ?? this.details,
      selectedTabIndex: selectedTabIndex ?? this.selectedTabIndex,
      isFavorite: isFavorite ?? this.isFavorite,
      errorMessage: errorMessage,
      isSubmittingReview: isSubmittingReview ?? this.isSubmittingReview,
      reviewSubmittedSuccessfully:
          reviewSubmittedSuccessfully ?? this.reviewSubmittedSuccessfully,
    );
  }

  @override
  List<Object?> get props => [
        status,
        details,
        selectedTabIndex,
        isFavorite,
        errorMessage,
        isSubmittingReview,
        reviewSubmittedSuccessfully,
      ];
}
