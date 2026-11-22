import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';
import '../../../domain/entities/patient_payment_item_entity.dart';

class PaymentHistoryCard extends StatelessWidget {
  final PatientPaymentItemEntity payment;
  final VoidCallback onViewReceipt;
  final VoidCallback onDownloadReceipt;

  const PaymentHistoryCard({
    super.key,
    required this.payment,
    required this.onViewReceipt,
    required this.onDownloadReceipt,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isRefunded = payment.isRefunded;

    return Container(
      decoration: BoxDecoration(
        color: isRefunded ? colors.surface.withValues(alpha: 0.95) : colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isRefunded
              ? const Color(0xFF8B5CF6).withValues(alpha: 0.35)
              : colors.border,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Top Row: Type Tag + Status Pill + Date
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Wrap(
                spacing: 6,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  // Type Tag
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                    decoration: BoxDecoration(
                      color: payment.isQueueToken
                          ? const Color(0xFF2563EB).withValues(alpha: 0.12)
                          : const Color(0xFF10B981).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: payment.isQueueToken
                            ? const Color(0xFF2563EB).withValues(alpha: 0.25)
                            : const Color(0xFF10B981).withValues(alpha: 0.25),
                      ),
                    ),
                    child: Text(
                      payment.isQueueToken ? '🎟️ Walk-in Queue Token' : '📅 Booked Appointment',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: payment.isQueueToken
                            ? const Color(0xFF2563EB)
                            : const Color(0xFF10B981),
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),

                  // Status Pill
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                    decoration: BoxDecoration(
                      color: isRefunded
                          ? const Color(0xFF8B5CF6).withValues(alpha: 0.15)
                          : const Color(0xFF10B981).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: isRefunded
                            ? const Color(0xFF8B5CF6).withValues(alpha: 0.35)
                            : const Color(0xFF10B981).withValues(alpha: 0.35),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (!isRefunded) ...[
                          Container(
                            width: 5,
                            height: 5,
                            decoration: const BoxDecoration(
                              color: Color(0xFF10B981),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 4),
                        ],
                        Text(
                          isRefunded ? '↺ Refunded' : '✓ Paid',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: isRefunded
                                ? const Color(0xFF8B5CF6)
                                : const Color(0xFF10B981),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Text(
                payment.date,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: colors.textMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Middle Row: Clinic & Doctor & Identifiers vs Amount Block
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      payment.clinicName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800,
                        color: colors.textPrimary,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${payment.service} · ${payment.doctor}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: colors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        if (payment.token != null && payment.token!.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: colors.surfaceSecondary,
                              borderRadius: BorderRadius.circular(5),
                              border: Border.all(color: colors.border),
                            ),
                            child: Text(
                              '🏷️ ${payment.token}',
                              style: GoogleFonts.spaceMono(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                                color: colors.primary,
                              ),
                            ),
                          ),
                        if (payment.bookingId.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: colors.surfaceSecondary,
                              borderRadius: BorderRadius.circular(5),
                              border: Border.all(color: colors.border),
                            ),
                            child: Text(
                              '📅 ${payment.bookingId}',
                              style: GoogleFonts.spaceMono(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF10B981),
                              ),
                            ),
                          ),
                        Text(
                          payment.receiptNo,
                          style: GoogleFonts.spaceMono(
                            fontSize: 10.5,
                            color: colors.textSubtle,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '₹${payment.amount.toStringAsFixed(0)}',
                    style: GoogleFonts.spaceMono(
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                      color: isRefunded ? const Color(0xFF8B5CF6) : colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    isRefunded ? 'Full Refund Credited' : '✓ Paid (Success)',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: isRefunded ? const Color(0xFFA78BFA) : const Color(0xFF10B981),
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Refund Callout Box (if refunded)
          if (isRefunded) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF8B5CF6).withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: const Color(0xFF8B5CF6).withValues(alpha: 0.3),
                  style: BorderStyle.solid,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '↺ Refund Credited to Original Source',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF7C3AED),
                        ),
                      ),
                      Text(
                        payment.refundId ?? 'REF-2026',
                        style: GoogleFonts.spaceMono(
                          fontSize: 10,
                          color: colors.textMuted,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${payment.refundReason ?? "Appointment cancelled by patient"} · Credited to ${payment.refundToAccount ?? payment.method}',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: colors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Processed on ${payment.refundedAt ?? payment.date}',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      color: colors.textSubtle,
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 10),
          Divider(height: 1, color: colors.border),
          const SizedBox(height: 8),

          // Footer: Payment Method & Action Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Text('💳', style: TextStyle(fontSize: 13)),
                  const SizedBox(width: 5),
                  Text(
                    payment.method,
                    style: GoogleFonts.inter(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                      color: colors.textMuted,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  OutlinedButton.icon(
                    onPressed: onViewReceipt,
                    icon: Text(
                      isRefunded ? '↺' : '🧾',
                      style: const TextStyle(fontSize: 12),
                    ),
                    label: Text(
                      isRefunded ? 'Refund Slip' : 'View Receipt',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: colors.textPrimary,
                      side: BorderSide(color: colors.border),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      visualDensity: VisualDensity.compact,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  InkWell(
                    onTap: onDownloadReceipt,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: colors.surfaceSecondary,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: colors.border),
                      ),
                      alignment: Alignment.center,
                      child: const Text('⬇️', style: TextStyle(fontSize: 12)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
