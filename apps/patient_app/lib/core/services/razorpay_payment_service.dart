import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:patient_app/core/constants/payment_constants.dart';
import 'package:patient_app/features/booking/domain/entities/payment_info_entity.dart';
import 'razorpay_native_checkout.dart';
import 'razorpay_web_checkout_stub.dart'
    if (dart.library.js_interop) 'razorpay_web_checkout.dart';
import 'razorpay_web_dialog.dart';

typedef PaymentSuccessCallback = void Function(PaymentInfoEntity paymentInfo);
typedef PaymentFailureCallback = void Function(String errorMessage, int? errorCode);
typedef ExternalWalletCallback = void Function(String walletName);

class RazorpayPaymentService {
  Razorpay? _razorpay;
  RazorpayPaymentService({Razorpay? razorpayClient}) : _razorpay = razorpayClient;

  PaymentSuccessCallback? _activeSuccessCallback;
  PaymentFailureCallback? _activeFailureCallback;
  ExternalWalletCallback? _activeWalletCallback;
  double _activeAmount = 0.0;

  bool get isSupportedPlatform =>
      kIsWeb || defaultTargetPlatform == TargetPlatform.android || defaultTargetPlatform == TargetPlatform.iOS;

  void initialize() {
    if (!kIsWeb && isSupportedPlatform && _razorpay == null) {
      _razorpay = RazorpayNativeCheckout.create(
        onSuccess: (id) => _completePayment(id, 'Razorpay Test Checkout'),
        onError: (msg, code) => _activeFailureCallback?.call(msg, code),
        onWallet: (w) => _activeWalletCallback != null
            ? _activeWalletCallback!(w)
            : _completePayment('wallet_${DateTime.now().millisecondsSinceEpoch}', 'Razorpay Wallet ($w)'),
      );
    }
  }

  void dispose() {
    try {
      _razorpay?.clear();
    } catch (_) {}
    _razorpay = null;
  }

  Future<void> openPayment({
    required BuildContext context,
    required double amount,
    required String bookingTitle,
    required String bookingRef,
    required String clinicName,
    String patientName = '',
    String patientPhone = '',
    String patientEmail = '',
    required PaymentSuccessCallback onSuccess,
    required PaymentFailureCallback onFailure,
    ExternalWalletCallback? onExternalWallet,
  }) async {
    _activeAmount = amount;
    _activeSuccessCallback = onSuccess;
    _activeFailureCallback = onFailure;
    _activeWalletCallback = onExternalWallet;

    final phone = patientPhone.replaceAll(RegExp(r'[^0-9+]'), '');
    final cleanPhone = phone.isNotEmpty ? phone : '9876543210';
    final email = patientEmail.trim().isNotEmpty ? patientEmail.trim() : 'test.patient@queueflow.in';
    final name = patientName.trim().isNotEmpty ? patientName.trim() : 'QueueFlow Patient';

    if (kIsWeb) {
      await _handleWebPay(context, amount, bookingTitle, bookingRef, clinicName, name, email, cleanPhone, onFailure);
      return;
    }
    if (isSupportedPlatform) {
      initialize();
      try {
        RazorpayNativeCheckout.open(
          rzp: _razorpay!,
          amount: amount,
          bookingTitle: bookingTitle,
          bookingRef: bookingRef,
          clinicName: clinicName,
          name: name,
          email: email,
          phone: cleanPhone,
        );
      } catch (e) {
        onFailure('Could not open Razorpay checkout. Please try again.', null);
      }
      return;
    }
    onFailure('Razorpay checkout is not supported on this platform.', null);
  }

  Future<void> _handleWebPay(
    BuildContext context,
    double amount,
    String title,
    String ref,
    String clinic,
    String name,
    String email,
    String phone,
    PaymentFailureCallback onFailure,
  ) async {
    if (RazorpayWebCheckout.isAvailable) {
      final pId = await RazorpayWebCheckout.pay(
        keyId: RazorpayConstants.keyId,
        amount: amount,
        merchantName: RazorpayConstants.merchantName,
        description: '$title • $ref',
        currency: RazorpayConstants.currency,
        themeColor: RazorpayConstants.themeColor,
        prefillName: name,
        prefillEmail: email,
        prefillContact: phone,
        bookingRef: ref,
        clinicName: clinic,
      );
      pId != null ? _completePayment(pId, 'Razorpay Web Checkout') : onFailure('Payment cancelled by user.', null);
      return;
    }
    if (context.mounted) {
      final ok = await RazorpayWebDialog.showFallback(
        context: context,
        amount: amount,
        clinicName: clinic,
        bookingTitle: title,
      );
      ok
          ? _completePayment('pay_web_${DateTime.now().millisecondsSinceEpoch}', 'Razorpay Test Sandbox')
          : onFailure('Payment cancelled.', null);
    }
  }

  void _completePayment(String paymentId, String method) {
    final now = DateTime.now();
    final timeStr = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    _activeSuccessCallback?.call(PaymentInfoEntity(
      paymentId: paymentId,
      status: 'paid',
      gateway: 'Razorpay (Test Mode)',
      amount: _activeAmount,
      method: method,
      paidAt: timeStr,
    ));
  }
}
