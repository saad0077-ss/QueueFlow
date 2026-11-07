import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/services/current_clinic_resolver.dart';
import '../../domain/entities/clinic_doctor_profile_entity.dart';
import '../../domain/entities/doctor_daily_schedule.dart';
import '../../domain/entities/doctor_plan_entity.dart';
import '../../domain/entities/doctor_review_entity.dart';
import '../../domain/repositories/clinic_doctors_repository.dart';
import '../models/clinic_doctor_profile_model.dart';

class ClinicDoctorsRepositoryImpl implements ClinicDoctorsRepository {
  final FirebaseFirestore? _explicitFirestore;
  final FirebaseAuth? _explicitAuth;

  FirebaseFirestore? get _firestore {
    if (_explicitFirestore != null) return _explicitFirestore;
    try {
      return FirebaseFirestore.instance;
    } catch (_) {
      return null;
    }
  }

  FirebaseAuth? get _auth {
    if (_explicitAuth != null) return _explicitAuth;
    try {
      return FirebaseAuth.instance;
    } catch (_) {
      return null;
    }
  }

  final StreamController<List<ClinicDoctorProfileEntity>> _doctorsStreamController =
      StreamController<List<ClinicDoctorProfileEntity>>.broadcast();

  List<ClinicDoctorProfileEntity> _cachedDoctors = [];
  DocumentSnapshot<Map<String, dynamic>>? _cachedClinicDoc;
  String _cachedClinicId = 'sunrise-health';

  static const List<String> _fallbackSpecialties = [
    'General Medicine',
    'Dental & Oral Surgery',
    'Pediatrics & Child Care',
    'Cardiology',
    'Dermatology & Cosmetology',
    'Orthopedics & Sports Medicine',
    'ENT / Otorhinolaryngology',
    'Gynecology & Obstetrics',
    'Ophthalmology',
  ];

  static final List<ClinicDoctorProfileEntity> sampleSeedDoctors = [
    ClinicDoctorProfileEntity(
      id: 'doc-1',
      clinicId: 'sunrise-health',
      name: 'Dr. Priya',
      title: 'Chief Medical Officer',
      specialty: 'General & Family Medicine',
      department: 'General & Family Medicine',
      room: 'Room 1 (Consultation)',
      email: 'priya@sunrisehealth.com',
      phone: '+91 98450 00001',
      schedule: 'Mon–Fri, 9:00 AM – 5:00 PM',
      status: 'available',
      accountStatus: 'active',
      qualifications: 'MBBS, MD (General Medicine)',
      experienceYears: 8,
      registrationNo: 'NCT-08801-KA',
      employmentType: 'Full-time',
      consultationFee: 500,
      slotDuration: 20,
      bio: 'Dr. Priya is a chief medical officer focused on general & family medicine, evidence-based outpatient care and clear patient communication.',
      initials: 'DP',
      nowServing: 'A-021',
      waitingCount: 1,
      services: const ['General Consultation', 'Health Checkup', 'Follow-up Visit & Review'],
      weeklySchedule: DoctorDailySchedule.defaultWeekly(),
      reviews: const [
        DoctorReviewEntity(
          id: 'rev-1',
          userName: 'Aisha Rahman',
          rating: 5.0,
          date: '10 Jun 2026',
          service: 'General Consultation',
          comment: 'Dr. Priya was exceptionally attentive. The digital queue made sure I didn\'t spend even 5 minutes in a crowded waiting room! Very clean clinic.',
          tags: ['Friendly Doctor', 'Clean Facility', 'Zero Wait Time'],
        ),
        DoctorReviewEntity(
          id: 'rev-2',
          userName: 'Deepak V.',
          rating: 5.0,
          date: '02 Jun 2026',
          service: 'Health Checkup',
          comment: 'Outstanding experience. Transparent wait time estimates and exceptional care from Dr. Priya.',
          tags: ['Accurate Diagnosis', 'Polite Staff'],
        ),
      ],
      totalAppointments: 7,
      completedAppointments: 1,
      upcomingAppointments: 4,
    ),
  ];

