import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

import '../../../domain/entities/support_ticket_entity.dart';

class ConcernChatBubble extends StatelessWidget {
  final TicketMessageEntity msg;

  const ConcernChatBubble({super.key, required this.msg});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isPatient = msg.isUser || msg.senderRole == 'patient';

    return LayoutBuilder(
      builder: (context, constraints) => Align(
        alignment: isPatient ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: (constraints.maxWidth * 0.78).clamp(220.0, 520.0),
          ),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isPatient ? const Color(0xFF2563EB) : colors.surfaceSecondary,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(14),
            topRight: const Radius.circular(14),
            bottomLeft: Radius.circular(isPatient ? 14 : 2),
            bottomRight: Radius.circular(isPatient ? 2 : 14),
          ),
          border: isPatient ? null : Border.all(color: colors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isPatient ? 'You' : msg.sender,
              style: GoogleFonts.inter(
                fontSize: 10.5,
                fontWeight: FontWeight.w800,
                color: isPatient
                    ? Colors.white.withValues(alpha: 0.85)
                    : const Color(0xFF2563EB),
              ),
            ),
            const SizedBox(height: 3),
            Text(
              msg.text,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: isPatient ? Colors.white : colors.textPrimary,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.bottomRight,
              child: Text(
                msg.time,
                style: GoogleFonts.inter(
                  fontSize: 9.5,
                  color: isPatient
                      ? Colors.white.withValues(alpha: 0.7)
                      : colors.textMuted,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
    );
  }
}
