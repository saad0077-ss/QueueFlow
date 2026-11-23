import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/patient_payment_item_entity.dart';
import '../../../domain/repositories/profile_repository.dart';

abstract class PaymentHistoryEvent extends Equatable {
  const PaymentHistoryEvent();
  @override
  List<Object?> get props => [];
}

class LoadPaymentHistoryEvent extends PaymentHistoryEvent {
  const LoadPaymentHistoryEvent();
}

class SetPaymentHistoryFilterEvent extends PaymentHistoryEvent {
  final String filter;
  const SetPaymentHistoryFilterEvent(this.filter);
  @override
  List<Object?> get props => [filter];
}

class SetPaymentHistorySearchEvent extends PaymentHistoryEvent {
  final String query;
  const SetPaymentHistorySearchEvent(this.query);
  @override
  List<Object?> get props => [query];
}

class ResetPaymentHistoryFiltersEvent extends PaymentHistoryEvent {
  const ResetPaymentHistoryFiltersEvent();
}

class PaymentHistoryState extends Equatable {
  final bool isLoading;
  final List<PatientPaymentItemEntity> allPayments;
  final String activeFilter; // 'all', 'queue', 'appointment', 'refunded'
  final String searchQuery;
  final String? activeQueueToken;
  final String? activeQueueClinicName;

  const PaymentHistoryState({
    required this.isLoading,
    required this.allPayments,
    this.activeFilter = 'all',
    this.searchQuery = '',
    this.activeQueueToken,
    this.activeQueueClinicName,
  });

  List<PatientPaymentItemEntity> get paidPayments =>
      allPayments.where((p) => p.isPaid).toList();
  List<PatientPaymentItemEntity> get refundedPayments =>
      allPayments.where((p) => p.isRefunded).toList();
  List<PatientPaymentItemEntity> get queuePayments =>
      allPayments.where((p) => p.isQueueToken).toList();
  List<PatientPaymentItemEntity> get apptPayments =>
      allPayments.where((p) => !p.isQueueToken).toList();

  double get totalPaid => paidPayments.fold(0.0, (sum, p) => sum + p.amount);
  double get totalRefunded =>
      refundedPayments.fold(0.0, (sum, p) => sum + p.amount);
  int get queueTokensCount => queuePayments.length;
  List<PatientPaymentItemEntity> get payments => allPayments;
  double get totalSpent => totalPaid;

  List<PatientPaymentItemEntity> get filteredPayments {
    var list = allPayments;
    if (activeFilter == 'queue') {
      list = queuePayments;
    } else if (activeFilter == 'appointment') {
      list = apptPayments;
    } else if (activeFilter == 'refunded') {
      list = refundedPayments;
    }

    final q = searchQuery.trim().toLowerCase();
    if (q.isNotEmpty) {
      list = list.where((p) {
        return p.receiptNo.toLowerCase().contains(q) ||
            p.clinicName.toLowerCase().contains(q) ||
            p.doctor.toLowerCase().contains(q) ||
            p.service.toLowerCase().contains(q) ||
            (p.token?.toLowerCase().contains(q) ?? false) ||
            p.bookingId.toLowerCase().contains(q) ||
            p.method.toLowerCase().contains(q) ||
            p.transactionId.toLowerCase().contains(q);
      }).toList();
    }
    return list;
  }

  PaymentHistoryState copyWith({
    bool? isLoading,
    List<PatientPaymentItemEntity>? allPayments,
    String? activeFilter,
    String? searchQuery,
    String? activeQueueToken,
    String? activeQueueClinicName,
  }) {
    return PaymentHistoryState(
      isLoading: isLoading ?? this.isLoading,
      allPayments: allPayments ?? this.allPayments,
      activeFilter: activeFilter ?? this.activeFilter,
      searchQuery: searchQuery ?? this.searchQuery,
      activeQueueToken: activeQueueToken ?? this.activeQueueToken,
      activeQueueClinicName:
          activeQueueClinicName ?? this.activeQueueClinicName,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    allPayments,
    activeFilter,
    searchQuery,
    activeQueueToken,
    activeQueueClinicName,
  ];
}

class PaymentHistoryBloc
    extends Bloc<PaymentHistoryEvent, PaymentHistoryState> {
  final ProfileRepository repository;

  PaymentHistoryBloc(
    this.repository, {
    List<PatientPaymentItemEntity>? initialPayments,
  }) : super(
         PaymentHistoryState(
           isLoading: initialPayments == null,
           allPayments: initialPayments ?? const [],
         ),
       ) {
    on<LoadPaymentHistoryEvent>(_onLoad);
    on<SetPaymentHistoryFilterEvent>(
      (event, emit) => emit(state.copyWith(activeFilter: event.filter)),
    );
    on<SetPaymentHistorySearchEvent>(
      (event, emit) => emit(state.copyWith(searchQuery: event.query)),
    );
    on<ResetPaymentHistoryFiltersEvent>(
      (event, emit) =>
          emit(state.copyWith(activeFilter: 'all', searchQuery: '')),
    );

    if (initialPayments == null) add(const LoadPaymentHistoryEvent());
  }

  Future<void> _onLoad(
    LoadPaymentHistoryEvent event,
    Emitter<PaymentHistoryState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));
    try {
      final items = await repository.getPaymentHistory();
      final queueItems = await repository.getQueueHistory();
      final activeTicket = queueItems.where((q) => q.isActive).firstOrNull;
      if (!isClosed) {
        emit(
          state.copyWith(
            isLoading: false,
            allPayments: items,
            activeQueueToken: activeTicket?.token,
            activeQueueClinicName: activeTicket?.clinicName,
          ),
        );
      }
    } catch (_) {
      if (!isClosed) emit(state.copyWith(isLoading: false));
    }
  }

  void load() => add(const LoadPaymentHistoryEvent());
  void setFilter(String filter) => add(SetPaymentHistoryFilterEvent(filter));
  void setSearchQuery(String query) => add(SetPaymentHistorySearchEvent(query));
  void resetFilters() => add(const ResetPaymentHistoryFiltersEvent());
}
