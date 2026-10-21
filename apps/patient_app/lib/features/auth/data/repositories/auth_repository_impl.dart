import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;

  static const String _webClientId =
      '1070765440897-a9u9ma9rks2ncd3660he26qams1a4krd.apps.googleusercontent.com';

  AuthRepositoryImpl({FirebaseAuth? firebaseAuth, GoogleSignIn? googleSignIn})
    : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
      _googleSignIn =
          googleSignIn ??
          GoogleSignIn(
            clientId: kIsWeb ? _webClientId : null,
            serverClientId: _webClientId,
          );

  @override
  UserEntity? getCurrentUser() {
    final user = _firebaseAuth.currentUser;
    if (user == null) return null;
    return UserModel(
      id: user.uid,
      fullName: user.displayName ?? (user.email?.split('@').first ?? 'Patient'),
      email: user.email ?? '',
      phoneNumber: user.phoneNumber ?? '',
    );
  }

  @override
  Future<UserEntity> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    final credential = await _firebaseAuth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    final user = credential.user!;
    return UserModel(
      id: user.uid,
      fullName: user.displayName ?? (email.split('@').first),
      email: user.email ?? email,
      phoneNumber: user.phoneNumber ?? '',
    );
  }

  @override
  Future<UserEntity> signUp({
    required String fullName,
    required String email,
    required String phoneNumber,
    required String password,
  }) async {
    final credential = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    final user = credential.user!;
    await user.updateDisplayName(fullName);

    // Send built-in verification email directly via Firebase Auth
    try {
      await user.sendEmailVerification();
    } catch (e) {
      debugPrint('sendEmailVerification exception: $e');
    }
    return UserModel(
      id: user.uid,
      fullName: fullName,
      email: email,
      phoneNumber: phoneNumber,
    );
  }

  @override
  Future<UserEntity> signInWithGoogle() async {
    try {
      // Ensure any cached stale account session is cleared so picker always shows
      try {
        await _googleSignIn.signOut();
      } catch (_) {}

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw FirebaseAuthException(
          code: 'ERROR_ABORTED_BY_USER',
          message: 'Google Sign-In was cancelled by user.',
        );
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _firebaseAuth.signInWithCredential(
        credential,
      );
      final user = userCredential.user!;

      return UserModel(
        id: user.uid,
        fullName: user.displayName ?? googleUser.displayName ?? 'Google User',
        email: user.email ?? googleUser.email,
        phoneNumber: user.phoneNumber ?? '',
      );
    } catch (e) {
      if (e is FirebaseAuthException) {
        rethrow;
      }
      throw FirebaseAuthException(
        code: 'GOOGLE_SIGN_IN_FAILED',
        message: e.toString(),
      );
    }
  }

  @override
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
    try {
      await _googleSignIn.signOut();
    } catch (_) {}
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    await _firebaseAuth.sendPasswordResetEmail(email: email.trim());
  }
}
