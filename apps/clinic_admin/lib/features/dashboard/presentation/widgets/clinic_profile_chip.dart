import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';
import '../../../../core/services/current_clinic_resolver.dart';
import '../../../auth/presentation/pages/clinic_staff_login_page.dart';

/// Signs the admin out and returns to the staff login page.
Future<void> clinicSignOut(BuildContext context) async {
  final navigator = Navigator.of(context, rootNavigator: true);
  await FirebaseAuth.instance.signOut();
  navigator.pushAndRemoveUntil(
    MaterialPageRoute(builder: (_) => const ClinicStaffLoginPage()),
    (_) => false,
  );
}

/// Clinic profile chip in the top bar: shows the clinic's name and photo,
/// with a popup menu for sign out.
class ClinicProfileChip extends StatefulWidget {
  /// Hides the name and role, leaving just the avatar.
  final bool compact;

  const ClinicProfileChip({super.key, this.compact = false});

  @override
  State<ClinicProfileChip> createState() => _ClinicProfileChipState();
}

class _ClinicProfileChipState extends State<ClinicProfileChip> {
  String _clinicName = '';
  String _imageUrl = '';
  Uint8List? _imageBytes;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final db = FirebaseFirestore.instance;
      final doc = await CurrentClinicResolver.resolve(
        auth: FirebaseAuth.instance,
        firestore: db,
      );
      if (doc == null) return;
      final data = doc.data() ?? const <String, dynamic>{};
      final name = (data['name'] as String? ?? '').trim();
      final url = (data['imageUrl'] as String? ?? '').trim();
      Uint8List? bytes;
      if (url.isEmpty) {
        final img = await db.collection('clinic_images').doc(doc.id).get();
        final b64 = img.data()?['data'] as String?;
        if (b64 != null && b64.isNotEmpty) bytes = base64Decode(b64);
      }
      if (!mounted) return;
      setState(() {
        _clinicName = name;
        _imageUrl = url;
        _imageBytes = bytes;
      });
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final compact = widget.compact;
    final colors = context.colors;
    final name = _clinicName.isNotEmpty ? _clinicName : 'Clinic';
    final initials = name
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .take(2)
        .map((w) => w[0].toUpperCase())
        .join();
    final ImageProvider? photo = _imageBytes != null
        ? MemoryImage(_imageBytes!)
        : (_imageUrl.isNotEmpty ? NetworkImage(_imageUrl) : null);

    return PopupMenuButton<String>(
      color: colors.surfaceElevated,
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: colors.border),
      ),
      offset: const Offset(0, 48),
      onSelected: (value) async {
        if (value == 'logout') {
          await clinicSignOut(context);
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'profile',
          child: Row(
            children: [
              Icon(
                Icons.person_outline_rounded,
                color: colors.textMuted,
                size: 18,
              ),
              const SizedBox(width: 10),
              Text(
                'Profile Settings',
                style: GoogleFonts.inter(fontSize: 13, color: colors.textPrimary),
              ),
            ],
          ),
        ),
        const PopupMenuDivider(height: 1),
        PopupMenuItem(
          value: 'logout',
          child: Row(
            children: [
              Icon(
                Icons.logout_rounded,
                color: colors.error,
                size: 18,
              ),
              const SizedBox(width: 10),
              Text(
                'Sign Out',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: colors.error,
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
              backgroundColor: colors.primary,
              backgroundImage: photo,
              onBackgroundImageError: photo == null ? null : (_, _) {},
              child: photo != null
                  ? null
                  : Text(
                      initials.isEmpty ? 'C' : initials,
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
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 160),
                    child: Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: colors.textPrimary,
                    ),
                  ),
                  ),
                  Text(
                    'Clinic Admin',
                    style: GoogleFonts.inter(
                      fontSize: 11.5,
                      color: colors.textMuted,
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
