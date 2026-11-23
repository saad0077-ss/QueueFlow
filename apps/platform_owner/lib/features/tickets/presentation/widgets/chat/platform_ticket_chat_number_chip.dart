import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class PlatformTicketChatNumberChip extends StatelessWidget {
  final String ticketNumber;

  const PlatformTicketChatNumberChip({super.key, required this.ticketNumber});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Clipboard.setData(ClipboardData(text: ticketNumber));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ticket $ticketNumber copied to clipboard'),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFF2563EB).withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: const Color(0xFF3B82F6).withValues(alpha: 0.35),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🎫', style: TextStyle(fontSize: 10.5)),
            const SizedBox(width: 4),
            Text(
              ticketNumber,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF60A5FA),
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.copy_rounded, size: 10, color: Color(0xFF93C5FD)),
          ],
        ),
      ),
    );
  }
}
