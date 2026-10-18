import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class QuickActionsCard extends StatelessWidget {
  final VoidCallback? onAddWalkIn;
  final VoidCallback? onCreateAppointment;
  final VoidCallback? onTogglePauseQueue;
  final bool isQueuePaused;

  const QuickActionsCard({
    super.key,
    this.onAddWalkIn,
    this.onCreateAppointment,
    this.onTogglePauseQueue,
    this.isQueuePaused = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF10192D),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF1E293B).withValues(alpha: 0.8),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick actions',
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 14),

          // Add Walk-In Patient Button
          _buildActionButton(
            label: 'Add Walk-In Patient',
            borderColor: const Color(0xFF27354E),
            textColor: Colors.white,
            onTap: onAddWalkIn,
          ),

          const SizedBox(height: 10),

          // Create Appointment Button
          _buildActionButton(
            label: 'Create Appointment',
            borderColor: const Color(0xFF27354E),
            textColor: Colors.white,
            onTap: onCreateAppointment,
          ),

          const SizedBox(height: 10),

          // Pause Live Queue Button
          _buildActionButton(
            label: isQueuePaused ? 'Resume Live Queue' : 'Pause Live Queue',
            borderColor: const Color(0xFFD97706),
            textColor: const Color(0xFFF59E0B),
            onTap: onTogglePauseQueue,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required Color borderColor,
    required Color textColor,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        height: 38,
        width: double.infinity,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderColor, width: 1.2),
          color: Colors.transparent,
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12.5,
            fontWeight: FontWeight.w500,
            color: textColor,
          ),
        ),
      ),
    );
  }
}
