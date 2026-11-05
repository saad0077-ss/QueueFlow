import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

class ClinicLocationPreviewCard extends StatelessWidget {
  final String fullAddress;
  final String landmark;
  final String lat;
  final String lng;
  final String mapsUrl;
  final VoidCallback onCopyAddress;
  final VoidCallback onOpenMaps;

  const ClinicLocationPreviewCard({
    super.key,
    required this.fullAddress,
    required this.landmark,
    required this.lat,
    required this.lng,
    required this.mapsUrl,
    required this.onCopyAddress,
    required this.onOpenMaps,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final hasCoords = lat.trim().isNotEmpty && lng.trim().isNotEmpty;
    final coordText = hasCoords ? '${lat.trim()}, ${lng.trim()}' : 'Not set';

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.surfaceSecondary,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(children: [
                Icon(Icons.location_on_rounded, size: 16, color: colors.info),
                const SizedBox(width: 8),
                Text(
                  'Patient Location Preview',
                  style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold, color: colors.textPrimary),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(color: colors.infoTint, borderRadius: BorderRadius.circular(6)),
                  child: Text('Live Sync', style: GoogleFonts.inter(fontSize: 9.5, fontWeight: FontWeight.bold, color: colors.info)),
                ),
              ]),
              OutlinedButton.icon(
                onPressed: fullAddress.trim().isNotEmpty ? onCopyAddress : null,
                style: OutlinedButton.styleFrom(
                  foregroundColor: colors.textPrimary,
                  side: BorderSide(color: colors.border),
                  backgroundColor: colors.surface,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                icon: const Icon(Icons.copy_rounded, size: 12),
                label: Text('Copy Formatted Address', style: GoogleFonts.inter(fontSize: 11)),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _detailRow(context, 'Address:', fullAddress.trim().isNotEmpty ? fullAddress : 'No address specified yet'),
          const SizedBox(height: 6),
          _detailRow(context, 'Landmark:', landmark.trim().isNotEmpty ? landmark : 'None specified'),
          const SizedBox(height: 6),
          _detailRow(context, 'GPS:', coordText),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 80,
                child: Text('Navigation:', style: GoogleFonts.inter(fontSize: 12, color: colors.textMuted, fontWeight: FontWeight.w600)),
              ),
              Expanded(
                child: InkWell(
                  onTap: hasCoords || mapsUrl.trim().isNotEmpty ? onOpenMaps : null,
                  child: Text(
                    'Open in Google Maps ↗',
                    style: GoogleFonts.inter(fontSize: 12, color: colors.info, fontWeight: FontWeight.w600, decoration: TextDecoration.underline),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _detailRow(BuildContext context, String label, String value) {
    final colors = context.colors;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(label, style: GoogleFonts.inter(fontSize: 12, color: colors.textMuted, fontWeight: FontWeight.w600)),
        ),
        Expanded(
          child: Text(value, style: GoogleFonts.inter(fontSize: 12, color: colors.textPrimary, height: 1.3)),
        ),
      ],
    );
  }
}
