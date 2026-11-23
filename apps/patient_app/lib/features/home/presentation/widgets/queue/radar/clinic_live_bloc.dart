import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../domain/entities/clinic_entity.dart';
import '../models/live_clinic_queue_info.dart';
import '../utils/queue_helpers.dart';
import 'clinic_live_evaluator.dart';

abstract class ClinicLiveEvent extends Equatable {
  const ClinicLiveEvent();
  @override
  List<Object?> get props => [];
}

class RecalculateClinicLiveEvent extends ClinicLiveEvent {
  const RecalculateClinicLiveEvent();
}

class ServicesUpdatedEvent extends ClinicLiveEvent {
  final Map<String, String> deptOf;
  const ServicesUpdatedEvent(this.deptOf);
  @override
  List<Object?> get props => [deptOf];
}

class QueueDocUpdatedEvent extends ClinicLiveEvent {
  final Map<String, dynamic>? queueDoc;
  const QueueDocUpdatedEvent(this.queueDoc);
  @override
  List<Object?> get props => [queueDoc];
}

class TicketsUpdatedEvent extends ClinicLiveEvent {
  final List<QueryDocumentSnapshot<Map<String, dynamic>>> docs;
  const TicketsUpdatedEvent(this.docs);
  @override
  List<Object?> get props => [docs];
}

class ClinicLiveBloc extends Bloc<ClinicLiveEvent, LiveInfo> {
  final ClinicEntity clinic;
  StreamSubscription? _servicesSub;
  StreamSubscription? _queueDocSub;
  StreamSubscription? _ticketsSub;
  Timer? _timer;

  List<QueryDocumentSnapshot<Map<String, dynamic>>>? _ticketDocs;
  Map<String, String> _deptOf = const {};
  Map<String, dynamic>? _queueDoc;

  ClinicLiveBloc(this.clinic)
    : super(
        ClinicLiveEvaluator.evaluate(
          clinic: clinic,
          docs: null,
          deptOf: const {},
          queueDoc: null,
        ),
      ) {
    on<RecalculateClinicLiveEvent>((event, emit) {
      emit(
        ClinicLiveEvaluator.evaluate(
          clinic: clinic,
          docs: _ticketDocs,
          deptOf: _deptOf,
          queueDoc: _queueDoc,
        ),
      );
    });

    on<ServicesUpdatedEvent>((event, emit) {
      _deptOf = event.deptOf;
      emit(
        ClinicLiveEvaluator.evaluate(
          clinic: clinic,
          docs: _ticketDocs,
          deptOf: _deptOf,
          queueDoc: _queueDoc,
        ),
      );
    });

    on<QueueDocUpdatedEvent>((event, emit) {
      _queueDoc = event.queueDoc;
      emit(
        ClinicLiveEvaluator.evaluate(
          clinic: clinic,
          docs: _ticketDocs,
          deptOf: _deptOf,
          queueDoc: _queueDoc,
        ),
      );
    });

    on<TicketsUpdatedEvent>((event, emit) {
      _ticketDocs = event.docs;
      emit(
        ClinicLiveEvaluator.evaluate(
          clinic: clinic,
          docs: _ticketDocs,
          deptOf: _deptOf,
          queueDoc: _queueDoc,
        ),
      );
    });

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
          if (!isClosed) add(ServicesUpdatedEvent(dept));
        });

    _queueDocSub = fs.collection('queues').doc(clinic.id).snapshots().listen((
      snap,
    ) {
      if (!isClosed) add(QueueDocUpdatedEvent(snap.data()));
    });

    _ticketsSub = fs
        .collection('tickets')
        .where('clinicId', isEqualTo: clinic.id)
        .where('status', whereIn: ['called', 'waiting', 'completed'])
        .snapshots()
        .listen((snap) {
          if (!isClosed) add(TicketsUpdatedEvent(snap.docs));
        });

    _timer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (!isClosed) add(const RecalculateClinicLiveEvent());
    });
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
