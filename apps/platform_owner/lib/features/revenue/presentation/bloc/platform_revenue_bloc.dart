import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/repositories/platform_revenue_repository_impl.dart';
import '../../domain/entities/platform_revenue_entity.dart';
import '../../domain/repositories/platform_revenue_repository.dart';
import 'platform_revenue_event.dart';
import 'platform_revenue_state.dart';

class PlatformRevenueBloc
    extends Bloc<PlatformRevenueEvent, PlatformRevenueState> {
  final PlatformRevenueRepository _repository;

  PlatformRevenueBloc({PlatformRevenueRepository? repository})
    : _repository = repository ?? PlatformRevenueRepositoryImpl(),
      super(const PlatformRevenueState()) {
    on<PlatformRevenueStarted>(_onStarted);
    on<PlatformRevenueTimeframeChanged>(_onTimeframeChanged);
  }

  Future<void> _onStarted(
    PlatformRevenueStarted event,
    Emitter<PlatformRevenueState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));
    try {
      final metrics = await _repository.getRevenueMetrics(
        timeframe: state.timeframe,
      );
      emit(_mapMetricsToState(metrics, state.timeframe));
    } catch (_) {
      emit(state.copyWith(isLoading: false));
    }
  }

  Future<void> _onTimeframeChanged(
    PlatformRevenueTimeframeChanged event,
    Emitter<PlatformRevenueState> emit,
  ) async {
    emit(state.copyWith(timeframe: event.timeframe, isLoading: true));
    try {
      final metrics = await _repository.getRevenueMetrics(
        timeframe: event.timeframe,
      );
      emit(_mapMetricsToState(metrics, event.timeframe));
    } catch (_) {
      emit(state.copyWith(isLoading: false));
    }
  }

  PlatformRevenueState _mapMetricsToState(
    PlatformRevenueEntity m,
    String timeframe,
  ) {
    final mrrStr = _formatCurrency(m.mrr);
    final arrStr = _formatCompact(m.arr);
    final grossStr = _formatCompact(m.grossRevenue);
    final arpuStr = _formatCurrency(m.arpu);

    final totalCount = m.enterpriseCount + m.multiCount + m.soloCount;
    final entPct = totalCount > 0
        ? (m.enterpriseCount / totalCount * 100)
        : 0.0;
    final mulPct = totalCount > 0 ? (m.multiCount / totalCount * 100) : 0.0;
    final solPct = totalCount > 0 ? (m.soloCount / totalCount * 100) : 0.0;

    return state.copyWith(
      timeframe: timeframe,
      isLoading: false,
      grossRevenue: grossStr,
      mrrAmount: mrrStr,
      arrAmount: arrStr,
      arpuAmount: arpuStr,
      activeClinicsCount: m.activeClinicsCount,
      clinicRevenueItems: m.clinicRevenueItems,
      recentInvoices: m.recentInvoices,
      totalMrr: '$mrrStr / mo',
      enterpriseAmount: '${_formatCurrency(m.enterpriseMrr)}/mo',
      enterpriseCount:
          '${m.enterpriseCount} Clinics (${entPct.toStringAsFixed(1)}%)',
      multiAmount: '${_formatCurrency(m.multiMrr)}/mo',
      multiCount: '${m.multiCount} Clinics (${mulPct.toStringAsFixed(1)}%)',
      soloAmount: '${_formatCurrency(m.soloMrr)}/mo',
      soloCount: '${m.soloCount} Clinics (${solPct.toStringAsFixed(1)}%)',
    );
  }

  String _formatCurrency(int val) {
    final s = val.toString();
    if (s.length <= 3) return '₹$s';
    final lastThree = s.substring(s.length - 3);
    final remaining = s.substring(0, s.length - 3);
    final formatted = remaining.replaceAllMapped(
      RegExp(r'\B(?=(\d{2})+(?!\d))'),
      (m) => '${m[0]},',
    );
    return '₹$formatted,$lastThree';
  }

  String _formatCompact(int val) {
    if (val >= 10000000) {
      return '₹${(val / 10000000).toStringAsFixed(2)}Cr';
    }
    if (val >= 100000) {
      return '₹${(val / 100000).toStringAsFixed(2)}L';
    }
    return _formatCurrency(val);
  }
}
