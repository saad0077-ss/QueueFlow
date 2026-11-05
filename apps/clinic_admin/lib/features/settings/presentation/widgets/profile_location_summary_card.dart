import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';
import '../../domain/entities/clinic_location_entity.dart';

class ProfileLocationSummaryCard extends StatelessWidget {
  final ClinicLocationEntity location;
  final VoidCallback onConfigureLocation;

  const ProfileLocationSummaryCard({
    super.key,
    required this.location,
    required this.onConfigureLocation,
  });

  String get _summary {
    final address = [location.street, location.area, location.city].map((p) => p.trim()).where((p) => p.isNotEmpty).join(', ');
    final hasCoords = location.latitude.trim().isNotEmpty && location.longitude.trim().isNotEmpty;
    final coords = hasCoords ? 'Lat: ${location.latitude}, Lng: ${location.longitude}' : 'GPS not set';
    return address.isEmpty ? 'No address set • $coords' : '$address • $coords';
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surfaceSecondary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: colors.infoTint,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.location_on_rounded, color: colors.info, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Clinic GPS & Google Maps Location',
                  style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: colors.textPrimary),
                ),
                const SizedBox(height: 2),
                Text(
                  _summary,
                  style: GoogleFonts.inter(fontSize: 11.5, color: colors.textMuted),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          OutlinedButton(
            onPressed: onConfigureLocation,
            style: OutlinedButton.styleFrom(
              foregroundColor: colors.primaryLight,
              side: BorderSide(color: colors.primary),
              backgroundColor: colors.surface,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Configure Location', style: GoogleFonts.inter(fontSize: 11.5, fontWeight: FontWeight.w600)),
                const SizedBox(width: 4),
                const Icon(Icons.arrow_forward_rounded, size: 14),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