  ClinicDoctorsRepositoryImpl({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _explicitFirestore = firestore,
        _explicitAuth = auth {
    _cachedDoctors = <ClinicDoctorProfileEntity>[];
  }

  Future<DocumentSnapshot<Map<String, dynamic>>?> _getClinicDoc() async {
    if (_cachedClinicDoc != null && _cachedClinicDoc!.exists) {
      return _cachedClinicDoc;
    }

    final fs = _firestore;
    final au = _auth;
    if (fs == null || au == null) return null;

    try {
      final doc = await CurrentClinicResolver.resolve(
        auth: au,
        firestore: fs,
      );
      if (doc != null && doc.exists) {
        _cachedClinicDoc = doc;
        _cachedClinicId = doc.id;
        return doc;
      }
    } catch (_) {
      // Continue to query fallbacks
    }

    try {
      final activeQuery = await fs
          .collection('clinics')
          .where('status', isEqualTo: 'ACTIVE')
          .limit(1)
          .get();
      if (activeQuery.docs.isNotEmpty) {
        _cachedClinicDoc = activeQuery.docs.first;
        _cachedClinicId = _cachedClinicDoc!.id;
        return _cachedClinicDoc;
      }

      final docDirect = await fs.collection('clinics').doc('sunrise-health').get();
      if (docDirect.exists) {
        _cachedClinicDoc = docDirect;
        _cachedClinicId = docDirect.id;
        return docDirect;
      }
    } catch (_) {
      // Offline or permission issue
    }

    return null;
  }

  @override
  Stream<List<ClinicDoctorProfileEntity>> watchDoctors() {
    _startWatching();
    return _doctorsStreamController.stream;
  }

  void _startWatching() async {
    final doc = await _getClinicDoc();
    if (doc != null) {
      _cachedClinicId = doc.id;
      final rawDocs = (doc.data()?['doctors'] as List<dynamic>? ?? []);
      if (rawDocs.isNotEmpty) {
        _cachedDoctors = <ClinicDoctorProfileEntity>[
          for (final m in rawDocs.whereType<Map<String, dynamic>>())
            ClinicDoctorProfileModel.fromMap(m, defaultClinicId: _cachedClinicId)
        ];
      } else {
        // Fresh clinic: when clinic admin logs in for the first time, start fresh with no doctors.
        // Do NOT make the clinic admin a doctor.
        _cachedDoctors = <ClinicDoctorProfileEntity>[];
      }
      _emit();

      // Listen for updates from Firestore
      final fs = _firestore;
      if (fs != null) {
        _watchDoctorReviews(fs, _cachedClinicId);
        fs.collection('clinics').doc(_cachedClinicId).snapshots().listen((snap) {
          if (!snap.exists) return;
          _cachedClinicDoc = snap;
          final docsList = (snap.data()?['doctors'] as List<dynamic>? ?? []);
          _cachedDoctors = <ClinicDoctorProfileEntity>[
            for (final m in docsList.whereType<Map<String, dynamic>>())
              ClinicDoctorProfileModel.fromMap(m, defaultClinicId: _cachedClinicId)
          ];
          _emit();
        }, onError: (_) {});
      }
    } else {
      _emit();
    }
  }

  void _emit() {
    if (!_doctorsStreamController.isClosed) {
      // Patient ratings live in `doctor_reviews`; overlay them at emit time so
      // they are shown but never written back into the clinic's doctors array.
      final withReviews = [
        for (final d in _cachedDoctors)
          (_reviewsByDoctor[d.id]?.isNotEmpty ?? false) ? d.copyWith(reviews: _reviewsByDoctor[d.id]) : d,
      ];
      _doctorsStreamController.add(List.unmodifiable(withReviews));
    }
  }

  final Map<String, List<DoctorReviewEntity>> _reviewsByDoctor = {};
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _reviewsSub;

  static const _months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

  /// Listens to ratings patients leave for this clinic's doctors.
  void _watchDoctorReviews(FirebaseFirestore fs, String clinicId) {
    _reviewsSub?.cancel();
    _reviewsSub = fs.collection('doctor_reviews').where('clinicId', isEqualTo: clinicId).snapshots().listen((snap) {
      final entries = <(DateTime?, String, DoctorReviewEntity)>[];
      for (final doc in snap.docs) {
        final m = doc.data();
        final doctorId = (m['doctorId'] ?? '').toString();
        if (doctorId.isEmpty) continue;
        final ts = m['createdAt'];
        final dt = ts is Timestamp ? ts.toDate() : null;
        entries.add((
          dt,
          doctorId,
          DoctorReviewEntity(
            id: doc.id,
            userName: (m['patientName'] ?? 'Verified Patient').toString(),
            rating: (m['rating'] as num?)?.toDouble() ?? 0,
            date: dt == null ? '' : '${dt.day.toString().padLeft(2, '0')} ${_months[dt.month - 1]} ${dt.year}',
            service: '',
            comment: (m['comment'] ?? '').toString(),
          ),
        ));
      }
      // Newest first.
      entries.sort((a, b) => (b.$1 ?? DateTime(0)).compareTo(a.$1 ?? DateTime(0)));
      _reviewsByDoctor.clear();
      for (final e in entries) {
        _reviewsByDoctor.putIfAbsent(e.$2, () => []).add(e.$3);
      }
      _emit();
    }, onError: (_) {});
  }

  @override
  Future<DoctorPlanEntity> getDoctorPlan() async {
    final doc = await _getClinicDoc();
    final data = doc?.data() ?? const <String, dynamic>{};
    final clinicName = data['name'] as String? ?? 'Sunrise Health Clinic';
    final planId = (data['planId'] as String? ?? 'solo').toLowerCase();

    switch (planId) {
      case 'enterprise':
        return DoctorPlanEntity(
          planName: 'Unlimited Doctors Plan',
          planPill: 'UNLIMITED DOCTORS PLAN',
          doctorsLimit: 999,
          clinicName: clinicName,
        );
      case 'multi':
        return DoctorPlanEntity(
          planName: 'Multi-Doctor Clinic Plan',
          planPill: 'MULTI-DOCTOR PRACTICE',
          doctorsLimit: 10,
          clinicName: clinicName,
        );
      default:
        return DoctorPlanEntity(
          planName: 'Solo Doctor Plan',
          planPill: 'SOLO DOCTOR PRACTICE',
          doctorsLimit: 1,
          clinicName: clinicName,
        );
    }
  }

  @override
  Future<List<String>> getDepartmentSpecialties() async {
    final fs = _firestore;
    if (fs != null) {
      try {
        final clinic = await _getClinicDoc();
        final clinicId = clinic?.id ?? _cachedClinicId;
        final clinicData = clinic?.data() ?? const <String, dynamic>{};
        final clinicName = (clinicData['name'] as String? ?? '').toLowerCase();
        final slug = clinicName
            .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
            .replaceAll(RegExp(r'^-+|-+$'), '');

        // Direct assigned departments in clinic doc if present
        final directDeptNames = <String>{};
        if (clinicData['departments'] is List) {
          for (final item in (clinicData['departments'] as List)) {
            if (item is String && item.trim().isNotEmpty) {
              directDeptNames.add(item.trim());
            } else if (item is Map && item['name'] is String) {
              directDeptNames.add((item['name'] as String).trim());
            }
          }
        }
        if (clinicData['department'] is String &&
            (clinicData['department'] as String).trim().isNotEmpty) {
          directDeptNames.add((clinicData['department'] as String).trim());
        }

        final snap = await fs.collection('departments').get();
        if (snap.docs.isNotEmpty) {
          final assignedList = <String>[];
          for (final doc in snap.docs) {
            final data = doc.data();
            final deptName = (data['name'] as String?)?.trim();
            if (deptName == null || deptName.isEmpty) continue;
            final deptStatus =
                (data['status'] ?? 'active').toString().toLowerCase();
            if (deptStatus != 'active') continue;

            final assignedClinics =
                (data['assignedClinics'] as List<dynamic>? ?? [])
                    .map((e) => e.toString().trim().toLowerCase());
            final clinicDeptIds =
                ((clinicData['departmentIds'] as List<dynamic>?) ?? [])
                    .map((e) => e.toString().trim());

            final isAssigned = assignedClinics.any(
                  (k) =>
                      k == clinicId.toLowerCase() ||
                      (k.isNotEmpty &&
                          slug.isNotEmpty &&
                          (slug == k ||
                              slug.startsWith(k) ||
                              k.startsWith(slug))),
                ) ||
                clinicDeptIds.contains(doc.id) ||
                directDeptNames.contains(deptName);

            if (isAssigned) {
              assignedList.add(deptName);
            }
          }

          if (assignedList.isNotEmpty) {
            final result = assignedList.toSet().toList()..sort();
            return result;
          }
        }

        if (directDeptNames.isNotEmpty) {
          final res = directDeptNames.toList()..sort();
          return res;
        }

        // Newly created clinic with no assigned departments yet: return empty list
        return const <String>[];
      } catch (_) {
        // Fallback to empty if querying fails
        return const <String>[];
      }
    }
    return _fallbackSpecialties;
  }

  @override
  Future<void> addDoctor(ClinicDoctorProfileEntity doctor) async {
    final updatedList = List<ClinicDoctorProfileEntity>.from(_cachedDoctors)..add(doctor);
    _cachedDoctors = updatedList;
    _emit();

    await _syncToDoctorsFirestore();
  }

  @override
  Future<void> updateDoctorProfile(ClinicDoctorProfileEntity doctor) async {
    final index = _cachedDoctors.indexWhere((d) => d.id == doctor.id);
    if (index != -1) {
      _cachedDoctors[index] = doctor;
      _emit();
      await _syncToDoctorsFirestore();
    }
  }

  @override
  Future<void> updateDoctorSchedule({
    required String doctorId,
    required Map<String, DoctorDailySchedule> schedule,
    required int slotDuration,
    List<String>? leaveDates,
  }) async {
    final index = _cachedDoctors.indexWhere((d) => d.id == doctorId);
    if (index != -1) {
      // Summarize into text schedule e.g. Mon–Sat, 9:00 AM – 5:00 PM
      final activeDays = schedule.values.where((d) => d.enabled).toList();
      String summaryText = 'No schedule set';
      if (activeDays.isNotEmpty) {
        summaryText = '${activeDays.first.shortName}–${activeDays.last.shortName}, ${activeDays.first.start} – ${activeDays.first.end}';
      }

      _cachedDoctors[index] = _cachedDoctors[index].copyWith(
        weeklySchedule: schedule,
        leaveDates: leaveDates,
        slotDuration: slotDuration,
        schedule: summaryText,
      );
      _emit();
      await _syncToDoctorsFirestore();
    }
  }

  @override
  Future<void> setDoctorAccountStatus(String doctorId, String accountStatus) async {
    final index = _cachedDoctors.indexWhere((d) => d.id == doctorId);
    if (index != -1) {
      _cachedDoctors[index] = _cachedDoctors[index].copyWith(accountStatus: accountStatus);
      _emit();
      await _syncToDoctorsFirestore();
    }
  }

  @override
  Future<void> updateDoctorStatus(String doctorId, String status) async {
    final index = _cachedDoctors.indexWhere((d) => d.id == doctorId);
    if (index != -1) {
      final updated = _cachedDoctors[index].copyWith(status: status);
      _cachedDoctors[index] = updated;
      _emit();
      await _syncToDoctorsFirestore();
    }
  }

  @override
  Future<void> deleteDoctor(String doctorId) async {
    _cachedDoctors.removeWhere((d) => d.id == doctorId);
    _emit();
    await _syncToDoctorsFirestore();
  }

  @override
  Future<String?> callNextPatient(String doctorName) async {
    final fs = _firestore;
    if (fs != null) {
      try {
        final queueRef = fs.collection('queues').doc(_cachedClinicId);
        final queueSnap = await queueRef.get();
        if (queueSnap.exists) {
          final data = queueSnap.data()!;
          final waiting = data['waitingCount'] as int? ?? 0;
          final currentNum = int.tryParse(
                (data['currentToken'] as String? ?? 'A-000').replaceAll('A-', ''),
              ) ??
              0;

          if (waiting > 0) {
            final nextNum = currentNum + 1;
            final nextToken = 'A-${nextNum.toString().padLeft(3, '0')}';
            await queueRef.update({
              'currentToken': nextToken,
              'waitingCount': waiting - 1,
              'lastCalledAt': FieldValue.serverTimestamp(),
            });

            // Update doctor's nowServing
            final docIndex = _cachedDoctors.indexWhere((d) => d.name == doctorName);
            if (docIndex != -1) {
              _cachedDoctors[docIndex] = _cachedDoctors[docIndex].copyWith(
                nowServing: nextToken,
                waitingCount: waiting - 1,
                status: 'busy',
              );
              _emit();
              await _syncToDoctorsFirestore();
            }
            return nextToken;
          }
        }
      } catch (_) {
        // In-memory fallback
      }
    }

    // Fallback simulation
    final docIndex = _cachedDoctors.indexWhere((d) => d.name == doctorName);
    if (docIndex != -1) {
      final currentServing = _cachedDoctors[docIndex].nowServing ?? 'A-021';
      final numPart = int.tryParse(currentServing.replaceAll(RegExp(r'[^0-9]'), '')) ?? 21;
      final nextToken = 'A-${(numPart + 1).toString().padLeft(3, '0')}';
      final currentWait = _cachedDoctors[docIndex].waitingCount;
      _cachedDoctors[docIndex] = _cachedDoctors[docIndex].copyWith(
        nowServing: nextToken,
        waitingCount: (currentWait > 0 ? currentWait - 1 : 0),
        status: 'busy',
      );
      _emit();
      return nextToken;
    }
    return null;
  }

  @override
  Future<int> getQueueWaitingCount() async {
    final fs = _firestore;
    if (fs != null) {
      try {
        final queueDoc = await fs.collection('queues').doc(_cachedClinicId).get();
        if (queueDoc.exists) {
          return (queueDoc.data()?['waitingCount'] as num?)?.toInt() ?? 0;
        }
      } catch (_) {}
    }
    return _cachedDoctors.isNotEmpty ? _cachedDoctors.first.waitingCount : 0;
  }

  Future<void> _syncToDoctorsFirestore() async {
    final fs = _firestore;
    if (fs == null) return;

    try {
      final serialized = _cachedDoctors.map((d) {
        return ClinicDoctorProfileModel.fromEntity(d).toMap();
      }).toList();

      await fs.collection('clinics').doc(_cachedClinicId).set({
        'doctors': serialized,
        'practicingDoctors': _cachedDoctors.length,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (_) {
      // Best effort sync
    }
  }
}
