import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'payment_history_active_banner.dart';
import 'payment_history_kpi_strip.dart';

class PaymentHistoryHeroBanner extends StatelessWidget {
  final double totalPaid;
  final int paidCount;
  final double totalRefunded;
  final int refundCount;
  final int queueTokensCount;
  final String? activeQueueToken;
  final String? activeQueueClinicName;

  const PaymentHistoryHeroBanner({
    super.key,
    required this.totalPaid,
    required this.paidCount,
    required this.totalRefunded,
    required this.refundCount,
    required this.queueTokensCount,
    this.activeQueueToken,
    this.activeQueueClinicName,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E1B4B), Color(0xFF312E81), Color(0xFF4338CA)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF312E81).withValues(alpha: 0.3),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('🛡️', style: TextStyle(fontSize: 11)),
                      const SizedBox(width: 5),
                      Flexible(
                        child: Text(
                          '100% Verified Invoices & Instant Refunds',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'GST Compliant',
                style: GoogleFonts.spaceMono(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: Colors.white.withValues(alpha: 0.85),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          PaymentHistoryKpiStrip(
            totalPaid: totalPaid,
            paidCount: paidCount,
            totalRefunded: totalRefunded,
            refundCount: refundCount,
            queueTokensCount: queueTokensCount,
          ),
          if (activeQueueToken != null && activeQueueToken!.isNotEmpty) ...[
            const SizedBox(height: 10),
            PaymentHistoryActiveBanner(
              token: activeQueueToken!,
              clinicName: activeQueueClinicName,
            ),
          ],
        ],
      ),
    );
  }
}
