import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';
import '../../../../core/widgets/app_snack_bar.dart';
import '../../domain/entities/clinic_appointment_entity.dart';
import '../../data/services/appointment_invoice_pdf.dart';
import '../widgets/patient_avatar.dart';

/// Full-screen appointment detail view (replaces the old slide-over drawer).
class AppointmentDetailPage extends StatelessWidget {
  final ClinicAppointmentEntity appointment;
  final VoidCallback onBack;
  final VoidCallback onCheckIn;
  final VoidCallback onComplete;
  final VoidCallback onReschedule;
  final VoidCallback onCancel;

  const AppointmentDetailPage({
    super.key,
    required this.appointment,
    required this.onBack,
    required this.onCheckIn,
    required this.onComplete,
    required this.onReschedule,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 40),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 960;

          final mainColumn = Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _serviceCard(context),
              const SizedBox(height: 18),
              _visitCard(context),
              const SizedBox(height: 18),
              _notesCard(context),
            ],
          );

          final sideColumn = Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _paymentCard(context),
              const SizedBox(height: 18),
              _timelineCard(context),
            ],
          );

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Back navigation
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: onBack,
                  icon: Icon(
                    Icons.arrow_back_rounded,
                    size: 18,
                    color: colors.textMuted,
                  ),
                  label: Text(
                    'Back to Appointments',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: colors.textMuted,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              _heroCard(context, wide),
              const SizedBox(height: 18),
              if (wide)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 60, child: mainColumn),
                    const SizedBox(width: 18),
                    Expanded(flex: 40, child: sideColumn),
                  ],
                )
              else ...[
                mainColumn,
                const SizedBox(height: 18),
                sideColumn,
              ],
            ],
          );
        },
      ),
    );
  }

  // ───────────────────────── Hero ─────────────────────────

  Widget _heroCard(BuildContext context, bool wide) {
    final colors = context.colors;
    final a = appointment;

    final identity = Row(
      children: [
        PatientAvatar(
          photo: a.customerPhoto,
          initials: a.initials,
          size: 64,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 10,
                runSpacing: 6,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    a.customerName,
                    style: GoogleFonts.inter(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: colors.textPrimary,
                      letterSpacing: -0.3,
                    ),
                  ),
                  _statusPill(context, a.status),
                ],
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 16,
                runSpacing: 4,
                children: [
                  _metaItem(
                    colors,
                    Icons.confirmation_number_outlined,
                    '#${a.bookingId}',
                    mono: true,
                  ),
                  _metaItem(colors, Icons.phone_outlined, a.phone),
                  _metaItem(colors, Icons.mail_outline_rounded, a.email),
                ],
              ),
            ],
          ),
        ),
      ],
    );

    final actions = Wrap(
      spacing: 10,
      runSpacing: 10,
      alignment: wide ? WrapAlignment.end : WrapAlignment.start,
      children: _actionButtons(context),
    );

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          identity,
          const SizedBox(height: 18),
          Divider(height: 1, color: colors.border),
          const SizedBox(height: 18),
          actions,
        ],
      ),
    );
  }

  Widget _metaItem(
    AppColorsExtension colors,
    IconData icon,
    String text, {
    bool mono = false,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: colors.textMuted),
        const SizedBox(width: 5),
        Flexible(
          child: Text(
            text,
            overflow: TextOverflow.ellipsis,
            style: mono
                ? GoogleFonts.jetBrainsMono(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: colors.primary,
                  )
                : GoogleFonts.inter(fontSize: 12.5, color: colors.textMuted),
          ),
        ),
      ],
    );
  }

  List<Widget> _actionButtons(BuildContext context) {
    final colors = context.colors;
    final a = appointment;
    final open = !a.isCompleted && !a.isCancelled;

    ButtonStyle outlined(Color side, {Color? bg}) => OutlinedButton.styleFrom(
      backgroundColor: bg,
      side: BorderSide(color: side),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
    );

    TextStyle label(Color c) => GoogleFonts.inter(
      fontSize: 12.5,
      fontWeight: FontWeight.w700,
      color: c,
    );

    return [
      if (open && !a.isCheckedIn)
        ElevatedButton.icon(
          onPressed: onCheckIn,
          icon: const Icon(
            Icons.how_to_reg_rounded,
            size: 17,
            color: Colors.white,
          ),
          label: Text('Check In Patient', style: label(Colors.white)),
          style: ElevatedButton.styleFrom(
            backgroundColor: colors.primary,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
        ),
      if (open)
        OutlinedButton.icon(
          onPressed: onComplete,
          icon: Icon(
            Icons.check_circle_outline_rounded,
            size: 17,
            color: colors.success,
          ),
          label: Text('Mark Completed', style: label(colors.success)),
          style: outlined(colors.success),
        ),
      if (open)
        OutlinedButton.icon(
          onPressed: onReschedule,
          icon: Icon(
            Icons.event_repeat_rounded,
            size: 17,
            color: colors.textPrimary,
          ),
          label: Text('Reschedule', style: label(colors.textPrimary)),
          style: outlined(colors.border, bg: colors.surfaceSecondary),
        ),
      if (open)
        OutlinedButton.icon(
          onPressed: onCancel,
          icon: Icon(Icons.close_rounded, size: 17, color: colors.error),
          label: Text('Cancel Appointment', style: label(colors.error)),
          style: outlined(colors.error),
        ),
    ];
  }

  // ───────────────────────── Cards ─────────────────────────

  Widget _card(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Widget child,
    Widget? trailing,
  }) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: colors.primaryTint,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(icon, size: 17, color: colors.primary),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: colors.textPrimary,
                  ),
                ),
              ),
              ?trailing,
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _serviceCard(BuildContext context) {
    final colors = context.colors;
    final a = appointment;

    return _card(
      context,
      title: 'Service Selected',
      icon: Icons.medical_services_outlined,
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: colors.badgeOpenBg,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.schedule_rounded, size: 12, color: colors.badgeOpenText),
            const SizedBox(width: 4),
            Text(
              a.serviceDuration,
              style: GoogleFonts.inter(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                color: colors.badgeOpenText,
              ),
            ),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            a.service,
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
            decoration: BoxDecoration(
              color: colors.primaryTint,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: colors.primary.withValues(alpha: 0.2)),
            ),
            child: Text(
              a.departmentName,
              style: GoogleFonts.inter(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: colors.primary,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            a.serviceDescription,
            style: GoogleFonts.inter(
              fontSize: 13,
              height: 1.55,
              color: colors.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _visitCard(BuildContext context) {
    final a = appointment;

    return _card(
      context,
      title: 'Visit Details',
      icon: Icons.event_note_rounded,
      child: LayoutBuilder(
        builder: (context, c) {
          final cols = c.maxWidth >= 480 ? 2 : 1;
          final w = (c.maxWidth - 16 * (cols - 1)) / cols;
          Widget cell(String label, String value, IconData icon) =>
              SizedBox(width: w, child: _infoTile(context, label, value, icon));
          return Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              cell('Assigned Doctor', a.doctor, Icons.person_outline_rounded),
              cell('Doctor Role', a.doctorRole, Icons.badge_outlined),
              cell('Date & Time', a.dateTime, Icons.calendar_today_outlined),
              cell('Visit Type', a.type, Icons.groups_2_outlined),
              cell('Room', a.room, Icons.meeting_room_outlined),
              cell('Category', a.serviceCategory, Icons.category_outlined),
            ],
          );
        },
      ),
    );
  }

  Widget _infoTile(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.surfaceSecondary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: colors.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label.toUpperCase(),
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.4,
                    color: colors.textMuted,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: colors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _notesCard(BuildContext context) {
    final colors = context.colors;
    final a = appointment;
    return _card(
      context,
      title: 'Visit Notes & Symptoms',
      icon: Icons.sticky_note_2_outlined,
      child: Text(
        a.notes.isNotEmpty ? a.notes : 'No specific symptoms noted.',
        style: GoogleFonts.inter(
          fontSize: 13,
          height: 1.55,
          color: colors.textPrimary,
        ),
      ),
    );
  }

  Widget _paymentCard(BuildContext context) {
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

    return _card(
      context,
      title: 'Payment & Billing',
      icon: Icons.account_balance_wallet_outlined,
      trailing: _paymentPill(context, p),
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

  Widget _timelineCard(BuildContext context) {
    final colors = context.colors;
    final a = appointment;

    final steps = <_Step>[
      const _Step('Booked', 'Appointment created', true),
      _Step(
        'Confirmed',
        'Slot confirmed with clinic',
        a.isConfirmed || a.isCheckedIn || a.isCompleted,
      ),
      _Step(
        'Checked In',
        'Patient arrived at clinic',
        a.isCheckedIn || a.isCompleted,
      ),
      _Step('Completed', 'Consultation finished', a.isCompleted),
    ];

    return _card(
      context,
      title: 'Progress',
      icon: Icons.timeline_rounded,
      child: a.isCancelled
          ? Row(
              children: [
                Icon(Icons.cancel_rounded, color: colors.error, size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'This appointment was cancelled.',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: colors.error,
                    ),
                  ),
                ),
              ],
            )
          : Column(
              children: [
                for (var i = 0; i < steps.length; i++)
                  _timelineRow(colors, steps[i], isLast: i == steps.length - 1),
              ],
            ),
    );
  }

  Widget _timelineRow(
    AppColorsExtension colors,
    _Step s, {
    required bool isLast,
  }) {
    final color = s.done ? colors.success : colors.border;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 24,
            child: Column(
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: s.done ? colors.success : Colors.transparent,
                    border: Border.all(color: color, width: 2),
                  ),
                  child: s.done
                      ? const Icon(Icons.check, size: 12, color: Colors.white)
                      : null,
                ),
                if (!isLast) Expanded(child: Container(width: 2, color: color)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    s.title,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: s.done ? colors.textPrimary : colors.textMuted,
                    ),
                  ),
                  Text(
                    s.subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 11.5,
                      color: colors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ───────────────────────── Pills ─────────────────────────

  Widget _statusPill(BuildContext context, String status) {
    final colors = context.colors;
    Color bg;
    Color fg;
    String label;
    switch (status.toLowerCase()) {
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 10.5,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.3,
          color: fg,
        ),
      ),
    );
  }

  Widget _paymentPill(BuildContext context, AppointmentPaymentEntity p) {
    final colors = context.colors;
    final Color bg;
    final Color fg;
    final String label;
    if (p.isPaid) {
      bg = colors.successTint;
      fg = colors.success;
      label = 'PAID';
    } else if (p.isRefunded) {
      bg = colors.errorTint;
      fg = colors.error;
      label = p.isRefundPending ? 'REFUND PENDING' : 'REFUNDED';
    } else if (p.isVoid) {
      bg = colors.surfaceSecondary;
      fg = colors.textMuted;
      label = 'VOID';
    } else {
      bg = colors.warningTint;
      fg = colors.warning;
      label = 'DUE';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 10.5,
          fontWeight: FontWeight.w800,
          color: fg,
        ),
      ),
    );
  }
}

class _Step {
  final String title;
  final String subtitle;
  final bool done;

  const _Step(this.title, this.subtitle, this.done);
}
