import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/patient_payment_item_entity.dart';
import '../../../domain/repositories/profile_repository.dart';

class PaymentHistoryState extends Equatable {
  final bool isLoading;
  final List<PatientPaymentItemEntity> payments;

  const PaymentHistoryState({
    required this.isLoading,
    required this.payments,
  });

  double get totalSpent =>
      payments.where((p) => p.isPaid).fold(0.0, (sum, p) => sum + p.amount);

  PaymentHistoryState copyWith({
    bool? isLoading,
    List<PatientPaymentItemEntity>? payments,
  }) {
    return PaymentHistoryState(
      isLoading: isLoading ?? this.isLoading,
      payments: payments ?? this.payments,
    );
  }

  @override
  List<Object?> get props => [isLoading, payments];
}

class PaymentHistoryCubit extends Cubit<PaymentHistoryState> {
  final ProfileRepository repository;

  PaymentHistoryCubit(this.repository)
      : super(const PaymentHistoryState(isLoading: true, payments: [])) {
    load();
  }

  Future<void> load() async {
    emit(state.copyWith(isLoading: true));
    final items = await repository.getPaymentHistory();
    if (isClosed) return;
    emit(state.copyWith(isLoading: false, payments: items));
  }
}
