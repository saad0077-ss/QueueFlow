import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
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
        .limit(50)
        .get();

    final list = snap.docs
        .map((d) => BillingInvoiceModel.fromMap(d.id, d.data()))
        .toList();
    // Newest first (sorted here to avoid needing a composite index).
    list.sort((a, b) => (b.createdAt ?? DateTime(2000)).compareTo(a.createdAt ?? DateTime(2000)));
    return list;
  }

  @override
  Future<void> activateSubscription({
    required String planId,
    required String billingCycle,
    required String paymentId,
  }) async {
    try {
      await FirebaseFunctions.instance.httpsCallable('activateSubscription').call({
        'planId': planId,
        'billingCadence': billingCycle,
        'paymentId': paymentId,
      });
    } on FirebaseFunctionsException catch (e) {
      throw Exception(e.message ?? 'Could not activate the subscription.');
    }
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
