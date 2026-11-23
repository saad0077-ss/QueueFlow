import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class QueueFilterEvent extends Equatable {
  const QueueFilterEvent();
  @override
  List<Object?> get props => [];
}

class QueueFilterDepartmentChanged extends QueueFilterEvent {
  final String department;
  const QueueFilterDepartmentChanged(this.department);
  @override
  List<Object?> get props => [department];
}

class QueueFilterStatusChanged extends QueueFilterEvent {
  final String status;
  const QueueFilterStatusChanged(this.status);
  @override
  List<Object?> get props => [status];
}

class QueueFilterSortChanged extends QueueFilterEvent {
  final String sort;
  const QueueFilterSortChanged(this.sort);
  @override
  List<Object?> get props => [sort];
}

class QueueFilterResetRequested extends QueueFilterEvent {
  const QueueFilterResetRequested();
}

class QueueFilterState extends Equatable {
  final String department;
  final String status;
  final String sort;

  const QueueFilterState({
    required this.department,
    required this.status,
    required this.sort,
  });

  QueueFilterState copyWith({
    String? department,
    String? status,
    String? sort,
  }) {
    return QueueFilterState(
      department: department ?? this.department,
      status: status ?? this.status,
      sort: sort ?? this.sort,
    );
  }

  @override
  List<Object?> get props => [department, status, sort];
}

class QueueFilterBloc extends Bloc<QueueFilterEvent, QueueFilterState> {
  QueueFilterBloc({
    required String initialDepartment,
    required String initialStatus,
    required String initialSort,
  }) : super(
         QueueFilterState(
           department: initialDepartment,
           status: initialStatus,
           sort: initialSort,
         ),
       ) {
    on<QueueFilterDepartmentChanged>((event, emit) {
      emit(state.copyWith(department: event.department));
    });
    on<QueueFilterStatusChanged>((event, emit) {
      emit(state.copyWith(status: event.status));
    });
    on<QueueFilterSortChanged>((event, emit) {
      emit(state.copyWith(sort: event.sort));
    });
    on<QueueFilterResetRequested>((event, emit) {
      emit(
        const QueueFilterState(
          department: 'all',
          status: 'all',
          sort: 'default',
        ),
      );
    });
  }

  void setDepartment(String department) =>
      add(QueueFilterDepartmentChanged(department));
  void setStatus(String status) => add(QueueFilterStatusChanged(status));
  void setSort(String sort) => add(QueueFilterSortChanged(sort));
  void reset() => add(const QueueFilterResetRequested());
}
