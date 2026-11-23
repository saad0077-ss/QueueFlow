import '../../domain/entities/platform_support_ticket_entity.dart';

class PlatformTicketsFilterHelper {
  static List<PlatformSupportTicketEntity> applyFilters({
    required List<PlatformSupportTicketEntity> all,
    required String status,
    required String clinicId,
    required String sla,
    required String category,
    required String searchQuery,
    required String topBarSearch,
  }) {
    var res = all;
    if (status != 'all') res = res.where((t) => t.status == status).toList();
    if (clinicId != 'all') {
      res = res.where((t) => t.clinicId == clinicId).toList();
    }
    if (sla == 'urgent') {
      res = res
          .where((t) => t.slaMinutes < 15 || t.priority == 'high')
          .toList();
    } else if (sla == 'high') {
      res = res.where((t) => t.priority == 'high').toList();
    }
    if (category != 'all') {
      res = res
          .where(
            (t) => t.category.toLowerCase().contains(category.toLowerCase()),
          )
          .toList();
    }
    final q = '$topBarSearch $searchQuery'.trim().toLowerCase();
    if (q.isNotEmpty) {
      res = res
          .where(
            (t) =>
                t.ticketNumber.toLowerCase().contains(q) ||
                t.patientName.toLowerCase().contains(q) ||
                t.clinicName.toLowerCase().contains(q) ||
                t.subject.toLowerCase().contains(q) ||
                t.description.toLowerCase().contains(q),
          )
          .toList();
    }
    return res;
  }
}
