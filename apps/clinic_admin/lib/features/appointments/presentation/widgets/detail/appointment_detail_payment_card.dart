import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';
import '../../../../../core/widgets/app_snack_bar.dart';
import '../../../data/services/appointment_invoice_pdf.dart';
import '../../../domain/entities/clinic_appointment_entity.dart';
import 'appointment_detail_section_card.dart';
import 'appointment_status_pills.dart';

class AppointmentDetailPaymentCard extends StatelessWidget {
  final ClinicAppointmentEntity appointment;

  const AppointmentDetailPaymentCard({super.key, required this.appointment});

  Widget _dataRow(
    AppColorsExtension colors,
    String label,
    String value, {
    bool mono = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(fontSize: 12, color: colors.textMuted),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: mono
                  ? GoogleFonts.jetBrainsMono(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: colors.textPrimary,
                    )
                  : GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: colors.textPrimary,
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _transactionRow(BuildContext context, String id) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Text(
            'Transaction ID',
            style: GoogleFonts.inter(fontSize: 12, color: colors.textMuted),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              id,
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.jetBrainsMono(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                color: colors.primary,
              ),
            ),
          ),
          const SizedBox(width: 6),
          InkWell(
            borderRadius: BorderRadius.circular(6),
            onTap: () {
              Clipboard.setData(ClipboardData(text: id));
              AppSnackBar.showSuccess(
                context,
                message: 'Transaction ID copied!',
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Icon(
                Icons.copy_rounded,
                size: 14,
                color: colors.textMuted,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final p = appointment.payment;

    final amountLabel = p.isPaid
        ? 'TOTAL AMOUNT PAID'
        : (p.isRefunded
              ? 'REFUND AMOUNT'
              : (p.isVoid ? 'NO PAYMENT COLLECTED' : 'AMOUNT DUE ON ARRIVAL'));
    final amountColor = p.isPaid
        ? colors.success
        : (p.isRefunded ? colors.error : colors.warning);

    return AppointmentDetailSectionCard(
      title: 'Payment & Billing',
      icon: Icons.account_balance_wallet_outlined,
      trailing: AppointmentPaymentPill(payment: p),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colors.surfaceSecondary,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  amountLabel,
                  style: GoogleFonts.inter(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.4,
                    color: colors.textMuted,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '₹${p.amount.toStringAsFixed(2)}',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: amountColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  p.gateway,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: colors.primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          _dataRow(colors, 'Payment Method', p.method),
          if (p.paymentId.isNotEmpty) _transactionRow(context, p.paymentId),
          if (p.receiptNo.isNotEmpty)
            _dataRow(colors, 'Receipt Ref', p.receiptNo, mono: true),
          if (p.paidAt.isNotEmpty) _dataRow(colors, 'Paid At', p.paidAt),
          if (p.isRefunded) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colors.errorTint,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: colors.error.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    p.isRefundPending
                        ? 'Refund Pending · arrives in 5-7 working days'
                        : 'Refund Processed',
                    style: GoogleFonts.inter(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                      color: colors.error,
                    ),
                  ),
                  const SizedBox(height: 6),
                  _dataRow(
                    colors,
                    'Refund Amount',
                    '₹${(p.refundAmount ?? p.amount).toStringAsFixed(2)}',
                    mono: true,
                  ),
                  _dataRow(
                    colors,
                    'Refund ID',
                    p.refundId ?? 'rfnd_direct',
                    mono: true,
                  ),
                  _dataRow(
                    colors,
                    'Refunded At',
                    p.refundedAt ?? 'Instant Gateway Refund',
                  ),
                  if (p.refundNote != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        p.refundNote!,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: colors.textMuted,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 14),
          OutlinedButton.icon(
            onPressed: () async {
              try {
                await AppointmentInvoicePdf.download(appointment);
              } catch (e) {
                if (context.mounted) {
                  AppSnackBar.showError(
                    context,
                    message: 'Could not generate the invoice: $e',
                  );
                }
              }
            },
            icon: Icon(
              Icons.receipt_long_rounded,
              size: 16,
              color: colors.textPrimary,
            ),
            label: Text(
              'Download Invoice',
              style: GoogleFonts.inter(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: colors.textPrimary,
              ),
            ),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 42),
              backgroundColor: colors.surfaceSecondary,
              side: BorderSide(color: colors.border),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
