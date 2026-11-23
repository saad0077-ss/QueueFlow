import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

class PlatformUsersHeaderBar extends StatelessWidget {
  final int? totalCount;
  final VoidCallback onRefresh;
  final VoidCallback onExport;
  final VoidCallback? onBroadcast;
  final VoidCallback? onRegisterUser;

  const PlatformUsersHeaderBar({
    super.key,
    this.totalCount,
    required this.onRefresh,
    required this.onExport,
    this.onBroadcast,
    this.onRegisterUser,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 980;

        final titleCol = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Users',
              style: GoogleFonts.inter(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: colors.textPrimary,
                letterSpacing: -0.4,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'All registered patients & users across partner clinics • Real-time tokens, appointments & patient records',
              style: GoogleFonts.inter(fontSize: 12.5, color: colors.textMuted),
            ),
          ],
        );

        final actionsRow = Wrap(
          spacing: 10,
          runSpacing: 8,
          children: [
            _btn(colors, Icons.picture_as_pdf_outlined, 'Export PDF', onExport),
            _btn(colors, Icons.refresh_rounded, 'Refresh', onRefresh),
            if (onBroadcast != null)
              _btn(colors, Icons.campaign_outlined, 'Broadcast', onBroadcast!),
            if (onRegisterUser != null)
              ElevatedButton.icon(
                onPressed: onRegisterUser,
                icon: const Icon(Icons.person_add_rounded, size: 16),
                label: Text(
                  'Add Patient',
                  style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                ),
              ),
          ],
        );

        if (isMobile) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [titleCol, const SizedBox(height: 14), actionsRow],
          );
        }

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(child: titleCol),
            actionsRow,
          ],
        );
      },
    );
  }

  Widget _btn(dynamic colors, IconData icon, String label, VoidCallback onTap) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 16),
      label: Text(
        label,
        style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600),
      ),
      style: OutlinedButton.styleFrom(
        foregroundColor: colors.textPrimary,
        side: BorderSide(color: colors.border),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      ),
    );
  }
}
