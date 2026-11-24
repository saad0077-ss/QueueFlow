/// Stub for Razorpay Web Checkout on non-web platforms.
class RazorpayWebCheckout {
  RazorpayWebCheckout._();

  static bool get isAvailable => false;

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
  }) async {
    return null;
  }
}
