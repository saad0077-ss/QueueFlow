import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

class ClinicLogTicketDropdowns extends StatelessWidget {
  final String category;
  final ValueChanged<String> onCategoryChanged;
  final String priority;
  final ValueChanged<String> onPriorityChanged;

  const ClinicLogTicketDropdowns({
    super.key,
    required this.category,
    required this.onCategoryChanged,
    required this.priority,
    required this.onPriorityChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Category *',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: colors.textMuted,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: colors.surfaceSecondary,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: colors.border),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: category,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: colors.textPrimary,
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'queue',
                        child: Text('⏱️ Queue & Delay'),
                      ),
                      DropdownMenuItem(
                        value: 'booking',
                        child: Text('📅 Appointment'),
                      ),
                      DropdownMenuItem(
                        value: 'billing',
                        child: Text('💳 Billing / Receipt'),
                      ),
                      DropdownMenuItem(
                        value: 'doctor',
                        child: Text('🩺 Doctor Triage'),
                      ),
                      DropdownMenuItem(
                        value: 'technical',
                        child: Text('📱 Mobile App'),
                      ),
                      DropdownMenuItem(
                        value: 'feedback',
                        child: Text('💬 General Feedback'),
                      ),
                    ],
                    onChanged: (val) {
                      if (val != null) onCategoryChanged(val);
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Priority *',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: colors.textMuted,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: colors.surfaceSecondary,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: colors.border),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: priority,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: colors.textPrimary,
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'high',
                        child: Text('🔴 Urgent (<5m SLA)'),
                      ),
                      DropdownMenuItem(
                        value: 'medium',
                        child: Text('🟠 Standard (<15m SLA)'),
                      ),
                      DropdownMenuItem(
                        value: 'low',
                        child: Text('🟢 Low (<25m SLA)'),
                      ),
                    ],
                    onChanged: (val) {
                      if (val != null) onPriorityChanged(val);
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
