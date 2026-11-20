import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/patient_queue_history_entity.dart';
import '../../domain/repositories/profile_repository.dart';

class LiveQueueHistoryState extends Equatable {
  final bool isLoading;
  final List<PatientQueueHistoryEntity> allQueues;
  final int filterIndex; // 0: All, 1: Active, 2: Completed

  const LiveQueueHistoryState({
    required this.isLoading,
    required this.allQueues,
    required this.filterIndex,
  });

  PatientQueueHistoryEntity? get activeTicket =>
      allQueues.where((q) => q.isActive).firstOrNull;

  List<PatientQueueHistoryEntity> get filteredQueues {
    if (filterIndex == 1) {
      return allQueues.where((q) => q.isActive).toList();
    } else if (filterIndex == 2) {
      return allQueues.where((q) => !q.isActive).toList();
    }
    return allQueues;
  }

  int get totalJoined => allQueues.length;
  int get totalServed => allQueues.where((q) => !q.isActive).length;
  int get totalActive => allQueues.where((q) => q.isActive).length;

  String get avgWait {
    final served =
        allQueues.where((q) => !q.isActive && q.waitTime != null).toList();
    if (served.isEmpty) return '--';
    int totalMinutes = 0;
    int count = 0;
    for (final q in served) {
      final match = RegExp(r'(\d+)').firstMatch(q.waitTime ?? '');
      if (match != null) {
        totalMinutes += int.tryParse(match.group(1)!) ?? 0;
        count++;
      }
    }
    if (count == 0) return '--';
    return '${(totalMinutes / count).round()}m';
  }

  LiveQueueHistoryState copyWith({
    bool? isLoading,
    List<PatientQueueHistoryEntity>? allQueues,
    int? filterIndex,
  }) {
    return LiveQueueHistoryState(
      isLoading: isLoading ?? this.isLoading,
      allQueues: allQueues ?? this.allQueues,
      filterIndex: filterIndex ?? this.filterIndex,
    );
  }

  @override
  List<Object?> get props => [isLoading, allQueues, filterIndex];
}

class LiveQueueHistoryCubit extends Cubit<LiveQueueHistoryState> {
  final ProfileRepository repository;
  StreamSubscription<List<PatientQueueHistoryEntity>>? _sub;

  LiveQueueHistoryCubit(this.repository)
      : super(const LiveQueueHistoryState(
          isLoading: true,
          allQueues: [],
          filterIndex: 0,
        )) {
    _init();
  }

  void _init() {
    load();
    _sub = repository.watchQueueHistory().listen((list) {
      if (isClosed) return;
      emit(state.copyWith(allQueues: list, isLoading: false));
    }, onError: (_) {});
  }

  Future<void> load() async {
    emit(state.copyWith(isLoading: true));
    final items = await repository.getQueueHistory();
    if (isClosed) return;
    emit(state.copyWith(allQueues: items, isLoading: false));
  }

  void setFilter(int index) {
    emit(state.copyWith(filterIndex: index));
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
