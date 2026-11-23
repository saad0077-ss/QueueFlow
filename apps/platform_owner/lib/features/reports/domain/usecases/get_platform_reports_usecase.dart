import 'package:flutter/material.dart';

import '../entities/platform_report_entity.dart';
import '../repositories/platform_reports_repository.dart';

class GetPlatformReportsUseCase {
  final PlatformReportsRepository repository;

  const GetPlatformReportsUseCase(this.repository);

  Future<PlatformReportEntity> call({
    String timeRange = '30d',
    String tierFilter = 'all',
    DateTimeRange? customRange,
  }) {
    return repository.getPlatformReport(
      timeRange: timeRange,
      tierFilter: tierFilter,
      customRange: customRange,
    );
  }
}
