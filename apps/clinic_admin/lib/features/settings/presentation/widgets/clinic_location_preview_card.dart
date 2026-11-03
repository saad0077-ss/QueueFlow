import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
    final hasCoords = lat.trim().isNotEmpty && lng.trim().isNotEmpty;
    final coordText = hasCoords ? '${lat.trim()}, ${lng.trim()}' : 'Not set';

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF131F33),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(children: [
                const Icon(Icons.location_on_rounded, size: 16, color: Color(0xFF38BDF8)),
                const SizedBox(width: 8),
                Text('Patient Location Preview', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(color: const Color(0xFF0284C7).withAlpha(50), borderRadius: BorderRadius.circular(6)),
                  child: Text('Live Sync', style: GoogleFonts.inter(fontSize: 9.5, fontWeight: FontWeight.bold, color: const Color(0xFF38BDF8))),
                ),
              ]),
              OutlinedButton.icon(
                onPressed: fullAddress.trim().isNotEmpty ? onCopyAddress : null,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Color(0xFF1E293B)),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                icon: const Icon(Icons.copy_rounded, size: 12),
                label: Text('Copy Formatted Address', style: GoogleFonts.inter(fontSize: 11)),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _detailRow('Address:', fullAddress.trim().isNotEmpty ? fullAddress : 'No address specified yet'),
          const SizedBox(height: 6),
          _detailRow('Landmark:', landmark.trim().isNotEmpty ? landmark : 'None specified'),
          const SizedBox(height: 6),
          _detailRow('GPS:', coordText),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(width: 80, child: Text('Navigation:', style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF94A3B8), fontWeight: FontWeight.w600))),
              Expanded(
                child: InkWell(
                  onTap: hasCoords || mapsUrl.trim().isNotEmpty ? onOpenMaps : null,
                  child: Text('Open in Google Maps ↗', style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF38BDF8), fontWeight: FontWeight.w600, decoration: TextDecoration.underline)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(width: 80, child: Text(label, style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF94A3B8), fontWeight: FontWeight.w600))),
        Expanded(child: Text(value, style: GoogleFonts.inter(fontSize: 12, color: Colors.white, height: 1.3))),
      ],
    );
  }
}
