import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/platform_billing_kpis.dart';
import '../../domain/entities/platform_invoice_entity.dart';
import '../../domain/entities/platform_plan_tier_entity.dart';
import '../../domain/entities/platform_tenant_subscription_entity.dart';
import '../../domain/repositories/platform_billing_repository.dart';
import '../models/platform_billing_sample_data.dart';
import '../models/platform_invoice_model.dart';
import '../models/platform_tenant_subscription_model.dart';

class PlatformBillingRepositoryImpl implements PlatformBillingRepository {
  final FirebaseFirestore _firestore;

  PlatformBillingRepositoryImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<PlatformBillingKpis> getKpis() async {
    try {
      final snap = await _firestore.collection('clinics').get();
      final count = snap.docs.length;
      final activeCount = snap.docs.where((d) => (d.data()['status'] ?? '').toString().toUpperCase() == 'ACTIVE').length;

      return PlatformBillingKpis(
        totalMrr: '₹2,40,000',
        mrrTrend: '↑ 14.2% MoM',
        activeSubscriptions: count > 0 ? (activeCount > 0 ? activeCount : count) : 5,
        retentionRate: '100% Retained',
        overdueCount: 2,
        overdueAmount: '₹16,000 pending',
        arpu: '₹8,200',
        churnRate: '2.1% Churn',
        collectionRate: '94.2% On Time',
      );
    } catch (_) {
      return const PlatformBillingKpis();
    }
  }

  @override
  Stream<List<PlatformTenantSubscriptionEntity>> watchTenantSubscriptions() {
    return _firestore.collection('clinics').snapshots().map((snap) {
      if (snap.docs.isEmpty) return const [];
      return snap.docs
          .map((d) => PlatformTenantSubscriptionModel.fromMap(d.id, d.data()))
          .toList();
    });
  }

  @override
  Future<List<PlatformPlanTierEntity>> getPlanTiers() async {
    return PlatformBillingSampleData.defaultTiers;
  }

  @override
  Future<List<PlatformInvoiceEntity>> getInvoices() async {
    try {
      final snap = await _firestore.collection('invoices').limit(50).get();
      if (snap.docs.isNotEmpty) {
        return snap.docs
            .map((d) => PlatformInvoiceModel.fromMap(d.id, d.data()))
            .toList();
      }
    } catch (_) {}
    return PlatformBillingSampleData.defaultInvoices;
  }

  @override
  Future<void> markInvoicePaid(String invoiceId) async {
    try {
      await _firestore.collection('invoices').doc(invoiceId).update({'status': 'completed'});
    } catch (_) {
      // Sample-data invoices have no backing document; the bloc updates them locally.
    }
  }

  @override
  Future<void> issueInvoice({
    required String clinicId,
    required String clinicName,
    required String plan,
    required String amount,
    required String dueDate,
  }) async {
    final now = DateTime.now();
    final invNum = 'QF-INV-${now.year}-${(now.millisecondsSinceEpoch % 1000).toString().padLeft(3, '0')}';

    await _firestore.collection('invoices').add({
      'number': invNum,
      'clinicId': clinicId,
      'clinic': clinicName,
      'plan': plan,
      'amount': amount.startsWith('₹') ? amount : '₹$amount',
      'due': dueDate,
      'date': '${now.day} ${_monthName(now.month)} ${now.year}',
      'status': 'pending',
      'method': 'Razorpay AutoPay (Pending)',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> updateTenantSubscription({
    required String clinicId,
    required String planId,
    required String billingCadence,
    required String status,
  }) async {
    await _firestore.collection('clinics').doc(clinicId).update({
      'planId': planId,
      'billingCadence': billingCadence,
      'status': status.toUpperCase(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> savePlanTier(PlatformPlanTierEntity tier) async {
    await _firestore.collection('plan_tiers').doc(tier.id).set({
      'name': tier.name,
      'tagline': tier.tagline,
      'monthlyPrice': tier.monthlyPrice,
      'annualPrice': tier.annualPrice,
      'doctorLimit': tier.doctorLimit,
      'serviceLimit': tier.serviceLimit,
      'badge': tier.badge,
      'features': tier.features,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  String _monthName(int m) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return (m >= 1 && m <= 12) ? months[m - 1] : 'Oct';
  }
}
