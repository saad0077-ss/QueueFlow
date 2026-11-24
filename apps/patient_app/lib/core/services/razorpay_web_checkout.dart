import 'dart:async';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';
import 'package:flutter/foundation.dart';

@JS('Razorpay')
extension type _RazorpayJs._(JSObject _) implements JSObject {
  external _RazorpayJs(JSObject options);
  external void open();
  external void on(String event, JSFunction callback);
}

/// Web-specific Razorpay checkout using checkout.js in Chrome.
class RazorpayWebCheckout {
  RazorpayWebCheckout._();

  static bool get isAvailable {
    if (!kIsWeb) return false;
    try {
      return globalContext.has('Razorpay');
    } catch (_) {
      return false;
    }
  }

  static Future<String?> pay({
    required String keyId,
    required double amount,
    required String merchantName,
    required String description,
    required String currency,
    required String themeColor,
    required String prefillName,
    required String prefillEmail,
    required String prefillContact,
    required String bookingRef,
    required String clinicName,
  }) {
    final completer = Completer<String?>();

    void finish(String? paymentId) {
      if (!completer.isCompleted) {
        completer.complete(paymentId);
      }
    }

    try {
      final options = JSObject();
      options['key'] = keyId.toJS;
      options['amount'] = (amount * 100).round().toJS;
      options['currency'] = currency.toJS;
      options['name'] = merchantName.toJS;
      options['description'] = description.toJS;

      final prefill = JSObject();
      if (prefillName.isNotEmpty) prefill['name'] = prefillName.toJS;
      if (prefillEmail.isNotEmpty) prefill['email'] = prefillEmail.toJS;
      if (prefillContact.isNotEmpty) prefill['contact'] = prefillContact.toJS;
      options['prefill'] = prefill;

      final notes = JSObject();
      notes['bookingRef'] = bookingRef.toJS;
      notes['clinicName'] = clinicName.toJS;
      notes['env'] = 'test_mode'.toJS;
      options['notes'] = notes;

      final theme = JSObject();
      theme['color'] = themeColor.toJS;
      options['theme'] = theme;

      options['handler'] = ((JSObject response) {
        final id = response['razorpay_payment_id'];
        final pId = id.isA<JSString>()
            ? (id as JSString).toDart
            : 'pay_web_${DateTime.now().millisecondsSinceEpoch}';
        finish(pId);
      }).toJS;

      final modal = JSObject();
      modal['ondismiss'] = (() {
        finish(null);
      }).toJS;
      options['modal'] = modal;

      final rzp = _RazorpayJs(options);
      rzp.on(
        'payment.failed',
        ((JSObject err) {
          finish(null);
        }).toJS,
      );
      rzp.open();
    } catch (e) {
      debugPrint('[RazorpayWebCheckout] Error opening checkout.js: $e');
      if (!completer.isCompleted) completer.complete(null);
    }

    return completer.future;
  }
}
