import '../entities/clinic_revenue_summary.dart';

/// Contract for streaming real-time clinic earnings and payment settlements.
abstract class ClinicRevenueRepository {
  /// Emits an updated [ClinicRevenueSummary] whenever clinic appointments or
  /// services change in the selected [period].
  Stream<ClinicRevenueSummary> watchRevenue({
    ClinicRevenuePeriod period = ClinicRevenuePeriod.month,
  });
}
