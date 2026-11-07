import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:patient_app/core/utils/booking_date_formatter.dart';
import 'package:patient_app/features/clinic_details/data/models/clinic_doctor_model.dart';
import 'package:patient_app/features/clinic_details/data/models/clinic_service_model.dart';
import 'package:patient_app/features/clinic_details/domain/entities/clinic_doctor_item.dart';
import 'package:patient_app/features/clinic_details/domain/entities/clinic_service_item.dart';
import 'package:patient_app/features/booking/domain/entities/appointment_entity.dart';
import 'package:patient_app/features/booking/domain/repositories/booking_repository.dart';
import 'package:patient_app/features/booking/data/models/appointment_model.dart';

class BookingRepositoryImpl implements BookingRepository {
  final FirebaseFirestore? _firestore;
  final FirebaseAuth? _auth;

  // Session cache, only used when Firebase is unavailable.
  static final List<AppointmentEntity> _localCache = [];

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
    return const [];
  }

  @override
  Future<List<ClinicDoctorItem>> getClinicDoctors(String clinicId, String category) async {
    if (_firestore != null) {
      try {
        return await ClinicDoctorModel.fetchForClinic(_firestore, clinicId);
      } catch (e) {
        debugPrint('Error fetching doctors from Firestore: $e');
      }
    }
    return const [];
  }

  @override
  Future<List<String>> getAvailableTimeSlots({
    required String clinicId,
    required String doctorId,
    required DateTime date,
  }) async {
    return const [];
  }

  static String _normSlot(String s) => s.trim().toUpperCase();

  @override
  Future<Set<String>> getBookedSlots({
    required String clinicId,
    required String doctorId,
    required DateTime date,
  }) async {
    final dateRaw = BookingDateFormatter.formatRawDate(date);
    final booked = <String>{};

    for (final a in _localCache) {
      if (a.doctorId == doctorId && a.dateRaw == dateRaw && a.status.toLowerCase() != 'cancelled') {
        booked.add(_normSlot(a.timeRaw));
      }
    }

    if (_firestore != null) {
      try {
        final snap = await _firestore
            .collection('appointments')
            .where('doctorId', isEqualTo: doctorId)
            .where('dateRaw', isEqualTo: dateRaw)
            .get();
        for (final d in snap.docs) {
          final m = d.data();
          final status = (m['status'] ?? '').toString().toLowerCase();
          if (status == 'cancelled' || status == 'canceled') continue;
          final t = (m['timeRaw'] ?? '').toString();
          if (t.isNotEmpty) booked.add(_normSlot(t));
        }
      } catch (e) {
        debugPrint('Error fetching booked slots: $e');
      }
    }
    return booked;
  }

  /// The patient's profile photo (base64), shown to the clinic on the booking.
  Future<String> _customerPhoto(String customerId) async {
    final fs = _firestore;
    final uid = customerId.isNotEmpty ? customerId : (_auth?.currentUser?.uid ?? '');
    if (fs == null || uid.isEmpty) return '';
    try {
      final doc = await fs.collection('users').doc(uid).get();
      return (doc.data()?['photoBase64'] ?? '').toString();
    } catch (_) {
      return '';
    }
  }

  @override
  Future<AppointmentEntity> createAppointment(AppointmentEntity appointment) async {
    // Block double booking: the slot may have been taken since it was shown.
    final taken = await getBookedSlots(
      clinicId: appointment.clinicId,
      doctorId: appointment.doctorId,
      date: DateTime.tryParse(appointment.dateRaw) ?? DateTime.now(),
    );
    if (taken.contains(_normSlot(appointment.timeRaw))) {
      throw Exception('This time slot was just booked by someone else. Please choose another slot.');
    }

    // Generate bookingRef if missing
    String ref = appointment.bookingRef;
    if (ref.isEmpty || ref == 'QF-00000') {
      final randNum = 10000 + Random().nextInt(90000);
      ref = 'QF-$randNum';
    }

    final newAppointment = appointment.copyWith(bookingRef: ref);

    if (_firestore != null) {
      try {
        final photo = await _customerPhoto(newAppointment.customerId);
        final docRef = await _firestore.collection('appointments').add({
              ...AppointmentModel(
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
              if (photo.isNotEmpty) 'customerPhoto': photo,
            });

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
        final list = snap.docs.map(AppointmentModel.fromFirestore).toList();
        list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        return list;
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
          final list = snap.docs.map(AppointmentModel.fromFirestore).toList();
          list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return list;
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
