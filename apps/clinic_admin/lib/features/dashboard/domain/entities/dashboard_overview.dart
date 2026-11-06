import '../../../appointments/domain/entities/clinic_appointment_entity.dart';
import '../../../services/domain/entities/clinic_doctor_entity.dart';
import '../../../services/domain/entities/clinic_service_entity.dart';
import '../../../services/domain/entities/service_department_entity.dart';
import 'clinic_department_summary_entity.dart';

class TrendPoint {
  final String label;
  final int count;
  final bool isToday;
  const TrendPoint(this.label, this.count, {this.isToday = false});
}

class ServiceUsage {
  final String name;
  final String department;
  final int count;
  final int percentage;
  const ServiceUsage(this.name, this.department, this.count, this.percentage);
}

/// Everything the dashboard shows, derived from the clinic's real
/// departments, services, doctors and appointments (no placeholder data).
class DashboardOverview {
  final String clinicName;
  final List<ClinicDepartmentSummaryEntity> departments;
  final int todayAppointments;
  final int servedToday;
  final int checkedInNow;
  final List<ClinicAppointmentEntity> upcoming;
  final List<TrendPoint> trend;
  final List<ServiceUsage> popularServices;

  const DashboardOverview({
    this.clinicName = '',
    this.departments = const [],
    this.todayAppointments = 0,
    this.servedToday = 0,
    this.checkedInNow = 0,
    this.upcoming = const [],
    this.trend = const [],
    this.popularServices = const [],
  });

  static const _weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  static String _key(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  static String _norm(String s) => s.trim().toLowerCase();

  /// Sortable minutes-since-midnight from labels like "11:00 AM".
  static int _minutes(String t) {
    final m = RegExp(r'(\d{1,2}):(\d{2})\s*(AM|PM)?', caseSensitive: false)
        .firstMatch(t);
    if (m == null) return 0;
    var h = int.parse(m.group(1)!);
    final min = int.parse(m.group(2)!);
    final ap = m.group(3)?.toUpperCase();
    if (ap == 'PM' && h < 12) h += 12;
    if (ap == 'AM' && h == 12) h = 0;
    return h * 60 + min;
  }

  factory DashboardOverview.build({
    required String clinicName,
    required List<ServiceDepartmentEntity> departments,
    required List<ClinicServiceEntity> services,
    required List<ClinicDoctorEntity> doctors,
    required List<ClinicAppointmentEntity> appointments,
    DateTime? now,
  }) {
    final today = now ?? DateTime.now();
    final todayKey = _key(today);
    final live = appointments.where((a) => !a.isCancelled).toList();
    final todays = live.where((a) => a.dateRaw == todayKey).toList();

    final summaries = departments.map((d) {
      final name = _norm(d.name);
      final deptAppts = live.where((a) => _norm(a.departmentName) == name);
      return ClinicDepartmentSummaryEntity(
        id: d.id,
        code: d.code,
        name: d.name,
        icon: d.icon,
        description: d.standardServices.isEmpty
            ? ''
            : d.standardServices.take(4).map((s) => s.name).join(', '),
        doctorCount: doctors
            .where(
              (x) => _norm(x.department) == name || _norm(x.specialty) == name,
            )
            .length,
        proceduresCount: services
            .where(
              (s) =>
                  s.status == 'active' &&
                  (s.departmentId == d.id || _norm(s.departmentName) == name),
            )
            .length,
        waitingCount: deptAppts
            .where((a) => a.dateRaw == todayKey && a.isCheckedIn)
            .length,
        appointmentCount: deptAppts.where((a) => !a.isCompleted).length,
      );
    }).toList();

    // Appointment volume, last 7 days ending today.
    final trend = <TrendPoint>[];
    for (var i = 6; i >= 0; i--) {
      final day = DateTime(today.year, today.month, today.day - i);
      final k = _key(day);
      trend.add(
        TrendPoint(
          _weekdays[day.weekday - 1],
          live.where((a) => a.dateRaw == k).length,
          isToday: i == 0,
        ),
      );
    }

    // Most booked services, remembering each one's department.
    final counts = <String, int>{};
    final deptOf = <String, String>{};
    for (final a in live) {
      counts[a.service] = (counts[a.service] ?? 0) + 1;
      deptOf[a.service] = a.departmentName;
    }
    final ranked = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final top = ranked.take(10).toList();
    final maxCount = top.isEmpty ? 1 : top.first.value;
    final popular = [
      for (final e in top)
        ServiceUsage(
          e.key,
          deptOf[e.key] ?? '',
          e.value,
          (e.value * 100 / maxCount).round(),
        ),
    ];

    final upcoming = live.where((a) => !a.isCompleted).toList()
      ..sort((a, b) {
        final c = a.dateRaw.compareTo(b.dateRaw);
        return c != 0 ? c : _minutes(a.timeRaw).compareTo(_minutes(b.timeRaw));
      });
    final fromToday = upcoming.where((a) => a.dateRaw.compareTo(todayKey) >= 0);

    return DashboardOverview(
      clinicName: clinicName,
      departments: summaries,
      todayAppointments: todays.length,
      servedToday: todays.where((a) => a.isCompleted).length,
      checkedInNow: todays.where((a) => a.isCheckedIn).length,
      upcoming: fromToday.toList(),
      trend: trend,
      popularServices: popular,
    );
  }
}
