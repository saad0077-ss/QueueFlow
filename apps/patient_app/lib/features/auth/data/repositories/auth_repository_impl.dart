import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;
  final GoogleSignIn _googleSignIn;

  static const String _webClientId =
      '1070765440897-a9u9ma9rks2ncd3660he26qams1a4krd.apps.googleusercontent.com';

  AuthRepositoryImpl({
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
    GoogleSignIn? googleSignIn,
  }) : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
       _firestore = firestore ?? FirebaseFirestore.instance,
       _googleSignIn =
           googleSignIn ??
           GoogleSignIn(
             clientId: kIsWeb ? _webClientId : null,
             serverClientId: kIsWeb ? null : _webClientId,
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

    // Immediately create patient profile document in Firestore so platform admin sees the new user
    try {
      final healthId =
          'QF-${user.uid.substring(0, user.uid.length >= 6 ? 6 : user.uid.length).toUpperCase()}';
      await _firestore.collection('users').doc(user.uid).set({
        'name': fullName.trim(),
        'fullName': fullName.trim(),
        'email': email.trim().toLowerCase(),
        'phone': phoneNumber.trim(),
        'phoneNumber': phoneNumber.trim(),
        'role': 'patient',
        'status': 'active',
        'isVerified': false,
        'healthId': healthId,
        'userType': 'platform_user',
        'visitsCount': 0,
        'queuesCount': 0,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Error creating user profile in Firestore: $e');
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
      final User user;
      if (kIsWeb) {
        final GoogleAuthProvider googleProvider = GoogleAuthProvider();
        googleProvider.addScope('email');
        googleProvider.setCustomParameters({'prompt': 'select_account'});
        final userCredential =
            await _firebaseAuth.signInWithPopup(googleProvider);
        user = userCredential.user!;
      } else {
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
        user = userCredential.user!;
      }

      // Ensure patient document exists in Firestore for Google accounts
      try {
        final docRef = _firestore.collection('users').doc(user.uid);
        final docSnap = await docRef.get();
        if (!docSnap.exists) {
          final healthId =
              'QF-${user.uid.substring(0, user.uid.length >= 6 ? 6 : user.uid.length).toUpperCase()}';
          final name =
              user.displayName ?? (user.email?.split('@').first ?? 'Google User');
          await docRef.set({
            'name': name.trim(),
            'fullName': name.trim(),
            'email': (user.email ?? '').trim().toLowerCase(),
            'phone': (user.phoneNumber ?? '').trim(),
            'phoneNumber': (user.phoneNumber ?? '').trim(),
            'role': 'patient',
            'status': 'active',
            'isVerified': true,
            'healthId': healthId,
            'userType': 'platform_user',
            'visitsCount': 0,
            'queuesCount': 0,
            'createdAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
        }
      } catch (e) {
        debugPrint('Error syncing Google user to Firestore: $e');
      }

      return UserModel(
        id: user.uid,
        fullName:
            user.displayName ?? (user.email?.split('@').first ?? 'Google User'),
        email: user.email ?? '',
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
    if (!kIsWeb) {
      try {
        await _googleSignIn.signOut();
      } catch (_) {}
    }
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    await _firebaseAuth.sendPasswordResetEmail(email: email.trim());
  }
}
