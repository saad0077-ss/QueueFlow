enum PatientNotificationCategory { queue, booking, support, broadcast }

class PatientNotificationEntity {
  final String id;
  final String title;
  final String body;
  final DateTime timestamp;
  final PatientNotificationCategory category;
  final String route;
  final bool isRead;

  const PatientNotificationEntity({
    required this.id,
    required this.title,
    required this.body,
    required this.timestamp,
    required this.category,
    required this.route,
    this.isRead = false,
  });

  PatientNotificationEntity copyWith({bool? isRead}) {
    return PatientNotificationEntity(
      id: id,
      title: title,
      body: body,
      timestamp: timestamp,
      category: category,
      route: route,
      isRead: isRead ?? this.isRead,
    );
  }
}
