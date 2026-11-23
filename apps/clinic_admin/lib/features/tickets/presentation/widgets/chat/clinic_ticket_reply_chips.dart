import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ClinicTicketReplyChips extends StatelessWidget {
  final bool isNote;
  final ValueChanged<bool> onToggleMode;

  const ClinicTicketReplyChips({
    super.key,
    required this.isNote,
    required this.onToggleMode,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ChoiceChip(
          label: const Text('💬 Reply to Patient (Live Firebase)'),
          selected: !isNote,
          onSelected: (_) => onToggleMode(false),
          labelStyle: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(width: 8),
        ChoiceChip(
          label: const Text('🔒 Private Clinic Staff Note'),
          selected: isNote,
          onSelected: (_) => onToggleMode(true),
          labelStyle: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
