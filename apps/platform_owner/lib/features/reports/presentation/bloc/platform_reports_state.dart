import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/platform_report_entity.dart';

enum PlatformReportsStatus { initial, loading, loaded, failure }

class PlatformReportsState extends Equatable {
  final PlatformReportsStatus status;
  final PlatformReportEntity? report;
  final String timeRange;
  final DateTimeRange? customDateRange;
  final String tierFilter;
  final String? errorMessage;
  final String? feedbackMessage;

  const PlatformReportsState({
    this.status = PlatformReportsStatus.initial,
    this.report,
    this.timeRange = '30d',
    this.customDateRange,
    this.tierFilter = 'all',
    this.errorMessage,
    this.feedbackMessage,
  });

  PlatformReportsState copyWith({
    PlatformReportsStatus? status,
    PlatformReportEntity? report,
    String? timeRange,
    DateTimeRange? Function()? customDateRange,
    String? tierFilter,
    String? errorMessage,
    String? feedbackMessage,
  }) {
    return PlatformReportsState(
      status: status ?? this.status,
      report: report ?? this.report,
      timeRange: timeRange ?? this.timeRange,
      customDateRange: customDateRange != null
          ? customDateRange()
          : this.customDateRange,
      tierFilter: tierFilter ?? this.tierFilter,
      errorMessage: errorMessage,
      feedbackMessage: feedbackMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    report,
    timeRange,
    customDateRange,
    tierFilter,
    errorMessage,
    feedbackMessage,
  ];
}
