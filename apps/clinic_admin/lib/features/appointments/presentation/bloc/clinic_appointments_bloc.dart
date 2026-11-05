import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/clinic_appointments_repository.dart';
import 'clinic_appointments_event.dart';
import 'clinic_appointments_state.dart';

class ClinicAppointmentsBloc
    extends Bloc<ClinicAppointmentsEvent, ClinicAppointmentsState> {
  final ClinicAppointmentsRepository repository;
  StreamSubscription? _appointmentsSubscription;

  ClinicAppointmentsBloc({required this.repository})
    : super(ClinicAppointmentsState(isLoading: true)) {
    on<StartWatchingAppointments>(_onStartWatching);
    on<AppointmentsUpdated>(_onAppointmentsUpdated);
    on<ChangeDateRangeFilter>(_onChangeDateRangeFilter);
    on<ChangeDepartmentFilter>(_onChangeDepartmentFilter);
    on<ChangeServiceFilter>(_onChangeServiceFilter);
    on<ChangeDoctorFilter>(_onChangeDoctorFilter);
    on<ChangeStatusFilter>(_onChangeStatusFilter);
    on<ChangePaymentFilter>(_onChangePaymentFilter);
    on<ChangeSearchQuery>(_onChangeSearchQuery);
    on<ResetAppointmentFilters>(_onResetFilters);
    on<ToggleAppointmentViewMode>(_onToggleViewMode);
    on<SelectAppointment>(_onSelectAppointment);
    on<SelectCalendarDate>(_onSelectCalendarDate);
    on<CheckInAppointment>(_onCheckInAppointment);
    on<CompleteAppointment>(_onCompleteAppointment);
    on<RescheduleAppointment>(_onRescheduleAppointment);
    on<CancelAppointment>(_onCancelAppointment);
    on<CreateAppointment>(_onCreateAppointment);

    add(const StartWatchingAppointments());
  }

  void _onStartWatching(
    StartWatchingAppointments event,
    Emitter<ClinicAppointmentsState> emit,
  ) {
    _appointmentsSubscription?.cancel();
    _appointmentsSubscription = repository.watchAppointments().listen((
      appointments,
    ) {
      add(AppointmentsUpdated(appointments));
    });
  }

  void _onAppointmentsUpdated(
    AppointmentsUpdated event,
    Emitter<ClinicAppointmentsState> emit,
  ) {
    // If an appointment was selected, refresh it from new list if still present
    final currentSelectedId = state.selectedAppointment?.id;
    final updatedSelected = currentSelectedId != null
        ? event.appointments.where((a) => a.id == currentSelectedId).firstOrNull
        : null;

    emit(
      state.copyWith(
        allAppointments: event.appointments,
        isLoading: false,
        selectedAppointment: () => updatedSelected,
      ),
    );
  }

  void _onChangeDateRangeFilter(
    ChangeDateRangeFilter event,
    Emitter<ClinicAppointmentsState> emit,
  ) {
    emit(state.copyWith(dateRangeFilter: event.dateRange));
  }

  void _onChangeDepartmentFilter(
    ChangeDepartmentFilter event,
    Emitter<ClinicAppointmentsState> emit,
  ) {
    emit(state.copyWith(departmentFilter: event.department));
  }

  void _onChangeServiceFilter(
    ChangeServiceFilter event,
    Emitter<ClinicAppointmentsState> emit,
  ) {
    emit(state.copyWith(serviceFilter: event.service));
  }

  void _onChangeDoctorFilter(
    ChangeDoctorFilter event,
    Emitter<ClinicAppointmentsState> emit,
  ) {
    emit(state.copyWith(doctorFilter: event.doctor));
  }

  void _onChangeStatusFilter(
    ChangeStatusFilter event,
    Emitter<ClinicAppointmentsState> emit,
  ) {
    emit(state.copyWith(statusFilter: event.status));
  }

  void _onChangePaymentFilter(
    ChangePaymentFilter event,
    Emitter<ClinicAppointmentsState> emit,
  ) {
    emit(state.copyWith(paymentFilter: event.payment));
  }

  void _onChangeSearchQuery(
    ChangeSearchQuery event,
    Emitter<ClinicAppointmentsState> emit,
  ) {
    emit(state.copyWith(searchQuery: event.query));
  }

  void _onResetFilters(
    ResetAppointmentFilters event,
    Emitter<ClinicAppointmentsState> emit,
  ) {
    emit(
      state.copyWith(
        dateRangeFilter: 'all',
        departmentFilter: 'all',
        serviceFilter: 'all',
        doctorFilter: 'all',
        statusFilter: 'all',
        paymentFilter: 'all',
        searchQuery: '',
      ),
    );
  }

  void _onToggleViewMode(
    ToggleAppointmentViewMode event,
    Emitter<ClinicAppointmentsState> emit,
  ) {
    emit(state.copyWith(viewMode: event.viewMode));
  }

  void _onSelectAppointment(
    SelectAppointment event,
    Emitter<ClinicAppointmentsState> emit,
  ) {
    emit(state.copyWith(selectedAppointment: () => event.appointment));
  }

  void _onSelectCalendarDate(
    SelectCalendarDate event,
    Emitter<ClinicAppointmentsState> emit,
  ) {
    emit(state.copyWith(selectedCalendarDate: event.selectedDate));
  }

  Future<void> _onCheckInAppointment(
    CheckInAppointment event,
    Emitter<ClinicAppointmentsState> emit,
  ) async {
    await repository.checkInAppointment(event.id);
  }

  Future<void> _onCompleteAppointment(
    CompleteAppointment event,
    Emitter<ClinicAppointmentsState> emit,
  ) async {
    await repository.completeAppointment(event.id);
  }

  Future<void> _onRescheduleAppointment(
    RescheduleAppointment event,
    Emitter<ClinicAppointmentsState> emit,
  ) async {
    await repository.rescheduleAppointment(
      event.id,
      event.newDate,
      event.newTime,
    );
  }

  Future<void> _onCancelAppointment(
    CancelAppointment event,
    Emitter<ClinicAppointmentsState> emit,
  ) async {
    await repository.cancelAppointment(
      event.id,
      reason: event.reason,
      refundAmount: event.refundAmount,
    );
  }

  Future<void> _onCreateAppointment(
    CreateAppointment event,
    Emitter<ClinicAppointmentsState> emit,
  ) async {
    await repository.addAppointment(event.appointment);
  }

  @override
  Future<void> close() {
    _appointmentsSubscription?.cancel();
    return super.close();
  }
}
