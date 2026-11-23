import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';
import 'clinic_ticket_reply_chips.dart';
import 'clinic_ticket_reply_closed_banner.dart';

class ClinicTicketReplyInput extends StatelessWidget {
  final TextEditingController controller;
  final bool isNote;
  final bool isClosed;
  final ValueChanged<bool> onToggleMode;
  final VoidCallback onSend;

  const ClinicTicketReplyInput({
    super.key,
    required this.controller,
    required this.isNote,
    required this.isClosed,
    required this.onToggleMode,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    if (isClosed) {
      return const ClinicTicketReplyClosedBanner();
    }

    final hint = isNote
        ? 'Write internal clinic note (visible only to staff & platform admin)...'
        : 'Type response to patient (syncs instantly via Firebase)... (Ctrl+Enter to send)';

    final fillColor = isNote
        ? (colors.isDark
              ? const Color(0xFF78350F).withValues(alpha: 0.15)
              : const Color(0xFFFFFBEB))
        : (colors.isDark ? const Color(0xFF0F172A) : colors.surfaceSecondary);

    final borderColor = isNote ? const Color(0xFFF59E0B) : colors.border;

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(top: BorderSide(color: colors.border)),
      ),
      child: Column(
        children: [
          ClinicTicketReplyChips(isNote: isNote, onToggleMode: onToggleMode),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  maxLines: 4,
                  minLines: 1,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: colors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: hint,
                    hintStyle: GoogleFonts.inter(
                      fontSize: 12.5,
                      color: colors.textMuted,
                    ),
                    filled: true,
                    fillColor: fillColor,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: borderColor),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: isNote
                            ? const Color(0xFFF59E0B).withValues(alpha: 0.5)
                            : colors.border,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: isNote
                            ? const Color(0xFFF59E0B)
                            : const Color(0xFF2563EB),
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: onSend,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isNote
                      ? const Color(0xFFD97706)
                      : const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: Icon(
                  isNote ? Icons.lock_outline_rounded : Icons.send_rounded,
                  size: 15,
                ),
                label: Text(
                  isNote ? 'Save Note' : 'Send',
                  style: GoogleFonts.inter(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
