import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../dashboard/data/repositories/tenant_repository_impl.dart';
import '../../domain/entities/platform_revenue_entity.dart';
import '../../domain/repositories/platform_revenue_repository.dart';

class PlatformRevenueRepositoryImpl implements PlatformRevenueRepository {
  final FirebaseFirestore _firestore;

  PlatformRevenueRepositoryImpl({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<PlatformRevenueEntity> getRevenueMetrics({
    String timeframe = 'current_month',
  }) async {
    int enterprise = 0, multi = 0, solo = 0;
    final clinicItems = <Map<String, dynamic>>[];

    try {
      final snap = await _firestore.collection('clinics').get();
      for (final doc in snap.docs) {
        final d = doc.data();
        final name = (d['name'] ?? '').toString();
        final email = (d['adminEmail'] ?? '').toString();
        if (TenantRepositoryImpl.isDummyClinicName(name, email)) continue;

        final plan = (d['planId'] ?? 'solo').toString().toLowerCase();
        int fee = 999;
        String pName = 'Solo Doctor Plan';

        if (plan.contains('enterprise') || plan.contains('unlimited')) {
          enterprise++;
          fee = 6999;
          pName = 'Unlimited Doctors Plan';
        } else if (plan.contains('multi')) {
          multi++;
          fee = 2999;
          pName = 'Multi-Doctor Clinic Plan';
        } else {
          solo++;
        }

        final docsList = (d['doctors'] as List<dynamic>?) ?? [];
        final docCount = docsList.isNotEmpty
            ? docsList.length
            : (d['practicingDoctors'] as int? ?? 1);

        clinicItems.add({
          'id': doc.id,
          'name': name,
          'category': (d['category'] ?? 'General & Family Practice').toString(),
          'city': (d['city'] ?? 'Active Partner Site').toString(),
          'planName': pName,
          'monthlyFee': fee,
          'status': (d['status'] ?? 'ACTIVE').toString().toUpperCase(),
          'doctorsCount': docCount,
        });
      }
    } catch (_) {}

    int totalInvoiceRevenue = 0;
    final invoiceList = <Map<String, dynamic>>[];
    try {
      final invSnap = await _firestore
          .collection('invoices')
          .orderBy('createdAt', descending: true)
          .limit(10)
          .get();
      for (final doc in invSnap.docs) {
        final d = doc.data();
        final amt = (d['amount'] as num?)?.toInt() ?? 0;
        final st = (d['status'] ?? 'completed').toString().toLowerCase();
        if (st == 'paid' || st == 'completed') {
          totalInvoiceRevenue += amt;
        }
        invoiceList.add({
          'id': doc.id,
          'number':
              (d['invoiceNumber'] ??
                      'INV-${doc.id.substring(0, 5).toUpperCase()}')
                  .toString(),
          'clinicName': (d['clinicName'] ?? 'Partner Clinic').toString(),
          'amount': amt,
          'status': st,
          'date': (d['createdAtDisplay'] ?? 'Recent').toString(),
        });
      }
    } catch (_) {}

    final entMrr = enterprise * 6999;
    final mulMrr = multi * 2999;
    final solMrr = solo * 999;
    final totalMrr = entMrr + mulMrr + solMrr;
    final totalClinics = clinicItems.length;

    final gross = totalInvoiceRevenue > 0 ? totalInvoiceRevenue : totalMrr;
    final arr = totalMrr * 12;
    final arpu = totalClinics > 0 ? (totalMrr / totalClinics).round() : 0;

    return PlatformRevenueEntity(
      mrr: totalMrr,
      arr: arr,
      grossRevenue: gross,
      arpu: arpu,
      activeClinicsCount: totalClinics,
      enterpriseCount: enterprise,
      enterpriseMrr: entMrr,
      multiCount: multi,
      multiMrr: mulMrr,
      soloCount: solo,
      soloMrr: solMrr,
      clinicRevenueItems: clinicItems,
      recentInvoices: invoiceList,
    );
  }
}
