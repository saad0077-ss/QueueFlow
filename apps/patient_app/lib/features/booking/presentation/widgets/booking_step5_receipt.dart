import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:patient_app/core/theme/app_colors.dart';
import 'package:patient_app/core/widgets/gradient_button.dart';
import 'package:patient_app/features/booking/domain/entities/appointment_entity.dart';

class BookingStep5Receipt extends StatelessWidget {
  final AppointmentEntity appointment;
  final VoidCallback onViewMyBookings;
  final VoidCallback onBackToHome;

  const BookingStep5Receipt({
    super.key,
    required this.appointment,
    required this.onViewMyBookings,
    required this.onBackToHome,
  });

  void _copyReference(BuildContext context) {
    Clipboard.setData(ClipboardData(text: appointment.bookingRef));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Booking Reference ${appointment.bookingRef} copied!'),
        backgroundColor: AppColors.success,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 12),

        // Glowing Success Badge
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [Color(0xFF10B981), Color(0xFF059669)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF10B981).withValues(alpha: 0.45),
                blurRadius: 24,
                spreadRadius: 4,
              ),
            ],
          ),
          child: const Center(
            child: Icon(
              Icons.check_rounded,
              color: Colors.white,
              size: 40,
            ),
          ),
        ),

        const SizedBox(height: 18),

        Text(
          'Appointment Confirmed!',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AppColors.darkInk,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Your medical consultation has been booked successfully.',
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 12.5,
            color: AppColors.darkInkMuted,
          ),
        ),

        const SizedBox(height: 20),

        // Receipt Card
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.darkSurface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.darkBorder, width: 1.2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Booking Reference Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'BOOKING REFERENCE',
                        style: GoogleFonts.inter(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          color: AppColors.darkInkMuted,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        appointment.bookingRef,
                        style: GoogleFonts.robotoMono(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primaryLight,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () => _copyReference(context),
                    icon: const Icon(Icons.copy_rounded, color: AppColors.primaryLight),
                    tooltip: 'Copy Reference',
                  ),
                ],
              ),

              const SizedBox(height: 14),
              const Divider(color: AppColors.darkBorder, height: 1),
              const SizedBox(height: 14),

              // Detail Rows
              _buildDetailRow(
                'Clinic',
                appointment.clinicName,
                subtitle: appointment.clinicAddress,
              ),
              const SizedBox(height: 12),
              _buildDetailRow(
                'Doctor',
                appointment.doctorName,
                subtitle: appointment.doctorSpecialty,
              ),
              const SizedBox(height: 12),
              _buildDetailRow(
                'Service',
                appointment.serviceName,
                subtitle: '${appointment.serviceDuration} min consultation',
              ),
              const SizedBox(height: 12),
              _buildDetailRow(
                'Scheduled For',
                appointment.dateTime,
                isHighlight: true,
              ),

              const SizedBox(height: 14),
              const Divider(color: AppColors.darkBorder, height: 1),
              const SizedBox(height: 14),

              // Payment Status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Payment Status',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: AppColors.darkInkMuted,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.success.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: AppColors.success.withValues(alpha: 0.35),
                          ),
                        ),
                        child: Text(
                          'PAID (RAZORPAY TEST)',
                          style: GoogleFonts.inter(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                            color: AppColors.success,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Amount Paid',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: AppColors.darkInkMuted,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '₹${appointment.servicePrice.toStringAsFixed(2)}',
                        style: GoogleFonts.robotoMono(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: AppColors.darkInk,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              if (appointment.payment?.paymentId != null) ...[
                const SizedBox(height: 8),
                Text(
                  'Transaction ID: ${appointment.payment!.paymentId}',
                  style: GoogleFonts.robotoMono(
                    fontSize: 10.5,
                    color: AppColors.darkInkFaint,
                  ),
                ),
              ],
            ],
          ),
        ),

        const SizedBox(height: 14),

        // SMS & Push alert notice strip
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.25),
            ),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.notifications_active_outlined,
                size: 16,
                color: AppColors.primaryLight,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Confirmation SMS and reminder alerts dispatched to ${appointment.customerPhone.isNotEmpty ? appointment.customerPhone : 'your mobile'}.',
                  style: GoogleFonts.inter(
                    fontSize: 11.5,
                    color: AppColors.primaryLight,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Action Buttons
        GradientButton(
          text: 'View in My Bookings',
          onPressed: onViewMyBookings,
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.darkSurface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.darkBorder, width: 1.2),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(24),
              onTap: onBackToHome,
              child: Center(
                child: Text(
                  'Back to Home',
                  style: GoogleFonts.inter(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkInk,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value, {String? subtitle, bool isHighlight = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            color: AppColors.darkInkMuted,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: isHighlight ? AppColors.primaryLight : AppColors.darkInk,
                ),
                textAlign: TextAlign.end,
              ),
              if (subtitle != null && subtitle.isNotEmpty) ...[
                const SizedBox(height: 1),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: AppColors.darkInkMuted,
                  ),
                  textAlign: TextAlign.end,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
