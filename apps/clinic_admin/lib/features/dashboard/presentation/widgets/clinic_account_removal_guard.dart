import 'dart:async';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Monitors in real-time whether the current clinic facility has been deleted
/// or removed by the platform owner. If removed while the clinic staff/admin is
/// active in the portal, it immediately locks the UI, presents a non-dismissible
/// alert dialog informing them of the removal, and signs out upon acknowledgment.
class ClinicAccountRemovalGuard extends StatefulWidget {
  final Widget child;

  const ClinicAccountRemovalGuard({super.key, required this.child});

  @override
  State<ClinicAccountRemovalGuard> createState() => _ClinicAccountRemovalGuardState();
}

class _ClinicAccountRemovalGuardState extends State<ClinicAccountRemovalGuard> {
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _removedSub;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _clinicsSub;
  bool _dialogShown = false;
  bool _hadActiveClinic = false;

  @override
  void initState() {
    super.initState();
    _startWatchingClinicStatus();
  }

  void _startWatchingClinicStatus() {
    final user = FirebaseAuth.instance.currentUser;
    final email = user?.email?.trim().toLowerCase();
    if (email == null || email.isEmpty) return;

    // 1. Listen to removed_clinics collection for explicit removal tombstone
    _removedSub = FirebaseFirestore.instance
        .collection('removed_clinics')
        .doc(email)
        .snapshots()
        .listen(
      (snapshot) {
        if (!mounted || _dialogShown) return;
        if (snapshot.exists) {
          final data = snapshot.data();
          final message = data?['reason'] as String? ??
              'The platform owner has removed your clinic facility and account.';
          _showRemovalDialog(message);
        }
      },
      onError: (e) {
        debugPrint('ClinicAccountRemovalGuard removed_clinics listen error: $e');
      },
    );

    // 2. Listen to clinics collection where adminEmail == email
    _clinicsSub = FirebaseFirestore.instance
        .collection('clinics')
        .where('adminEmail', isEqualTo: email)
        .snapshots()
        .listen(
      (snapshot) {
        if (!mounted || _dialogShown) return;

        if (snapshot.docs.isNotEmpty) {
          _hadActiveClinic = true;
          final status = (snapshot.docs.first.data()['status'] ?? '').toString().toUpperCase();
          if (status == 'REMOVED' || status == 'DELETED') {
            _showRemovalDialog('The platform owner has removed your clinic facility and account.');
          }
        } else {
          // If clinics query is empty:
          if (_hadActiveClinic) {
            // It previously existed and was just erased by platform owner
            _showRemovalDialog('The platform owner has removed your clinic facility and account.');
          } else {
            // Check if clinic was already removed
            _checkIfRemovedTombstoneExists(email);
          }
        }
      },
      onError: (e) {
        debugPrint('ClinicAccountRemovalGuard clinics listen error: $e');
      },
    );
  }

  Future<void> _checkIfRemovedTombstoneExists(String email) async {
    try {
      final removedDoc = await FirebaseFirestore.instance
          .collection('removed_clinics')
          .doc(email)
          .get();
      if (!mounted || _dialogShown) return;
      if (removedDoc.exists) {
        _showRemovalDialog('The platform owner has removed your clinic facility and account.');
      }
    } catch (_) {}
  }

  void _showRemovalDialog(String reason) {
    if (_dialogShown || !mounted) return;
    _dialogShown = true;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) {
        return PopScope(
          canPop: false,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: Container(
                width: 440,
                padding: const EdgeInsets.fromLTRB(26, 26, 26, 24),
                decoration: BoxDecoration(
                  color: const Color(0xFF0D1527),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFFDC2626).withValues(alpha: 0.6),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFDC2626).withValues(alpha: 0.25),
                      blurRadius: 40,
                      offset: const Offset(0, 10),
                    ),
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.8),
                      blurRadius: 50,
                      offset: const Offset(0, 20),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: const Color(0xFFDC2626).withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFFDC2626).withValues(alpha: 0.4),
                          width: 1.5,
                        ),
                      ),
                      child: const Icon(
                        Icons.domain_disabled_rounded,
                        color: Color(0xFFEF4444),
                        size: 32,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Clinic Account Removed',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 18.5,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'The platform owner has removed your clinic facility and account.\n\nAll clinic records, live queues, tickets, and services have been erased from the system.\n\nYou have been logged out of the clinic portal.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 13.5,
                        color: const Color(0xFF94A3B8),
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 26),
                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFDC2626),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () async {
                          Navigator.of(dialogCtx, rootNavigator: true).pop();
                          await FirebaseAuth.instance.signOut();
                        },
                        child: Text(
                          'Acknowledge & Sign Out',
                          style: GoogleFonts.inter(
                            fontSize: 13.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _removedSub?.cancel();
    _clinicsSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
