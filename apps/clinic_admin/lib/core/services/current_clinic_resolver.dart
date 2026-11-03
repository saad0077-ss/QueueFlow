import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Finds the `clinics` document managed by the signed-in admin.
class CurrentClinicResolver {
  /// Returns the admin's clinic document, or null when no clinic is linked.
  ///
  /// On web, Firebase Auth restores a persisted session asynchronously, so
  /// right after a hot restart `currentUser` is still null. Waiting for the
  /// first auth state event avoids resolving against a signed-out user.
  static Future<DocumentSnapshot<Map<String, dynamic>>?> resolve({
    required FirebaseAuth auth,
    required FirebaseFirestore firestore,
  }) async {
    final user = auth.currentUser ?? await auth.authStateChanges().first;
    final email = user?.email?.trim().toLowerCase();
    if (email == null || email.isEmpty) return null;

    final snap = await firestore
        .collection('clinics')
        .where('adminEmail', isEqualTo: email)
        .limit(1)
        .get();
    return snap.docs.firstOrNull;
  }

  /// Like [resolve], but throws when no clinic is linked to the admin.
  static Future<DocumentSnapshot<Map<String, dynamic>>> require({
    required FirebaseAuth auth,
    required FirebaseFirestore firestore,
  }) async {
    final doc = await resolve(auth: auth, firestore: firestore);
    if (doc == null) {
      throw Exception('No clinic is linked to this admin account. Please sign in again.');
    }
    return doc;
  }
}
