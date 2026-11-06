import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';
import '../../../appointments/domain/entities/clinic_appointment_entity.dart';

/// Card showing the table of upcoming appointments in the clinic dashboard matching web-admin:
/// Columns: Time, Customer, Service Selected, Doctor, Payment, Status.
class UpcomingAppointmentsCard extends StatelessWidget {
  static const double _minTableWidth = 660;
  static const double cardHeight = 480;

  final List<ClinicAppointmentEntity> appointments;
  final VoidCallback? onViewAll;
  final ValueChanged<ClinicAppointmentEntity>? onSelectAppointment;

  const UpcomingAppointmentsCard({
    super.key,
    this.appointments = const [],
    this.onViewAll,
    this.onSelectAppointment,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final apptList = appointments;

    return Container(
      height: cardHeight,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border),
      ),
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Title and "View all →" action
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Upcoming appointments',
                style: GoogleFonts.inter(
                  fontSize: 15.5,
                  fontWeight: FontWeight.w700,
                  color: colors.textPrimary,
                ),
              ),
              InkWell(
                onTap: onViewAll,
                borderRadius: BorderRadius.circular(6),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  child: Row(
                    children: [
                      Text(
                        'View all',
                        style: GoogleFonts.inter(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: colors.primary,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.arrow_forward_rounded,
                        size: 14,
                        color: colors.primary,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Responsive Table
          Expanded(
            child: LayoutBuilder(
            builder: (context, constraints) {
              final tableContent = Column(
                children: [
                  // Table Header
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      children: [
                        _colHeader('TIME', flex: 2, colors: colors),
                        _colHeader('CUSTOMER', flex: 4, colors: colors),
                        _colHeader('SERVICE SELECTED', flex: 5, colors: colors),
                        _colHeader('DOCTOR', flex: 3, colors: colors),
                        _colHeader('PAYMENT', flex: 3, colors: colors),
                        _colHeader('STATUS', flex: 3, colors: colors, alignRight: true),
                      ],
                    ),
                  ),

                  Divider(height: 1, color: colors.border),

                  if (apptList.isEmpty)
                    Expanded(
                      child: Center(
                        child: Text(
                          'No upcoming appointments.',
                          style: GoogleFonts.inter(
                            fontSize: 12.5,
                            color: colors.textMuted,
                          ),
                        ),
                      ),
                    )
                  else
                    Expanded(
                      child: Scrollbar(
                        child: ListView.separated(
                          itemCount: apptList.length,
                          separatorBuilder: (context, index) =>
                              Divider(height: 1, color: colors.borderSubtle),
                          itemBuilder: (context, index) {
                            final a = apptList[index];
                            return _AppointmentRowItem(
                              appointment: a,
                              onTap: () => onSelectAppointment?.call(a),
                            );
                          },
                        ),
                      ),
                    ),
                ],
              );

              if (constraints.maxWidth >= _minTableWidth) return tableContent;
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SizedBox(width: _minTableWidth, child: tableContent),
              );
            },
            ),
          ),
        ],
      ),
    );
  }

  Widget _colHeader(
    String title, {
    required int flex,
    required AppColorsExtension colors,
    bool alignRight = false,
  }) {
    return Expanded(
      flex: flex,
      child: Text(
        title,
        textAlign: alignRight ? TextAlign.right : TextAlign.left,
        style: GoogleFonts.inter(
          fontSize: 10.5,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
          color: colors.textMuted,
        ),
      ),
    );
  }
}

class _AppointmentRowItem extends StatelessWidget {
  final ClinicAppointmentEntity appointment;
  final VoidCallback onTap;

  const _AppointmentRowItem({
    required this.appointment,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 1. Time (Mono bold)
            Expanded(
              flex: 2,
              child: Text(
                appointment.timeRaw,
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: colors.textPrimary,
                ),
              ),
            ),

            // 2. Customer (Name + phone)
            Expanded(
              flex: 4,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    appointment.customerName,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: colors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    appointment.phone,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: colors.textMuted,
                    ),
                  ),
                ],
              ),
            ),

            // 3. Service Selected (Title + Dept Chip + Duration)
            Expanded(
              flex: 5,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    appointment.service,
                    style: GoogleFonts.inter(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: colors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Wrap(
                    spacing: 6,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                        decoration: BoxDecoration(
                          color: colors.primaryTint,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          appointment.departmentName,
                          style: GoogleFonts.inter(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w700,
                            color: colors.primary,
                          ),
                        ),
                      ),
                      Text(
                        '⏱️ ${appointment.serviceDuration}',
                        style: GoogleFonts.inter(
                          fontSize: 10.5,
                          color: colors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // 4. Doctor
            Expanded(
              flex: 3,
              child: Text(
                appointment.doctor,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: colors.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            // 5. Payment Pill
            Expanded(
              flex: 3,
              child: _buildPaymentPill(context, appointment.payment),
            ),

            // 6. Status Pill
            Expanded(
              flex: 3,
              child: Align(
                alignment: Alignment.centerRight,
                child: _buildStatusPill(context, appointment.status),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentPill(BuildContext context, AppointmentPaymentEntity payment) {
    final colors = context.colors;
    Color bg;
    Color fg;
    String text;

    final amt = payment.amount.toStringAsFixed(0);
    if (payment.isPaid) {
      bg = colors.successTint;
      fg = colors.success;
      text = '✓ PAID ₹$amt';
    } else if (payment.isRefunded) {
      bg = colors.errorTint;
      fg = colors.error;
      text = '↩ REFUNDED ₹$amt';
    } else {
      bg = colors.warningTint;
      fg = colors.warning;
      text = '⏳ DUE ₹$amt';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: fg,
        ),
      ),
    );
  }

  Widget _buildStatusPill(BuildContext context, String status) {
    final colors = context.colors;
    Color bg;
    Color fg;

    switch (status.toLowerCase()) {
      case 'confirmed':
        bg = colors.primaryTint;
        fg = colors.primary;
        break;
      case 'upcoming':
        bg = colors.infoTint;
        fg = colors.info;
        break;
      case 'checkedin':
      case 'checked-in':
        bg = colors.badgeOpenBg;
        fg = colors.badgeOpenText;
        break;
      case 'completed':
        bg = colors.surfaceSecondary;
        fg = colors.textMuted;
        break;
      case 'cancelled':
        bg = colors.errorTint;
        fg = colors.error;
        break;
      default:
        bg = colors.surfaceSecondary;
        fg = colors.textMuted;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status.toUpperCase(),
        style: GoogleFonts.inter(
          fontSize: 9.5,
          fontWeight: FontWeight.w800,
          color: fg,
        ),
      ),
    );
  }
}
