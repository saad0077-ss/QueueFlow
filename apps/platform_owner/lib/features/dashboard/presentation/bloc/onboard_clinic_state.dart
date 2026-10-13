import 'package:equatable/equatable.dart';

class OnboardClinicState extends Equatable {
  final String name;
  final String selectedCategory;
  final String selectedPlan;

  const OnboardClinicState({
    this.name = '',
    this.selectedCategory = 'General Medicine',
    this.selectedPlan = 'solo',
  });

  OnboardClinicState copyWith({
    String? name,
    String? selectedCategory,
    String? selectedPlan,
  }) {
    return OnboardClinicState(
      name: name ?? this.name,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      selectedPlan: selectedPlan ?? this.selectedPlan,
    );
  }

  @override
  List<Object?> get props => [name, selectedCategory, selectedPlan];
}
