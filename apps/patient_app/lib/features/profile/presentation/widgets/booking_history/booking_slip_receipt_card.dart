import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';
import 'package:patient_app/features/booking/domain/entities/appointment_entity.dart';

class BookingSlipReceiptCard extends StatelessWidget {
  final AppointmentEntity appointment;

  const BookingSlipReceiptCard({super.key, required this.appointment});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final apt = appointment;
    final isPaid = apt.isPaid;
    final payAmount = apt.payment?.amount ?? apt.servicePrice;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border, width: 1.2),
      ),
      child: Column(
        children: [
          Text(
            apt.clinicName,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: colors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Text(
            'QueueFlow Verified Healthcare Provider',
            style: TextStyle(fontSize: 11, color: colors.textMuted),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Text(
            'GSTIN: 32AABCU9603R1ZM',
            style: GoogleFonts.robotoMono(fontSize: 10, color: colors.textSubtle),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Divider(color: colors.border, height: 1),
          const SizedBox(height: 12),
          _item(colors, 'Booking ID:', apt.bookingRef, isMono: true),
          _item(colors, 'Scheduled Time:', apt.dateTime),
          _item(colors, 'Patient Name:', apt.customerName),
          _item(colors, 'Service:', apt.serviceName),
          _item(colors, 'Attending Doctor:', apt.doctorName),
          _item(
            colors,
            'Status:',
            apt.status.toUpperCase(),
            valueColor: isPaid ? const Color(0xFF10B981) : colors.textPrimary,
          ),
          _item(
            colors,
            'Payment Method:',
            apt.payment?.method ?? (isPaid ? 'Online UPI' : 'Pay at Clinic'),
          ),
          _item(
            colors,
            'Transaction Ref:',
            apt.payment?.paymentId ?? 'pay_rzp_${apt.id.substring(0, 6)}',
            isMono: true,
          ),
          const SizedBox(height: 10),
          Divider(color: colors.border, height: 1),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'TOTAL AMOUNT',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: colors.textMuted,
                  letterSpacing: 0.5,
                ),
              ),
              Text(
                '₹${payAmount.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF10B981),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _item(dynamic colors, String label, String value, {bool isMono = false, Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w500, color: colors.textMuted)),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              value,
              style: isMono
                  ? GoogleFonts.robotoMono(fontSize: 11.5, fontWeight: FontWeight.w700, color: valueColor ?? colors.textPrimary)
                  : TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: valueColor ?? colors.textPrimary),
              textAlign: TextAlign.right,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
