import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import '../../domain/entities/clinic_report_data.dart';

enum ClinicReportsStatus { initial, loading, success, failure }

class ClinicReportsState extends Equatable {
  final ClinicReportsStatus status;
  final ClinicReportData? data;
  final String activePeriod;
  final DateTimeRange? customRange;
  final String? errorMessage;

  const ClinicReportsState({
    this.status = ClinicReportsStatus.initial,
    this.data,
    this.activePeriod = 'month',
    this.customRange,
    this.errorMessage,
  });

  bool get isLoading => status == ClinicReportsStatus.loading;
  bool get isSuccess => status == ClinicReportsStatus.success;

  ClinicReportsState copyWith({
    ClinicReportsStatus? status,
    ClinicReportData? data,
    String? activePeriod,
    DateTimeRange? customRange,
    bool clearCustomRange = false,
    String? errorMessage,
  }) {
    return ClinicReportsState(
      status: status ?? this.status,
      data: data ?? this.data,
      activePeriod: activePeriod ?? this.activePeriod,
      customRange: clearCustomRange ? null : (customRange ?? this.customRange),
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    data,
    activePeriod,
    customRange,
    errorMessage,
  ];
}
