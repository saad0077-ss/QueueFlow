import 'package:flutter_bloc/flutter_bloc.dart';
import 'onboard_clinic_event.dart';
import 'onboard_clinic_state.dart';

class OnboardClinicBloc extends Bloc<OnboardClinicEvent, OnboardClinicState> {
  OnboardClinicBloc() : super(const OnboardClinicState()) {
    on<OnboardClinicNameChanged>((event, emit) {
      emit(state.copyWith(name: event.name));
    });

    on<OnboardClinicCategoryChanged>((event, emit) {
      emit(state.copyWith(selectedCategory: event.category));
    });

    on<OnboardClinicPlanChanged>((event, emit) {
      emit(state.copyWith(selectedPlan: event.plan));
    });
  }
}
