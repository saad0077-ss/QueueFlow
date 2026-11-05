import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';
import '../../domain/entities/clinic_appointment_entity.dart';

class AppointmentsListTable extends StatelessWidget {
  final List<ClinicAppointmentEntity> appointments;
  final ValueChanged<ClinicAppointmentEntity> onSelectAppointment;

  const AppointmentsListTable({
    super.key,
    required this.appointments,
    required this.onSelectAppointment,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    if (appointments.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 20),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: colors.border),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: colors.primaryTint,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.search_off_rounded,
                size: 28,
                color: colors.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No appointments found',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: colors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Try adjusting your filters or search query to find patient bookings.',
              style: GoogleFonts.inter(fontSize: 13, color: colors.textMuted),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 760) {
          return _buildCardList();
        }
        return _buildTable(context, constraints.maxWidth);
      },
    );
  }

  Widget _buildCardList() {
    return Column(
      children: [
        for (final appt in appointments)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _AppointmentMobileCard(
              appointment: appt,
              onTap: () => onSelectAppointment(appt),
            ),
          ),
      ],
    );
  }

  Widget _buildTable(BuildContext context, double availableWidth) {
    final colors = context.colors;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: availableWidth < 1400 ? 1400 : availableWidth - 2,
            child: DataTable(
              showCheckboxColumn: false,
              headingRowColor: WidgetStateProperty.all(colors.surfaceSecondary),
              horizontalMargin: 20,
              columnSpacing: 22,
              headingRowHeight: 48,
              dataRowMinHeight: 68,
              dataRowMaxHeight: 72,
              border: TableBorder(
                horizontalInside: BorderSide(color: colors.border, width: 0.8),
              ),
              columns: [
                _buildHeader(context, 'Booking Ref'),
                _buildHeader(context, 'Patient'),
                _buildHeader(context, 'Service Selected'),
                _buildHeader(context, 'Department'),
                _buildHeader(context, 'Doctor'),
                _buildHeader(context, 'Date & Time'),
                _buildHeader(context, 'Payment'),
                _buildHeader(context, 'Status'),
                _buildHeader(context, 'Action', alignRight: true),
              ],
              rows: appointments.map((appt) {
                return DataRow(
                  onSelectChanged: (_) => onSelectAppointment(appt),
                  cells: [
                    // Booking Ref
                    DataCell(
                      InkWell(
                        onTap: () => onSelectAppointment(appt),
                        child: Text(
                          '#${appt.bookingId}',
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: colors.primary,
                          ),
                        ),
                      ),
                    ),

                    // Patient (Name + phone)
                    DataCell(
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _Avatar(initials: appt.initials),
                          const SizedBox(width: 10),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                appt.customerName,
                                style: GoogleFonts.inter(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w700,
                                  color: colors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                appt.phone,
                                style: GoogleFonts.inter(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w500,
                                  color: colors.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Service Selected (Name + duration)
                    DataCell(
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            appt.service,
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: colors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.schedule_rounded,
                                size: 11,
                                color: colors.textMuted,
                              ),
                              const SizedBox(width: 3),
                              Text(
                                appt.serviceDuration,
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  color: colors.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Department chip
                    DataCell(
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: colors.primaryTint,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: colors.primary.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Text(
                          appt.departmentName,
                          softWrap: false,
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: colors.primary,
                          ),
                        ),
                      ),
                    ),

                    // Doctor
                    DataCell(
                      Text(
                        appt.doctor,
                        softWrap: false,
                        style: GoogleFonts.inter(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: colors.textPrimary,
                        ),
                      ),
                    ),

                    // Date & Time
                    DataCell(
                      Text(
                        appt.dateTime,
                        softWrap: false,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: colors.textPrimary,
                        ),
                      ),
                    ),

                    // Payment pill
                    DataCell(_PaymentCell(payment: appt.payment)),

                    // Status pill
                    DataCell(_StatusCell(status: appt.status)),

                    // Action: Details
                    DataCell(
                      Align(
                        alignment: Alignment.centerRight,
                        child: OutlinedButton(
                          onPressed: () => onSelectAppointment(appt),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: colors.surfaceSecondary,
                            side: BorderSide(color: colors.border),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 7,
                            ),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Details',
                                style: GoogleFonts.inter(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w600,
                                  color: colors.textPrimary,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                Icons.chevron_right_rounded,
                                size: 14,
                                color: colors.textMuted,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  DataColumn _buildHeader(
    BuildContext context,
    String text, {
    bool alignRight = false,
  }) {
    final colors = context.colors;
    return DataColumn(
      label: alignRight
          ? Expanded(
              child: Text(
                text.toUpperCase(),
                textAlign: TextAlign.right,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.05,
                  color: colors.textMuted,
                ),
              ),
            )
          : Text(
              text.toUpperCase(),
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.05,
                color: colors.textMuted,
              ),
            ),
    );
  }
}

class _PaymentCell extends StatelessWidget {
  final AppointmentPaymentEntity payment;

  const _PaymentCell({required this.payment});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    Color bg;
    Color fg;
    String prefix;

    if (payment.isPaid) {
      bg = colors.successTint;
      fg = colors.success;
      prefix = '✓ PAID';
    } else if (payment.isRefunded) {
      bg = colors.errorTint;
      fg = colors.error;
      prefix = payment.isRefundPending ? '↩ REFUND PENDING' : '↩ REFUNDED';
    } else if (payment.isVoid) {
      bg = colors.surfaceSecondary;
      fg = colors.textMuted;
      prefix = '— VOID';
    } else {
      bg = colors.warningTint;
      fg = colors.warning;
      prefix = '⏳ DUE';
    }

    final amountStr = '₹${payment.amount.toStringAsFixed(0)}';

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: fg.withValues(alpha: 0.2)),
          ),
          child: Text(
            '$prefix $amountStr',
            style: GoogleFonts.inter(
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.2,
              color: fg,
            ),
          ),
        ),
        if (payment.paymentId.isNotEmpty) ...[
          const SizedBox(height: 2),
          Text(
            payment.paymentId,
            style: GoogleFonts.jetBrainsMono(
              fontSize: 9.5,
              color: colors.textMuted,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }
}

class _StatusCell extends StatelessWidget {
  final String status;

  const _StatusCell({required this.status});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final s = status.toLowerCase();

    Color bg;
    Color fg;
    String label;

    switch (s) {
      case 'confirmed':
        bg = colors.primaryTint;
        fg = colors.primary;
        label = 'CONFIRMED';
        break;
      case 'upcoming':
        bg = colors.infoTint;
        fg = colors.info;
        label = 'UPCOMING';
        break;
      case 'checkedin':
      case 'checked-in':
        bg = colors.badgeOpenBg;
        fg = colors.badgeOpenText;
        label = 'CHECKED IN';
        break;
      case 'completed':
        bg = colors.surfaceSecondary;
        fg = colors.textMuted;
        label = 'COMPLETED';
        break;
      case 'cancelled':
        bg = colors.errorTint;
        fg = colors.error;
        label = 'CANCELLED';
        break;
      default:
        bg = colors.surfaceSecondary;
        fg = colors.textMuted;
        label = status.toUpperCase();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.3,
          color: fg,
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final String initials;
  final double size;

  const _Avatar({required this.initials, this.size = 36});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(colors: [colors.primary, colors.accent]),
      ),
      child: Text(
        initials,
        style: GoogleFonts.inter(
          fontSize: size * 0.36,
          fontWeight: FontWeight.w800,
          color: Colors.white,
        ),
      ),
    );
  }
}

class _AppointmentMobileCard extends StatelessWidget {
  final ClinicAppointmentEntity appointment;
  final VoidCallback onTap;

  const _AppointmentMobileCard({
    required this.appointment,
    required this.onTap,
  });

  Widget _infoRow(
    AppColorsExtension colors,
    IconData icon,
    String text, {
    bool strong = false,
    Widget? trailing,
  }) {
    return Row(
      children: [
        Icon(icon, size: 14, color: colors.textMuted),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              fontSize: 12.5,
              fontWeight: strong ? FontWeight.w600 : FontWeight.w400,
              color: strong ? colors.textPrimary : colors.textMuted,
            ),
          ),
        ),
        ?trailing,
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final a = appointment;

    return Material(
      color: colors.surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: colors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _Avatar(initials: a.initials, size: 40),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          a.customerName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: colors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '#${a.bookingId} · ${a.phone}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            fontSize: 11.5,
                            color: colors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  _StatusCell(status: a.status),
                ],
              ),
              const SizedBox(height: 12),
              Divider(height: 1, color: colors.border),
              const SizedBox(height: 12),
              _infoRow(
                colors,
                Icons.medical_services_outlined,
                '${a.service} · ${a.serviceDuration}',
                strong: true,
              ),
              const SizedBox(height: 6),
              _infoRow(
                colors,
                Icons.person_outline_rounded,
                '${a.doctor} · ${a.departmentName}',
              ),
              const SizedBox(height: 6),
              _infoRow(
                colors,
                Icons.schedule_rounded,
                a.dateTime,
                trailing: _PaymentCell(payment: a.payment),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
