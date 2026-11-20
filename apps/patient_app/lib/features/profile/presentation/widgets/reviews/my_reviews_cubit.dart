import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:patient_app/features/profile/domain/entities/patient_review_entity.dart';

class MyReviewsState extends Equatable {
  final List<PatientReviewEntity> reviews;

  const MyReviewsState({required this.reviews});

  @override
  List<Object?> get props => [reviews];
}

class MyReviewsCubit extends Cubit<MyReviewsState> {
  final void Function(String id) onDeleteCallback;

  MyReviewsCubit({
    required List<PatientReviewEntity> initialReviews,
    required this.onDeleteCallback,
  }) : super(MyReviewsState(reviews: List.of(initialReviews)));

  void delete(String id) {
    onDeleteCallback(id);
    emit(MyReviewsState(
      reviews: state.reviews.where((r) => r.id != id).toList(),
    ));
  }
}
