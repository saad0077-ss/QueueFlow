import 'support_ticket_model.dart';

class DefaultSupportTickets {
  static List<SupportTicketModel> get defaultTickets => const [
    SupportTicketModel(
      id: 'TKT-104',
      clinicId: 'sunrise-health',
      clinicName: 'Sunrise Health Clinic',
      category: 'queue',
      subject: 'Queue slot reschedule query',
      description: 'Can I defer my afternoon queue slot by 30 mins due to commute delay?',
      status: 'in_progress',
      priority: 'medium',
      createdAt: 'Today, 10:15 AM',
      slaNotice: 'Est. SLA: Resolution within 2 hrs',
      messages: [
        TicketMessageModel(
          sender: 'Aisha Rahman',
          text: 'Can I defer my afternoon queue slot by 30 mins due to commute delay?',
          time: '10:15 AM',
          isUser: true,
        ),
        TicketMessageModel(
          sender: 'Clinic Front Desk (Anu)',
          text: 'Hello Aisha! Yes, we have applied a 25-minute buffer to Token A-024. See you soon.',
          time: '10:22 AM',
          isUser: false,
        ),
      ],
    ),
    SupportTicketModel(
      id: 'TKT-098',
      clinicId: 'smile-dental',
      clinicName: 'Smile Dental Clinic',
      category: 'billing',
      subject: 'Digital invoice copy requested',
      description:
          'Please email the tax invoice for the teeth cleaning procedure.',
      status: 'resolved',
      priority: 'low',
      createdAt: '12 Jun 2026',
      slaNotice: 'Resolved on 12 Jun 2026',
      messages: [
        TicketMessageModel(
          sender: 'Aisha Rahman',
          text: 'Please send an itemized invoice for dental insurance claim.',
          time: '12 Jun, 2:00 PM',
          isUser: true,
        ),
        TicketMessageModel(
          sender: 'Smile Dental Accounts',
          text: 'Sent the PDF receipt to aisha.rahman@email.com with ARN ref.',
          time: '12 Jun, 2:45 PM',
          isUser: false,
        ),
      ],
    ),
  ];
}
