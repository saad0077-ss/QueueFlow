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
  Future<DocumentSnapshot<Map<String, dynamic>>> _clinicDoc() async {
    if (_clinicFuture != null) return _clinicFuture!;

    Future<DocumentSnapshot<Map<String, dynamic>>> resolver() async {
      try {
        final doc = await CurrentClinicResolver.resolve(
          auth: _auth,
          firestore: _firestore,
        );
        if (doc != null && doc.exists) return doc;
      } catch (_) {}

      try {
        final activeQuery = await _firestore
            .collection('clinics')
            .where('status', isEqualTo: 'ACTIVE')
            .limit(1)
            .get();
        if (activeQuery.docs.isNotEmpty) {
          return activeQuery.docs.first;
        }

        final docDirect = await _firestore
            .collection('clinics')
            .doc('sunrise-health')
            .get();
        if (docDirect.exists) return docDirect;
      } catch (_) {}

      return CurrentClinicResolver.require(auth: _auth, firestore: _firestore);
    }

    _clinicFuture = resolver().catchError((Object e) {
      _clinicFuture = null;
      throw e;
    });
    return _clinicFuture!;
  }

  Future<String> _clinicId() async => (await _clinicDoc()).id;

  /// Id of the clinic managed by the signed-in admin.
  Future<String> currentClinicId() => _clinicId();

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
  Stream<List<ServiceDepartmentEntity>> watchDepartments() {
    return _firestore
        .collection('departments')
        .snapshots()
        .asyncMap((_) => getDepartments());
  }

  @override
  Future<List<ServiceDepartmentEntity>> getDepartments() async {
    final clinic = await _clinicDoc();
    final clinicId = clinic.id;
    final clinicData = clinic.data() ?? const <String, dynamic>{};
    final clinicName = (clinicData['name'] as String? ?? '').trim();
    final slug = _slug(clinicName);

    // 1. Direct assigned departments in clinic document if present
    final clinicDeptIds = <String>{};
    if (clinicData['departmentIds'] is List) {
      for (final item in (clinicData['departmentIds'] as List)) {
        if (item != null && item.toString().trim().isNotEmpty) {
          clinicDeptIds.add(item.toString().trim());
        }
      }
    }

    final clinicDeptNames = <String>{};
    if (clinicData['departments'] is List) {
      for (final item in (clinicData['departments'] as List)) {
        if (item is String && item.trim().isNotEmpty) {
          clinicDeptNames.add(item.trim().toLowerCase());
        } else if (item is Map && item['name'] is String) {
          clinicDeptNames.add((item['name'] as String).trim().toLowerCase());
        }
      }
    }
    if (clinicData['department'] is String &&
        (clinicData['department'] as String).trim().isNotEmpty) {
      clinicDeptNames.add(
        (clinicData['department'] as String).trim().toLowerCase(),
      );
    }

    // 2. Active services configured for this clinic
    final serviceDeptIds = <String>{};
    final serviceDeptNames = <String>{};
    final List<ClinicServiceEntity> clinicServices = [];
    try {
      final svcsSnap = await _firestore
          .collection('services')
          .where('clinicId', isEqualTo: clinicId)
          .get();
      for (final doc in svcsSnap.docs) {
        final s = ClinicServiceModel.fromFirestore(doc);
        clinicServices.add(s);
        final sId = s.departmentId.trim();
        final sName = s.departmentName.trim().toLowerCase();
        if (sId.isNotEmpty) serviceDeptIds.add(sId);
        if (sName.isNotEmpty) serviceDeptNames.add(sName);
      }
    } catch (_) {}

    final List<ServiceDepartmentEntity> result = [];

    // 3. Fetch master departments collection
    try {
      final snap = await _firestore.collection('departments').get();
      for (final doc in snap.docs) {
        final data = doc.data();
        final status = (data['status'] ?? 'active').toString().toLowerCase();
        if (status == 'inactive') continue;

        final docId = doc.id.trim();
        final deptName = (data['name'] ?? '').toString().trim();
        final deptNameLower = deptName.toLowerCase();

        final assignedClinics =
            (data['assignedClinics'] as List<dynamic>? ?? [])
                .map((e) => e.toString().trim().toLowerCase())
                .toList();

        final isExplicitlyAssigned = assignedClinics.any(
          (k) =>
              k == clinicId.toLowerCase() ||
              k == 'all' ||
              (slug.isNotEmpty &&
                  (slug == k || slug.startsWith(k) || k.startsWith(slug))) ||
              (clinicName.isNotEmpty && k == clinicName.toLowerCase()),
        );

        final isLinkedToClinic =
            clinicDeptIds.contains(docId) ||
            clinicDeptNames.contains(deptNameLower);

        final hasServiceForClinic =
            serviceDeptIds.contains(docId) ||
            serviceDeptNames.contains(deptNameLower);

        // Global platform department (assignedClinics is empty, meaning available across platform)
        final isGlobalDepartment = assignedClinics.isEmpty;

        if (isExplicitlyAssigned ||
            isLinkedToClinic ||
            hasServiceForClinic ||
            isGlobalDepartment) {
          result.add(ServiceDepartmentModel.fromFirestore(doc));
        }
      }
    } catch (_) {}

    // 4. Synthesize any service department defined in clinic services not in master departments
    for (final s in clinicServices) {
      final sDeptName = s.departmentName.trim();
      final sDeptId = s.departmentId.trim();
      if (sDeptName.isNotEmpty &&
          !result.any(
            (d) =>
                (sDeptId.isNotEmpty && d.id == sDeptId) ||
                d.name.trim().toLowerCase() == sDeptName.toLowerCase(),
          )) {
        result.add(
          ServiceDepartmentEntity(
            id: sDeptId.isNotEmpty ? sDeptId : 'dept-${_slug(sDeptName)}',
            code: _departmentCodeFor(sDeptName),
            name: sDeptName,
            icon: _departmentIconFor(sDeptName),
          ),
        );
      }
    }

    // 5. Strictly deduplicate by normalized name
    final Map<String, ServiceDepartmentEntity> uniqueByName = {};
    for (final dept in result) {
      final key = dept.name.trim().toLowerCase();
      if (!uniqueByName.containsKey(key)) {
        uniqueByName[key] = dept;
      }
    }

    final deduped = uniqueByName.values.toList()
      ..sort((a, b) => a.name.compareTo(b.name));
    return deduped;
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
    final clinicId = await _clinicId();
    final snap = await _firestore.collection('clinics').doc(clinicId).get();
    final data = snap.data() ?? const <String, dynamic>{};
    final rawDocs = data['doctors'] as List<dynamic>? ?? [];
    return rawDocs
        .whereType<Map<String, dynamic>>()
        .map(
          (m) => ClinicDoctorEntity(
            name: (m['name'] as String? ?? '').trim(),
            specialty: (m['specialty'] as String? ?? '').trim(),
            department:
                (m['department'] as String? ?? m['specialty'] as String? ?? '')
                    .trim(),
            room: (m['room'] as String? ?? 'Consultation Suite').trim(),
          ),
        )
        .where((d) => d.name.isNotEmpty)
        .toList();
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
        'clinicName': clinic.data()?['name'] as String? ?? '',
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

  static String _departmentCodeFor(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('general') || lower.contains('medicine')) return 'GM';
    if (lower.contains('dental') || lower.contains('oral')) return 'DENT';
    if (lower.contains('pediatric') || lower.contains('child')) return 'PED';
    if (lower.contains('derma') || lower.contains('skin')) return 'DERM';
    if (lower.contains('cardio') || lower.contains('heart')) return 'CARD';
    if (lower.contains('ortho') || lower.contains('bone')) return 'ORTHO';
    if (lower.contains('ent') || lower.contains('throat')) return 'ENT';
    if (lower.contains('eye') || lower.contains('ophthal')) return 'EYE';
    final words = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .toList();
    if (words.length >= 2) {
      return (words[0][0] + words[1][0]).toUpperCase();
    }
    return name.substring(0, name.length >= 3 ? 3 : name.length).toUpperCase();
  }

  static String _departmentIconFor(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('dental') || lower.contains('teeth')) return '🦷';
    if (lower.contains('pediatric') || lower.contains('child')) return '👶';
    if (lower.contains('derma') || lower.contains('skin')) return '🔬';
    if (lower.contains('cardio') || lower.contains('heart')) return '❤️';
    if (lower.contains('ortho') || lower.contains('bone')) return '🦴';
    if (lower.contains('eye') || lower.contains('ophthal')) return '👁️';
    if (lower.contains('ent') || lower.contains('ear')) return '👂';
    return '🩺';
  }
}
