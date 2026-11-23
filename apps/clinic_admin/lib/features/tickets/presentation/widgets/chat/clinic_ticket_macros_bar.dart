import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

class ClinicTicketMacrosBar extends StatelessWidget {
  final List<Map<String, String>> macros;
  final ValueChanged<String> onSelectMacro;

  const ClinicTicketMacrosBar({
    super.key,
    this.macros = defaultMacros,
    required this.onSelectMacro,
  });

  static const List<Map<String, String>> defaultMacros = [
    {
      'label': 'Dr. Running 15m Late',
      'icon': '🕒',
      'text':
          'Doctor running 15 min behind schedule due to emergency procedure. Thank you for your patience!',
    },
    {
      'label': 'Fast-Track to Counter 2',
      'icon': '⚡',
      'text':
          'We have fast-tracked your token to Counter 2. Please head directly to the consultation desk.',
    },
    {
      'label': 'Reschedule Confirmed',
      'icon': '📅',
      'text':
          'Your appointment has been confirmed for the requested alternate slot. Thank you!',
    },
    {
      'label': 'Prescription at Pharmacy',
      'icon': '💊',
      'text':
          'Your digital prescription has been sent to the clinic pharmacy counter.',
    },
    {
      'label': 'Receipt Emailed',
      'icon': '🧾',
      'text':
          'Tax invoice receipt has been dispatched to your registered email address.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: colors.isDark
            ? const Color(0xFF0D1526)
            : colors.surfaceSecondary,
        border: Border(top: BorderSide(color: colors.border)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: [
            Text(
              'Quick Macros: ',
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: colors.textMuted,
              ),
            ),
            const SizedBox(width: 6),
            ...macros.map((m) {
              return Padding(
                padding: const EdgeInsets.only(right: 6),
                child: InkWell(
                  onTap: () => onSelectMacro(m['text']!),
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
                      '${m["icon"]} ${m["label"]}',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: colors.textPrimary,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
