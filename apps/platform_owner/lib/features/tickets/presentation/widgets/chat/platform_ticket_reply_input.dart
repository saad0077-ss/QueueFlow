import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

class PlatformTicketReplyInput extends StatelessWidget {
  final TextEditingController controller;
  final bool isInternalNote;
  final bool isSending;
  final ValueChanged<bool> onToggleMode;
  final VoidCallback onSend;

  const PlatformTicketReplyInput({
    super.key,
    required this.controller,
    required this.isInternalNote,
    required this.isSending,
    required this.onToggleMode,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDark = colors.isDark;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
        border: Border(top: BorderSide(color: colors.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ChoiceChip(
                label: const Text('📢 Public Response (Patient Visible)'),
                selected: !isInternalNote,
                onSelected: (_) => onToggleMode(false),
                labelStyle: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 8),
              ChoiceChip(
                label: const Text('🔒 Platform Internal Audit Memo'),
                selected: isInternalNote,
                onSelected: (_) => onToggleMode(true),
                labelStyle: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
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
                    hintText: isInternalNote
                        ? 'Write an internal platform audit memo (visible only to platform staff)...'
                        : 'Broadcast public update to patient (Ctrl+Enter to send)...',
                    hintStyle: GoogleFonts.inter(
                      fontSize: 12.5,
                      color: colors.textMuted,
                    ),
                    filled: true,
                    fillColor: isInternalNote
                        ? (isDark
                              ? const Color(0xFF78350F).withValues(alpha: 0.15)
                              : const Color(0xFFFFFBEB))
                        : (isDark
                              ? const Color(0xFF0F172A)
                              : colors.surfaceSecondary),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: isInternalNote
                            ? const Color(0xFFF59E0B)
                            : colors.border,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: isInternalNote
                            ? const Color(0xFFF59E0B).withValues(alpha: 0.5)
                            : colors.border,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: isInternalNote
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
                onPressed: isSending ? null : onSend,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isInternalNote
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
                icon: isSending
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Icon(
                        isInternalNote
                            ? Icons.lock_outline_rounded
                            : Icons.send_rounded,
                        size: 15,
                      ),
                label: Text(
                  isInternalNote ? 'Save Memo' : 'Dispatch',
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
