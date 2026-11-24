import '../../../../features/appointments/domain/entities/clinic_appointment_entity.dart';
import '../../../../features/services/domain/entities/clinic_service_entity.dart';
import '../../domain/entities/service_revenue_metric.dart';

/// Aggregates popularity, visit share and revenue per clinical service.
class ServiceRevenueCalculator {
  static List<ServiceRevenueMetric> calculateServiceMetrics({
    required List<ClinicServiceEntity> services,
    required List<ClinicAppointmentEntity> appointments,
  }) {
    final Map<String, int> counts = {};
    for (final a in appointments) {
      if (a.service.isNotEmpty) {
        counts[a.service] = (counts[a.service] ?? 0) + 1;
      }
    }

    final totalCount = appointments.isEmpty ? 1 : appointments.length;

    if (services.isEmpty) {
      return counts.entries.map((e) {
        final share = (e.value / totalCount) * 100;
        final rev = e.value * 500.0;
        return ServiceRevenueMetric(
          serviceId: e.key,
          serviceName: e.key,
          icon: _iconForService(e.key),
          fee: 500.0,
          visits: e.value,
          sharePercentage: double.parse(share.toStringAsFixed(1)),
          revenue: rev,
        );
      }).toList();
    }

    final list = services.map((svc) {
      final visits = counts[svc.name] ?? counts[svc.id] ?? 0;
      final fee = svc.price > 0 ? svc.price.toDouble() : 500.0;
      final share = (visits / totalCount) * 100;
      final revenue = visits * fee;

      return ServiceRevenueMetric(
        serviceId: svc.id,
        serviceName: svc.name,
        icon: _iconForService(svc.name),
        fee: fee,
        visits: visits,
        sharePercentage: double.parse(share.toStringAsFixed(1)),
        revenue: revenue,
      );
    }).toList();

    list.sort((a, b) => b.visits.compareTo(a.visits));
    return list;
  }

  static String _iconForService(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('checkup') || lower.contains('preventive')) return '🔬';
    if (lower.contains('diabet') || lower.contains('chronic')) return '💊';
    if (lower.contains('follow') || lower.contains('review')) return '📋';
    if (lower.contains('blood') || lower.contains('vital')) return '❤️';
    if (lower.contains('prescript') || lower.contains('refill')) return '📄';
    return '🩺';
  }
}
