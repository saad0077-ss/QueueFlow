import 'package:equatable/equatable.dart';

/// Domain entity representing the aggregate live queue metrics.
class ClinicQueueSummaryEntity extends Equatable {
  final String currentToken;
  final int waitingCount;
  final String avgWaitTime;
  final bool isPaused;
  final String status; // 'open' or 'paused'
  final String clinicName;

  /// Time today's configured break ends ("14:00") while the clinic is on its
  /// break; null otherwise.
  final String? breakEndsAt;

  /// Services whose queue was closed by the clinic: lower-cased service name
  /// -> date (yyyy-MM-dd) it was closed for.
  final Map<String, String> closedServices;

  const ClinicQueueSummaryEntity({
    this.breakEndsAt,
    this.currentToken = 'A-021',
    this.waitingCount = 3,
    this.avgWaitTime = '18 min',
    this.isPaused = false,
    this.status = 'open',
    this.clinicName = 'Sunrise Health Clinic',
    this.closedServices = const {},
  });

  bool get isOpen => !isPaused && status == 'open';
  bool get isOnBreak => breakEndsAt != null;

  static String todayKey([DateTime? now]) {
    final d = now ?? DateTime.now();
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-'
        '${d.day.toString().padLeft(2, '0')}';
  }

  /// True when [service]'s queue was closed for today.
  bool isServiceClosedToday(String service) =>
      closedServices[service.trim().toLowerCase()] == todayKey();

  ClinicQueueSummaryEntity copyWith({
    String? currentToken,
    int? waitingCount,
    String? avgWaitTime,
    bool? isPaused,
    String? status,
    String? clinicName,
    String? breakEndsAt,
    Map<String, String>? closedServices,
  }) {
    return ClinicQueueSummaryEntity(
      breakEndsAt: breakEndsAt ?? this.breakEndsAt,
      currentToken: currentToken ?? this.currentToken,
      waitingCount: waitingCount ?? this.waitingCount,
      avgWaitTime: avgWaitTime ?? this.avgWaitTime,
      isPaused: isPaused ?? this.isPaused,
      status: status ?? this.status,
      clinicName: clinicName ?? this.clinicName,
      closedServices: closedServices ?? this.closedServices,
    );
  }

  @override
  List<Object?> get props => [
    currentToken,
    waitingCount,
    avgWaitTime,
    isPaused,
    status,
    clinicName,
    breakEndsAt,
    closedServices,
  ];
}
