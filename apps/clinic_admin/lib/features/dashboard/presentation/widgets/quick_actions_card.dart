import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

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
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick actions',
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: 14),

          // Add Walk-In Patient Button
          _buildActionButton(
            label: 'Add Walk-In Patient',
            borderColor: colors.border,
            textColor: colors.textPrimary,
            onTap: onAddWalkIn,
          ),

          const SizedBox(height: 10),

          // Create Appointment Button
          _buildActionButton(
            label: 'Create Appointment',
            borderColor: colors.border,
            textColor: colors.textPrimary,
            onTap: onCreateAppointment,
          ),

          const SizedBox(height: 10),

          // Pause Live Queue Button
          _buildActionButton(
            label: isQueuePaused ? 'Resume Live Queue' : 'Pause Live Queue',
            borderColor: colors.warning,
            textColor: colors.warning,
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
