import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/clinic_staff_entity.dart';
import '../../domain/repositories/clinic_auth_repository.dart';
import '../models/clinic_staff_model.dart';

class ClinicAuthRepositoryImpl implements ClinicAuthRepository {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  ClinicAuthRepositoryImpl({
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<ClinicStaffEntity> signIn({
    required String email,
    required String password,
  }) async {
    final cleanEmail = email.trim().toLowerCase();
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: cleanEmail,
        password: password,
      );
      if (credential.user == null) {
        throw Exception('Sign-in failed.');
      }
      // If clinic was in INVITED status, successful sign-in activates it
      await _markClinicAsActive(cleanEmail);
      return ClinicStaffModel.fromFirebaseUser(credential.user!);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found' || e.code == 'invalid-credential' || e.code == 'wrong-password') {
        try {
          final clinicSnap = await _firestore
              .collection('clinics')
              .where('adminEmail', isEqualTo: cleanEmail)
              .where('status', isEqualTo: 'INVITED')
              .get();
          if (clinicSnap.docs.isNotEmpty) {
            throw Exception(
                'Your clinic account is not activated yet. Please click the activation link sent to $cleanEmail to set your password.');
          }
        } catch (inner) {
          if (inner.toString().contains('clinic account is not activated yet')) {
            rethrow;
          }
        }
        throw Exception('Invalid email or password. Please verify credentials.');
      } else if (e.code == 'too-many-requests') {
        throw Exception('Too many attempts. Please try again in a few moments.');
      }
      throw Exception('Sign-in failed. Please check credentials.');
    }
  }

  @override
  Future<ClinicStaffEntity> activateAccount({
    required String email,
    required String password,
    required String doctorName,
    required String role,
    required String clinicName,
  }) async {
    final cleanEmail = email.trim().toLowerCase();
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: cleanEmail,
        password: password,
      );
      final user = credential.user;
      if (user != null) {
        await user.updateDisplayName(doctorName);
        await _firestore.collection('users').doc(user.uid).set({
          'email': cleanEmail,
          'name': doctorName,
          'role': 'clinic_admin',
          'clinicName': clinicName,
          'status': 'active',
          'activatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        // Update clinic status to 'ACTIVE' in clinics collection
        await _markClinicAsActive(cleanEmail);

        return ClinicStaffModel.fromFirebaseUser(
          user,
          fallbackName: doctorName,
          role: role,
          clinicName: clinicName,
        );
      }
      throw Exception('Activation failed.');
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        try {
          final signInCred = await _firebaseAuth.signInWithEmailAndPassword(
            email: cleanEmail,
            password: password,
          );
          if (signInCred.user != null) {
            await signInCred.user!.updateDisplayName(doctorName);
            await _firestore.collection('users').doc(signInCred.user!.uid).set({
              'email': cleanEmail,
              'name': doctorName,
              'role': 'clinic_admin',
              'clinicName': clinicName,
              'status': 'active',
              'activatedAt': FieldValue.serverTimestamp(),
            }, SetOptions(merge: true));

            // Update clinic status to 'ACTIVE' in clinics collection
            await _markClinicAsActive(cleanEmail);

            return ClinicStaffModel.fromFirebaseUser(
              signInCred.user!,
              fallbackName: doctorName,
              role: role,
              clinicName: clinicName,
            );
          }
        } on FirebaseAuthException catch (authErr) {
          if (authErr.code == 'invalid-credential' || authErr.code == 'wrong-password') {
            throw Exception(
              'An account with this email is already registered with a different password. Please sign in on the login page or use "Forgot password" to reset it.',
            );
          }
          throw Exception(
            authErr.message ?? 'Credentials could not be verified.',
          );
        }
      } else if (e.code == 'weak-password') {
        throw Exception('Password is too weak. Please use at least 8 characters with numbers and letters.');
      }
      throw Exception(e.message ?? 'Account activation failed.');
    }
  }

  Future<void> _markClinicAsActive(String cleanEmail) async {
    try {
      final clinicSnap = await _firestore
          .collection('clinics')
          .where('adminEmail', isEqualTo: cleanEmail)
          .get();
      for (final doc in clinicSnap.docs) {
        await doc.reference.update({
          'status': 'ACTIVE',
          'activatedAt': FieldValue.serverTimestamp(),
        });
      }
      final inviteSnap = await _firestore
          .collection('invites')
          .where('adminEmail', isEqualTo: cleanEmail)
          .get();
      for (final doc in inviteSnap.docs) {
        await doc.reference.update({
          'status': 'activated',
          'activatedAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (_) {}
  }

  @override
  Future<void> sendPasswordReset(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (_) {
      throw Exception('Reset email failed.');
    }
  }

  @override
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }
}
