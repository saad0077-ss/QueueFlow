import 'package:flutter/material.dart';
import '../entities/clinic_report_data.dart';

abstract class ClinicReportsRepository {
  /// Fetches aggregated reports data for the given period or custom date range.
  Future<ClinicReportData> getReport({
    String period = 'month',
    DateTimeRange? customRange,
  });

  /// Streams real-time updates for the active clinic report.
  Stream<ClinicReportData> watchReport({
    String period = 'month',
    DateTimeRange? customRange,
  });
}
