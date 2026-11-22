import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/patient_payment_item_entity.dart';
import '../../../domain/repositories/profile_repository.dart';

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

  // KPI Calculations
  List<PatientPaymentItemEntity> get paidPayments =>
      allPayments.where((p) => p.isPaid).toList();

  List<PatientPaymentItemEntity> get refundedPayments =>
      allPayments.where((p) => p.isRefunded).toList();

  List<PatientPaymentItemEntity> get queuePayments =>
      allPayments.where((p) => p.isQueueToken).toList();

  List<PatientPaymentItemEntity> get apptPayments =>
      allPayments.where((p) => !p.isQueueToken).toList();

  double get totalPaid =>
      paidPayments.fold(0.0, (sum, p) => sum + p.amount);

  double get totalRefunded =>
      refundedPayments.fold(0.0, (sum, p) => sum + p.amount);

  int get queueTokensCount => queuePayments.length;

  // Compatibility getters for legacy widgets
  List<PatientPaymentItemEntity> get payments => allPayments;
  double get totalSpent => totalPaid;

  // Filtered List
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
      activeQueueClinicName: activeQueueClinicName ?? this.activeQueueClinicName,
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

class PaymentHistoryCubit extends Cubit<PaymentHistoryState> {
  final ProfileRepository repository;

  PaymentHistoryCubit(this.repository, {List<PatientPaymentItemEntity>? initialPayments})
      : super(PaymentHistoryState(
          isLoading: initialPayments == null,
          allPayments: initialPayments ?? const [],
        )) {
    if (initialPayments == null) {
      load();
    }
  }

  Future<void> load() async {
    emit(state.copyWith(isLoading: true));
    try {
      final items = await repository.getPaymentHistory();
      final queueItems = await repository.getQueueHistory();
      final activeTicket = queueItems.where((q) => q.isActive).firstOrNull;

      if (isClosed) return;
      emit(state.copyWith(
        isLoading: false,
        allPayments: items,
        activeQueueToken: activeTicket?.token,
        activeQueueClinicName: activeTicket?.clinicName,
      ));
    } catch (_) {
      if (isClosed) return;
      emit(state.copyWith(isLoading: false));
    }
  }

  void setFilter(String filter) {
    emit(state.copyWith(activeFilter: filter));
  }

  void setSearchQuery(String query) {
    emit(state.copyWith(searchQuery: query));
  }

  void resetFilters() {
    emit(state.copyWith(activeFilter: 'all', searchQuery: ''));
  }
}
