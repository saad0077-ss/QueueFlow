enum ClinicNotificationType { queue, appointment, support, system }

class ClinicNotificationItem {
  final String id;
  final String title;
  final String body;
  final DateTime timestamp;
  final ClinicNotificationType type;
  final String routeNav;
  final bool isRead;

  const ClinicNotificationItem({
    required this.id,
    required this.title,
    required this.body,
    required this.timestamp,
    required this.type,
    required this.routeNav,
    this.isRead = false,
  });

  ClinicNotificationItem copyWith({bool? isRead}) {
    return ClinicNotificationItem(
      id: id,
      title: title,
      body: body,
      timestamp: timestamp,
      type: type,
      routeNav: routeNav,
      isRead: isRead ?? this.isRead,
    );
  }
}
