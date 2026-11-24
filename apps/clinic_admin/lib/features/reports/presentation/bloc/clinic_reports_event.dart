import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

abstract class ClinicReportsEvent extends Equatable {
  const ClinicReportsEvent();

  @override
  List<Object?> get props => [];
}

/// Initial load or refresh event.
class ClinicReportsStarted extends ClinicReportsEvent {
  const ClinicReportsStarted();
}

/// Switched period preset (e.g. 'today', 'week', 'month', 'quarter').
class ClinicReportsPeriodChanged extends ClinicReportsEvent {
  final String period;

  const ClinicReportsPeriodChanged(this.period);

  @override
  List<Object?> get props => [period];
}

/// Picked custom date range (start & end).
class ClinicReportsCustomRangeSelected extends ClinicReportsEvent {
  final DateTimeRange range;

  const ClinicReportsCustomRangeSelected(this.range);

  @override
  List<Object?> get props => [range];
}

/// Refreshes the reports with live Firestore state.
class ClinicReportsRefreshRequested extends ClinicReportsEvent {
  const ClinicReportsRefreshRequested();
}
