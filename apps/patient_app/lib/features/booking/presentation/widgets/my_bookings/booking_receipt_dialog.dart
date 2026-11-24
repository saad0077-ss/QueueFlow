import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

import '../../../domain/entities/appointment_entity.dart';
import 'booking_receipt_dialog_helpers.dart';

class BookingReceiptDialog extends StatelessWidget {
  final AppointmentEntity apt;

  const BookingReceiptDialog({super.key, required this.apt});

  static void show(BuildContext context, AppointmentEntity apt) {
    final colors = context.colors;
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: colors.surfaceElevated,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: colors.border),
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(18),
            child: BookingReceiptDialog(apt: apt),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final label = GoogleFonts.inter(
      fontSize: 10.5,
      fontWeight: FontWeight.w800,
      letterSpacing: 0.6,
    );
    final payId = apt.payment?.paymentId ?? '';
    final receiptNo = 'REC-${apt.bookingRef.replaceAll('QF-', '')}';

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'REF: ${apt.bookingRef}',
                    style: GoogleFonts.robotoMono(
                      fontSize: 11,
                      color: colors.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    apt.clinicName,
                    style: GoogleFonts.inter(
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                      color: colors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Icon(
                Icons.close_rounded,
                color: colors.textPrimary,
                size: 22,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        BookingReceiptDialogHelpers.dlgBox(
          context,
          colors.primary.withValues(alpha: 0.5),
          [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'SERVICE SELECTED',
                    style: label.copyWith(color: colors.primary),
                  ),
                ),
                BookingReceiptDialogHelpers.pill(
                  '⏰ ${apt.serviceDuration} mins',
                  colors.success,
                  size: 11,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              apt.serviceName,
              style: GoogleFonts.inter(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: colors.textPrimary,
              ),
            ),
            if (apt.doctorSpecialty.isNotEmpty) ...[
              const SizedBox(height: 8),
              BookingReceiptDialogHelpers.pill(
                '🩺 ${apt.doctorSpecialty}',
                colors.primary,
                size: 11,
              ),
            ],
            if (apt.notes.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                apt.notes,
                style: GoogleFonts.inter(
                  fontSize: 12.5,
                  color: colors.textMuted,
                  height: 1.4,
                ),
              ),
            ],
            Divider(color: colors.border, height: 22),
            BookingReceiptDialogHelpers.dlgRow(
              context,
              'Consulting Doctor:',
              apt.doctorName,
            ),
            BookingReceiptDialogHelpers.dlgRow(
              context,
              'Appointment Time:',
              apt.dateTime,
            ),
          ],
        ),
        if (apt.isCancelled) ...[
          const SizedBox(height: 14),
          BookingReceiptDialogHelpers.dlgBox(
            context,
            colors.error.withValues(alpha: 0.5),
            [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'CANCELLATION & REFUND',
                      style: label.copyWith(color: colors.error),
                    ),
                  ),
                  BookingReceiptDialogHelpers.pill(
                    '✕ CANCELLED',
                    colors.error,
                    size: 11,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              BookingReceiptDialogHelpers.dlgRow(
                context,
                'Booking Status:',
                'Cancelled',
              ),
              BookingReceiptDialogHelpers.dlgRow(
                context,
                'Refund Status:',
                apt.isPaid ? 'Refund initiated' : 'No charge applied',
                color: apt.isPaid ? colors.warning : colors.success,
              ),
              if (apt.isPaid) ...[
                BookingReceiptDialogHelpers.dlgRow(
                  context,
                  'Refund Amount:',
                  '₹${apt.servicePrice.toStringAsFixed(2)}',
                ),
                BookingReceiptDialogHelpers.dlgRow(
                  context,
                  'Refund To:',
                  apt.payment?.method ?? 'Original payment method',
                ),
                BookingReceiptDialogHelpers.dlgRow(
                  context,
                  'Expected By:',
                  '5-7 business days',
                ),
              ],
              const SizedBox(height: 6),
              Text(
                apt.isPaid
                    ? 'Your payment will be returned to the original payment method.'
                    : 'This booking was unpaid, so there is nothing to refund.',
                style: GoogleFonts.inter(
                  fontSize: 11.5,
                  color: colors.textMuted,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ],
        const SizedBox(height: 14),
        BookingReceiptDialogHelpers.dlgBox(context, colors.border, [
          Row(
            children: [
              Expanded(
                child: Text(
                  'PAYMENT & INVOICING',
                  style: label.copyWith(color: colors.textMuted),
                ),
              ),
              apt.isCancelled && apt.isPaid
                  ? BookingReceiptDialogHelpers.pill(
                      '↩ REFUND',
                      colors.warning,
                      size: 11,
                    )
                  : apt.isPaid
                  ? BookingReceiptDialogHelpers.pill(
                      '✓ PAID',
                      colors.success,
                      size: 11,
                    )
                  : BookingReceiptDialogHelpers.pill(
                      '⏳ DUE',
                      colors.warning,
                      size: 11,
                    ),
            ],
          ),
          const SizedBox(height: 10),
          BookingReceiptDialogHelpers.dlgRow(
            context,
            apt.isPaid ? 'Total Amount Paid:' : 'Total Amount Due:',
            '₹${apt.servicePrice.toStringAsFixed(2)}',
            size: 20,
          ),
          BookingReceiptDialogHelpers.dlgRow(
            context,
            'Payment Method:',
            apt.isPaid ? (apt.payment?.method ?? 'Online') : 'Pay at clinic',
          ),
          if (payId.isNotEmpty)
            BookingReceiptDialogHelpers.dlgRow(
              context,
              'Transaction ID:',
              payId,
              color: colors.primary,
              mono: true,
              size: 11.5,
            ),
          BookingReceiptDialogHelpers.dlgRow(
            context,
            'Receipt Reference:',
            receiptNo,
          ),
        ]),
        const SizedBox(height: 18),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(16),
          ),
          child: TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: Text(
              'Close Details',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
