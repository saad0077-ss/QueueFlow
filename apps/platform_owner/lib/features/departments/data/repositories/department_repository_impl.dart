import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../../domain/entities/department_entity.dart';
import '../../domain/entities/dept_expansion_request_entity.dart';
import '../../domain/entities/dept_service_request_entity.dart';
import '../../domain/entities/standard_service_entity.dart';
import '../../domain/repositories/department_repository.dart';
import '../models/department_mapper.dart';
import '../models/department_model.dart';
import '../models/dept_expansion_request_model.dart';
import '../models/dept_service_request_model.dart';
import '../models/sample_departments_seed.dart';
import '../models/sample_requests_seed.dart';

class DepartmentRepositoryImpl implements DepartmentRepository {
  final FirebaseFirestore _firestore;

  DepartmentRepositoryImpl({FirebaseFirestore? firestore}) : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Stream<List<DepartmentEntity>> watchDepartments() {
    // Re-emits whenever departments, clinics or tickets change, so the counts stay live
    late final StreamController<List<DepartmentEntity>> controller;
    final subs = <StreamSubscription>[];
    List<DepartmentEntity>? departments;
    List<Map<String, dynamic>>? clinics;
    List<Map<String, dynamic>> tickets = const [];

    void emit() {
      if (departments == null || clinics == null) return;
      controller.add(_withLiveStats(departments!, clinics!, tickets));
    }

    controller = StreamController<List<DepartmentEntity>>(
      onListen: () {
        subs.add(_firestore.collection('departments').snapshots().listen((s) {
          departments = s.docs.map((d) => DepartmentModel.fromFirestore(d)).toList();
          emit();
        }, onError: controller.addError));
        subs.add(_firestore.collection('clinics').snapshots().listen((s) {
          clinics = s.docs.map((d) => {...d.data(), 'id': d.id}).toList();
          emit();
        }, onError: controller.addError));
        subs.add(_firestore.collection('tickets').snapshots().listen((s) {
          tickets = s.docs.map((d) => d.data()).toList();
          emit();
        }, onError: (_) {}));
      },
      onCancel: () async {
        for (final sub in subs) {
          await sub.cancel();
        }
      },
    );
    return controller.stream;
  }

  /// Replaces stored doctor/visit/clinic counts with values derived from real clinics and tickets
  static List<DepartmentEntity> _withLiveStats(List<DepartmentEntity> departments, List<Map<String, dynamic>> clinics, List<Map<String, dynamic>> tickets) {
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month);
    final monthTickets = tickets.where((t) {
      final raw = t['joinedAt'];
      // A pending serverTimestamp reads as null, which means "just now"
      final joinedAt = raw is Timestamp ? raw.toDate() : (raw is String ? DateTime.tryParse(raw) : now);
      return joinedAt != null && !joinedAt.isBefore(monthStart);
    }).toList();

    List<String> deptIdsOf(Map<String, dynamic> c) => ((c['departmentIds'] as List<dynamic>?) ?? []).map((e) => e.toString()).toList();

