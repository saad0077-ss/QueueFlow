import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/services/current_clinic_resolver.dart';
import '../../../services/data/models/clinic_service_model.dart';
import '../../../services/data/models/service_department_model.dart';
import '../../../services/domain/entities/clinic_service_entity.dart';
import '../../../services/domain/entities/service_department_entity.dart';
import '../../domain/entities/clinic_queue_item_entity.dart';
import '../../domain/entities/clinic_queue_summary_entity.dart';
import '../../domain/repositories/clinic_queue_repository.dart';
import '../../domain/utils/clinic_token_generator.dart';
import '../models/clinic_queue_item_model.dart';

class ClinicQueueRepositoryImpl implements ClinicQueueRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  String? _resolvedClinicId;
  String _resolvedClinicName = 'Sunrise Health Clinic';

  final List<ClinicQueueItemEntity> _fallbackItems = [
    ClinicQueueItemEntity(
      id: 'seed-001',
      token: 'SH-GC-001',
      clinicId: 'sunrise-health',
      patientName: 'Vivek Nair',
      serviceName: 'General Consultation',
      doctorName: 'Dr. Priya',
      phone: '+91 98450 11234',
      email: 'vivek.nair@email.com',
      joinedTime: '10:40 AM',
      joinedAt: DateTime.now().subtract(const Duration(minutes: 35)),
      estDuration: '20 min',
      status: 'called',
      note: 'Prefers morning slots. Routine follow-up.',
    ),
    ClinicQueueItemEntity(
      id: 'seed-002',
      token: 'SH-GC-002',
      clinicId: 'sunrise-health',
      patientName: 'Meera Pillai',
      serviceName: 'General Consultation',
      doctorName: 'Dr. Priya',
      phone: '+91 98450 22345',
      email: 'meera.p@email.com',
      joinedTime: '10:45 AM',
      joinedAt: DateTime.now().subtract(const Duration(minutes: 25)),
      estDuration: '15 min',
      status: 'waiting',
      note: 'First visit. Blood pressure check.',
    ),
    ClinicQueueItemEntity(
      id: 'seed-003',
      token: 'SH-PC-001',
      clinicId: 'sunrise-health',
      patientName: 'Arjun Das',
      serviceName: 'Pediatric Health Checkup',
      doctorName: 'Dr. Marcus Vance',
      phone: '+91 98450 33456',
      email: 'arjun.das@email.com',
      joinedTime: '10:52 AM',
      joinedAt: DateTime.now().subtract(const Duration(minutes: 18)),
      estDuration: '20 min',
      status: 'waiting',
      note: 'Child fever consultation.',
    ),
    ClinicQueueItemEntity(
      id: 'seed-004',
      token: 'SH-SA-001',
      clinicId: 'sunrise-health',
      patientName: 'Pooja Hegde',
      serviceName: 'Skin Allergy & Rash Assessment',
      doctorName: 'Dr. Alisha Roy',
      phone: '+91 98450 44567',
      email: 'pooja.h@email.com',
      joinedTime: '11:05 AM',
      joinedAt: DateTime.now().subtract(const Duration(minutes: 5)),
      estDuration: '25 min',
      status: 'waiting',
      note: 'Skin allergy rash assessment.',
    ),
  ];

  static const List<ServiceDepartmentEntity> _fallbackDepartments = [
    ServiceDepartmentEntity(
      id: 'dept-gen',
      code: 'GM',
      name: 'General Medicine',
      icon: '🩺',
    ),
    ServiceDepartmentEntity(
      id: 'dept-dent',
      code: 'DENT',
      name: 'Dental & Oral Surgery',
      icon: '🦷',
    ),
    ServiceDepartmentEntity(
      id: 'dept-ped',
      code: 'PED',
      name: 'Pediatrics & Child Care',
      icon: '👶',
    ),
    ServiceDepartmentEntity(
      id: 'dept-derm',
      code: 'DERM',
      name: 'Dermatology & Skin Care',
      icon: '🔬',
    ),
  ];

  static const List<ClinicServiceEntity> _fallbackServices = [
    ClinicServiceEntity(
      id: 'svc-1',
      name: 'General Consultation',
      description:
          'Comprehensive medical examination, diagnosis and clinical care with Dr. Priya.',
      duration: 20,
      price: 500,
      departmentId: 'dept-gen',
      departmentName: 'General Medicine',
      assignedStaff: ['Dr. Priya'],
      status: 'active',
    ),
    ClinicServiceEntity(
      id: 'svc-2',
      name: 'Follow-up Visit & Review',
      description:
          'Review of test reports, treatment progress, and medication prescription adjustments.',
      duration: 15,
      price: 350,
      departmentId: 'dept-gen',
      departmentName: 'General Medicine',
      assignedStaff: ['Dr. Priya'],
      status: 'active',
    ),
    ClinicServiceEntity(
      id: 'svc-3',
      name: 'Dental Checkup & Cleaning',
      description:
          'Routine oral exam, ultrasonic scaling, and gum health inspection.',
      duration: 30,
      price: 800,
      departmentId: 'dept-dent',
      departmentName: 'Dental & Oral Surgery',
      assignedStaff: ['Dr. Rahul Menon'],
      status: 'active',
    ),
    ClinicServiceEntity(
      id: 'svc-4',
      name: 'Pediatric Health Checkup',
      description:
          'Growth monitoring, developmental screening, and pediatric assessment.',
      duration: 20,
      price: 600,
      departmentId: 'dept-ped',
      departmentName: 'Pediatrics & Child Care',
      assignedStaff: ['Dr. Marcus Vance'],
      status: 'active',
    ),
    ClinicServiceEntity(
      id: 'svc-5',
      name: 'Skin Allergy & Rash Assessment',
      description:
          'Clinical evaluation of dermatitis, acute rashes, and allergic reactions.',
      duration: 25,
      price: 750,
      departmentId: 'dept-derm',
      departmentName: 'Dermatology & Skin Care',
      assignedStaff: ['Dr. Alisha Roy'],
      status: 'active',
    ),
  ];

  ClinicQueueRepositoryImpl({FirebaseFirestore? firestore, FirebaseAuth? auth})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _auth = auth ?? FirebaseAuth.instance;

  Future<DocumentSnapshot<Map<String, dynamic>>?> _getClinicDoc() async {
    try {
      final doc = await CurrentClinicResolver.resolve(
        auth: _auth,
        firestore: _firestore,
      );
      if (doc != null && doc.exists) {
        _resolvedClinicId = doc.id;
        final data = doc.data();
        if (data != null && data['name'] != null) {
          _resolvedClinicName = data['name'].toString();
        }
        return doc;
      }
    } catch (_) {}
    return null;
  }

  Future<String> _clinicId() async {
    if (_resolvedClinicId != null) return _resolvedClinicId!;
    final doc = await _getClinicDoc();
    if (doc != null) return doc.id;
    _resolvedClinicId = 'sunrise-health';
    return _resolvedClinicId!;
  }

  DocumentReference<Map<String, dynamic>> _queueDocRef(String clinicId) =>
      _firestore.collection('queues').doc(clinicId);

  @override
  Stream<ClinicQueueSummaryEntity> watchQueueSummary() async* {
    final clinicId = await _clinicId();
    yield* _queueDocRef(clinicId).snapshots().map((snap) {
      if (!snap.exists || snap.data() == null) {
        return ClinicQueueSummaryEntity(
          currentToken: 'SH-GC-001',
          waitingCount: 3,
          avgWaitTime: '15 min',
          isPaused: false,
          status: 'open',
          clinicName: _resolvedClinicName,
        );
      }
      final data = snap.data()!;
      final isPaused =
          (data['status'] == 'paused') || (data['isPaused'] == true);
      return ClinicQueueSummaryEntity(
        currentToken: (data['currentToken'] ?? 'SH-GC-001').toString(),
        waitingCount: (data['waitingCount'] is int)
            ? data['waitingCount'] as int
            : int.tryParse(data['waitingCount']?.toString() ?? '3') ?? 3,
        avgWaitTime: (data['avgWaitTime'] ?? '15 min').toString(),
        isPaused: isPaused,
        status: isPaused ? 'paused' : 'open',
        clinicName: _resolvedClinicName,
        closedServices: data['closedServices'] is Map
            ? (data['closedServices'] as Map).map(
                (k, v) => MapEntry(k.toString(), v.toString()),
              )
            : const {},
      );
    });
  }

  @override
  Stream<List<ClinicQueueItemEntity>> watchQueueItems() async* {
    final clinicId = await _clinicId();
    yield* _firestore
        .collection('tickets')
        .where('clinicId', isEqualTo: clinicId)
        .snapshots()
        .map((snap) {
          if (snap.docs.isEmpty) {
            return clinicId == 'sunrise-health'
                ? List<ClinicQueueItemEntity>.from(_fallbackItems)
                : <ClinicQueueItemEntity>[];
          }
          final items = snap.docs
              .map((d) => ClinicQueueItemModel.fromFirestore(d))
              .where((item) => item.status != 'cancelled')
              .toList();

          if (items.isEmpty) {
            return clinicId == 'sunrise-health'
                ? List<ClinicQueueItemEntity>.from(_fallbackItems)
                : <ClinicQueueItemEntity>[];
          }

          items.sort((a, b) {
            final statusWeight = {
              'called': 0,
              'waiting': 1,
              'skipped': 2,
              'completed': 3,
            };
            final weightA = statusWeight[a.status] ?? 4;
            final weightB = statusWeight[b.status] ?? 4;
            if (weightA != weightB) return weightA.compareTo(weightB);
            return a.joinedAt.compareTo(b.joinedAt);
          });

          return items;
        });
  }

  @override
  Future<List<ServiceDepartmentEntity>> getDepartments() async {
    final clinicDoc = await _getClinicDoc();
    final clinicId = clinicDoc?.id ?? _resolvedClinicId ?? 'sunrise-health';
    final clinicData = clinicDoc?.data() ?? {};
    final clinicName = (clinicData['name'] as String?) ?? _resolvedClinicName;
    final slug = _slug(clinicName);

    // 1. Get all active services configured in clinic admin for this clinic
    List<ClinicServiceEntity> clinicServices = [];
    try {
      final svcsSnap = await _firestore
          .collection('services')
          .where('clinicId', isEqualTo: clinicId)
          .get();
      clinicServices = svcsSnap.docs
          .map(ClinicServiceModel.fromFirestore)
          .where((s) => s.isActive)
          .toList();
    } catch (_) {}

    if (clinicServices.isEmpty && clinicId == 'sunrise-health') {
      clinicServices = _fallbackServices;
    }

    final serviceDeptIds = clinicServices
        .map((s) => s.departmentId.trim())
        .where((id) => id.isNotEmpty)
        .toSet();
    final serviceDeptNames = clinicServices
        .map((s) => s.departmentName.trim().toLowerCase())
        .where((n) => n.isNotEmpty)
        .toSet();

    final clinicDeptIds =
        ((clinicData['departmentIds'] as List<dynamic>?) ?? [])
            .map((e) => e.toString().trim())
            .toSet();
    final clinicDeptNames =
        ((clinicData['departments'] as List<dynamic>?) ?? [])
            .map((e) => e.toString().trim().toLowerCase())
            .toSet();

    final List<ServiceDepartmentEntity> result = [];

    // 2. Fetch master departments collection and filter strictly to those assigned to this clinic
    try {
      final deptSnap = await _firestore.collection('departments').get();
      for (final doc in deptSnap.docs) {
        final data = doc.data();
        final status = (data['status'] ?? 'active').toString().toLowerCase();
        if (status != 'active') continue;

        final deptName = (data['name'] ?? '').toString().trim();
        final deptNameLower = deptName.toLowerCase();

        final assignedClinics =
            (data['assignedClinics'] as List<dynamic>? ?? [])
                .map((e) => e.toString().trim().toLowerCase())
                .toList();

        final isExplicitlyAssigned = assignedClinics.any(
          (k) =>
              k == clinicId.toLowerCase() ||
              (k.isNotEmpty &&
                  slug.isNotEmpty &&
                  (slug == k || slug.startsWith(k) || k.startsWith(slug))),
        );

        final isLinkedToClinic =
            clinicDeptIds.contains(doc.id) ||
            clinicDeptNames.contains(deptNameLower);

        final hasServiceForClinic =
            serviceDeptIds.contains(doc.id) ||
            serviceDeptNames.contains(deptNameLower);

        if (isExplicitlyAssigned || isLinkedToClinic || hasServiceForClinic) {
          final deptModel = ServiceDepartmentModel.fromFirestore(doc);
          final alreadyExists = result.any(
            (d) =>
                d.id == deptModel.id ||
                d.name.trim().toLowerCase() == deptNameLower,
          );
          if (!alreadyExists) {
            result.add(deptModel);
          }
        }
      }
    } catch (_) {}

    // 3. For any service added in clinic admin whose department wasn't in master departments,
    // synthesize the department entity so the clinic admin's services are grouped and visible
    for (final s in clinicServices) {
      final sDeptName = s.departmentName.trim();
      if (sDeptName.isNotEmpty &&
          !result.any(
            (d) =>
                (s.departmentId.isNotEmpty && d.id == s.departmentId) ||
                d.name.trim().toLowerCase() == sDeptName.toLowerCase(),
          )) {
        result.add(
          ServiceDepartmentEntity(
            id: s.departmentId.isNotEmpty
                ? s.departmentId
                : 'dept-${_slug(sDeptName)}',
            code: _departmentCodeFor(sDeptName),
            name: sDeptName,
            icon: _departmentIconFor(sDeptName),
          ),
        );
      }
    }

    // 4. Strictly deduplicate by normalized department name
    final Map<String, ServiceDepartmentEntity> uniqueByName = {};
    for (final dept in result) {
      final key = dept.name.trim().toLowerCase();
      if (!uniqueByName.containsKey(key)) {
        uniqueByName[key] = dept;
      }
    }

    final dedupedList = uniqueByName.values.toList();
    if (dedupedList.isNotEmpty) {
      dedupedList.sort((a, b) => a.name.compareTo(b.name));
      return dedupedList;
    }

    // Fallback for tests/local mock when clinic is sunrise-health
    if (clinicId == 'sunrise-health') {
      return _fallbackDepartments;
    }

    return const [];
  }

  @override
  Stream<List<ClinicServiceEntity>> watchServices() async* {
    final clinicId = await _clinicId();
    yield* _firestore
        .collection('services')
        .where('clinicId', isEqualTo: clinicId)
        .snapshots()
        .map((snap) {
          final list = snap.docs
              .map(ClinicServiceModel.fromFirestore)
              .where((s) => s.isActive)
              .toList();

          if (list.isEmpty && clinicId == 'sunrise-health') {
            return _fallbackServices;
          }

          final Map<String, ClinicServiceEntity> uniqueServices = {};
          for (final s in list) {
            final key =
                '${s.departmentName.trim().toLowerCase()}_${s.name.trim().toLowerCase()}';
            if (!uniqueServices.containsKey(key)) {
              uniqueServices[key] = s;
            }
          }
          return uniqueServices.values.toList();
        });
  }

  @override
  Future<void> callNextToken([String? serviceName]) async {
    final clinicId = await _clinicId();
    try {
      // Find currently called item to mark completed
      var calledQuery = _firestore
          .collection('tickets')
          .where('clinicId', isEqualTo: clinicId)
          .where('status', isEqualTo: 'called');

      if (serviceName != null && serviceName.isNotEmpty) {
        calledQuery = calledQuery.where('serviceName', isEqualTo: serviceName);
      }

      final calledSnap = await calledQuery.limit(1).get();
      if (calledSnap.docs.isNotEmpty) {
        await calledSnap.docs.first.reference.update({
          'status': 'completed',
          'completedAt': FieldValue.serverTimestamp(),
        });
      }

      // Find first waiting item
      var waitingQuery = _firestore
          .collection('tickets')
          .where('clinicId', isEqualTo: clinicId)
          .where('status', isEqualTo: 'waiting')
          .orderBy('joinedAt', descending: false);

      if (serviceName != null && serviceName.isNotEmpty) {
        waitingQuery = waitingQuery.where(
          'serviceName',
          isEqualTo: serviceName,
        );
      }

      final waitingSnap = await waitingQuery.limit(1).get();
      if (waitingSnap.docs.isNotEmpty) {
        final nextDoc = waitingSnap.docs.first;
        final nextToken = nextDoc.data()['token']?.toString() ?? 'SH-GC-001';
        await nextDoc.reference.update({
          'status': 'called',
          'calledAt': FieldValue.serverTimestamp(),
        });

        await _queueDocRef(clinicId).set({
          'currentToken': nextToken,
          'waitingCount': FieldValue.increment(-1),
          'lastCalledAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      } else {
        // Fallback local update
        final calledIdx = _fallbackItems.indexWhere(
          (i) =>
              i.status == 'called' &&
              (serviceName == null ||
                  i.serviceName.toLowerCase() == serviceName.toLowerCase()),
        );
        if (calledIdx != -1) {
          _fallbackItems[calledIdx] = _fallbackItems[calledIdx].copyWith(
            status: 'completed',
          );
        }
        final waitingIdx = _fallbackItems.indexWhere(
          (i) =>
              i.status == 'waiting' &&
              (serviceName == null ||
                  i.serviceName.toLowerCase() == serviceName.toLowerCase()),
        );
        if (waitingIdx != -1) {
          _fallbackItems[waitingIdx] = _fallbackItems[waitingIdx].copyWith(
            status: 'called',
          );
          await _queueDocRef(clinicId).set({
            'currentToken': _fallbackItems[waitingIdx].token,
            'waitingCount': _fallbackItems
                .where((i) => i.status == 'waiting')
                .length,
          }, SetOptions(merge: true));
        }
      }
    } catch (_) {
      final calledIdx = _fallbackItems.indexWhere(
        (i) =>
            i.status == 'called' &&
            (serviceName == null ||
                i.serviceName.toLowerCase() == serviceName.toLowerCase()),
      );
      if (calledIdx != -1) {
        _fallbackItems[calledIdx] = _fallbackItems[calledIdx].copyWith(
          status: 'completed',
        );
      }
      final waitingIdx = _fallbackItems.indexWhere(
        (i) =>
            i.status == 'waiting' &&
            (serviceName == null ||
                i.serviceName.toLowerCase() == serviceName.toLowerCase()),
      );
      if (waitingIdx != -1) {
        _fallbackItems[waitingIdx] = _fallbackItems[waitingIdx].copyWith(
          status: 'called',
        );
      }
    }
  }

  @override
  Future<void> callSpecificToken(String token) async {
    final clinicId = await _clinicId();
    try {
      final calledSnap = await _firestore
          .collection('tickets')
          .where('clinicId', isEqualTo: clinicId)
          .where('status', isEqualTo: 'called')
          .get();

      for (final doc in calledSnap.docs) {
        await doc.reference.update({
          'status': 'completed',
          'completedAt': FieldValue.serverTimestamp(),
        });
      }

      final targetSnap = await _firestore
          .collection('tickets')
          .where('clinicId', isEqualTo: clinicId)
          .where('token', isEqualTo: token)
          .limit(1)
          .get();

      if (targetSnap.docs.isNotEmpty) {
        await targetSnap.docs.first.reference.update({
          'status': 'called',
          'calledAt': FieldValue.serverTimestamp(),
        });
      }

      await _queueDocRef(clinicId).set({
        'currentToken': token,
        'lastCalledAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (_) {
      for (int i = 0; i < _fallbackItems.length; i++) {
        if (_fallbackItems[i].status == 'called') {
          _fallbackItems[i] = _fallbackItems[i].copyWith(status: 'completed');
        }
        if (_fallbackItems[i].token == token) {
          _fallbackItems[i] = _fallbackItems[i].copyWith(status: 'called');
        }
      }
    }
  }

  @override
  Future<void> completeToken(String token) async {
    final clinicId = await _clinicId();
    try {
      final snap = await _firestore
          .collection('tickets')
          .where('clinicId', isEqualTo: clinicId)
          .where('token', isEqualTo: token)
          .limit(1)
          .get();

      if (snap.docs.isNotEmpty) {
        await snap.docs.first.reference.update({
          'status': 'completed',
          'completedAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (_) {
      final idx = _fallbackItems.indexWhere((i) => i.token == token);
      if (idx != -1) {
        _fallbackItems[idx] = _fallbackItems[idx].copyWith(status: 'completed');
      }
    }
  }

  @override
  Future<void> skipToken(String token) async {
    final clinicId = await _clinicId();
    try {
      final snap = await _firestore
          .collection('tickets')
          .where('clinicId', isEqualTo: clinicId)
          .where('token', isEqualTo: token)
          .limit(1)
          .get();

      if (snap.docs.isNotEmpty) {
        await snap.docs.first.reference.update({
          'status': 'skipped',
          'joinedAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (_) {
      final idx = _fallbackItems.indexWhere((i) => i.token == token);
      if (idx != -1) {
        final item = _fallbackItems.removeAt(idx);
        _fallbackItems.add(item.copyWith(status: 'skipped'));
      }
    }
  }

  @override
  Future<void> removeToken(String token) async {
    final clinicId = await _clinicId();
    try {
      final snap = await _firestore
          .collection('tickets')
          .where('clinicId', isEqualTo: clinicId)
          .where('token', isEqualTo: token)
          .limit(1)
          .get();

      if (snap.docs.isNotEmpty) {
        await snap.docs.first.reference.update({
          'status': 'cancelled',
          'cancelledAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (_) {
      _fallbackItems.removeWhere((i) => i.token == token);
    }
  }

  @override
  Future<void> setServiceClosedToday(String service, bool closed) async {
    final clinicId = await _clinicId();
    final key = service.trim().toLowerCase();
    final today = ClinicQueueSummaryEntity.todayKey();
    await _queueDocRef(clinicId).set({
      'closedServices': {key: closed ? today : FieldValue.delete()},
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  @override
  Future<void> togglePauseQueue(bool isPaused) async {
    final clinicId = await _clinicId();
    final newStatus = isPaused ? 'paused' : 'open';
    try {
      await _queueDocRef(clinicId).set({
        'status': newStatus,
        'isPaused': isPaused,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (_) {}
  }

  @override
  Future<ClinicQueueItemEntity> addWalkInPatient({
    required String name,
    required String phone,
    required String service,
    String? doctor,
    String? note,
    String? email,
    String? department,
  }) async {
    final clinicId = await _clinicId();
    final clinicName = _resolvedClinicName;
    final now = DateTime.now();
    final hour = now.hour;
    final minute = now.minute.toString().padLeft(2, '0');
    final ampm = hour >= 12 ? 'PM' : 'AM';
    final h12 = hour % 12 == 0 ? 12 : hour % 12;
    final joinedTime = '$h12:$minute $ampm';

    final effectiveService = service.isNotEmpty
        ? service
        : 'General Consultation';
    final serviceCode = ClinicTokenGenerator.extractServiceCode(
      effectiveService,
    );

    int nextSeq = 1;
    try {
      final queueSnap = await _queueDocRef(clinicId).get();
      if (queueSnap.exists) {
        final data = queueSnap.data()!;
        final serviceCounters =
            (data['serviceCounters'] as Map<String, dynamic>?) ?? {};
        final currentForService =
            serviceCounters[serviceCode] as int? ??
            serviceCounters[effectiveService] as int?;
        if (currentForService != null) {
          nextSeq = currentForService + 1;
        } else {
          // If not in counters map yet, check existing tickets for this service today
          final ticketsSnap = await _firestore
              .collection('tickets')
              .where('clinicId', isEqualTo: clinicId)
              .where('serviceName', isEqualTo: effectiveService)
              .get();
          int maxNum = 0;
          for (final doc in ticketsSnap.docs) {
            final tok = (doc.data()['token'] ?? '').toString();
            final num = ClinicTokenGenerator.parseSequenceNumber(tok);
            if (num != null && num > maxNum) {
              maxNum = num;
            }
          }
          nextSeq = maxNum + 1;
        }
      }
    } catch (_) {
      // In fallback / offline mode, find max sequence for this service
      int maxNum = 0;
      for (final item in _fallbackItems) {
        if (item.serviceName.toLowerCase() == effectiveService.toLowerCase() ||
            item.token.contains('-$serviceCode-')) {
          final num = ClinicTokenGenerator.parseSequenceNumber(item.token);
          if (num != null && num > maxNum) {
            maxNum = num;
          }
        }
      }
      nextSeq = maxNum + 1;
    }

    final token = ClinicTokenGenerator.generateToken(
      clinicName: clinicName,
      serviceName: effectiveService,
      sequenceNumber: nextSeq,
    );

    final newItem = ClinicQueueItemModel(
      id: 'walkin-$serviceCode-$nextSeq-${now.millisecondsSinceEpoch}',
      token: token,
      clinicId: clinicId,
      patientName: name,
      serviceName: effectiveService,
      doctorName: doctor?.isNotEmpty == true ? doctor! : 'Attending Doctor',
      phone: phone.isNotEmpty ? phone : '+91 98450 00000',
      email: (email ?? '').trim(),
      joinedTime: joinedTime,
      joinedAt: now,
      estDuration: '20 min',
      status: 'waiting',
      note: note ?? '',
    );

    try {
      final docRef = await _firestore.collection('tickets').add({
        ...newItem.toMap(),
        if (email != null && email.trim().isNotEmpty)
          'patientEmail': email.trim().toLowerCase(),
        if (department != null && department.trim().isNotEmpty)
          'departmentName': department.trim(),
      });
      await _queueDocRef(clinicId).set({
        'serviceCounters': {serviceCode: nextSeq},
        'waitingCount': FieldValue.increment(1),
        'status': 'open',
        'lastIssuedToken': token,
      }, SetOptions(merge: true));
      return newItem.copyWith(id: docRef.id);
    } catch (_) {
      _fallbackItems.add(newItem);
      return newItem;
    }
  }

  @override
  Future<List<String>> getAvailableServices() async {
    final svcs = await watchServices().first;
    return svcs.map((s) => s.name).toList();
  }

  @override
  Future<List<String>> getAvailableDoctors() async {
    final clinicId = await _clinicId();
    try {
      final snap = await _firestore
          .collection('doctors')
          .where('clinicId', isEqualTo: clinicId)
          .get();

      if (snap.docs.isNotEmpty) {
        return snap.docs
            .map((d) => (d.data()['name'] ?? '').toString())
            .where((n) => n.isNotEmpty)
            .toList();
      }
    } catch (_) {}

    return const [
      'Dr. Priya',
      'Dr. Rahul Menon',
      'Dr. Marcus Vance',
      'Dr. Alisha Roy',
    ];
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
