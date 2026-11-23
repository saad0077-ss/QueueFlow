import 'package:flutter/material.dart';

import '../entities/platform_report_entity.dart';

abstract class PlatformReportsRepository {
  Future<PlatformReportEntity> getPlatformReport({
    String timeRange = '30d',
    String tierFilter = 'all',
    DateTimeRange? customRange,
  });
}
