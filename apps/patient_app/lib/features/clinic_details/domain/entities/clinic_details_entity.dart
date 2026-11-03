import 'package:equatable/equatable.dart';
import '../../../home/domain/entities/clinic_entity.dart';
import 'clinic_doctor_item.dart';
import 'clinic_review_item.dart';
import 'clinic_service_item.dart';

class ClinicDetailsEntity extends Equatable {
  final ClinicEntity clinic;
  final String description;
  final List<String> features;
  final String? holidayNotice;
  final List<ClinicServiceItem> services;
  final List<ClinicDoctorItem> doctors;
  final List<ClinicReviewItem> reviews;
  /// Share of reviews per star, ordered 5★ → 1★ (each 0–100).
  final List<int> starPercents;
  final bool isFavorite;

  const ClinicDetailsEntity({
    required this.clinic,
    required this.description,
    this.features = const [],
    this.holidayNotice,
    this.services = const [],
    this.doctors = const [],
    this.reviews = const [],
    this.starPercents = const [0, 0, 0, 0, 0],
    this.isFavorite = false,
  });

  ClinicDetailsEntity copyWith({
    ClinicEntity? clinic,
    String? description,
    List<String>? features,
    String? holidayNotice,
    List<ClinicServiceItem>? services,
    List<ClinicDoctorItem>? doctors,
    List<ClinicReviewItem>? reviews,
    List<int>? starPercents,
    bool? isFavorite,
  }) {
    return ClinicDetailsEntity(
      clinic: clinic ?? this.clinic,
      description: description ?? this.description,
      features: features ?? this.features,
      holidayNotice: holidayNotice ?? this.holidayNotice,
      services: services ?? this.services,
      doctors: doctors ?? this.doctors,
      reviews: reviews ?? this.reviews,
      starPercents: starPercents ?? this.starPercents,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  @override
  List<Object?> get props => [
        clinic,
        description,
        features,
        holidayNotice,
        services,
        doctors,
        reviews,
        starPercents,
        isFavorite,
      ];
}
