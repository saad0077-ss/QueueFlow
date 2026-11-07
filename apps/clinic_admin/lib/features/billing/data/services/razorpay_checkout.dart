import 'dart:async';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';

/// Razorpay test-mode credentials (public key id only; the secret never
/// belongs in a client app).
class RazorpayConfig {
  RazorpayConfig._();
  static const keyId = 'rzp_test_TvpkxpdWERWihB';
  static const merchantName = 'QueueFlow';
  static const currency = 'INR';
  static const themeColor = '#2563EB';
}

/// Outcome of a Razorpay checkout session.
class RazorpayResult {
  final bool success;
  final String? paymentId;
  final String? message;

  const RazorpayResult.success(this.paymentId) : success = true, message = null;
  const RazorpayResult.failed(this.message) : success = false, paymentId = null;
}

@JS('Razorpay')
extension type _RazorpayJs._(JSObject _) implements JSObject {
  external _RazorpayJs(JSObject options);
  external void open();
  external void on(String event, JSFunction callback);
}

/// Opens the Razorpay Checkout popup (checkout.js, loaded in web/index.html).
class RazorpayCheckout {
  RazorpayCheckout._();

  static bool get isAvailable => globalContext.has('Razorpay');

  /// [amount] is in rupees. Completes when the payment succeeds, fails or the
  /// popup is dismissed.
  static Future<RazorpayResult> pay({
    required double amount,
    required String description,
    required String reference,
    String name = '',
    String email = '',
    String phone = '',
    String clinicId = '',
  }) {
    final completer = Completer<RazorpayResult>();

    if (!isAvailable) {
      completer.complete(
        const RazorpayResult.failed(
          'Razorpay could not be loaded. Check your internet connection and retry.',
        ),
      );
      return completer.future;
    }

    void finish(RazorpayResult r) {
      if (!completer.isCompleted) completer.complete(r);
    }

    final options = JSObject();
    options['key'] = RazorpayConfig.keyId.toJS;
    options['amount'] = (amount * 100).round().toJS; // paise
    options['currency'] = RazorpayConfig.currency.toJS;
    options['name'] = RazorpayConfig.merchantName.toJS;
    options['description'] = description.toJS;

    final prefill = JSObject();
    if (name.isNotEmpty) prefill['name'] = name.toJS;
    if (email.isNotEmpty) prefill['email'] = email.toJS;
    if (phone.isNotEmpty) prefill['contact'] = phone.toJS;
    options['prefill'] = prefill;

    final notes = JSObject();
    notes['reference'] = reference.toJS;
    notes['purpose'] = 'clinic_subscription'.toJS;
    if (clinicId.isNotEmpty) notes['clinicId'] = clinicId.toJS;
    options['notes'] = notes;

    final theme = JSObject();
    theme['color'] = RazorpayConfig.themeColor.toJS;
    options['theme'] = theme;

    options['handler'] = ((JSObject response) {
      final id = response['razorpay_payment_id'];
      finish(RazorpayResult.success(id.isA<JSString>() ? (id as JSString).toDart : null));
    }).toJS;

    final modal = JSObject();
    modal['ondismiss'] = (() {
      finish(const RazorpayResult.failed('Payment cancelled.'));
    }).toJS;
    options['modal'] = modal;

    final rzp = _RazorpayJs(options);
    rzp.on(
      'payment.failed',
      ((JSObject response) {
        String msg = 'Payment failed. Please try again.';
        final err = response['error'];
        if (err.isA<JSObject>()) {
          final d = (err as JSObject)['description'];
          if (d.isA<JSString>()) msg = (d as JSString).toDart;
        }
        finish(RazorpayResult.failed(msg));
      }).toJS,
    );
    rzp.open();

    return completer.future;
  }
}
