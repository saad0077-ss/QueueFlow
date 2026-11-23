import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

typedef OnApplyPreset = void Function({
  required String category,
  required String priority,
  required String subject,
  required String desc,
});

class RaiseConcernPresetsSection extends StatelessWidget {
  final AppColorsExtension colors;
  final OnApplyPreset onApplyPreset;

  const RaiseConcernPresetsSection({
    super.key,
    required this.colors,
    required this.onApplyPreset,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '⚡ Quick Presets (Tap to Auto-fill)',
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: colors.textMuted,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: [
              _presetChip(
                label: '⏱️ Waiting > 20m past time',
                onTap: () => onApplyPreset(
                  category: 'queue',
                  priority: 'medium',
                  subject: 'Waiting room delay exceeding 20 minutes',
                  desc: 'I have been waiting in the clinic lobby past my estimated consultation time. Please check triage queue status.',
                ),
              ),
              const SizedBox(width: 8),
              _presetChip(
                label: '⏭️ My token was skipped',
                onTap: () => onApplyPreset(
                  category: 'queue',
                  priority: 'high',
                  subject: 'My token was skipped in queue',
                  desc: 'My queue number passed while I was waiting. Kindly assist to re-queue me for the next consultation slot.',
                ),
              ),
              const SizedBox(width: 8),
              _presetChip(
                label: '📅 Reschedule appointment',
                onTap: () => onApplyPreset(
                  category: 'booking',
                  priority: 'low',
                  subject: 'Request to reschedule appointment slot',
                  desc: 'I need to reschedule my scheduled appointment to an alternate slot or day. Please share available openings.',
                ),
              ),
              const SizedBox(width: 8),
              _presetChip(
                label: '💳 Payment / Tax invoice receipt',
                onTap: () => onApplyPreset(
                  category: 'billing',
                  priority: 'low',
                  subject: 'Payment receipt / Tax invoice query',
                  desc: 'Need consultation receipt or clarification on recent transaction/charge.',
                ),
              ),
              const SizedBox(width: 8),
              _presetChip(
                label: '🩺 Urgent symptom pain triage',
                onTap: () => onApplyPreset(
                  category: 'doctor',
                  priority: 'high',
                  subject: 'Urgent symptom escalation / Medical triage',
                  desc: 'Experiencing acute symptom escalation while waiting. Requesting immediate nurse or doctor assistance.',
                ),
              ),
              const SizedBox(width: 8),
              _presetChip(
                label: '📱 GPS radar not updating',
                onTap: () => onApplyPreset(
                  category: 'technical',
                  priority: 'low',
                  subject: 'App GPS radar tracking issue',
                  desc: 'The queue distance radar / estimated arrival time is not updating accurately on my device.',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _presetChip({required String label, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: const Color(0xFF2563EB).withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: const Color(0xFF2563EB).withValues(alpha: 0.2),
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF2563EB),
          ),
        ),
      ),
    );
  }
}
