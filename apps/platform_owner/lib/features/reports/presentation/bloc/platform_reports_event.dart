import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

abstract class PlatformReportsEvent extends Equatable {
  const PlatformReportsEvent();

  @override
  List<Object?> get props => [];
}

class PlatformReportsStarted extends PlatformReportsEvent {
  const PlatformReportsStarted();
}

class PlatformReportsTimeRangeChanged extends PlatformReportsEvent {
  final String timeRange;

  const PlatformReportsTimeRangeChanged(this.timeRange);

  @override
  List<Object?> get props => [timeRange];
}

class PlatformReportsCustomRangeChanged extends PlatformReportsEvent {
  final DateTimeRange? customRange;

  const PlatformReportsCustomRangeChanged(this.customRange);

  @override
  List<Object?> get props => [customRange];
}

class PlatformReportsTierFilterChanged extends PlatformReportsEvent {
  final String tierFilter;

  const PlatformReportsTierFilterChanged(this.tierFilter);

  @override
  List<Object?> get props => [tierFilter];
}

class PlatformReportsSyncRequested extends PlatformReportsEvent {
  const PlatformReportsSyncRequested();
}
