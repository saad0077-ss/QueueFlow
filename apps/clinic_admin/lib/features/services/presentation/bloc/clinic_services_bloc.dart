import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/clinic_services_repository.dart';
import '../../domain/usecases/delete_clinic_service_usecase.dart';
import '../../domain/usecases/get_clinic_services_usecase.dart';
import '../../domain/usecases/save_clinic_service_usecase.dart';
import '../../domain/usecases/toggle_service_status_usecase.dart';
import 'clinic_services_event.dart';
import 'clinic_services_state.dart';

class ClinicServicesBloc
    extends Bloc<ClinicServicesEvent, ClinicServicesState> {
  final GetClinicServicesUseCase _getServicesUseCase;
  final SaveClinicServiceUseCase _saveServiceUseCase;
  final ToggleServiceStatusUseCase _toggleServiceStatusUseCase;
  final DeleteClinicServiceUseCase _deleteServiceUseCase;
  final ClinicServicesRepository _repository;

  StreamSubscription? _servicesSub;

  ClinicServicesBloc({
    required GetClinicServicesUseCase getServicesUseCase,
    required SaveClinicServiceUseCase saveServiceUseCase,
    required ToggleServiceStatusUseCase toggleServiceStatusUseCase,
    required DeleteClinicServiceUseCase deleteServiceUseCase,
    required ClinicServicesRepository repository,
  }) : _getServicesUseCase = getServicesUseCase,
       _saveServiceUseCase = saveServiceUseCase,
       _toggleServiceStatusUseCase = toggleServiceStatusUseCase,
       _deleteServiceUseCase = deleteServiceUseCase,
       _repository = repository,
       super(const ClinicServicesState()) {
    on<ServicesSubscriptionRequested>(_onSubscriptionRequested);
    on<ServicesUpdated>(_onServicesUpdated);
    on<ServicesLoadFailed>(_onLoadFailed);
    on<ServiceSaveSubmitted>(_onServiceSaveSubmitted);
    on<ServiceStatusTogglePressed>(_onStatusTogglePressed);
    on<ServiceDeletePressed>(_onDeletePressed);
    on<ServicesClearToast>(_onClearToast);
  }

  Future<void> _onSubscriptionRequested(
    ServicesSubscriptionRequested event,
    Emitter<ClinicServicesState> emit,
  ) async {
    emit(state.copyWith(status: ServicesStatus.loading));
    try {
      final depts = await _repository.getDepartments();
      final plan = await _repository.getServicePlan();
      final doctors = await _repository.getDoctors();
      emit(state.copyWith(departments: depts, plan: plan, doctors: doctors));

      await _servicesSub?.cancel();
      _servicesSub = _getServicesUseCase().listen(
        (services) => add(ServicesUpdated(services)),
        onError: (Object e) => add(ServicesLoadFailed(e.toString())),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: ServicesStatus.failure,
          toastMessage: 'Failed to load services: $e',
          isErrorToast: true,
        ),
      );
    }
  }

  void _onServicesUpdated(
    ServicesUpdated event,
    Emitter<ClinicServicesState> emit,
  ) {
    emit(
      state.copyWith(status: ServicesStatus.success, services: event.services),
    );
  }

  void _onLoadFailed(
    ServicesLoadFailed event,
    Emitter<ClinicServicesState> emit,
  ) {
    emit(
      state.copyWith(
        status: ServicesStatus.failure,
        toastMessage: 'Failed to load services: ${event.message}',
        isErrorToast: true,
      ),
    );
  }

  Future<void> _onServiceSaveSubmitted(
    ServiceSaveSubmitted event,
    Emitter<ClinicServicesState> emit,
  ) async {
    try {
      await _saveServiceUseCase(event.service);
      final msg = event.service.isPending
          ? 'Service submitted for Super Admin review.'
          : 'Service saved successfully.';
      emit(state.copyWith(toastMessage: msg, isErrorToast: false));
    } catch (e) {
      emit(
        state.copyWith(
          toastMessage: 'Error saving service: $e',
          isErrorToast: true,
        ),
      );
    }
  }

  Future<void> _onStatusTogglePressed(
    ServiceStatusTogglePressed event,
    Emitter<ClinicServicesState> emit,
  ) async {
    try {
      await _toggleServiceStatusUseCase(event.serviceId, event.currentStatus);
      emit(
        state.copyWith(
          toastMessage: 'Service status updated.',
          isErrorToast: false,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          toastMessage: 'Error updating service status: $e',
          isErrorToast: true,
        ),
      );
    }
  }

  Future<void> _onDeletePressed(
    ServiceDeletePressed event,
    Emitter<ClinicServicesState> emit,
  ) async {
    try {
      await _deleteServiceUseCase(event.serviceId);
      emit(
        state.copyWith(
          toastMessage: 'Service deleted permanently.',
          isErrorToast: false,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          toastMessage: 'Error deleting service: $e',
          isErrorToast: true,
        ),
      );
    }
  }

  void _onClearToast(
    ServicesClearToast event,
    Emitter<ClinicServicesState> emit,
  ) {
    emit(state.copyWith(clearToast: true));
  }

  @override
  Future<void> close() {
    _servicesSub?.cancel();
    return super.close();
  }
}
