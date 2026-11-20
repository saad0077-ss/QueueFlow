import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../data/repositories/home_repository_impl.dart'
    show isTicketFromToday;
import '../../../../domain/entities/clinic_entity.dart';
import '../models/live_clinic_queue_info.dart';

class ClinicLiveEvaluator {
  const ClinicLiveEvaluator._();

  static LiveInfo evaluate({
    required ClinicEntity clinic,
    required List<QueryDocumentSnapshot<Map<String, dynamic>>>? docs,
    required Map<String, String> deptOf,
    required Map<String, dynamic>? queueDoc,
    DateTime? currentTime,
  }) {
    final now = currentTime ?? DateTime.now();
    String serving = docs == null && clinic.currentToken != '—'
        ? clinic.currentToken
        : '';
    int waiting = docs == null ? clinic.waitingCount : 0;
    bool completedToday = false;
    final queues = <String, LiveServiceQueue>{};
    final completedServices = <String>{};

    for (final d in docs ?? const <QueryDocumentSnapshot<Map<String, dynamic>>>[]) {
      final data = d.data();
      final status = data['status'];
      final service = (data['serviceName'] ?? '').toString().trim();
      final svc = service.isEmpty ? 'General Consultation' : service;
      if (status == 'completed' && isTicketFromToday(data)) {
        completedServices.add(svc.toLowerCase());
      }
      if (status == 'called' || status == 'waiting') {
        final key = svc.toLowerCase();
        final dept = (data['departmentName'] ?? deptOf[key] ?? '')
            .toString()
            .trim();
        final prev = queues[key];
        queues[key] = LiveServiceQueue(
          department: dept.isNotEmpty ? dept : (prev?.department ?? ''),
          service: svc,
          waiting: (prev?.waiting ?? 0) + (status == 'waiting' ? 1 : 0),
          serving: (prev?.serving ?? false) || status == 'called',
          servingToken: status == 'called'
              ? (data['token'] ?? '').toString().trim()
              : (prev?.servingToken ?? ''),
        );
      }
      if (status == 'called') {
        serving = (data['token'] ?? '').toString().trim();
      } else if (status == 'waiting') {
        waiting++;
      } else if (status == 'completed' && isTicketFromToday(data)) {
        completedToday = true;
      }
    }

    final today =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-'
        '${now.day.toString().padLeft(2, '0')}';
    final closedRaw = queueDoc?['closedServices'];
    final closedKeys = <String>{
      if (closedRaw is Map)
        for (final e in closedRaw.entries)
          if (e.value.toString() == today) e.key.toString().toLowerCase(),
    };
    final clinicPaused =
        queueDoc?['status'] == 'paused' || queueDoc?['isPaused'] == true;
    final hadQueues = queues.isNotEmpty;
    queues.removeWhere((key, _) => closedKeys.contains(key));
    final allServicesClosed =
        deptOf.isNotEmpty && deptOf.keys.every(closedKeys.contains);
    final hidden =
        clinicPaused || allServicesClosed || (hadQueues && queues.isEmpty);

    final liveQueues =
        queues.entries
            .map(
              (e) => completedServices.contains(e.key)
                  ? e.value.withCompletedToday()
                  : e.value,
            )
            .toList()
          ..sort((a, b) {
            final c = a.department.toLowerCase().compareTo(
              b.department.toLowerCase(),
            );
            return c != 0
                ? c
                : a.service.toLowerCase().compareTo(b.service.toLowerCase());
          });

    final breakEnd = clinic.breakEndsAt(now);
    final LiveQueuePhase phase;
    if (breakEnd != null) {
      phase = LiveQueuePhase.onBreak;
    } else if (serving.isNotEmpty) {
      phase = LiveQueuePhase.serving;
    } else if (completedToday) {
      phase = waiting > 0 ? LiveQueuePhase.between : LiveQueuePhase.closed;
    } else if (waiting > 0) {
      phase = LiveQueuePhase.upcoming;
    } else {
      phase = LiveQueuePhase.idle;
    }

    return LiveInfo(
      phase,
      serving: serving,
      waiting: waiting,
      breakEnd: breakEnd ?? '',
      liveQueues: liveQueues,
      hidden: hidden,
    );
  }
}
