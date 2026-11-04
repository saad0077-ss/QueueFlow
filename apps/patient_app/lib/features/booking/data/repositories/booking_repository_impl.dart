import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:patient_app/core/utils/booking_date_formatter.dart';
import 'package:patient_app/features/clinic_details/data/models/clinic_doctor_model.dart';
import 'package:patient_app/features/clinic_details/data/models/clinic_fallback_data.dart';
import 'package:patient_app/features/clinic_details/data/models/clinic_service_model.dart';
import 'package:patient_app/features/clinic_details/domain/entities/clinic_doctor_item.dart';
import 'package:patient_app/features/clinic_details/domain/entities/clinic_service_item.dart';
import 'package:patient_app/features/booking/domain/entities/appointment_entity.dart';
import 'package:patient_app/features/booking/domain/entities/payment_info_entity.dart';
import 'package:patient_app/features/booking/domain/repositories/booking_repository.dart';
import 'package:patient_app/features/booking/data/models/appointment_model.dart';

class BookingRepositoryImpl implements BookingRepository {
  final FirebaseFirestore? _firestore;
  final FirebaseAuth? _auth;

  // In-memory appointments fallback & cache (session-persistent across views)
  static final List<AppointmentEntity> _localCache = [
    AppointmentEntity(
      id: 'apt-seed-1',
      bookingRef: 'QF-48210',
      clinicId: 'smile-dental',
      clinicName: 'Smile Dental Clinic',
      clinicAddress: '14 MG Road, Kochi',
      customerId: 'user-001',
      customerName: 'Aisha Rahman',
      customerPhone: '+91 98765 43210',
      customerEmail: 'aisha@example.com',
      doctorId: 'd-1',
      doctorName: 'Dr. Rahul Menon',
      doctorSpecialty: 'Orthodontics',
      serviceId: 's-2',
      serviceName: 'Teeth Cleaning & Polishing',
      serviceDuration: 30,
      servicePrice: 900,
      dateRaw: BookingDateFormatter.formatRawDate(DateTime.now().add(const Duration(days: 2))),
      timeRaw: '11:00 AM',
      dateTime: BookingDateFormatter.formatDateTime(
        DateTime.now().add(const Duration(days: 2)),
        '11:00 AM',
      ),
      status: 'confirmed',
      payment: const PaymentInfoEntity(
        paymentId: 'pay_test_seeded12345',
        amount: 900,
        method: 'UPI (GPay)',
        paidAt: '10:30 AM',
      ),
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];

  final StreamController<List<AppointmentEntity>> _streamController =
      StreamController<List<AppointmentEntity>>.broadcast();

  BookingRepositoryImpl({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? _safeFirestore(),
        _auth = auth ?? _safeAuth();

  static FirebaseFirestore? _safeFirestore() {
    try {
      if (Firebase.apps.isNotEmpty) return FirebaseFirestore.instance;
    } catch (_) {}
    return null;
  }

  static FirebaseAuth? _safeAuth() {
    try {
      if (Firebase.apps.isNotEmpty) return FirebaseAuth.instance;
    } catch (_) {}
    return null;
  }

  @override
  Future<List<ClinicServiceItem>> getClinicServices(String clinicId, String category) async {
    if (_firestore != null) {
      try {
        final snap = await _firestore
            .collection('services')
            .where('clinicId', isEqualTo: clinicId)
            .get();
        if (snap.docs.isNotEmpty) {
          return snap.docs.map(ClinicServiceModel.fromFirestore).toList();
        }
      } catch (e) {
        debugPrint('Error fetching services from Firestore: $e');
      }
    }
    return ClinicFallbackData.getServices(category);
  }

  @override
  Future<List<ClinicDoctorItem>> getClinicDoctors(String clinicId, String category) async {
    if (_firestore != null) {
      try {
        final snap = await _firestore
            .collection('staff')
            .where('clinicId', isEqualTo: clinicId)
            .get();
        if (snap.docs.isNotEmpty) {
          return snap.docs.map(ClinicDoctorModel.fromFirestore).toList();
        }
      } catch (e) {
        debugPrint('Error fetching staff/doctors from Firestore: $e');
      }
    }
    return ClinicFallbackData.getDoctors(category);
  }

  @override
  Future<List<String>> getAvailableTimeSlots({
    required String clinicId,
    required String doctorId,
    required DateTime date,
  }) async {
    return const [
      '09:30 AM',
      '10:30 AM',
      '11:00 AM',
      '02:15 PM',
      '03:30 PM',
      '04:45 PM',
      '06:00 PM',
    ];
  }

  @override
  Future<AppointmentEntity> createAppointment(AppointmentEntity appointment) async {
    // Generate bookingRef if missing
    String ref = appointment.bookingRef;
    if (ref.isEmpty || ref == 'QF-00000') {
      final randNum = 10000 + Random().nextInt(90000);
      ref = 'QF-$randNum';
    }

    final newAppointment = appointment.copyWith(bookingRef: ref);

    if (_firestore != null) {
      try {
        final docRef = await _firestore.collection('appointments').add(
              AppointmentModel(
                id: newAppointment.id,
                bookingRef: newAppointment.bookingRef,
                clinicId: newAppointment.clinicId,
                clinicName: newAppointment.clinicName,
                clinicAddress: newAppointment.clinicAddress,
                customerId: newAppointment.customerId,
                customerName: newAppointment.customerName,
                customerPhone: newAppointment.customerPhone,
                customerEmail: newAppointment.customerEmail,
                doctorId: newAppointment.doctorId,
                doctorName: newAppointment.doctorName,
                doctorSpecialty: newAppointment.doctorSpecialty,
                serviceId: newAppointment.serviceId,
                serviceName: newAppointment.serviceName,
                serviceDuration: newAppointment.serviceDuration,
                servicePrice: newAppointment.servicePrice,
                dateRaw: newAppointment.dateRaw,
                timeRaw: newAppointment.timeRaw,
                dateTime: newAppointment.dateTime,
                status: newAppointment.status,
                payment: newAppointment.payment,
                notes: newAppointment.notes,
                createdAt: newAppointment.createdAt,
              ).toMap(),
            );

        try {
          await _firestore.collection('notifications').add({
            'title': 'Booking Confirmed',
            'desc':
                'Your appointment for ${newAppointment.serviceName} at ${newAppointment.clinicName} on ${newAppointment.dateTime} is confirmed. Ref: ${newAppointment.bookingRef}',
            'userId': newAppointment.customerId,
            'userEmail': newAppointment.customerEmail,
            'clinicId': newAppointment.clinicId,
            'bookingRef': newAppointment.bookingRef,
            'createdAt': FieldValue.serverTimestamp(),
            'unread': true,
          });
        } catch (_) {}

        final saved = newAppointment.copyWith(id: docRef.id);
        _localCache.insert(0, saved);
        _streamController.add(List.unmodifiable(_localCache));
        return saved;
      } catch (e) {
        debugPrint('Firestore write failed, saving to local session cache: $e');
      }
    }

    _localCache.insert(0, newAppointment);
    _streamController.add(List.unmodifiable(_localCache));
    return newAppointment;
  }

  @override
  Future<List<AppointmentEntity>> getUserAppointments({
    String? customerId,
    String? customerEmail,
  }) async {
    final user = _auth?.currentUser;
    final email = customerEmail ?? user?.email;
    final uid = customerId ?? user?.uid;

    if (_firestore != null) {
      try {
        Query<Map<String, dynamic>> query = _firestore.collection('appointments');
        if (email != null && email.isNotEmpty) {
          query = query.where('customerEmail', isEqualTo: email.trim().toLowerCase());
        } else if (uid != null && uid.isNotEmpty) {
          query = query.where('customerId', isEqualTo: uid);
        }

        final snap = await query.get();
        if (snap.docs.isNotEmpty) {
          final list = snap.docs.map(AppointmentModel.fromFirestore).toList();
          list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return list;
        }
      } catch (e) {
        debugPrint('Error fetching user appointments from Firestore: $e');
      }
    }

    return List.unmodifiable(_localCache);
  }

  @override
  Stream<List<AppointmentEntity>> watchUserAppointments({
    String? customerId,
    String? customerEmail,
  }) {
    final user = _auth?.currentUser;
    final email = customerEmail ?? user?.email;
    final uid = customerId ?? user?.uid;

    if (_firestore != null) {
      try {
        Query<Map<String, dynamic>> query = _firestore.collection('appointments');
        if (email != null && email.isNotEmpty) {
          query = query.where('customerEmail', isEqualTo: email.trim().toLowerCase());
        } else if (uid != null && uid.isNotEmpty) {
          query = query.where('customerId', isEqualTo: uid);
        }

        return query.snapshots().map((snap) {
          if (snap.docs.isNotEmpty) {
            final list = snap.docs.map(AppointmentModel.fromFirestore).toList();
            list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
            return list;
          }
          return List.unmodifiable(_localCache);
        });
      } catch (_) {}
    }

    return _streamController.stream;
  }

  @override
  Future<void> cancelAppointment(String appointmentId) async {
    if (_firestore != null) {
      try {
        await _firestore.collection('appointments').doc(appointmentId).update({
          'status': 'cancelled',
          'cancelledAt': FieldValue.serverTimestamp(),
        });
      } catch (e) {
        debugPrint('Error cancelling appointment in Firestore: $e');
      }
    }

    final idx = _localCache.indexWhere(
      (a) => a.id == appointmentId || a.bookingRef == appointmentId,
    );
    if (idx != -1) {
      _localCache[idx] = _localCache[idx].copyWith(status: 'cancelled');
      _streamController.add(List.unmodifiable(_localCache));
    }
  }
}
