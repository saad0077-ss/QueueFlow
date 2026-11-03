import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/clinic_doctors_repository.dart';
import '../../domain/usecases/call_next_patient_usecase.dart';
import '../../domain/usecases/delete_clinic_doctor_usecase.dart';
import '../../domain/usecases/get_clinic_doctors_usecase.dart';
import '../../domain/usecases/save_clinic_doctor_usecase.dart';
import '../../domain/usecases/update_doctor_status_usecase.dart';
import 'clinic_doctors_event.dart';
import 'clinic_doctors_state.dart';

class ClinicDoctorsBloc extends Bloc<ClinicDoctorsEvent, ClinicDoctorsState> {
  final GetClinicDoctorsUseCase _getDoctorsUseCase;
  final SaveClinicDoctorUseCase _saveDoctorUseCase;
  final UpdateDoctorStatusUseCase _updateDoctorStatusUseCase;
  final DeleteClinicDoctorUseCase _deleteDoctorUseCase;
  final CallNextPatientUseCase _callNextPatientUseCase;
  final ClinicDoctorsRepository _repository;

  StreamSubscription? _doctorsSubscription;

  ClinicDoctorsBloc({
    required GetClinicDoctorsUseCase getDoctorsUseCase,
    required SaveClinicDoctorUseCase saveDoctorUseCase,
    required UpdateDoctorStatusUseCase updateDoctorStatusUseCase,
    required DeleteClinicDoctorUseCase deleteDoctorUseCase,
    required CallNextPatientUseCase callNextPatientUseCase,
    required ClinicDoctorsRepository repository,
  })  : _getDoctorsUseCase = getDoctorsUseCase,
        _saveDoctorUseCase = saveDoctorUseCase,
        _updateDoctorStatusUseCase = updateDoctorStatusUseCase,
        _deleteDoctorUseCase = deleteDoctorUseCase,
        _callNextPatientUseCase = callNextPatientUseCase,
        _repository = repository,
        super(const ClinicDoctorsState()) {
    on<DoctorsSubscriptionRequested>(_onSubscriptionRequested);
    on<DoctorsUpdated>(_onDoctorsUpdated);
    on<DoctorsLoadFailed>(_onLoadFailed);
    on<DoctorSelected>(_onDoctorSelected);
    on<DoctorAddSubmitted>(_onDoctorAddSubmitted);
    on<DoctorProfileUpdated>(_onDoctorProfileUpdated);
    on<DoctorScheduleUpdated>(_onDoctorScheduleUpdated);
    on<DoctorAccountStatusToggled>(_onDoctorAccountStatusToggled);
    on<DoctorAccountStatusChanged>(_onDoctorAccountStatusChanged);
    on<DoctorStatusChanged>(_onStatusChanged);
    on<DoctorDeletePressed>(_onDeletePressed);
    on<DoctorCallNextPressed>(_onCallNextPressed);
    on<DoctorsClearToast>(_onClearToast);
  }

  Future<void> _onSubscriptionRequested(
    DoctorsSubscriptionRequested event,
    Emitter<ClinicDoctorsState> emit,
  ) async {
    emit(state.copyWith(status: DoctorsStatus.loading));
    try {
      final plan = await _repository.getDoctorPlan();
      final departments = await _repository.getDepartmentSpecialties();
      final waiting = await _repository.getQueueWaitingCount();

      emit(state.copyWith(
        plan: plan,
        departments: departments,
        waitingCount: waiting,
      ));

      await _doctorsSubscription?.cancel();
      _doctorsSubscription = _getDoctorsUseCase().listen(
        (doctors) => add(DoctorsUpdated(doctors)),
        onError: (e) => add(DoctorsLoadFailed(e.toString())),
      );
    } catch (e) {
      emit(state.copyWith(
        status: DoctorsStatus.failure,
        toastMessage: 'Failed to load doctors: $e',
        isErrorToast: true,
      ));
    }
  }

  void _onDoctorsUpdated(
    DoctorsUpdated event,
    Emitter<ClinicDoctorsState> emit,
  ) {
    var selected = state.selectedDoctor;
    if (selected != null) {
      final match = event.doctors.where((d) => d.id == selected!.id).firstOrNull;
      selected = match;
    }

    emit(state.copyWith(
      status: DoctorsStatus.success,
      doctors: event.doctors,
      selectedDoctor: selected,
      clearSelectedDoctor: selected == null,
    ));
  }

  void _onLoadFailed(
    DoctorsLoadFailed event,
    Emitter<ClinicDoctorsState> emit,
  ) {
    emit(state.copyWith(
      status: DoctorsStatus.failure,
      toastMessage: 'Failed to load doctors: ${event.message}',
      isErrorToast: true,
    ));
  }

  void _onDoctorSelected(
    DoctorSelected event,
    Emitter<ClinicDoctorsState> emit,
  ) {
    emit(state.copyWith(
      selectedDoctor: event.doctor,
      clearSelectedDoctor: event.doctor == null,
    ));
  }

  Future<void> _onDoctorAddSubmitted(
    DoctorAddSubmitted event,
    Emitter<ClinicDoctorsState> emit,
  ) async {
    if (state.isLimitReached) {
      emit(state.copyWith(
        toastMessage:
            'Doctor limit reached (${state.doctors.length}/${state.plan.doctorsLimit}). Upgrade your plan to add more practicing doctors.',
        isErrorToast: true,
      ));
      return;
    }

    try {
      await _saveDoctorUseCase(event.doctor);
      emit(state.copyWith(
        toastMessage: '${event.doctor.name} added to practicing doctor roster!',
        isErrorToast: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        toastMessage: 'Failed to add doctor: $e',
        isErrorToast: true,
      ));
    }
  }

