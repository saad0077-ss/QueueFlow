import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:patient_app/core/widgets/gradient_button.dart';
import 'package:patient_app/features/clinic_details/domain/entities/clinic_doctor_item.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

class BookingStep3Schedule extends StatefulWidget {
  final DateTime selectedDate;
  final List<String> availableSlots;
  final String selectedSlot;
  final Set<String> bookedSlots;
  final double payableFee;
  final ClinicDoctorItem? doctor;
  final ValueChanged<DateTime> onDateSelected;
  final ValueChanged<String> onSlotSelected;
  final VoidCallback onBack;
  final VoidCallback onContinue;

  const BookingStep3Schedule({
    super.key,
    required this.doctor,
    required this.selectedDate,
    required this.availableSlots,
    required this.selectedSlot,
    this.bookedSlots = const {},
    required this.payableFee,
    required this.onDateSelected,
    required this.onSlotSelected,
    required this.onBack,
    required this.onContinue,
  });

  @override
  State<BookingStep3Schedule> createState() => _BookingStep3ScheduleState();
}

class _BookingStep3ScheduleState extends State<BookingStep3Schedule> {
  static const _weekdayShort = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  late DateTime _weekStart;

  static String _monthName(int m) => _months[m - 1];

  static DateTime _mondayOf(DateTime d) {
    final day = DateTime(d.year, d.month, d.day);
    return day.subtract(Duration(days: day.weekday - 1));
  }

  @override
  void initState() {
    super.initState();
    _weekStart = _mondayOf(widget.selectedDate);
  }

  @override
  void didUpdateWidget(covariant BookingStep3Schedule old) {
    super.didUpdateWidget(old);
    // Follow the selected date if it moved to another week (e.g. doctor changed).
    if (!DateUtils.isSameDay(old.selectedDate, widget.selectedDate)) {
      final w = _mondayOf(widget.selectedDate);
      if (w != _weekStart) _weekStart = w;
    }
  }

  bool get _canGoPrev => _weekStart.isAfter(_mondayOf(DateTime.now()));