    return departments.map((d) {
      final linked = clinics.where((c) => deptIdsOf(c).contains(d.id) || d.assignedClinics.contains(c['id'])).toList();
      final name = d.name.toLowerCase();
      final code = d.code.toLowerCase();
      final serviceNames = d.standardServices.map((s) => s.name.toLowerCase().trim()).toSet();

      var doctors = 0;
      var visits = 0;
      for (final c in linked) {
        // A single-department clinic's whole roster and queue belong to that department
        final soleDept = deptIdsOf(c).length <= 1;
        final roster = ((c['doctors'] as List<dynamic>?) ?? []).whereType<Map<String, dynamic>>();
        doctors += roster.where((doc) {
          if (soleDept) return true;
          final spec = (doc['specialty'] ?? '').toString().toLowerCase();
          return spec.isNotEmpty && (spec.contains(name) || name.contains(spec) || spec == code);
        }).length;
        visits += monthTickets.where((t) {
          if (t['clinicId'] != c['id']) return false;
          return soleDept || serviceNames.contains((t['serviceName'] ?? '').toString().toLowerCase().trim());
        }).length;
      }

      return d.copyWith(doctorCount: doctors, totalVisits: visits, assignedClinics: linked.map((c) => c['id'] as String).toList());
    }).toList();
  }

  @override
  Stream<List<DeptExpansionRequestEntity>> watchExpansionRequests() {
    return _firestore.collection('department_requests').snapshots().map((s) => s.docs.map((d) => DeptExpansionRequestModel.fromFirestore(d)).toList());
  }

  @override
  Stream<List<DeptServiceRequestEntity>> watchServiceRequests() {
    return _firestore.collection('service_requests').snapshots().map((s) => s.docs.map((d) => DeptServiceRequestModel.fromFirestore(d)).toList());
  }

  @override
  Future<void> seedDepartmentsIfEmpty() async {
    final snap = await _firestore.collection('departments').limit(1).get();
    if (snap.docs.isEmpty) {
      // Starter catalog only; counts and clinic links come from live data
      for (final d in sampleDepartmentsSeed) {
        await _firestore.collection('departments').add({...d, 'doctorCount': 0, 'totalVisits': 0, 'assignedClinics': <String>[]});
      }
    }
  }

  @override
  Future<void> purgeSampleRequests() async {
    final sampleClinics = {
      for (final r in [...sampleExpansionRequestsSeed, ...sampleServiceRequestsSeed]) r['clinicName'],
    };
    try {
      for (final col in ['department_requests', 'service_requests']) {
        final snap = await _firestore.collection(col).get();
        for (final doc in snap.docs) {
          if (sampleClinics.contains(doc.data()['clinicName'])) await doc.reference.delete();
        }
      }
    } catch (e) {
      debugPrint('Error purging sample department requests: $e');
    }
  }

  @override
  Future<void> addDepartment(DepartmentEntity department) async {
    await _firestore.collection('departments').add(department.toFirestoreMap());
  }

  @override
  Future<void> updateDepartment(DepartmentEntity department) async {
    await _firestore.collection('departments').doc(department.id).update(department.toFirestoreMap());
  }

  @override
  Future<void> toggleDepartmentStatus(String id, bool currentStatus) async {
    final next = currentStatus ? 'inactive' : 'active';
    await _firestore.collection('departments').doc(id).update({'status': next});
  }

  @override
  Future<void> deleteDepartment(String id) async {
    await _firestore.collection('departments').doc(id).delete();
  }

  @override
  Future<void> addStandardService(String departmentId, StandardServiceEntity service) async {
    await _firestore.collection('departments').doc(departmentId).update({
      'standardServices': FieldValue.arrayUnion([service.toServiceMap()]),
    });
  }

  @override
  Future<void> updateStandardService(String departmentId, StandardServiceEntity service) async {
    final doc = await _firestore.collection('departments').doc(departmentId).get();
    final d = DepartmentModel.fromFirestore(doc);
    final updated = d.standardServices.map((s) => s.id == service.id ? service : s).toList();
    await _firestore.collection('departments').doc(departmentId).update({'standardServices': updated.map((s) => s.toServiceMap()).toList()});
  }

  @override
  Future<void> removeStandardService(String departmentId, String serviceId) async {
    final doc = await _firestore.collection('departments').doc(departmentId).get();
    final d = DepartmentModel.fromFirestore(doc);
    final updated = d.standardServices.where((s) => s.id != serviceId).toList();
    await _firestore.collection('departments').doc(departmentId).update({'standardServices': updated.map((s) => s.toServiceMap()).toList()});
  }

  @override
  Future<void> approveExpansionRequest(String reqId) async {
    final reqDoc = await _firestore.collection('department_requests').doc(reqId).get();
    if (!reqDoc.exists) return;

    final data = reqDoc.data()!;
    final clinicId = (data['clinicId'] as String?)?.trim() ?? '';
    final deptIds = (data['departmentIds'] as List<dynamic>? ?? []).map((e) => e.toString()).toList();
    final deptNames = (data['departmentNames'] as List<dynamic>? ?? []).map((e) => e.toString()).toList();

    await reqDoc.reference.update({
      'status': 'approved',
      'reviewedAt': DateTime.now().toIso8601String(),
    });

    for (final deptId in deptIds) {
      try {
        final dDoc = await _firestore.collection('departments').doc(deptId).get();
        if (dDoc.exists) {
          await dDoc.reference.update({
            'assignedClinics': FieldValue.arrayUnion([clinicId]),
          });
        }
      } catch (_) {}
    }

    if (clinicId.isNotEmpty) {
      try {
        final clinicDoc = await _firestore.collection('clinics').doc(clinicId).get();
        if (clinicDoc.exists) {
          await clinicDoc.reference.update({
            'departmentIds': FieldValue.arrayUnion(deptIds),
            'departments': FieldValue.arrayUnion(deptNames),
          });
        }
      } catch (_) {}
    }
  }

  @override
  Future<void> rejectExpansionRequest(String reqId, String r) => _firestore.collection('department_requests').doc(reqId).update({
    'status': 'rejected',
    'rejectionReason': r,
    'reviewedAt': DateTime.now().toIso8601String(),
  });

  @override
  Future<void> approveServiceRequest(String reqId) async {
    final reqDoc = await _firestore.collection('service_requests').doc(reqId).get();
    if (!reqDoc.exists) return;

    final data = reqDoc.data()!;
    final serviceId = (data['serviceId'] as String?)?.trim() ?? reqId;
    final clinicId = (data['clinicId'] as String?)?.trim() ?? '';
    final deptId = (data['departmentId'] as String?)?.trim() ?? '';
    final deptName = (data['departmentName'] as String?)?.trim() ?? '';
    final serviceName = (data['serviceName'] as String?)?.trim() ?? '';
    final duration = (data['duration'] as num?)?.toInt() ?? 20;
    final suggestedPrice = (data['suggestedPrice'] as num?)?.toInt() ?? 500;
    final description = (data['description'] as String?)?.trim() ?? '';

    // 1. Mark the request as approved
    await reqDoc.reference.update({
      'status': 'approved',
      'reviewedAt': DateTime.now().toIso8601String(),
    });

    // 2. Find target department document
    DocumentReference<Map<String, dynamic>>? targetDeptRef;
    if (deptId.isNotEmpty) {
      final docSnap = await _firestore.collection('departments').doc(deptId).get();
      if (docSnap.exists) {
        targetDeptRef = docSnap.reference;
      }
    }

    if (targetDeptRef == null) {
      final allDepts = await _firestore.collection('departments').get();
      for (final doc in allDepts.docs) {
        final dData = doc.data();
        final name = (dData['name'] ?? '').toString().trim().toLowerCase();
        final code = (dData['code'] ?? '').toString().trim().toLowerCase();
        final id = doc.id.toLowerCase();
        if ((deptName.isNotEmpty && name == deptName.toLowerCase()) ||
            (deptId.isNotEmpty && (code == deptId.toLowerCase() || id == deptId.toLowerCase()))) {
          targetDeptRef = doc.reference;
          break;
        }
      }
    }

    // 3. Add to department standardServices
    if (targetDeptRef != null && serviceName.isNotEmpty) {
      final deptSnap = await targetDeptRef.get();
      final deptData = deptSnap.data() ?? {};
      final currentServices = (deptData['standardServices'] as List<dynamic>? ?? [])
          .whereType<Map<String, dynamic>>()
          .toList();

      final alreadyExists = currentServices.any(
        (s) => (s['name'] ?? '').toString().trim().toLowerCase() == serviceName.toLowerCase(),
      );

      final serviceMap = {
        'id': 'svc-${DateTime.now().millisecondsSinceEpoch}',
        'name': serviceName,
        'duration': duration,
        'suggestedPrice': suggestedPrice,
        'description': description,
      };

      if (!alreadyExists) {
        await targetDeptRef.update({
          'standardServices': FieldValue.arrayUnion([serviceMap]),
        });
      }

      if (clinicId.isNotEmpty) {
        final assigned = (deptData['assignedClinics'] as List<dynamic>? ?? [])
            .map((e) => e.toString())
            .toList();
        if (!assigned.contains(clinicId)) {
          await targetDeptRef.update({
            'assignedClinics': FieldValue.arrayUnion([clinicId]),
          });
        }
      }
    }

    // 4. Update clinic service in services collection
    if (serviceId.isNotEmpty) {
      try {
        final svcDoc = await _firestore.collection('services').doc(serviceId).get();
        if (svcDoc.exists) {
          await svcDoc.reference.update({
            'status': 'active',
            'departmentId': targetDeptRef?.id ?? deptId,
            'departmentName': deptName,
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }
      } catch (e) {
        debugPrint('Error updating service status in services collection: $e');
      }
    }
  }

  @override
  Future<void> rejectServiceRequest(String reqId, String r) async {
    final reqDoc = await _firestore.collection('service_requests').doc(reqId).get();
    if (!reqDoc.exists) return;

    final data = reqDoc.data()!;
    final serviceId = (data['serviceId'] as String?)?.trim() ?? reqId;

    await reqDoc.reference.update({
      'status': 'rejected',
      'rejectionReason': r,
      'reviewedAt': DateTime.now().toIso8601String(),
    });

    if (serviceId.isNotEmpty) {
      try {
        final svcDoc = await _firestore.collection('services').doc(serviceId).get();
        if (svcDoc.exists) {
          await svcDoc.reference.update({
            'status': 'rejected',
            'rejectionReason': r,
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }
      } catch (e) {
        debugPrint('Error updating service rejection status: $e');
      }
    }
  }
}
