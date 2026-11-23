import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/clinic_support_ticket_model.dart';
import 'clinic_tickets_creation_helper.dart';
import 'clinic_tickets_mutation_helper.dart';
import 'clinic_tickets_remote_datasource.dart';

class ClinicTicketsRemoteDataSourceImpl
    implements ClinicTicketsRemoteDataSource {
  final FirebaseFirestore _firestore;

  ClinicTicketsRemoteDataSourceImpl({FirebaseFirestore? firestore})
    : _firestore = firestore ?? _safeFirestore();

  static FirebaseFirestore _safeFirestore() {
    return FirebaseFirestore.instance;
  }

  @override
  Stream<List<ClinicSupportTicketModel>> watchTickets({
    required String clinicId,
    String? clinicName,
  }) {
    return _firestore.collection('support_tickets').snapshots().map((snap) {
      final list = <ClinicSupportTicketModel>[];
      for (final doc in snap.docs) {
        final data = doc.data();
        final docClinicId = (data['clinicId'] ?? '').toString();
        final docClinicName = (data['clinicName'] ?? '').toString();
        final isClinic = data['isClinicRelated'] as bool? ?? true;
        final category = (data['category'] ?? '').toString().toLowerCase();

        final isAppBug =
            !isClinic ||
            category == 'technical' ||
            category.contains('bug') ||
            docClinicId == 'platform';
        if (isAppBug) continue;

        final matchClinic =
            (clinicId.isNotEmpty && docClinicId == clinicId) ||
            (clinicName != null &&
                clinicName.isNotEmpty &&
                docClinicName.toLowerCase().contains(
                  clinicName.toLowerCase(),
                )) ||
            (clinicId.isEmpty && docClinicId != 'platform');

        if (matchClinic) {
          try {
            list.add(ClinicSupportTicketModel.fromFirestore(doc));
          } catch (e) {
            debugPrint('Error parsing clinic ticket ${doc.id}: $e');
          }
        }
      }

      list.sort((a, b) {
        final da = a.createdAtDate ?? DateTime(2000);
        final db = b.createdAtDate ?? DateTime(2000);
        return db.compareTo(da);
      });
      return list;
    });
  }

  @override
  Future<void> sendReply({
    required String ticketId,
    required String text,
    required String staffName,
    bool isInternalNote = false,
  }) {
    return ClinicTicketsMutationHelper.sendReply(
      firestore: _firestore,
      ticketId: ticketId,
      text: text,
      staffName: staffName,
      isInternalNote: isInternalNote,
    );
  }

  @override
  Future<void> updateStatus({
    required String ticketId,
    required String status,
    String staffName = 'Clinic Admin',
  }) {
    return ClinicTicketsMutationHelper.updateStatus(
      firestore: _firestore,
      ticketId: ticketId,
      status: status,
      staffName: staffName,
    );
  }

  @override
  Future<void> updatePriority({
    required String ticketId,
    required String priority,
  }) {
    return ClinicTicketsMutationHelper.updatePriority(
      firestore: _firestore,
      ticketId: ticketId,
      priority: priority,
    );
  }

  @override
  Future<void> escalateTicket({
    required String ticketId,
    required String staffName,
  }) {
    return ClinicTicketsMutationHelper.escalateTicket(
      firestore: _firestore,
      ticketId: ticketId,
      staffName: staffName,
    );
  }

  @override
  Future<ClinicSupportTicketModel> createManualTicket({
    required String clinicId,
    required String clinicName,
    required String patientName,
    required String patientPhone,
    String? patientEmail,
    String? tokenNumber,
    required String category,
    required String priority,
    required String subject,
    required String description,
  }) {
    return ClinicTicketsCreationHelper.createManualTicket(
      firestore: _firestore,
      clinicId: clinicId,
      clinicName: clinicName,
      patientName: patientName,
      patientPhone: patientPhone,
      patientEmail: patientEmail,
      tokenNumber: tokenNumber,
      category: category,
      priority: priority,
      subject: subject,
      description: description,
    );
  }
}
