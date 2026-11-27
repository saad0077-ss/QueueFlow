import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:patient_app/features/booking/domain/entities/appointment_entity.dart';
import 'package:patient_app/features/home/data/models/clinic_model.dart';
import 'package:patient_app/features/home/domain/entities/clinic_entity.dart';
import 'package:patient_app/features/home/presentation/widgets/queue/utils/queue_helpers.dart';

import '../../../domain/utils/booking_queue_access_evaluator.dart';

/// Streams the clinic schedule and live queue state so the queue CTA updates
/// automatically the moment consultation day operating hours start or the
/// clinic admin opens/pauses the queue.
class BookingQueueAvailabilityBuilder extends StatefulWidget {
  final AppointmentEntity appointment;
  final ClinicEntity? overrideClinic;
  final Map<String, dynamic>? overrideQueueDoc;
  final DateTime? currentTime;
  final Widget Function(BuildContext context, BookingQueueAccessResult access)
      builder;

  const BookingQueueAvailabilityBuilder({
    super.key,
    required this.appointment,
    required this.builder,
    this.overrideClinic,
    this.overrideQueueDoc,
    this.currentTime,
  });

  @override
  State<BookingQueueAvailabilityBuilder> createState() =>
      _BookingQueueAvailabilityBuilderState();
}

class _BookingQueueAvailabilityBuilderState
    extends State<BookingQueueAvailabilityBuilder> {
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _clinicSub;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _queueSub;
  Timer? _timer;
  ClinicEntity? _clinic;
  Map<String, dynamic>? _queueDoc;

  @override
  void initState() {
    super.initState();
    _subscribe();
    _timer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void didUpdateWidget(covariant BookingQueueAvailabilityBuilder oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.appointment.clinicId != widget.appointment.clinicId ||
        oldWidget.appointment.status != widget.appointment.status ||
        oldWidget.overrideClinic != widget.overrideClinic) {
      _cancelSubs();
      _clinic = null;
      _queueDoc = null;
      _subscribe();
    }
  }

  void _subscribe() {
    if (widget.overrideClinic != null ||
        !widget.appointment.isUpcoming ||
        widget.appointment.clinicId.isEmpty) {
      return;
    }
    final fs = safeFirestore();
    if (fs == null) return;

    final cid = widget.appointment.clinicId;
    _clinicSub = fs.collection('clinics').doc(cid).snapshots().listen((snap) {
      if (!mounted) return;
      setState(() {
        _clinic = snap.exists ? ClinicModel.fromFirestore(snap) : null;
      });
    }, onError: (_) {});

    _queueSub = fs.collection('queues').doc(cid).snapshots().listen((snap) {
      if (!mounted) return;
      setState(() => _queueDoc = snap.data());
    }, onError: (_) {});
  }

  void _cancelSubs() {
    _clinicSub?.cancel();
    _queueSub?.cancel();
    _clinicSub = null;
    _queueSub = null;
  }

  @override
  void dispose() {
    _timer?.cancel();
    _cancelSubs();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final access = BookingQueueAccessEvaluator.evaluate(
      appointment: widget.appointment,
      clinic: widget.overrideClinic ?? _clinic,
      queueDoc: widget.overrideQueueDoc ?? _queueDoc,
      currentTime: widget.currentTime,
    );
    return widget.builder(context, access);
  }
}
