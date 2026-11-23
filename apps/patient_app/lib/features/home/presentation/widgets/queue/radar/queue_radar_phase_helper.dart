import 'package:flutter/material.dart';

import '../models/live_clinic_queue_info.dart';

class QueueRadarPhaseHelper {
  const QueueRadarPhaseHelper._();

  static String phaseLabel(LiveInfo info) {
    return switch (info.phase) {
      LiveQueuePhase.idle => 'No queue',
      LiveQueuePhase.onBreak => 'On break',
      LiveQueuePhase.closed => 'Closed',
      LiveQueuePhase.serving ||
      LiveQueuePhase.between => '${info.waiting} waiting',
      LiveQueuePhase.upcoming => 'Upcoming',
    };
  }

  static (IconData, String) phaseNotice(LiveInfo info) {
    return switch (info.phase) {
      LiveQueuePhase.idle => (
        Icons.people_outline_rounded,
        'No patients in queue yet',
      ),
      LiveQueuePhase.onBreak => (
        Icons.free_breakfast_outlined,
        'On break · queue resumes at ${info.breakEnd}',
      ),
      LiveQueuePhase.closed => (
        Icons.check_circle_outline_rounded,
        'Queue closed · all patients seen',
      ),
      LiveQueuePhase.between => (
        Icons.hourglass_bottom_rounded,
        'Next patient will be called shortly',
      ),
      _ => (Icons.schedule_rounded, 'Upcoming · consulting not started'),
    };
  }
}
