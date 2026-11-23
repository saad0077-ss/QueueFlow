import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/services/current_clinic_resolver.dart';
import '../../core/utils/clinic_tickets_filter_util.dart';
import '../models/clinic_support_ticket_model.dart';
import 'clinic_tickets_creation_helper.dart';
import 'clinic_tickets_mutation_helper.dart';
import 'clinic_tickets_remote_datasource.dart';

class ClinicTicketsRemoteDataSourceImpl
    implements ClinicTicketsRemoteDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  ClinicTicketsRemoteDataSourceImpl({FirebaseFirestore? firestore, FirebaseAuth? auth})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _auth = auth ?? FirebaseAuth.instance;

  @override
  Stream<List<ClinicSupportTicketModel>> watchTickets({
    required String clinicId,
    String? clinicName,
  }) {
    final clinicDocStream = clinicId.isNotEmpty
        ? Stream<DocumentSnapshot<Map<String, dynamic>>?>.value(null)
        : Stream.fromFuture(CurrentClinicResolver.resolve(auth: _auth, firestore: _firestore));

    return clinicDocStream.asyncExpand((cDoc) {
      final effId = clinicId.isNotEmpty ? clinicId : (cDoc?.id ?? '');
      final effName = (clinicName != null && clinicName.isNotEmpty)
          ? clinicName
          : (cDoc?.data()?['name']?.toString() ?? '');

      return _firestore.collection('support_tickets').snapshots().map((snap) {
        final list = <ClinicSupportTicketModel>[];
        for (final doc in snap.docs) {
          final data = doc.data();
          final docClinicId = (data['clinicId'] ?? '').toString();
          final docClinicName = (data['clinicName'] ?? '').toString();

          final isAppBug = ClinicTicketsFilterUtil.isAppRelatedBug(
            isClinicRelated: data['isClinicRelated'],
            clinicId: docClinicId,
            category: (data['category'] ?? '').toString(),
            subject: (data['subject'] ?? '').toString(),
            description: (data['description'] ?? '').toString(),
          );
          if (isAppBug) continue;

          final match = ClinicTicketsFilterUtil.matchesClinic(
            targetClinicId: effId,
            targetClinicName: effName,
            ticketClinicId: docClinicId,
            ticketClinicName: docClinicName,
          );
          if (!match) continue;

          try {
            list.add(ClinicSupportTicketModel.fromFirestore(doc));
          } catch (e) {
            debugPrint('Error parsing clinic ticket ${doc.id}: $e');
          }
        }

        list.sort((a, b) {
          final da = a.createdAtDate ?? DateTime(2000);
          final db = b.createdAtDate ?? DateTime(2000);
          return db.compareTo(da);
        });
        return list;
      });
    });
  }

  @override
  Future<void> sendReply({
    required String ticketId,
    required String text,
    required String staffName,
    bool isInternalNote = false,
  }) => ClinicTicketsMutationHelper.sendReply(
    firestore: _firestore,
    ticketId: ticketId,
    text: text,
    staffName: staffName,
    isInternalNote: isInternalNote,
  );

  @override
  Future<void> updateStatus({
    required String ticketId,
    required String status,
    String staffName = 'Clinic Admin',
  }) => ClinicTicketsMutationHelper.updateStatus(
    firestore: _firestore,
    ticketId: ticketId,
    status: status,
    staffName: staffName,
  );

  @override
  Future<void> updatePriority({
    required String ticketId,
    required String priority,
  }) => ClinicTicketsMutationHelper.updatePriority(
    firestore: _firestore,
    ticketId: ticketId,
    priority: priority,
  );

  @override
  Future<void> escalateTicket({
    required String ticketId,
    required String staffName,
  }) => ClinicTicketsMutationHelper.escalateTicket(
    firestore: _firestore,
    ticketId: ticketId,
    staffName: staffName,
  );

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
  }) => ClinicTicketsCreationHelper.createManualTicket(
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
