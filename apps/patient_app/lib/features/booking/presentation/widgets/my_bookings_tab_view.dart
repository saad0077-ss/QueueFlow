import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:patient_app/features/booking/data/repositories/booking_repository_impl.dart';
import 'package:patient_app/features/booking/domain/entities/appointment_entity.dart';
import 'package:patient_app/features/booking/domain/repositories/booking_repository.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

class MyBookingsTabView extends StatefulWidget {
  final BookingRepository? repository;
  final VoidCallback? onExploreClinics;

  const MyBookingsTabView({super.key, this.repository, this.onExploreClinics});

  @override
  State<MyBookingsTabView> createState() => _MyBookingsTabViewState();
}

class _MyBookingsTabViewState extends State<MyBookingsTabView> {
  late final BookingRepository _repo;
  int _selectedFilterIndex = 0; // 0: Upcoming, 1: Completed, 2: Cancelled
  List<AppointmentEntity> _allAppointments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _repo = widget.repository ?? BookingRepositoryImpl();
    _loadAppointments();
  }

  Future<void> _loadAppointments() async {
    setState(() => _isLoading = true);
    final list = await _repo.getUserAppointments();
    if (mounted) {
      setState(() {
        _allAppointments = list;
        _isLoading = false;
      });
    }
  }

  List<AppointmentEntity> get _filteredAppointments {
    if (_selectedFilterIndex == 0) {
      return _allAppointments.where((a) => a.isUpcoming).toList();
    } else if (_selectedFilterIndex == 1) {
      return _allAppointments.where((a) => a.isCompleted).toList();
    } else {
      return _allAppointments.where((a) => a.isCancelled).toList();
    }
  }

  Future<void> _confirmCancelAppointment(AppointmentEntity apt) async {
    final colors = context.colors;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: colors.surfaceElevated,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: colors.border),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: colors.error,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.delete_outline_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'Cancel appointment?',
                style: GoogleFonts.inter(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: colors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Are you sure you want to cancel this booking? This slot will be released to other patients.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 12.5,
                  color: colors.textMuted,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(9999),
                      ),
                      child: TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Text(
                          'Keep booking',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: colors.error,
                          width: 1.5,
                        ),
                        shape: const StadiumBorder(),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text(
                        'Yes, cancel',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: colors.error,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (confirmed == true) {
      await _repo.cancelAppointment(apt.id);
      await _loadAppointments();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Appointment has been cancelled.'),
            backgroundColor: colors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'My Bookings',
                    style: GoogleFonts.inter(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: colors.textPrimary,
                    ),
                  ),
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(11),
                        decoration: BoxDecoration(
                          color: colors.surface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: colors.border),
                        ),
                        child: Icon(
                          Icons.notifications_none_rounded,
                          color: colors.textPrimary,
                          size: 22,
                        ),
                      ),
                      Positioned(
                        right: 10,
                        top: 10,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: colors.error,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Segmented Filter Tabs
              Container(
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: colors.border),
                ),
                padding: const EdgeInsets.all(4),
                child: Row(
                  children: [
                    _buildFilterTab(0, 'Upcoming'),
                    _buildFilterTab(1, 'Completed'),
                    _buildFilterTab(2, 'Cancelled'),
                  ],
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _loadAppointments,
            color: colors.primary,
            backgroundColor: colors.surface,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Content List
                  if (_isLoading)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: colors.primary,
                        ),
                      ),
                    )
                  else if (_filteredAppointments.isEmpty)
                    _buildEmptyState()
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _filteredAppointments.length,
                      itemBuilder: (context, index) {
                        return _buildAppointmentCard(
                          _filteredAppointments[index],
                        );
                      },
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterTab(int index, String label) {
    final colors = context.colors;
    final isSelected = _selectedFilterIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedFilterIndex = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            gradient: isSelected ? AppColors.primaryGradient : null,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12.5,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected ? Colors.white : colors.textMuted,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final colors = context.colors;
    String label = 'upcoming';
    if (_selectedFilterIndex == 1) label = 'completed';
    if (_selectedFilterIndex == 2) label = 'cancelled';

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 20),
      alignment: Alignment.center,
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colors.surface,
              border: Border.all(color: colors.border),
            ),
            child: Icon(
              Icons.event_busy_rounded,
              size: 30,
              color: colors.textSubtle,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No $label appointments',
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'You do not have any $label clinic consultations at this moment.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 12.5,
              color: colors.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _pill(String text, Color color, {double size = 10.5}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: size,
          fontWeight: FontWeight.w800,
          color: color,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  Widget _infoRow(BuildContext context, IconData icon, String text) {
    final colors = context.colors;
    return Row(
      children: [
        Icon(icon, size: 16, color: colors.textMuted),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.inter(fontSize: 12.5, color: colors.textMuted),
          ),
        ),
      ],
    );
  }

  Widget _dlgRow(
    BuildContext context,
    String k,
    String v, {
    Color? color,
    bool mono = false,
    double size = 12.5,
  }) {
    final colors = context.colors;
    final style = mono ? GoogleFonts.robotoMono : GoogleFonts.inter;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(k, style: GoogleFonts.inter(fontSize: 12.5, color: colors.textMuted)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              v,
              textAlign: TextAlign.right,
              style: style(
                fontSize: size,
                fontWeight: FontWeight.w800,
                color: color ?? colors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dlgBox(BuildContext context, Color border, List<Widget> children) {
    final colors = context.colors;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.surfaceSecondary,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  void _showReceipt(AppointmentEntity apt) {
    final colors = context.colors;
    final label = GoogleFonts.inter(
      fontSize: 10.5,
      fontWeight: FontWeight.w800,
      letterSpacing: 0.6,
    );
    final payId = apt.payment?.paymentId ?? '';
    final receiptNo = 'REC-${apt.bookingRef.replaceAll('QF-', '')}';
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: colors.surfaceElevated,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: colors.border),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(18),
          child: Column(
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
                    onTap: () => Navigator.pop(ctx),
                    child: Icon(
                      Icons.close_rounded,
                      color: colors.textPrimary,
                      size: 22,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _dlgBox(context, colors.primary.withValues(alpha: 0.5), [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'SERVICE SELECTED',
                        style: label.copyWith(color: colors.primary),
                      ),
                    ),
                    _pill(
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
                  _pill('🩺 ${apt.doctorSpecialty}', colors.primary, size: 11),
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
                _dlgRow(context, 'Consulting Doctor:', apt.doctorName),
                _dlgRow(context, 'Appointment Time:', apt.dateTime),
              ]),
              if (apt.isCancelled) ...[
                const SizedBox(height: 14),
                _dlgBox(context, colors.error.withValues(alpha: 0.5), [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'CANCELLATION & REFUND',
                          style: label.copyWith(color: colors.error),
                        ),
                      ),
                      _pill('✕ CANCELLED', colors.error, size: 11),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _dlgRow(context, 'Booking Status:', 'Cancelled'),
                  _dlgRow(
                    context,
                    'Refund Status:',
                    apt.isPaid ? 'Refund initiated' : 'No charge applied',
                    color: apt.isPaid ? colors.warning : colors.success,
                  ),
                  if (apt.isPaid) ...[
                    _dlgRow(
                      context,
                      'Refund Amount:',
                      '₹${apt.servicePrice.toStringAsFixed(2)}',
                    ),
                    _dlgRow(
                      context,
                      'Refund To:',
                      apt.payment?.method ?? 'Original payment method',
                    ),
                    _dlgRow(context, 'Expected By:', '5-7 business days'),
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
                ]),
              ],
              const SizedBox(height: 14),
              _dlgBox(context, colors.border, [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'PAYMENT & INVOICING',
                        style: label.copyWith(color: colors.textMuted),
                      ),
                    ),
                    apt.isCancelled && apt.isPaid
                        ? _pill('↩ REFUND', colors.warning, size: 11)
                        : apt.isPaid
                        ? _pill('✓ PAID', colors.success, size: 11)
                        : _pill('⏳ DUE', colors.warning, size: 11),
                  ],
                ),
                const SizedBox(height: 10),
                _dlgRow(
                  context,
                  apt.isPaid ? 'Total Amount Paid:' : 'Total Amount Due:',
                  '₹${apt.servicePrice.toStringAsFixed(2)}',
                  size: 20,
                ),
                _dlgRow(
                  context,
                  'Payment Method:',
                  apt.isPaid
                      ? (apt.payment?.method ?? 'Online')
                      : 'Pay at clinic',
                ),
                if (payId.isNotEmpty)
                  _dlgRow(
                    context,
                    'Transaction ID:',
                    payId,
                    color: colors.primary,
                    mono: true,
                    size: 11.5,
                  ),
                _dlgRow(context, 'Receipt Reference:', receiptNo),
              ]),
              const SizedBox(height: 18),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: TextButton(
                  onPressed: () => Navigator.pop(ctx),
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
          ),
        ),
      ),
    );
  }

  Widget _actionBtn(String text, IconData icon, Color c, VoidCallback onTap) {
    return Expanded(
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 15),
        label: Text(
          text,
          style: GoogleFonts.inter(fontSize: 12.5, fontWeight: FontWeight.w800),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: c,
          backgroundColor: c.withValues(alpha: 0.10),
          side: BorderSide(color: c.withValues(alpha: 0.4)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 8),
          visualDensity: VisualDensity.compact,
        ),
      ),
    );
  }

  Widget _buildAppointmentCard(AppointmentEntity apt) {
    final colors = context.colors;
    Color statusColor = colors.primary;
    String statusLabel = 'UPCOMING';
    if (apt.isCompleted) {
      statusColor = colors.success;
      statusLabel = 'COMPLETED';
    } else if (apt.isCancelled) {
      statusColor = colors.error;
      statusLabel = 'CANCELLED';
    } else if (apt.isPending) {
      statusColor = colors.warning;
      statusLabel = 'PENDING';
    }
    final price = '₹${apt.servicePrice.toStringAsFixed(0)}';
    final payColor = apt.isPaid ? colors.success : colors.warning;
    var payText = apt.isPaid ? '✓ PAID · $price' : '⏳ DUE · $price';
    var payColor2 = payColor;
    if (apt.isCancelled) {
      payText = apt.isPaid ? '↩ REFUND · $price' : 'NO REFUND · UNPAID';
      payColor2 = apt.isPaid ? colors.warning : colors.textMuted;
    }
    final refText = (apt.payment?.paymentId.isNotEmpty ?? false)
        ? apt.payment!.paymentId
        : apt.bookingRef;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
        child: Column(
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
                        apt.clinicName,
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: colors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        apt.serviceName,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: colors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _pill(statusLabel, statusColor),
                    ...[const SizedBox(height: 5), _pill(payText, payColor2)],
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                if (apt.doctorSpecialty.isNotEmpty) ...[
                  Flexible(
                    child: _pill(
                      '🩺 ${apt.doctorSpecialty}',
                      colors.success,
                      size: 10.5,
                    ),
                  ),
                  const SizedBox(width: 10),
                ],
                Text(
                  '⏰ ${apt.serviceDuration} mins',
                  style: GoogleFonts.inter(fontSize: 12, color: colors.textMuted),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _infoRow(context, Icons.person_outline_rounded, apt.doctorName),
            const SizedBox(height: 6),
            _infoRow(context, Icons.schedule_rounded, apt.dateTime),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: apt.bookingRef));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Copied ${apt.bookingRef}'),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                    child: Row(
                      children: [
                        Icon(Icons.bolt_rounded, size: 14, color: colors.primary),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            refText,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.robotoMono(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: colors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: () => _showReceipt(apt),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colors.textPrimary,
                    backgroundColor: colors.surfaceSecondary,
                    side: BorderSide(color: colors.border),
                    shape: const StadiumBorder(),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    visualDensity: VisualDensity.compact,
                  ),
                  child: Text(
                    apt.isCancelled
                        ? 'Cancellation Details ↗'
                        : 'Receipt & Details ↗',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            if (apt.isUpcoming) ...[
              const SizedBox(height: 10),
              Divider(color: colors.border, height: 1),
              const SizedBox(height: 10),
              Row(
                children: [
                  _actionBtn(
                    'Reschedule',
                    Icons.event_repeat_rounded,
                    colors.primary,
                    () => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Rescheduling is coming soon.'),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  _actionBtn(
                    'Cancel',
                    Icons.close_rounded,
                    colors.error,
                    () => _confirmCancelAppointment(apt),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
