/// Razorpay payment gateway configuration for QueueFlow (Test Mode)
class RazorpayConstants {
  RazorpayConstants._();

  /// Razorpay Test Key ID provided for QueueFlow integration
  static const String keyId = 'rzp_test_TvpkxpdWERWihB';

  /// Razorpay Test Key Secret (used for test signature verification / secure backend orders)
  static const String keySecret = 'ZcBuuFN24emIZiDJk7BbYT7V';

  /// Merchant Name shown in Razorpay checkout header
  static const String merchantName = 'QueueFlow';

  /// Merchant Description for appointment checkout
  static const String defaultDescription = 'Clinic Appointment Booking Fee';

  /// Default currency (INR)
  static const String currency = 'INR';

  /// Primary theme color hex matching QueueFlow branding (#0284C7)
  static const String themeColor = '#0284C7';

  /// Razorpay test card credentials for easy reference in test mode
  static const String testCardNumber = '4242 4242 4242 4242';
  static const String testCardExpiry = '12/28';
  static const String testCardCvv = '123';
  static const String testCardOtp = '123456';
  static const String testUpiVpa = 'success@razorpay';
}
