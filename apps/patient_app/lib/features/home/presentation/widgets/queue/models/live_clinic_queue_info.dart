enum LiveQueuePhase { idle, upcoming, serving, between, closed, onBreak }

class LiveServiceQueue {
  final String department;
  final String service;
  final int waiting;
  final bool serving;
  final String servingToken;
  final bool completedToday;

  const LiveServiceQueue({
    required this.department,
    required this.service,
    required this.waiting,
    required this.serving,
    this.servingToken = '',
    this.completedToday = false,
  });

  LiveServiceQueue withCompletedToday() => LiveServiceQueue(
    department: department,
    service: service,
    waiting: waiting,
    serving: serving,
    servingToken: servingToken,
    completedToday: true,
  );

  LiveInfo toInfo(LiveInfo clinic) {
    final LiveQueuePhase phase;
    if (clinic.phase == LiveQueuePhase.onBreak) {
      phase = LiveQueuePhase.onBreak;
    } else if (serving) {
      phase = LiveQueuePhase.serving;
    } else if (completedToday) {
      phase = LiveQueuePhase.between;
    } else {
      phase = LiveQueuePhase.upcoming;
    }
    return LiveInfo(
      phase,
      serving: servingToken,
      waiting: waiting,
      breakEnd: clinic.breakEnd,
      liveQueues: [this],
    );
  }
}

class LiveInfo {
  final LiveQueuePhase phase;
  final String serving;
  final int waiting;
  final String breakEnd;
  final List<LiveServiceQueue> liveQueues;
  final bool hidden;

  const LiveInfo(
    this.phase, {
    this.serving = '',
    this.waiting = 0,
    this.breakEnd = '',
    this.liveQueues = const [],
    this.hidden = false,
  });
}
