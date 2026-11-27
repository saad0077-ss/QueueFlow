import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/clinic_revenue_summary.dart';
import '../../domain/repositories/clinic_revenue_repository.dart';
import 'clinic_revenue_event.dart';
import 'clinic_revenue_state.dart';

class _RevenueSummaryReceived extends ClinicRevenueEvent {
  final ClinicRevenueSummary summary;
  const _RevenueSummaryReceived(this.summary);

  @override
  List<Object?> get props => [summary];
}

class _RevenueStreamFailed extends ClinicRevenueEvent {
  final String message;
  const _RevenueStreamFailed(this.message);

  @override
  List<Object?> get props => [message];
}

/// Manages real-time clinic earnings, period filtering, and ledger queries.
class ClinicRevenueBloc extends Bloc<ClinicRevenueEvent, ClinicRevenueState> {
  final ClinicRevenueRepository _repository;
  StreamSubscription<ClinicRevenueSummary>? _sub;
  int _subToken = 0;

  ClinicRevenueBloc({required ClinicRevenueRepository repository})
    : _repository = repository,
      super(const ClinicRevenueState()) {
    on<ClinicRevenueStarted>((_, emit) => _subscribe(state.period, emit));
    on<ClinicRevenueRefreshRequested>(
      (_, emit) => _subscribe(state.period, emit),
    );
    on<ClinicRevenuePeriodChanged>(
      (event, emit) => _subscribe(event.period, emit),
    );
    on<ClinicRevenueLedgerFilterChanged>(
      (event, emit) =>
          emit(state.copyWith(ledgerStatusFilter: event.statusFilter)),
    );
    on<ClinicRevenueSearchChanged>(
      (event, emit) => emit(state.copyWith(searchQuery: event.query)),
    );
    on<_RevenueSummaryReceived>(
      (event, emit) => emit(
        state.copyWith(
          isLoading: false,
          summary: event.summary,
          clearError: true,
        ),
      ),
    );
    on<_RevenueStreamFailed>(
      (event, emit) => emit(
        state.copyWith(isLoading: false, errorMessage: event.message),
      ),
    );
  }

  void _subscribe(
    ClinicRevenuePeriod period,
    Emitter<ClinicRevenueState> emit,
  ) {
    final token = ++_subToken;
    emit(state.copyWith(period: period, isLoading: true, clearError: true));
    unawaited(_sub?.cancel());
    _sub = _repository.watchRevenue(period: period).listen(
      (summary) {
        if (token == _subToken && !isClosed) {
          add(_RevenueSummaryReceived(summary));
        }
      },
      onError: (Object error) {
        if (token == _subToken && !isClosed) {
          add(_RevenueStreamFailed(error.toString()));
        }
      },
    );
  }

  @override
  Future<void> close() async {
    _subToken++;
    await _sub?.cancel();
    return super.close();
  }
}
