import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/services/current_clinic_resolver.dart';
import '../../domain/entities/billing_invoice_entity.dart';
import '../../domain/entities/billing_plan_tier_entity.dart';
import '../../domain/entities/clinic_subscription_entity.dart';
import '../../domain/repositories/clinic_billing_repository.dart';
import '../models/billing_invoice_model.dart';
import '../models/billing_sample_data.dart';
import '../models/clinic_subscription_model.dart';

class ClinicBillingRepositoryImpl implements ClinicBillingRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  ClinicBillingRepositoryImpl({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  Future<DocumentSnapshot<Map<String, dynamic>>> _clinicDoc() =>
      CurrentClinicResolver.require(auth: _auth, firestore: _firestore);

  @override
  Future<ClinicSubscriptionEntity> getClinicSubscription() async {
    final doc = await _clinicDoc();
    final clinicId = doc.id;
    final data = doc.data() ?? <String, dynamic>{};

    final svcsSnap = await _firestore
        .collection('services')
        .where('clinicId', isEqualTo: clinicId)
        .get();
    final activeSvcs = svcsSnap.docs.length;
    final doctorsList = data['doctors'] as List<dynamic>?;
    final activeDocs = doctorsList?.length ?? 0;

    return ClinicSubscriptionModel.fromClinicData(
      clinicId,
      data,
      activeDocs: activeDocs,
      activeSvcs: activeSvcs,
    );
  }

  @override
  Future<List<BillingPlanTierEntity>> getPlanTiers() async =>
      BillingSampleData.defaultTiers;

  @override
  Future<List<BillingInvoiceEntity>> getInvoices() async {
    final doc = await _clinicDoc();
    final clinicId = doc.id;

    final snap = await _firestore
        .collection('invoices')
        .where('clinicId', isEqualTo: clinicId)
        .limit(20)
        .get();

    return snap.docs
        .map((d) => BillingInvoiceModel.fromMap(d.id, d.data()))
        .toList();
  }

  @override
  Future<void> updatePlan({
    required String planId,
    required String planName,
    required String billingCycle,
    required String amount,
  }) async {
    final doc = await _clinicDoc();
    final clinicId = doc.id;
    await _firestore.collection('clinics').doc(clinicId).set({
      'planId': planId,
      'planName': planName,
      'billingCadence': billingCycle,
      'amount': amount,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  @override
  Future<void> toggleBillingCycle(String newCycle) async {
    final doc = await _clinicDoc();
    final clinicId = doc.id;
    await _firestore.collection('clinics').doc(clinicId).set({
      'billingCadence': newCycle,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  @override
  Future<void> updateBillingContact(ClinicBillingContactEntity contact) async {
    final doc = await _clinicDoc();
    final clinicId = doc.id;
    await _firestore.collection('clinics').doc(clinicId).set({
      'billingContact': {
        'legalName': contact.legalName,
        'gstin': contact.gstin,
        'email': contact.email,
        'phone': contact.phone,
        'address': contact.address,
      },
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
