import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../models/platform_support_ticket_model.dart';
import '../models/platform_ticket_message_model.dart';

class PlatformTicketsSeedHelper {
  static List<PlatformSupportTicketModel> get defaultTickets => [
    PlatformSupportTicketModel(
      id: 'TK-1758',
      ticketNumber: 'TK-1758',
      patientId: 'patient_saad',
      patientName: 'Muhammed Saad',
      patientEmail: 'muhammedsaad007700@gmail.com',
      patientPhone: '8921873547',
      clinicId: 'green_heaven',
      clinicName: 'Green Heaven Clinic',
      isClinicRelated: true,
      category: 'Billing',
      subject: 'Payment receipt / Tax invoice query',
      description:
          'Need consultation receipt or clarification on recent transaction.',
      status: 'resolved',
      priority: 'low',
      slaMinutes: 25,
      slaNotice: 'SLA Met',
      assignedTo: 'Platform Admin',
      resolvedAt: 'Yesterday',
      createdAt: 'Yesterday',
      createdAtDate: DateTime.now().subtract(const Duration(days: 1)),
      messages: [
        PlatformTicketMessageModel(
          sender: 'Muhammed Saad',
          senderRole: 'patient',
          text:
              'Need consultation receipt or clarification on recent transaction.',
          time: 'Yesterday 14:20',
          isUser: true,
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
        ),
        PlatformTicketMessageModel(
          sender: 'Platform Admin',
          senderRole: 'platform_owner',
          text:
              'Hello Muhammed Saad, your tax invoice has been sent to your email.',
          time: 'Yesterday 14:35',
          isUser: false,
          createdAt: DateTime.now().subtract(
            const Duration(days: 1, minutes: -15),
          ),
        ),
      ],
    ),
    PlatformSupportTicketModel(
      id: 'TK-2041',
      ticketNumber: 'TK-2041',
      patientId: 'patient_priya',
      patientName: 'Priya Nair',
      patientEmail: 'priya.nair@gmail.com',
      patientPhone: '9846012345',
      clinicId: 'platform',
      clinicName: 'Green Heaven Clinic',
      isClinicRelated: false,
      category: 'Technical Bug',
      subject: 'Queue check-in timeout error',
      description:
          'Getting an unexpected timeout when scanning QR code at counter 2.',
      status: 'resolved',
      priority: 'high',
      slaMinutes: 5,
      slaNotice: '< 5m SLA',
      assignedTo: 'Platform Operations',
      resolvedAt: '2 hours ago',
      createdAt: '2 hours ago',
      createdAtDate: DateTime.now().subtract(const Duration(hours: 2)),
      messages: [
        PlatformTicketMessageModel(
          sender: 'Priya Nair',
          senderRole: 'patient',
          text:
              'Getting an unexpected timeout when scanning QR code at counter 2.',
          time: '2h ago',
          isUser: true,
          createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        ),
        PlatformTicketMessageModel(
          sender: 'Platform Operations',
          senderRole: 'platform_owner',
          text: 'QR token gateway node refreshed. Terminal restored.',
          time: '1h 55m ago',
          isUser: false,
          createdAt: DateTime.now().subtract(
            const Duration(hours: 1, minutes: 55),
          ),
        ),
      ],
    ),
  ];

  static bool _hasSeeded = false;

  static void seedIfEmpty(FirebaseFirestore firestore) {
    if (_hasSeeded) return;
    _hasSeeded = true;
    firestore.collection('support_tickets').get().then((snap) {
      if (snap.docs.isEmpty) {
        for (final t in defaultTickets) {
          firestore
              .collection('support_tickets')
              .doc(t.id)
              .set(t.toJson())
              .catchError((e) {
                debugPrint('Error writing seed ticket: $e');
              });
        }
      }
    }).catchError((e) {
      debugPrint('Error checking support_tickets for seed: $e');
    });
  }
}
