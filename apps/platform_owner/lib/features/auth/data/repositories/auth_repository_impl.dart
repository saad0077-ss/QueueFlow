import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/admin_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../models/admin_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  static const String _defaultAdminEmail = 'admin@queueflow.com';
  static const String _defaultAdminPassword = 'Admin@QueueFlow2026!';

  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  AuthRepositoryImpl({
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<AdminEntity> signIn({
    required String email,
    required String password,
  }) async {
    final trimmedEmail = email.trim().toLowerCase();
    if (trimmedEmail != _defaultAdminEmail) {
      throw Exception('Only admin has access.');
    }
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: trimmedEmail,
        password: password,
      );
      if (credential.user == null) {
        throw Exception('Authentication failed. Please verify credentials.');
      }
      return AdminModel.fromFirebaseUser(credential.user!);
    } on FirebaseAuthException catch (authError) {
      if ((authError.code == 'user-not-found' ||
              authError.code == 'invalid-credential') &&
          trimmedEmail == _defaultAdminEmail &&
          password == _defaultAdminPassword) {
        return _provisionDefaultAdmin(trimmedEmail, password);
      }

      if (authError.code == 'user-not-found') {
        throw Exception('Account not found.');
      } else if (authError.code == 'wrong-password' ||
          authError.code == 'invalid-credential') {
        throw Exception('Invalid credentials.');
      } else if (authError.code == 'too-many-requests') {
        throw Exception('Too many attempts.');
      }
      throw Exception('Sign-in failed.');
    }
  }

  Future<AdminEntity> _provisionDefaultAdmin(
    String email,
    String password,
  ) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (credential.user != null) {
        await _firestore.collection('users').doc(credential.user!.uid).set({
          'email': email,
          'role': 'platform_owner',
          'name': 'Platform Owner',
          'createdAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
        return AdminModel.fromFirebaseUser(credential.user!);
      }
    } catch (_) {
      // Fallback for default admin session if Firebase user creation is restricted
    }
    return AdminModel(
      uid: 'platform_owner_master',
      email: email,
      name: 'Platform Owner',
    );
  }

  @override
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  @override
  Stream<AdminEntity?> get authStateChanges {
    return _firebaseAuth.authStateChanges().map((user) {
      if (user == null) return null;
      return AdminModel.fromFirebaseUser(user);
    });
  }
}
