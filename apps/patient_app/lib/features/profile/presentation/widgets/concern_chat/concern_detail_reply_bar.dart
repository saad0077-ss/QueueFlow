import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';
import '../../../domain/entities/support_ticket_entity.dart';
import 'concern_detail_closed_banner.dart';

/// Reply composer or resolved-ticket reopen banner for a support concern.
class ConcernDetailReplyBar extends StatelessWidget {
  final TextEditingController controller;
  final bool isSending;
  final bool isResolved;
  final SupportTicketEntity ticket;
  final VoidCallback onSend;
  final VoidCallback onReopen;
  final bool embedded;

  const ConcernDetailReplyBar({
    super.key,
    required this.controller,
    required this.isSending,
    required this.isResolved,
    required this.ticket,
    required this.onSend,
    required this.onReopen,
    this.embedded = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isResolved) {
      return ConcernDetailClosedBanner(embedded: embedded, onReopen: onReopen);
    }

    final colors = context.colors;
    final bottomPad = embedded
        ? 12.0
        : (MediaQuery.of(context).viewInsets.bottom > 0
              ? MediaQuery.of(context).viewInsets.bottom + 10
              : 24.0);

    return Container(
      padding: EdgeInsets.only(left: 12, right: 12, top: 10, bottom: bottomPad),
      decoration: BoxDecoration(
        color: embedded ? colors.surfaceSecondary : colors.surface,
        borderRadius: embedded
            ? const BorderRadius.vertical(bottom: Radius.circular(16))
            : null,
        border: Border(top: BorderSide(color: colors.border)),
        boxShadow: embedded
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -3),
                ),
              ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: embedded ? colors.surface : colors.surfaceSecondary,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: colors.border),
              ),
              child: TextField(
                controller: controller,
                style: GoogleFonts.inter(
                  fontSize: 12.5,
                  color: colors.textPrimary,
                ),
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => onSend(),
                decoration: InputDecoration(
                  hintText: 'Type reply to clinic desk...',
                  hintStyle: GoogleFonts.inter(
                    fontSize: 12.5,
                    color: colors.textMuted,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(24),
            ),
            child: IconButton(
              onPressed: isSending ? null : onSend,
              icon: isSending
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(
                      Icons.send_rounded,
                      size: 18,
                      color: Colors.white,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
