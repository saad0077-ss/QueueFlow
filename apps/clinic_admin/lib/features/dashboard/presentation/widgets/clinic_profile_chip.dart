import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../auth/presentation/pages/clinic_staff_login_page.dart';

/// Doctor/Staff profile chip in the clinic top bar with a logout popup menu.
class ClinicProfileChip extends StatelessWidget {
  /// Hides the name and role, leaving just the avatar.
  final bool compact;

  const ClinicProfileChip({super.key, this.compact = false});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final displayName = user?.displayName?.trim();
    final name = (displayName != null && displayName.isNotEmpty)
        ? displayName
        : 'Dr. Priya';
    final initials = name
        .replaceFirst(RegExp(r'^dr\.?\s*', caseSensitive: false), '')
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .take(2)
        .map((w) => w[0].toUpperCase())
        .join();

    return PopupMenuButton<String>(
      color: const Color(0xFF10192D),
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: const Color(0xFF1E293B).withValues(alpha: 0.9)),
      ),
      offset: const Offset(0, 48),
      onSelected: (value) async {
        if (value == 'logout') {
          await FirebaseAuth.instance.signOut();
          if (context.mounted) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const ClinicStaffLoginPage()),
            );
          }
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'profile',
          child: Row(
            children: [
              const Icon(
                Icons.person_outline_rounded,
                color: Color(0xFF94A3B8),
                size: 18,
              ),
              const SizedBox(width: 10),
              Text(
                'Profile Settings',
                style: GoogleFonts.inter(fontSize: 13, color: Colors.white),
              ),
            ],
          ),
        ),
        const PopupMenuDivider(height: 1),
        PopupMenuItem(
          value: 'logout',
          child: Row(
            children: [
              const Icon(
                Icons.logout_rounded,
                color: Color(0xFFEF4444),
                size: 18,
              ),
              const SizedBox(width: 10),
              Text(
                'Sign Out',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: const Color(0xFFEF4444),
                ),
              ),
            ],
          ),
        ),
      ],
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: const Color(0xFF0284C7),
              child: Text(
                initials.isEmpty ? 'DR' : initials,
                style: GoogleFonts.inter(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
            if (!compact) ...[
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    name,
                    style: GoogleFonts.inter(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'Clinic Admin',
                    style: GoogleFonts.inter(
                      fontSize: 11.5,
                      color: const Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
