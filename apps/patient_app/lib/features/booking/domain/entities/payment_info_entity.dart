import 'package:equatable/equatable.dart';

class PaymentInfoEntity extends Equatable {
  final String paymentId;
  final String status;
  final String gateway;
  final double amount;
  final String method;
  final String paidAt;

  const PaymentInfoEntity({
    required this.paymentId,
    this.status = 'paid',
    this.gateway = 'Razorpay (Test Mode)',
    required this.amount,
    required this.method,
    required this.paidAt,
  });

  String get formattedAmount => '₹${amount.toStringAsFixed(2)}';

  Map<String, dynamic> toMap() {
    return {
      'paymentId': paymentId,
      'status': status,
      'gateway': gateway,
      'amount': amount,
      'method': method,
      'paidAt': paidAt,
    };
  }

  factory PaymentInfoEntity.fromMap(Map<String, dynamic> map) {
    return PaymentInfoEntity(
      paymentId: (map['paymentId'] ?? '').toString(),
      status: (map['status'] ?? 'paid').toString(),
      gateway: (map['gateway'] ?? 'Razorpay (Test Mode)').toString(),
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      method: (map['method'] ?? 'UPI / Sandbox').toString(),
      paidAt: (map['paidAt'] ?? '').toString(),
    );
  }

  @override
  List<Object?> get props => [
        paymentId,
        status,
        gateway,
        amount,
        method,
        paidAt,
      ];
}
