import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Manages persistent session state for Clinic Admin using SharedPreferences.
///
/// Ensures the clinic admin remains logged in during hot reloads, hot restarts,
/// and web browser refreshes, while supporting clean explicit sign-outs.
class ClinicSessionManager {
  static const String _kLoggedInKey = 'clinic_admin_is_logged_in';
  static const String _kEmailKey = 'clinic_admin_email';
  static const String _kClinicIdKey = 'clinic_admin_clinic_id';
  static const String _kClinicNameKey = 'clinic_admin_clinic_name';
  static const String _kLastLoginKey = 'clinic_admin_last_login';

  /// Saves the authenticated session into SharedPreferences.
  static Future<void> saveSession({
    required String email,
    String? clinicId,
    String? clinicName,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_kLoggedInKey, true);
      await prefs.setString(_kEmailKey, email.trim().toLowerCase());
      if (clinicId != null && clinicId.isNotEmpty) {
        await prefs.setString(_kClinicIdKey, clinicId);
      }
      if (clinicName != null && clinicName.isNotEmpty) {
        await prefs.setString(_kClinicNameKey, clinicName);
      }
      await prefs.setString(_kLastLoginKey, DateTime.now().toIso8601String());
      debugPrint('ClinicSessionManager: Session saved for $email');
    } catch (e) {
      debugPrint('ClinicSessionManager error saving session: $e');
    }
  }

  /// Checks if a valid clinic admin session is persisted in SharedPreferences.
  static Future<bool> isSessionSaved() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_kLoggedInKey) ?? false;
    } catch (e) {
      debugPrint('ClinicSessionManager error checking session: $e');
      return false;
    }
  }

  /// Retrieves the saved email from SharedPreferences.
  static Future<String?> getSavedEmail() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_kEmailKey);
    } catch (e) {
      return null;
    }
  }

  /// Retrieves the saved clinic ID.
  static Future<String?> getSavedClinicId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_kClinicIdKey);
    } catch (e) {
      return null;
    }
  }

  /// Retrieves the saved clinic name.
  static Future<String?> getSavedClinicName() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_kClinicNameKey);
    } catch (e) {
      return null;
    }
  }

  /// Clears the session from SharedPreferences and signs out of FirebaseAuth.
  static Future<void> clearSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_kLoggedInKey, false);
      await prefs.remove(_kEmailKey);
      await prefs.remove(_kClinicIdKey);
      await prefs.remove(_kClinicNameKey);
      await prefs.remove(_kLastLoginKey);
      debugPrint('ClinicSessionManager: Session cleared.');
    } catch (e) {
      debugPrint('ClinicSessionManager error clearing session: $e');
    }

    try {
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      debugPrint('FirebaseAuth signOut error: $e');
    }
  }
}
