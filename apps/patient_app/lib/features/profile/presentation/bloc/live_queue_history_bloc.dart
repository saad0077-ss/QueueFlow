import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/patient_queue_history_entity.dart';
import '../../domain/repositories/profile_repository.dart';

abstract class LiveQueueHistoryEvent extends Equatable {
  const LiveQueueHistoryEvent();
  @override
  List<Object?> get props => [];
}

class LoadLiveQueueHistoryEvent extends LiveQueueHistoryEvent {
  const LoadLiveQueueHistoryEvent();
}

class LiveQueueHistoryUpdatedEvent extends LiveQueueHistoryEvent {
  final List<PatientQueueHistoryEntity> queues;
  const LiveQueueHistoryUpdatedEvent(this.queues);
  @override
  List<Object?> get props => [queues];
}

class SetLiveQueueHistoryFilterEvent extends LiveQueueHistoryEvent {
  final int filterIndex;
  const SetLiveQueueHistoryFilterEvent(this.filterIndex);
  @override
  List<Object?> get props => [filterIndex];
}

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
    final served = allQueues
        .where((q) => !q.isActive && q.waitTime != null)
        .toList();
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

class LiveQueueHistoryBloc
    extends Bloc<LiveQueueHistoryEvent, LiveQueueHistoryState> {
  final ProfileRepository repository;
  StreamSubscription<List<PatientQueueHistoryEntity>>? _sub;

  LiveQueueHistoryBloc(this.repository)
    : super(
        const LiveQueueHistoryState(
          isLoading: true,
          allQueues: [],
          filterIndex: 0,
        ),
      ) {
    on<LoadLiveQueueHistoryEvent>(_onLoad);
    on<LiveQueueHistoryUpdatedEvent>((event, emit) {
      emit(state.copyWith(allQueues: event.queues, isLoading: false));
    });
    on<SetLiveQueueHistoryFilterEvent>((event, emit) {
      emit(state.copyWith(filterIndex: event.filterIndex));
    });

    _init();
  }

  void _init() {
    add(const LoadLiveQueueHistoryEvent());
    _sub = repository.watchQueueHistory().listen((list) {
      if (!isClosed) add(LiveQueueHistoryUpdatedEvent(list));
    }, onError: (_) {});
  }

  Future<void> _onLoad(
    LoadLiveQueueHistoryEvent event,
    Emitter<LiveQueueHistoryState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));
    final items = await repository.getQueueHistory();
    if (!isClosed) emit(state.copyWith(allQueues: items, isLoading: false));
  }

  void load() => add(const LoadLiveQueueHistoryEvent());
  void setFilter(int index) => add(SetLiveQueueHistoryFilterEvent(index));

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
