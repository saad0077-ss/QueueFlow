import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

class ServiceQueueEmptyState extends StatelessWidget {
  final String activeTab;
  final String serviceName;
  final VoidCallback onAddWalkIn;

  const ServiceQueueEmptyState({
    super.key,
    required this.activeTab,
    required this.serviceName,
    required this.onAddWalkIn,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 20),
      child: Column(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: colors.primaryTint,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: const Text('🩺', style: TextStyle(fontSize: 24)),
          ),
          const SizedBox(height: 14),
          Text(
            'No Patients In ${activeTab.toUpperCase()} Queue',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'There are currently no patients in this view for "$serviceName".',
            style: GoogleFonts.inter(fontSize: 13, color: colors.textMuted),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: onAddWalkIn,
            icon: const Icon(Icons.add_rounded, size: 16),
            label: Text(
              'Add Walk-In Patient',
              style: GoogleFonts.inter(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
