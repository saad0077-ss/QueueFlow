import 'package:equatable/equatable.dart';
import '../../domain/entities/clinic_revenue_summary.dart';

/// Base event for [ClinicRevenueBloc].
abstract class ClinicRevenueEvent extends Equatable {
  const ClinicRevenueEvent();

  @override
  List<Object?> get props => [];
}

/// Starts watching live clinic revenue for the default period.
class ClinicRevenueStarted extends ClinicRevenueEvent {
  const ClinicRevenueStarted();
}

/// Changes the active reporting window and resubscribes to live metrics.
class ClinicRevenuePeriodChanged extends ClinicRevenueEvent {
  final ClinicRevenuePeriod period;

  const ClinicRevenuePeriodChanged(this.period);

  @override
  List<Object?> get props => [period];
}

/// Filters the bottom transaction ledger by status (`all`, `paid`, `pending`, `refunded`).
class ClinicRevenueLedgerFilterChanged extends ClinicRevenueEvent {
  final String statusFilter;

  const ClinicRevenueLedgerFilterChanged(this.statusFilter);

  @override
  List<Object?> get props => [statusFilter];
}

/// Filters the bottom transaction ledger by search text.
class ClinicRevenueSearchChanged extends ClinicRevenueEvent {
  final String query;

  const ClinicRevenueSearchChanged(this.query);

  @override
  List<Object?> get props => [query];
}

/// Forces a fresh stream subscription for the active period.
class ClinicRevenueRefreshRequested extends ClinicRevenueEvent {
  const ClinicRevenueRefreshRequested();
}
