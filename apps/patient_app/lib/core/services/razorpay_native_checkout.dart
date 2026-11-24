import 'package:flutter/foundation.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:patient_app/core/constants/payment_constants.dart';

class RazorpayNativeCheckout {
  RazorpayNativeCheckout._();

  static Razorpay create({
    required ValueChanged<String> onSuccess,
    required void Function(String message, int? code) onError,
    required ValueChanged<String> onWallet,
  }) {
    final rzp = Razorpay();
    rzp.on(Razorpay.EVENT_PAYMENT_SUCCESS, (PaymentSuccessResponse r) {
      onSuccess(r.paymentId ?? 'pay_${DateTime.now().millisecondsSinceEpoch}');
    });
    rzp.on(Razorpay.EVENT_PAYMENT_ERROR, (PaymentFailureResponse r) {
      onError(r.message ?? 'Payment failed or cancelled.', r.code);
    });
    rzp.on(Razorpay.EVENT_EXTERNAL_WALLET, (ExternalWalletResponse r) {
      onWallet(r.walletName ?? 'External Wallet');
    });
    return rzp;
  }

  static void open({
    required Razorpay rzp,
    required double amount,
    required String bookingTitle,
    required String bookingRef,
    required String clinicName,
    required String name,
    required String email,
    required String phone,
  }) {
    final options = <String, dynamic>{
      'key': RazorpayConstants.keyId,
      'amount': (amount * 100).round(),
      'name': RazorpayConstants.merchantName,
      'description': '$bookingTitle • $bookingRef',
      'currency': RazorpayConstants.currency,
      'timeout': 300,
      'prefill': {'contact': phone, 'email': email, 'name': name},
      'notes': {
        'bookingRef': bookingRef,
        'clinicName': clinicName,
        'env': 'test_mode',
        'gateway': 'razorpay',
      },
      'theme': {'color': RazorpayConstants.themeColor},
    };
    rzp.open(options);
  }
}
