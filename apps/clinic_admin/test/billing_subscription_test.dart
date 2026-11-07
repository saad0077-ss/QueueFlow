import 'package:clinic_admin/features/billing/data/services/billing_receipt_pdf.dart';
import 'package:clinic_admin/features/billing/domain/billing_dates.dart';
import 'package:clinic_admin/features/billing/domain/entities/billing_invoice_entity.dart';
import 'package:clinic_admin/features/billing/domain/entities/clinic_subscription_entity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('subscription lock', () {
    test('active period is locked, not expired', () {
      final sub = ClinicSubscriptionEntity(
        periodStartAt: DateTime.now().subtract(const Duration(days: 5)),
        periodEndAt: DateTime.now().add(const Duration(days: 25)),
      );
      expect(sub.isPlanLocked, isTrue);
      expect(sub.isPlanExpired, isFalse);
    });

    test('ended period unlocks plan changes', () {
      final sub = ClinicSubscriptionEntity(
        periodStartAt: DateTime.now().subtract(const Duration(days: 31)),
        periodEndAt: DateTime.now().subtract(const Duration(days: 1)),
      );
      expect(sub.isPlanLocked, isFalse);
      expect(sub.isPlanExpired, isTrue);
    });

    test('no recorded period (legacy clinic) is neither locked nor expired', () {
      const sub = ClinicSubscriptionEntity();
      expect(sub.isPlanLocked, isFalse);
      expect(sub.isPlanExpired, isFalse);
    });
  });

  group('date helpers', () {
    test('formats dates', () {
      expect(formatBillingDate(DateTime(2026, 11, 7)), '7 Nov 2026');
      expect(formatBillingDateTime(DateTime(2026, 11, 7, 14, 5)), '7 Nov 2026, 02:05 PM');
    });

    test('remaining time', () {
      expect(formatRemaining(DateTime.now().subtract(const Duration(minutes: 1))), 'Expired');
      expect(formatRemaining(DateTime.now().add(const Duration(days: 10, hours: 1))), '11 days left');
      expect(formatRemaining(DateTime.now().add(const Duration(hours: 5, minutes: 30))), '5 hours left');
    });
  });

  test('receipt PDF is generated with all fields', () async {
    final inv = BillingInvoiceEntity(
      id: 'pay_TEST1234',
      number: 'QF-RCPT-202611-TEST1234',
      clinicId: 'c1',
      clinic: 'Green Heaven Clinic',
      plan: 'Multi-Doctor Clinic Plan',
      amount: '₹2999',
      due: '7 Nov 2026',
      date: '7 Nov 2026',
      status: 'completed',
      method: 'UPI',
      paymentId: 'pay_TEST1234',
      customerName: 'Green Heaven Clinic',
      customerEmail: 'admin@example.com',
      billingCycle: 'monthly',
      subtotal: 2999,
      tax: 0,
      paidAt: DateTime(2026, 11, 7, 14, 5),
      startAt: DateTime(2026, 11, 7, 14, 5),
      endAt: DateTime(2026, 12, 7, 14, 5),
    );
    final bytes = await BillingReceiptPdf.build(inv);
    expect(bytes.length, greaterThan(1500));
    expect(String.fromCharCodes(bytes.take(5)), '%PDF-');
  });

  test('receipt PDF tolerates legacy invoices with missing fields', () async {
    const inv = BillingInvoiceEntity(
      id: 'x', number: 'QF-INV-2026-001', clinicId: '', clinic: '', plan: 'Solo Doctor Plan',
      amount: '₹999', due: '', date: '1 Oct 2026', status: 'completed', method: 'Razorpay UPI',
    );
    final bytes = await BillingReceiptPdf.build(inv);
    expect(String.fromCharCodes(bytes.take(5)), '%PDF-');
  });
}
