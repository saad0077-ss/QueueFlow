import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/active_ticket_entity.dart';
import '../../domain/entities/clinic_entity.dart';
import '../../domain/repositories/home_repository.dart';
import '../models/active_ticket_model.dart';
import '../models/clinic_model.dart';

class HomeRepositoryImpl implements HomeRepository {
  final FirebaseFirestore _firestore;

  // In-memory active ticket cache for real-time responsiveness
  ActiveTicketModel? _cachedTicket = const ActiveTicketModel(
    id: 'q-024',
    token: 'A-024',
    clinicId: 'smile-dental',
    clinicName: 'Smile Dental Clinic',
    serviceName: 'Teeth Cleaning',
    doctorName: 'Dr. Rahul Menon',
    position: 3,
    estWaitMin: 15,
    nowServing: 'A-021',
    status: 'waiting',
  );

  HomeRepositoryImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<List<ClinicEntity>> getFeaturedClinics() async {
    // Return verified dummy clinics for now as requested
    return ClinicModel.mockClinics;
  }

  @override
  Future<ActiveTicketEntity?> getActiveTicket() async {
    return _cachedTicket;
  }

  @override
  Future<ActiveTicketEntity> joinQueue({
    required String clinicId,
    required String clinicName,
    required String patientName,
    required int currentWaitingCount,
    required String currentToken,
  }) async {
    final nextNum = currentWaitingCount + 1;
    final tokenStr = 'A-${nextNum.toString().padLeft(3, '0')}';

    final ticket = ActiveTicketModel(
      id: 'q-${DateTime.now().millisecondsSinceEpoch}',
      token: tokenStr,
      clinicId: clinicId,
      clinicName: clinicName,
      serviceName: 'Consultation',
      doctorName: 'Attending Doctor',
      position: currentWaitingCount,
      estWaitMin: currentWaitingCount * 5,
      nowServing: currentToken,
      status: 'waiting',
      joinedAt: DateTime.now(),
    );

    _cachedTicket = ticket;

    try {
      await _firestore.collection('tickets').add(ticket.toMap());
    } catch (_) {}

    return ticket;
  }

  @override
  Future<void> cancelTicket(String ticketId) async {
    _cachedTicket = null;
    try {
      await _firestore.collection('tickets').doc(ticketId).update({'status': 'cancelled'});
    } catch (_) {}
  }
}