  Future<void> _onDoctorProfileUpdated(
    DoctorProfileUpdated event,
    Emitter<ClinicDoctorsState> emit,
  ) async {
    try {
      await _repository.updateDoctorProfile(event.doctor);
      emit(state.copyWith(
        selectedDoctor: event.doctor,
        toastMessage: '${event.doctor.name}\'s profile updated successfully.',
        isErrorToast: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        toastMessage: 'Failed to update profile: $e',
        isErrorToast: true,
      ));
    }
  }

  Future<void> _onDoctorScheduleUpdated(
    DoctorScheduleUpdated event,
    Emitter<ClinicDoctorsState> emit,
  ) async {
    try {
      await _repository.updateDoctorSchedule(
        doctorId: event.doctorId,
        schedule: event.schedule,
        slotDuration: event.slotDuration,
      );

      final current = state.selectedDoctor;
      if (current != null && current.id == event.doctorId) {
        emit(state.copyWith(
          selectedDoctor: current.copyWith(
            weeklySchedule: event.schedule,
            slotDuration: event.slotDuration,
          ),
          toastMessage: 'Weekly schedule and slot duration updated.',
          isErrorToast: false,
        ));
      } else {
        emit(state.copyWith(
          toastMessage: 'Weekly schedule and slot duration updated.',
          isErrorToast: false,
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        toastMessage: 'Failed to update schedule: $e',
        isErrorToast: true,
      ));
    }
  }

  Future<void> _onDoctorAccountStatusToggled(
    DoctorAccountStatusToggled event,
    Emitter<ClinicDoctorsState> emit,
  ) async {
    try {
      final doc = state.doctors.where((d) => d.id == event.doctorId).firstOrNull;
      if (doc == null) return;

      final nextStatus = doc.accountStatus == 'active' ? 'inactive' : 'active';
      await _repository.setDoctorAccountStatus(event.doctorId, nextStatus);

      final updated = doc.copyWith(accountStatus: nextStatus);
      emit(state.copyWith(
        selectedDoctor: state.selectedDoctor?.id == doc.id ? updated : state.selectedDoctor,
        toastMessage: '${doc.name} account is now ${nextStatus.toUpperCase()}.',
        isErrorToast: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        toastMessage: 'Failed to toggle account status: $e',
        isErrorToast: true,
      ));
    }
  }

  Future<void> _onDoctorAccountStatusChanged(
    DoctorAccountStatusChanged event,
    Emitter<ClinicDoctorsState> emit,
  ) async {
    try {
      final doc = state.doctors.where((d) => d.id == event.doctorId).firstOrNull;
      if (doc == null) return;

      await _repository.setDoctorAccountStatus(event.doctorId, event.accountStatus);

      final updated = doc.copyWith(accountStatus: event.accountStatus);
      emit(state.copyWith(
        selectedDoctor: state.selectedDoctor?.id == doc.id ? updated : state.selectedDoctor,
        toastMessage: '${doc.name} account status changed to ${event.accountStatus.toUpperCase()}.',
        isErrorToast: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        toastMessage: 'Failed to change account status: $e',
        isErrorToast: true,
      ));
    }
  }

  Future<void> _onStatusChanged(
    DoctorStatusChanged event,
    Emitter<ClinicDoctorsState> emit,
  ) async {
    try {
      await _updateDoctorStatusUseCase(event.doctorId, event.status);
      emit(state.copyWith(
        toastMessage: 'Doctor status updated to ${event.status.toUpperCase()}.',
        isErrorToast: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        toastMessage: 'Failed to update status: $e',
        isErrorToast: true,
      ));
    }
  }

  Future<void> _onDeletePressed(
    DoctorDeletePressed event,
    Emitter<ClinicDoctorsState> emit,
  ) async {
    try {
      await _deleteDoctorUseCase(event.doctorId);
      final isCurrent = state.selectedDoctor?.id == event.doctorId;
      emit(state.copyWith(
        clearSelectedDoctor: isCurrent,
        toastMessage: '${event.doctorName} removed from roster.',
        isErrorToast: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        toastMessage: 'Failed to remove doctor: $e',
        isErrorToast: true,
      ));
    }
  }

  Future<void> _onCallNextPressed(
    DoctorCallNextPressed event,
    Emitter<ClinicDoctorsState> emit,
  ) async {
    try {
      final token = await _callNextPatientUseCase(event.doctorName);
      if (token != null) {
        emit(state.copyWith(
          toastMessage: 'Called $token for consultation!',
          isErrorToast: false,
        ));
      } else {
        emit(state.copyWith(
          toastMessage: 'No patients currently waiting in queue.',
          isErrorToast: false,
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        toastMessage: 'Error calling next patient: $e',
        isErrorToast: true,
      ));
    }
  }

  void _onClearToast(
    DoctorsClearToast event,
    Emitter<ClinicDoctorsState> emit,
  ) {
    emit(state.copyWith(clearToast: true));
  }

  @override
  Future<void> close() async {
    await _doctorsSubscription?.cancel();
    return super.close();
  }
}
