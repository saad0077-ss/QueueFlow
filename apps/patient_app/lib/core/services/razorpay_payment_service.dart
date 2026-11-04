import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:patient_app/core/constants/payment_constants.dart';
import 'package:patient_app/features/booking/domain/entities/payment_info_entity.dart';
import 'package:patient_app/features/booking/presentation/widgets/razorpay_checkout_dialog.dart';

/// Callback type when payment succeeds
typedef PaymentSuccessCallback = void Function(PaymentInfoEntity paymentInfo);

/// Callback type when payment fails or is dismissed
typedef PaymentFailureCallback = void Function(String errorMessage, int? errorCode);

/// Callback type when an external wallet is chosen
typedef ExternalWalletCallback = void Function(String walletName);

/// Production-ready service managing Razorpay checkout in Test Mode
class RazorpayPaymentService {
  Razorpay? _razorpay;

  RazorpayPaymentService({Razorpay? razorpayClient}) : _razorpay = razorpayClient;

  PaymentSuccessCallback? _activeSuccessCallback;
  PaymentFailureCallback? _activeFailureCallback;
  ExternalWalletCallback? _activeWalletCallback;
  double _activeAmount = 0.0;

  bool get isSupportedNativePlatform =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  /// Initializes event listeners for Razorpay Native Checkout
  void initialize() {
    if (isSupportedNativePlatform && _razorpay == null) {
      _razorpay = Razorpay();
      _razorpay!.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handleNativePaymentSuccess);
      _razorpay!.on(Razorpay.EVENT_PAYMENT_ERROR, _handleNativePaymentError);
      _razorpay!.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleNativeExternalWallet);
    }
  }

  /// Cleans up listeners and resources
  void dispose() {
    try {
      _razorpay?.clear();
    } catch (_) {}
    _razorpay = null;
    _activeSuccessCallback = null;
    _activeFailureCallback = null;
    _activeWalletCallback = null;
  }

  /// Initiates payment checkout using Razorpay Test Mode with API Key:
  /// `rzp_test_TvpkxpdWERWihB`
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

    if (isSupportedNativePlatform) {
      initialize();

      // Normalize phone number (digits only or default test phone)
      final cleanPhone = patientPhone.replaceAll(RegExp(r'[^0-9+]'), '');
      final prefillPhone = cleanPhone.isNotEmpty ? cleanPhone : '9876543210';
      final prefillEmail =
          patientEmail.trim().isNotEmpty ? patientEmail.trim() : 'test.patient@queueflow.in';
      final prefillName =
          patientName.trim().isNotEmpty ? patientName.trim() : 'QueueFlow Patient';

      // Amount in paise (1 INR = 100 paise)
      final amountInPaise = (amount * 100).round();

      final options = <String, dynamic>{
        'key': RazorpayConstants.keyId,
        'amount': amountInPaise,
        'name': RazorpayConstants.merchantName,
        'description': '$bookingTitle • $bookingRef',
        'currency': RazorpayConstants.currency,
        'timeout': 300,
        'prefill': {
          'contact': prefillPhone,
          'email': prefillEmail,
          'name': prefillName,
        },
        'notes': {
          'bookingRef': bookingRef,
          'clinicName': clinicName,
          'env': 'test_mode',
          'gateway': 'razorpay',
        },
        'theme': {
          'color': RazorpayConstants.themeColor,
        },
      };

      try {
        _razorpay!.open(options);
        return;
      } catch (e) {
        debugPrint('[RazorpayPaymentService] Native open failed: $e, falling back to modal UI');
      }
    }

    // Fallback for Web/Desktop environments or simulator fallbacks
    if (context.mounted) {
      await RazorpayCheckoutDialog.show(
        context,
        title: bookingTitle,
        orderRef: bookingRef,
        amount: amount,
        onSuccess: (paymentInfo) {
          _activeSuccessCallback?.call(paymentInfo);
        },
      );
    }
  }

  void _handleNativePaymentSuccess(PaymentSuccessResponse response) {
    final now = DateTime.now();
    final timeStr =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    final payment = PaymentInfoEntity(
      paymentId: response.paymentId ?? 'pay_${DateTime.now().millisecondsSinceEpoch}',
      status: 'paid',
      gateway: 'Razorpay (Test Mode)',
      amount: _activeAmount,
      method: 'Razorpay Test Checkout',
      paidAt: timeStr,
    );

    _activeSuccessCallback?.call(payment);
  }

  void _handleNativePaymentError(PaymentFailureResponse response) {
    final msg = response.message ?? 'Payment failed or cancelled.';
    final code = response.code;
    _activeFailureCallback?.call(msg, code);
  }

  void _handleNativeExternalWallet(ExternalWalletResponse response) {
    final wallet = response.walletName ?? 'External Wallet';
    if (_activeWalletCallback != null) {
      _activeWalletCallback!(wallet);
    } else {
      // Default handling: treat as selected wallet
      final now = DateTime.now();
      final timeStr =
          '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

      final payment = PaymentInfoEntity(
        paymentId: 'wallet_${DateTime.now().millisecondsSinceEpoch}',
        status: 'paid',
        gateway: 'Razorpay Wallet ($wallet)',
        amount: _activeAmount,
        method: wallet,
        paidAt: timeStr,
      );
      _activeSuccessCallback?.call(payment);
    }
  }
}
