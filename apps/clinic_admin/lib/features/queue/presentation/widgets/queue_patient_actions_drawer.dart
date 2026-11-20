import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';
import '../../domain/entities/clinic_queue_item_entity.dart';
import 'drawer/queue_patient_action_buttons.dart';
import 'drawer/queue_patient_details_card.dart';
import 'drawer/queue_patient_hero_card.dart';

class QueuePatientActionsDrawer extends StatelessWidget {
  final ClinicQueueItemEntity patient;
  final VoidCallback onClose;
  final VoidCallback onCall;
  final VoidCallback onComplete;
  final VoidCallback onSkip;
  final VoidCallback onRemove;

  const QueuePatientActionsDrawer({
    super.key,
    required this.patient,
    required this.onClose,
    required this.onCall,
    required this.onComplete,
    required this.onSkip,
    required this.onRemove,
  });

  static Future<void> show(
    BuildContext context, {
    required ClinicQueueItemEntity patient,
    required VoidCallback onCall,
    required VoidCallback onComplete,
    required VoidCallback onSkip,
    required VoidCallback onRemove,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: QueuePatientActionsDrawer(
            patient: patient,
            onClose: () => Navigator.of(context).pop(),
            onCall: () {
              Navigator.of(context).pop();
              onCall();
            },
            onComplete: () {
              Navigator.of(context).pop();
              onComplete();
            },
            onSkip: () {
              Navigator.of(context).pop();
              onSkip();
            },
            onRemove: () {
              Navigator.of(context).pop();
              onRemove();
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 16, 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Patient Queue Details',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: colors.textPrimary,
                  ),
                ),
                IconButton(
                  onPressed: onClose,
                  icon: const Icon(Icons.close_rounded, size: 20),
                  color: colors.textMuted,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: colors.border),
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  QueuePatientHeroCard(patient: patient),
                  Divider(height: 1, color: colors.border),
                  QueuePatientDetailsCard(patient: patient),
                  Divider(height: 1, color: colors.border),
                  if (!patient.isCompleted && !patient.isCancelled)
                    QueuePatientActionButtons(
                      patient: patient,
                      onCall: onCall,
                      onComplete: onComplete,
                      onSkip: onSkip,
                      onRemove: onRemove,
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
