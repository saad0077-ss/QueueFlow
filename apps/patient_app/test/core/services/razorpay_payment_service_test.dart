import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patient_app/core/constants/payment_constants.dart';
import 'package:patient_app/core/services/razorpay_payment_service.dart';
import 'package:patient_app/features/booking/domain/entities/payment_info_entity.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('razorpay_flutter'),
      (MethodCall methodCall) async {
        return null;
      },
    );
  });

  tearDownAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('razorpay_flutter'),
      null,
    );
  });

  group('RazorpayConstants Tests', () {
    test('contains valid Razorpay Test Mode credentials', () {
      expect(RazorpayConstants.keyId, equals('rzp_test_TvpkxpdWERWihB'));
      expect(RazorpayConstants.keySecret, equals('ZcBuuFN24emIZiDJk7BbYT7V'));
      expect(RazorpayConstants.currency, equals('INR'));
      expect(RazorpayConstants.merchantName, equals('QueueFlow'));
      expect(RazorpayConstants.themeColor, equals('#0284C7'));
    });
  });

  group('RazorpayPaymentService Tests', () {
    late RazorpayPaymentService service;

    setUp(() {
      service = RazorpayPaymentService();
    });

    tearDown(() {
      service.dispose();
    });

    test('initializes and disposes cleanly without throwing', () {
      expect(() => service.initialize(), returnsNormally);
      expect(() => service.dispose(), returnsNormally);
    });

    test('PaymentInfoEntity correctly maps Razorpay test payment data', () {
      const payment = PaymentInfoEntity(
        paymentId: 'pay_NwtT6LhK23r1Xp',
        status: 'paid',
        gateway: 'Razorpay (Test Mode)',
        amount: 450.0,
        method: 'Razorpay Checkout (UPI)',
        paidAt: '10:30 AM',
      );

      expect(payment.formattedAmount, equals('₹450.00'));
      expect(payment.paymentId, equals('pay_NwtT6LhK23r1Xp'));

      final map = payment.toMap();
      expect(map['paymentId'], equals('pay_NwtT6LhK23r1Xp'));
      expect(map['amount'], equals(450.0));
      expect(map['gateway'], equals('Razorpay (Test Mode)'));

      final fromMap = PaymentInfoEntity.fromMap(map);
      expect(fromMap, equals(payment));
    });
  });
}
