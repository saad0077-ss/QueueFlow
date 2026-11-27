enum PatientNotificationCategory { queue, booking, support, broadcast }

class PatientNotificationEntity {
  final String id;
  final String title;
  final String body;
  final DateTime timestamp;
  final PatientNotificationCategory category;
  final String route;
  final bool isRead;
  final String clinicName;
  final String badgeLabel;
  final bool isUrgent;
  final bool isPushReceived;

  const PatientNotificationEntity({
    required this.id,
    required this.title,
    required this.body,
    required this.timestamp,
    required this.category,
    required this.route,
    this.isRead = false,
    this.clinicName = '',
    this.badgeLabel = '',
    this.isUrgent = false,
    this.isPushReceived = false,
  });

  PatientNotificationEntity copyWith({
    bool? isRead,
    String? clinicName,
    String? badgeLabel,
    bool? isUrgent,
    bool? isPushReceived,
  }) {
    return PatientNotificationEntity(
      id: id,
      title: title,
      body: body,
      timestamp: timestamp,
      category: category,
      route: route,
      isRead: isRead ?? this.isRead,
      clinicName: clinicName ?? this.clinicName,
      badgeLabel: badgeLabel ?? this.badgeLabel,
      isUrgent: isUrgent ?? this.isUrgent,
      isPushReceived: isPushReceived ?? this.isPushReceived,
    );
  }
}
