import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

import '../../../../data/repositories/home_repository_impl.dart'
    show completedTicketsQuery, hasCompletedServiceToday;
import '../../../../domain/entities/clinic_entity.dart';
import '../models/live_clinic_queue_info.dart';
import '../utils/queue_helpers.dart';

class QueueRadarJoinButton extends StatelessWidget {
  final ClinicEntity clinic;
  final LiveServiceQueue? target;
  final VoidCallback onJoin;

  const QueueRadarJoinButton({
    super.key,
    required this.clinic,
    this.target,
    required this.onJoin,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final email = safeAuth()?.currentUser?.email;

    Widget button(bool doneToday) => ElevatedButton(
      onPressed: doneToday ? null : onJoin,
      style: ElevatedButton.styleFrom(
        backgroundColor: colors.primary,
        foregroundColor: Colors.white,
        disabledBackgroundColor: colors.textMuted.withValues(alpha: 0.15),
        disabledForegroundColor: colors.textMuted,
        padding: const EdgeInsets.symmetric(vertical: 11),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 0,
      ),
      child: Text(
        doneToday
            ? 'Service completed today · rejoin tomorrow'
            : 'Join Digital Queue',
        style: GoogleFonts.inter(fontSize: 12.5, fontWeight: FontWeight.w700),
      ),
    );

    final fs = safeFirestore();
    if (email == null || email.isEmpty || fs == null) return button(false);

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: completedTicketsQuery(
        fs,
        email: email,
        clinicId: clinic.id,
      ).snapshots(),
      builder: (context, snap) {
        final doneToday =
            target != null &&
            hasCompletedServiceToday(
              (snap.data?.docs ?? const []).map((d) => d.data()),
              target!.service,
            );
        return button(doneToday);
      },
    );
  }
}
