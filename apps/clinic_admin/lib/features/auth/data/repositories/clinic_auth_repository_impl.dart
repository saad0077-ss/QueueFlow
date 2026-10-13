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
      return ClinicStaffModel.fromFirebaseUser(credential.user!);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        throw Exception('Staff account not found.');
      } else if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
        throw Exception('Invalid credentials.');
      } else if (e.code == 'too-many-requests') {
        throw Exception('Too many attempts.');
      }
      throw Exception('Sign-in failed.');
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
        final signInCred = await _firebaseAuth.signInWithEmailAndPassword(
          email: cleanEmail,
          password: password,
        );
        return ClinicStaffModel.fromFirebaseUser(
          signInCred.user!,
          fallbackName: doctorName,
          role: role,
          clinicName: clinicName,
        );
      }
      throw Exception('Account activation failed.');
    }
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
