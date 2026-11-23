import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/get_platform_reports_usecase.dart';
import 'platform_reports_event.dart';
import 'platform_reports_state.dart';

class PlatformReportsBloc
    extends Bloc<PlatformReportsEvent, PlatformReportsState> {
  final GetPlatformReportsUseCase getReportsUseCase;

  PlatformReportsBloc({required this.getReportsUseCase})
    : super(const PlatformReportsState()) {
    on<PlatformReportsStarted>(_onStarted);
    on<PlatformReportsTimeRangeChanged>(_onTimeRangeChanged);
    on<PlatformReportsCustomRangeChanged>(_onCustomRangeChanged);
    on<PlatformReportsTierFilterChanged>(_onTierFilterChanged);
    on<PlatformReportsSyncRequested>(_onSyncRequested);
  }

  Future<void> _onStarted(
    PlatformReportsStarted event,
    Emitter<PlatformReportsState> emit,
  ) async {
    await _loadReport(
      emit,
      state.timeRange,
      state.tierFilter,
      customRange: state.customDateRange,
    );
  }

  Future<void> _onTimeRangeChanged(
    PlatformReportsTimeRangeChanged event,
    Emitter<PlatformReportsState> emit,
  ) async {
    emit(state.copyWith(timeRange: event.timeRange, customDateRange: () => null));
    await _loadReport(emit, event.timeRange, state.tierFilter);
  }

  Future<void> _onCustomRangeChanged(
    PlatformReportsCustomRangeChanged event,
    Emitter<PlatformReportsState> emit,
  ) async {
    final range = event.customRange;
    if (range == null) {
      emit(state.copyWith(timeRange: '30d', customDateRange: () => null));
      await _loadReport(emit, '30d', state.tierFilter);
    } else {
      emit(state.copyWith(timeRange: 'custom', customDateRange: () => range));
      await _loadReport(emit, 'custom', state.tierFilter, customRange: range);
    }
  }

  Future<void> _onTierFilterChanged(
    PlatformReportsTierFilterChanged event,
    Emitter<PlatformReportsState> emit,
  ) async {
    emit(state.copyWith(tierFilter: event.tierFilter));
    await _loadReport(
      emit,
      state.timeRange,
      event.tierFilter,
      customRange: state.customDateRange,
    );
  }

  Future<void> _onSyncRequested(
    PlatformReportsSyncRequested event,
    Emitter<PlatformReportsState> emit,
  ) async {
    emit(state.copyWith(status: PlatformReportsStatus.loading));
    await _loadReport(
      emit,
      state.timeRange,
      state.tierFilter,
      customRange: state.customDateRange,
      feedback: 'Platform telemetry synchronized with live network cluster.',
    );
  }

  Future<void> _loadReport(
    Emitter<PlatformReportsState> emit,
    String timeRange,
    String tierFilter, {
    DateTimeRange? customRange,
    String? feedback,
  }) async {
    emit(state.copyWith(status: PlatformReportsStatus.loading));
    try {
      final report = await getReportsUseCase(
        timeRange: timeRange,
        tierFilter: tierFilter,
        customRange: customRange,
      );
      emit(
        state.copyWith(
          status: PlatformReportsStatus.loaded,
          report: report,
          feedbackMessage: feedback,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: PlatformReportsStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}
