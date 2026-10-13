import 'package:equatable/equatable.dart';

abstract class OnboardClinicEvent extends Equatable {
  const OnboardClinicEvent();

  @override
  List<Object?> get props => [];
}

class OnboardClinicNameChanged extends OnboardClinicEvent {
  final String name;
  const OnboardClinicNameChanged(this.name);

  @override
  List<Object?> get props => [name];
}

class OnboardClinicCategoryChanged extends OnboardClinicEvent {
  final String category;
  const OnboardClinicCategoryChanged(this.category);

  @override
  List<Object?> get props => [category];
}

class OnboardClinicPlanChanged extends OnboardClinicEvent {
  final String plan;
  const OnboardClinicPlanChanged(this.plan);

  @override
  List<Object?> get props => [plan];
}
