import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../domain/entities/clinic_entity.dart';
import '../models/live_clinic_queue_info.dart';
import '../utils/queue_helpers.dart';
import 'clinic_live_evaluator.dart';

class ClinicLiveCubit extends Cubit<LiveInfo> {
  final ClinicEntity clinic;
  StreamSubscription? _servicesSub;
  StreamSubscription? _queueDocSub;
  StreamSubscription? _ticketsSub;
  Timer? _timer;

  List<QueryDocumentSnapshot<Map<String, dynamic>>>? _ticketDocs;
  Map<String, String> _deptOf = const {};
  Map<String, dynamic>? _queueDoc;

  ClinicLiveCubit(this.clinic)
      : super(
          ClinicLiveEvaluator.evaluate(
            clinic: clinic,
            docs: null,
            deptOf: const {},
            queueDoc: null,
          ),
        ) {
    _init();
  }

  void _init() {
    final fs = safeFirestore();
    if (fs == null) return;

    _servicesSub = fs
        .collection('services')
        .where('clinicId', isEqualTo: clinic.id)
        .snapshots()
        .listen((snap) {
          final dept = <String, String>{};
          for (final d in snap.docs) {
            final m = d.data();
            final name = (m['name'] ?? '').toString().trim().toLowerCase();
            final dep = (m['departmentName'] ?? '').toString().trim();
            if (name.isNotEmpty && dep.isNotEmpty) dept[name] = dep;
          }
          _deptOf = dept;
          _recalculate();
        });

    _queueDocSub = fs
        .collection('queues')
        .doc(clinic.id)
        .snapshots()
        .listen((snap) {
          _queueDoc = snap.data();
          _recalculate();
        });

    _ticketsSub = fs
        .collection('tickets')
        .where('clinicId', isEqualTo: clinic.id)
        .where('status', whereIn: ['called', 'waiting', 'completed'])
        .snapshots()
        .listen((snap) {
          _ticketDocs = snap.docs;
          _recalculate();
        });

    _timer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => _recalculate(),
    );
  }

  void _recalculate() {
    if (isClosed) return;
    emit(
      ClinicLiveEvaluator.evaluate(
        clinic: clinic,
        docs: _ticketDocs,
        deptOf: _deptOf,
        queueDoc: _queueDoc,
      ),
    );
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    _servicesSub?.cancel();
    _queueDocSub?.cancel();
    _ticketsSub?.cancel();
    return super.close();
  }
}
