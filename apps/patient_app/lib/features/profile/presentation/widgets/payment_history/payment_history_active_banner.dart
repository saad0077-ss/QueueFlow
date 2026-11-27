import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Displays the currently active walk-in queue token banner inside the
/// payment history hero card.
class PaymentHistoryActiveBanner extends StatelessWidget {
  final String token;
  final String? clinicName;

  const PaymentHistoryActiveBanner({
    super.key,
    required this.token,
    this.clinicName,
  });

  @override
  Widget build(BuildContext context) {
    final clinicLabel =
        (clinicName != null && clinicName!.trim().isNotEmpty)
            ? clinicName!.trim()
            : 'In Queue';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF10B981).withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFF10B981).withValues(alpha: 0.35),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                    color: Color(0xFF10B981),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 7),
                Expanded(
                  child: Text(
                    'Active Token $token · ₹500 Paid ($clinicLabel)',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              'IN QUEUE',
              style: GoogleFonts.inter(
                fontSize: 9.5,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: 0.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