  void _shiftWeek(int delta) {
    setState(() => _weekStart = _weekStart.add(Duration(days: 7 * delta)));
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pick date & time',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: colors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Choose an available day this week, then a time slot.',
          style: GoogleFonts.inter(
            fontSize: 12.5,
            color: colors.textMuted,
          ),
        ),
        const SizedBox(height: 16),
        _buildCalendarCard(),
        const SizedBox(height: 16),
        Text(
          'Available time slots',
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: colors.textPrimary,
          ),
        ),
        const SizedBox(height: 10),
        _buildTimeSlotsWrap(),
        const SizedBox(height: 16),
        _buildFeePreviewCard(),
        const SizedBox(height: 24),
        Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colors.surface,
                border: Border.all(color: colors.border, width: 1.5),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: widget.onBack,
                  child: Center(
                    child: Icon(
                      Icons.chevron_left_rounded,
                      color: colors.textPrimary,
                      size: 26,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GradientButton(
                text: 'Review Booking',
                onPressed: widget.selectedSlot.isNotEmpty ? widget.onContinue : null,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildCalendarCard() {
    final colors = context.colors;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final doctor = widget.doctor;
    final days = List.generate(7, (i) => _weekStart.add(Duration(days: i)));
    final last = days.last;
    final rangeLabel = _weekStart.month == last.month
        ? '${_weekStart.day} – ${last.day} ${_monthName(last.month)} ${last.year}'
        : '${_weekStart.day} ${_monthName(_weekStart.month)} – ${last.day} ${_monthName(last.month)} ${last.year}';

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.border, width: 1.2),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
            child: Row(
              children: [
                const Icon(Icons.calendar_month_rounded, size: 18, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    rangeLabel,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
                InkWell(
                  onTap: _canGoPrev ? () => _shiftWeek(-1) : null,
                  borderRadius: BorderRadius.circular(20),
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Icon(
                      Icons.chevron_left_rounded,
                      color: Colors.white.withValues(alpha: _canGoPrev ? 1 : 0.35),
                      size: 22,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                InkWell(
                  onTap: () => _shiftWeek(1),
                  borderRadius: BorderRadius.circular(20),
                  child: const Padding(
                    padding: EdgeInsets.all(4),
                    child: Icon(Icons.chevron_right_rounded, color: Colors.white, size: 22),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 14, 10, 8),
            child: Row(
              children: [
                for (var i = 0; i < 7; i++) ...[
                  if (i > 0) const SizedBox(width: 5),
                  Expanded(child: _buildDayTile(days[i], today, doctor)),
                ],
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
            child: Row(
              children: [
                _legendDot(colors.primary, 'Available'),
                const SizedBox(width: 14),
                _legendDot(colors.error, 'On leave'),
                const SizedBox(width: 14),
                _legendDot(colors.textSubtle.withValues(alpha: 0.5), 'Day off'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _legendDot(Color color, String label) {
    final colors = context.colors;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 5),
        Text(label, style: GoogleFonts.inter(fontSize: 10.5, color: colors.textMuted)),
      ],
    );
  }

  Widget _buildDayTile(DateTime date, DateTime today, ClinicDoctorItem? doctor) {
    final colors = context.colors;
    final isPast = date.isBefore(today);
    final onLeave = !isPast && (doctor?.isOnLeave(date) ?? false);
    final bookable = !isPast && (doctor?.isBookableOn(date) ?? false);
    final isSelected = bookable && DateUtils.isSameDay(date, widget.selectedDate);
    final isToday = DateUtils.isSameDay(date, today);

    final Color textColor = isSelected
        ? Colors.white
        : onLeave
            ? colors.error
            : bookable
                ? colors.textPrimary
                : colors.textSubtle.withValues(alpha: 0.45);

    return GestureDetector(
      onTap: bookable ? () => widget.onDateSelected(date) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: isSelected ? AppColors.primaryGradient : null,
          color: isSelected
              ? null
              : onLeave
                  ? colors.error.withValues(alpha: 0.12)
                  : (isToday ? colors.primaryTint : Colors.transparent),
          border: Border.all(
            color: onLeave
                ? colors.error.withValues(alpha: 0.6)
                : (isToday && !isSelected ? colors.primary.withValues(alpha: 0.5) : Colors.transparent),
          ),
          boxShadow: isSelected
              ? [BoxShadow(color: colors.primary.withValues(alpha: 0.4), blurRadius: 8, offset: const Offset(0, 2))]
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _weekdayShort[date.weekday - 1],
              style: GoogleFonts.inter(
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
                color: isSelected ? Colors.white70 : (onLeave ? colors.error : colors.textSubtle),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '${date.day}',
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: isSelected || isToday ? FontWeight.w800 : FontWeight.w600,
                color: textColor,
              ),
            ),
            const SizedBox(height: 5),
            // Marker: red dot for leave, primary dot when bookable.
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: onLeave
                    ? colors.error
                    : (bookable
                        ? (isSelected ? Colors.white : colors.primary)
                        : Colors.transparent),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeSlotsWrap() {
    final colors = context.colors;

    if (widget.availableSlots.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text(
          'This doctor has no availability set. Please choose another doctor.',
          style: GoogleFonts.inter(fontSize: 12.5, color: colors.textMuted),
        ),
      );
    }

    return LayoutBuilder(builder: (context, constraints) {
      const cols = 3;
      const gap = 8.0;
      final w = (constraints.maxWidth - gap * (cols - 1)) / cols;
      return Wrap(
      spacing: gap,
      runSpacing: gap,
      children: widget.availableSlots.map((slot) {
        final isBooked = widget.bookedSlots.contains(slot.trim().toUpperCase());
        final isSelected = !isBooked && slot == widget.selectedSlot;

        return GestureDetector(
          onTap: isBooked ? null : () => widget.onSlotSelected(slot),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: w,
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              gradient: isSelected ? AppColors.primaryGradient : null,
              color: isSelected
                  ? null
                  : (isBooked ? colors.border.withValues(alpha: 0.25) : colors.surface),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? Colors.transparent : colors.border,
                width: 1.2,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: colors.primary.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  slot,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                    decoration: isBooked ? TextDecoration.lineThrough : null,
                    color: isSelected
                        ? Colors.white
                        : (isBooked ? colors.textSubtle.withValues(alpha: 0.6) : colors.textPrimary),
                  ),
                ),
                if (isBooked)
                  Text(
                    'Booked',
                    style: GoogleFonts.inter(fontSize: 9.5, fontWeight: FontWeight.w700, color: colors.error),
                  ),
              ],
            ),
          ),
        );
      }).toList(),
      );
    });
  }


  Widget _buildFeePreviewCard() {
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border, width: 1.2),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Consultation Service Fee',
                style: GoogleFonts.inter(
                  fontSize: 12.5,
                  color: colors.textMuted,
                ),
              ),
              Text(
                '₹${widget.payableFee.toStringAsFixed(2)}',
                style: GoogleFonts.robotoMono(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: colors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Payment Gateway',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: colors.textMuted,
                ),
              ),
              Row(
                children: [
                  Icon(
                    Icons.bolt_rounded,
                    size: 15,
                    color: colors.accent,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Razorpay (Test Mode)',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: colors.accent,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Divider(color: colors.border, height: 1),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Payable',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: colors.textPrimary,
                ),
              ),
              Text(
                '₹${widget.payableFee.toStringAsFixed(2)}',
                style: GoogleFonts.robotoMono(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: colors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
