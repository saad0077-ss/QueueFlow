import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/clinic_staff_entity.dart';
import '../../domain/repositories/clinic_auth_repository.dart';
import '../models/clinic_staff_model.dart';

/// Implementation of ClinicAuthRepository handling Firebase authentication
/// and Firestore user profile/clinic synchronization for clinic staff.
class ClinicAuthRepositoryImpl implements ClinicAuthRepository {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  ClinicAuthRepositoryImpl({
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
  })  : _auth = firebaseAuth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<ClinicStaffEntity> signIn({
    required String email,
    required String password,
  }) async {
    final cleanEmail = email.trim().toLowerCase();
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: cleanEmail,
        password: password,
      );
      if (credential.user == null) throw Exception('Sign-in failed.');

      // Check if clinic was removed by platform owner
      final removedSnap = await _firestore.collection('removed_clinics').doc(cleanEmail).get();
      if (removedSnap.exists) {
        await _auth.signOut();
        throw Exception('The platform owner has removed this clinic facility and account.');
      }

      final clinicSnap = await _firestore.collection('clinics').where('adminEmail', isEqualTo: cleanEmail).get();
      if (clinicSnap.docs.isEmpty) {
        await _auth.signOut();
        throw Exception('The platform owner has removed this clinic facility and account.');
      }

      await _markClinicAsActive(cleanEmail);
      return ClinicStaffModel.fromFirebaseUser(credential.user!);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found' || e.code == 'invalid-credential' || e.code == 'wrong-password') {
        final isInvited = await _isClinicInvited(cleanEmail);
        if (isInvited) {
          throw Exception(
            'Your clinic account is not activated yet. Please click the activation link sent to $cleanEmail to set your password.',
          );
        }
        throw Exception('Invalid email or password. Please verify credentials.');
      } else if (e.code == 'too-many-requests') {
        throw Exception('Too many attempts. Please try again in a few moments.');
      }
      throw Exception(e.message ?? 'Sign-in failed. Please check credentials.');
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
      final credential = await _auth.createUserWithEmailAndPassword(
        email: cleanEmail,
        password: password,
      );
      final user = credential.user!;
      await _saveUserProfile(user, doctorName, cleanEmail, clinicName);
      return ClinicStaffModel.fromFirebaseUser(user, fallbackName: doctorName, role: role, clinicName: clinicName);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        return _handleExistingUserActivation(cleanEmail, password, doctorName, role, clinicName);
      } else if (e.code == 'weak-password') {
        throw Exception('Password is too weak. Please use at least 8 characters with numbers and letters.');
      }
      throw Exception(e.message ?? 'Account activation failed.');
    }
  }

  Future<ClinicStaffEntity> _handleExistingUserActivation(
    String email,
    String password,
    String doctorName,
    String role,
    String clinicName,
  ) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(email: email, password: password);
      final user = credential.user!;
      await _saveUserProfile(user, doctorName, email, clinicName);
      return ClinicStaffModel.fromFirebaseUser(user, fallbackName: doctorName, role: role, clinicName: clinicName);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-credential' || e.code == 'wrong-password') {
        throw Exception(
          'An account with this email is already registered with a different password. Please sign in or use "Forgot password".',
        );
      }
      throw Exception(e.message ?? 'Credentials could not be verified.');
    }
  }

  Future<void> _saveUserProfile(User user, String name, String email, String clinicName) async {
    await user.updateDisplayName(name);
    await _firestore.collection('users').doc(user.uid).set({
      'email': email,
      'name': name,
      'role': 'clinic_admin',
      'clinicName': clinicName,
      'status': 'active',
      'activatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    await _markClinicAsActive(email);
  }

  Future<bool> _isClinicInvited(String email) async {
    try {
      final snap = await _firestore.collection('clinics').where('adminEmail', isEqualTo: email).where('status', isEqualTo: 'INVITED').get();
      return snap.docs.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  Future<void> _markClinicAsActive(String email) async {
    try {
      final clinicSnap = await _firestore.collection('clinics').where('adminEmail', isEqualTo: email).get();
      for (final doc in clinicSnap.docs) {
        await doc.reference.update({'status': 'ACTIVE', 'activatedAt': FieldValue.serverTimestamp()});
      }
      final inviteSnap = await _firestore.collection('invites').where('adminEmail', isEqualTo: email).get();
      for (final doc in inviteSnap.docs) {
        await doc.reference.update({'status': 'activated', 'activatedAt': FieldValue.serverTimestamp()});
      }
    } catch (_) {}
  }

  @override
  Future<void> sendPasswordReset(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (_) {
      throw Exception('Reset email failed.');
    }
  }

  @override
  Future<void> signOut() async => _auth.signOut();
}
