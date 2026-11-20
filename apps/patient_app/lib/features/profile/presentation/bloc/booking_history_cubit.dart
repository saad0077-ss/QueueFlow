import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../booking/domain/entities/appointment_entity.dart';
import '../../../booking/domain/repositories/booking_repository.dart';

class BookingHistoryState extends Equatable {
  final bool isLoading;
  final List<AppointmentEntity> allAppointments;
  final int filterIndex; // 0: All, 1: Completed, 2: Upcoming, 3: Cancelled
  final String searchQuery;

  const BookingHistoryState({
    required this.isLoading,
    required this.allAppointments,
    required this.filterIndex,
    required this.searchQuery,
  });

  List<AppointmentEntity> get filteredAppointments {
    List<AppointmentEntity> list = allAppointments;

    if (filterIndex == 1) {
      list = list.where((a) => a.isCompleted).toList();
    } else if (filterIndex == 2) {
      list = list.where((a) => a.isUpcoming).toList();
    } else if (filterIndex == 3) {
      list = list.where((a) => a.isCancelled).toList();
    }

    if (searchQuery.trim().isNotEmpty) {
      final q = searchQuery.trim().toLowerCase();
      list = list.where((a) {
        return a.clinicName.toLowerCase().contains(q) ||
            a.serviceName.toLowerCase().contains(q) ||
            a.doctorName.toLowerCase().contains(q) ||
            a.bookingRef.toLowerCase().contains(q);
      }).toList();
    }

    return list;
  }

  int get totalVisits => allAppointments.length;
  int get completedCount => allAppointments.where((a) => a.isCompleted).length;
  int get upcomingCount => allAppointments.where((a) => a.isUpcoming).length;

  BookingHistoryState copyWith({
    bool? isLoading,
    List<AppointmentEntity>? allAppointments,
    int? filterIndex,
    String? searchQuery,
  }) {
    return BookingHistoryState(
      isLoading: isLoading ?? this.isLoading,
      allAppointments: allAppointments ?? this.allAppointments,
      filterIndex: filterIndex ?? this.filterIndex,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        allAppointments,
        filterIndex,
        searchQuery,
      ];
}

class BookingHistoryCubit extends Cubit<BookingHistoryState> {
  final BookingRepository repository;
  StreamSubscription<List<AppointmentEntity>>? _sub;

  BookingHistoryCubit(this.repository)
      : super(const BookingHistoryState(
          isLoading: true,
          allAppointments: [],
          filterIndex: 0,
          searchQuery: '',
        )) {
    _init();
  }

  void _init() {
    load();
    _sub = repository.watchUserAppointments().listen((list) {
      if (isClosed) return;
      emit(state.copyWith(allAppointments: list, isLoading: false));
    }, onError: (_) {});
  }

  Future<void> load() async {
    emit(state.copyWith(isLoading: true));
    final items = await repository.getUserAppointments();
    if (isClosed) return;
    emit(state.copyWith(allAppointments: items, isLoading: false));
  }

  void setFilter(int index) {
    emit(state.copyWith(filterIndex: index));
  }

  void setSearchQuery(String query) {
    emit(state.copyWith(searchQuery: query));
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
