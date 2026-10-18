import 'package:equatable/equatable.dart';

/// Domain entity representing the live patient queue state.
class ClinicQueueEntity extends Equatable {
  final String currentToken;
  final int totalIssued;
  final int waitingCount;
  final String status;
  final bool isPaused;

  const ClinicQueueEntity({
    this.currentToken = 'A-029',
    this.totalIssued = 29,
    this.waitingCount = 0,
    this.status = 'open',
    this.isPaused = false,
  });

  @override
  List<Object?> get props => [
        currentToken,
        totalIssued,
        waitingCount,
        status,
        isPaused,
      ];
}
