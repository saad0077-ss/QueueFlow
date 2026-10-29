import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/services/current_clinic_resolver.dart';
import '../../domain/entities/clinic_doctor_entity.dart';
import '../../domain/entities/clinic_service_entity.dart';
import '../../domain/entities/service_department_entity.dart';
import '../../domain/entities/service_plan_entity.dart';
import '../../domain/repositories/clinic_services_repository.dart';
import '../models/clinic_service_model.dart';
import '../models/service_department_model.dart';

class ClinicServicesRepositoryImpl implements ClinicServicesRepository {
  static const _months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  Future<DocumentSnapshot<Map<String, dynamic>>>? _clinicFuture;

  ClinicServicesRepositoryImpl({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _auth = auth ?? FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> get _servicesRef =>
      _firestore.collection('services');

  /// The clinic managed by the signed-in admin, looked up once per repository.
  Future<DocumentSnapshot<Map<String, dynamic>>> _clinicDoc() =>
      _clinicFuture ??= CurrentClinicResolver.require(
        auth: _auth,
        firestore: _firestore,
      ).catchError((Object e) {
        // Allow a retry instead of caching the failure.
        _clinicFuture = null;
        throw e;
      });

  Future<String> _clinicId() async => (await _clinicDoc()).id;

  @override
  Stream<List<ClinicServiceEntity>> watchServices() {
    return Stream.fromFuture(_clinicId()).asyncExpand(
      (clinicId) => _servicesRef
          .where('clinicId', isEqualTo: clinicId)
          .snapshots()
          .map(
            (snap) => snap.docs
                .map((doc) => ClinicServiceModel.fromFirestore(doc))
                .toList(),
          ), 
    );
  }

  @override
  Future<List<ServiceDepartmentEntity>> getDepartments() async {
    final clinic = await _clinicDoc();
    final clinicId = clinic.id;
    final slug = _slug(clinic.data()?['name'] as String? ?? '');

    final snap = await _firestore.collection('departments').get();
    return snap.docs
        .where((doc) {
          final data = doc.data();
          final status = (data['status'] ?? 'active').toString().toLowerCase();
          if (status != 'active') return false;
          final assigned = (data['assignedClinics'] as List<dynamic>? ?? [])
              .map((e) => e.toString());
          // Same matching as the platform admin: Firestore id, or the
          // legacy name slug used in seed data (e.g. `sunrise-health`).
          return assigned.any(
            (k) =>
                k == clinicId ||
                (k.isNotEmpty && slug.isNotEmpty && slug.startsWith(k)),
          );
        })
        .map(ServiceDepartmentModel.fromFirestore)
        .toList()
      ..sort((a, b) => a.name.compareTo(b.name));
  }       
  
  @override
  Future<ServicePlanEntity> getServicePlan() async {
    final data = (await _clinicDoc()).data() ?? const <String, dynamic>{};
    final clinicName = data['name'] as String? ?? '';  

    // Derived from planId because the platform admin only updates planId
    // when a subscription changes.
    switch (data['planId'] as String? ?? 'solo') {  
      case 'enterprise':  
        return ServicePlanEntity(
          planName: 'Unlimited Doctors Plan',
          planPill: 'UNLIMITED DOCTORS PLAN',
          clinicName: clinicName,
        );
      case 'multi': 
        return ServicePlanEntity(
          planName: 'Multi-Doctor Clinic Plan',
          planPill: 'MULTI-DOCTOR PRACTICE',
          clinicName: clinicName,
        );
      default:
        return ServicePlanEntity(
          planName: 'Solo Doctor Plan',
          planPill: 'SOLO DOCTOR PRACTICE',
          clinicName: clinicName,
        );
    }
  }

  @override
  Future<List<ClinicDoctorEntity>> getDoctors() async {
    final data = (await _clinicDoc()).data() ?? const <String, dynamic>{};
    final doctors = (data['doctors'] as List<dynamic>? ?? [])
        .whereType<Map<String, dynamic>>()
        .map(
          (m) => ClinicDoctorEntity(
            name: m['name'] as String? ?? 'Dr. Specialist',
            specialty: m['specialty'] as String? ?? 'General Medicine',
            room: m['room'] as String? ?? 'Consultation Suite',
          ),
        )
        .toList();
    if (doctors.isNotEmpty) return doctors;

    final admin = (data['adminName'] as String?)?.trim();
    return [
      ClinicDoctorEntity(
        name: (admin != null && admin.isNotEmpty) ? admin : 'Dr. Priya',
      ),
    ];
  }

  @override
  Future<void> saveService(ClinicServiceEntity service) async {
    final clinic = await _clinicDoc();
    final clinicId = clinic.id;
    final docId = service.id.isEmpty
        ? 'svc-${DateTime.now().millisecondsSinceEpoch}'
        : service.id;
    final model = ClinicServiceModel(
      id: docId,
      clinicId: clinicId,
      name: service.name,
      description: service.description,
      duration: service.duration,
      price: service.price,
      assignedStaff: service.assignedStaff,
      status: service.status,
      departmentId: service.departmentId,
      departmentName: service.departmentName,
      justification: service.justification,
    );

    await _servicesRef.doc(docId).set(model.toMap(), SetOptions(merge: true));
    if (service.isPending) {
      // Shape matches what the platform admin's approval queue reads.
      final now = DateTime.now();
      await _firestore.collection('service_requests').doc(docId).set({
        'serviceId': docId,
        'clinicId': clinicId,
        'clinicName':
            clinic.data()?['name'] as String? ?? '',
        'departmentId': service.departmentId,
        'departmentName': service.departmentName,
        'serviceName': service.name,
        'duration': service.duration,
        'suggestedPrice': service.price,
        'description': service.description,
        'requestedBy': service.assignedStaff.isNotEmpty
            ? service.assignedStaff.first
            : 'Clinic Administrator',
        'notes': service.justification,
        'status': 'pending',
        'createdAt': '${now.day} ${_months[now.month - 1]} ${now.year}',
      }, SetOptions(merge: true));
    }
  }

  @override
  Future<void> toggleServiceStatus(
    String serviceId,
    String currentStatus,
  ) async {
    final newStatus = currentStatus == 'active' ? 'inactive' : 'active';
    await _servicesRef.doc(serviceId).update({
      'status': newStatus,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> deleteService(String serviceId) async {
    await _servicesRef.doc(serviceId).delete();
  }

  static String _slug(String name) =>
      name.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '-');
}
