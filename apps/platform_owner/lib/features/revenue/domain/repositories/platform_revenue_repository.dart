import '../entities/platform_revenue_entity.dart';

abstract class PlatformRevenueRepository {
  Future<PlatformRevenueEntity> getRevenueMetrics({
    String timeframe = 'current_month',
  });
}
