import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

class PlatformTicketMacrosBar extends StatelessWidget {
  final ValueChanged<String> onSelectMacro;

  const PlatformTicketMacrosBar({super.key, required this.onSelectMacro});

  static const List<Map<String, String>> _platformMacros = [
    {
      'label': '🏥 Escalated to Clinic Director',
      'text': 'This ticket has been escalated to the Clinic Medical Director for expedited in-person handling.',
    },
    {
      'label': '⚡ Queue Priority Updated',
      'text': 'Doctor has been alerted and consultation queue priority has been updated in real-time.',
    },
    {
      'label': '💳 Refund Initiated via Gateway',
      'text': 'Full consultation fee refund has been processed through Razorpay/UPI gateway. ARN will be sent via SMS.',
    },
    {
      'label': '📅 Slot Rescheduled & Confirmed',
      'text': 'Your appointment has been confirmed for the requested alternate slot. Thank you!',
    },
    {
      'label': '🔒 Tenant Audit Complete',
      'text': 'Platform operations have reviewed tenant audit logs. Compliance verification completed successfully.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDark = colors.isDark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : colors.surfaceSecondary,
        border: Border(top: BorderSide(color: colors.border)),
      ),
      child: Row(
        children: [
          Text(
            'Platform Macros:',
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: colors.textMuted,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _platformMacros.map((macro) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: InkWell(
                      onTap: () => onSelectMacro(macro['text']!),
                      borderRadius: BorderRadius.circular(6),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: colors.surface,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: colors.border),
                        ),
                        child: Text(
                          macro['label']!,
                          style: GoogleFonts.inter(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                            color: colors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
