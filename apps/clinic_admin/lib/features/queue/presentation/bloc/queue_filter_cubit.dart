import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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

class QueueFilterCubit extends Cubit<QueueFilterState> {
  QueueFilterCubit({
    required String initialDepartment,
    required String initialStatus,
    required String initialSort,
  }) : super(
         QueueFilterState(
           department: initialDepartment,
           status: initialStatus,
           sort: initialSort,
         ),
       );

  void setDepartment(String department) {
    emit(state.copyWith(department: department));
  }

  void setStatus(String status) {
    emit(state.copyWith(status: status));
  }

  void setSort(String sort) {
    emit(state.copyWith(sort: sort));
  }

  void reset() {
    emit(
      const QueueFilterState(
        department: 'all',
        status: 'all',
        sort: 'default',
      ),
    );
  }
}
