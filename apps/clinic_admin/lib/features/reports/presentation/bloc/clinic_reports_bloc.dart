import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/clinic_reports_repository.dart';
import 'clinic_reports_event.dart';
import 'clinic_reports_state.dart';

class ClinicReportsBloc extends Bloc<ClinicReportsEvent, ClinicReportsState> {
  final ClinicReportsRepository _repository;

  ClinicReportsBloc({required ClinicReportsRepository repository})
    : _repository = repository,
      super(const ClinicReportsState()) {
    on<ClinicReportsStarted>(_onStarted);
    on<ClinicReportsPeriodChanged>(_onPeriodChanged);
    on<ClinicReportsCustomRangeSelected>(_onCustomRangeSelected);
    on<ClinicReportsRefreshRequested>(_onRefreshRequested);
  }

  Future<void> _onStarted(
    ClinicReportsStarted event,
    Emitter<ClinicReportsState> emit,
  ) async {
    emit(state.copyWith(status: ClinicReportsStatus.loading));
    await _loadReport(emit, period: state.activePeriod, range: state.customRange);
  }

  Future<void> _onPeriodChanged(
    ClinicReportsPeriodChanged event,
    Emitter<ClinicReportsState> emit,
  ) async {
    emit(
      state.copyWith(
        status: ClinicReportsStatus.loading,
        activePeriod: event.period,
        clearCustomRange: true,
      ),
    );
    await _loadReport(emit, period: event.period, range: null);
  }

  Future<void> _onCustomRangeSelected(
    ClinicReportsCustomRangeSelected event,
    Emitter<ClinicReportsState> emit,
  ) async {
    emit(
      state.copyWith(
        status: ClinicReportsStatus.loading,
        activePeriod: 'custom',
        customRange: event.range,
      ),
    );
    await _loadReport(emit, period: 'custom', range: event.range);
  }

  Future<void> _onRefreshRequested(
    ClinicReportsRefreshRequested event,
    Emitter<ClinicReportsState> emit,
  ) async {
    emit(state.copyWith(status: ClinicReportsStatus.loading));
    await _loadReport(emit, period: state.activePeriod, range: state.customRange);
  }

  Future<void> _loadReport(
    Emitter<ClinicReportsState> emit, {
    required String period,
    DateTimeRange? range,
  }) async {
    try {
      final report = await _repository.getReport(
        period: period,
        customRange: range,
      );
      emit(
        state.copyWith(
          status: ClinicReportsStatus.success,
          data: report,
          errorMessage: null,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: ClinicReportsStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}
