import 'package:cloud_firestore/cloud_firestore.dart';

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
    return _firestore.collection('departments').snapshots().map((s) => s.docs.map((d) => DepartmentModel.fromFirestore(d)).toList());
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
      for (final d in sampleDepartmentsSeed) {
        await _firestore.collection('departments').add(d);
      }
      for (final r in sampleExpansionRequestsSeed) {
        await _firestore.collection('department_requests').add(r);
      }
      for (final s in sampleServiceRequestsSeed) {
        await _firestore.collection('service_requests').add(s);
      }
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
  Future<void> approveExpansionRequest(String reqId) =>
      _firestore.collection('department_requests').doc(reqId).update({'status': 'approved', 'reviewedAt': DateTime.now().toIso8601String()});

  @override
  Future<void> rejectExpansionRequest(String reqId, String r) => _firestore.collection('department_requests').doc(reqId).update({
    'status': 'rejected',
    'rejectionReason': r,
    'reviewedAt': DateTime.now().toIso8601String(),
  });

  @override
  Future<void> approveServiceRequest(String reqId) =>
      _firestore.collection('service_requests').doc(reqId).update({'status': 'approved', 'reviewedAt': DateTime.now().toIso8601String()});

  @override
  Future<void> rejectServiceRequest(String reqId, String r) =>
      _firestore.collection('service_requests').doc(reqId).update({'status': 'rejected', 'rejectionReason': r, 'reviewedAt': DateTime.now().toIso8601String()});
}
