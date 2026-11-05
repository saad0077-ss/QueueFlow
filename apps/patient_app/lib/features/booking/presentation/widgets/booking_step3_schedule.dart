import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:patient_app/core/utils/booking_date_formatter.dart';
import 'package:patient_app/core/widgets/gradient_button.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

class BookingStep3Schedule extends StatefulWidget {
  final DateTime selectedDate;
  final List<String> availableSlots;
  final String selectedSlot;
  final double payableFee;
  final ValueChanged<DateTime> onDateSelected;
  final ValueChanged<String> onSlotSelected;
  final VoidCallback onBack;
  final VoidCallback onContinue;

  const BookingStep3Schedule({
    super.key,
    required this.selectedDate,
    required this.availableSlots,
    required this.selectedSlot,
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
  late DateTime _displayedMonth;

  @override
  void initState() {
    super.initState();
    _displayedMonth = DateTime(widget.selectedDate.year, widget.selectedDate.month, 1);
  }

  void _previousMonth() {
    final now = DateTime.now();
    final prev = DateTime(_displayedMonth.year, _displayedMonth.month - 1, 1);
    if (prev.year > now.year || (prev.year == now.year && prev.month >= now.month)) {
      setState(() => _displayedMonth = prev);
    }
  }

  void _nextMonth() {
    setState(() {
      _displayedMonth = DateTime(_displayedMonth.year, _displayedMonth.month + 1, 1);
    });
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
          'Choose your preferred consultation day and appointment slot.',
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
    final daysInMonth = DateUtils.getDaysInMonth(_displayedMonth.year, _displayedMonth.month);
    final firstDayWeekday = DateTime(_displayedMonth.year, _displayedMonth.month, 1).weekday; // 1 = Mon

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.border, width: 1.2),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // Header Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: const BoxDecoration(
              gradient: AppColors.primaryGradient,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_month_rounded,
                      size: 18,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      BookingDateFormatter.formatMonthYear(_displayedMonth),
                      style: GoogleFonts.inter(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    InkWell(
                      onTap: _previousMonth,
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        child: const Icon(
                          Icons.chevron_left_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    InkWell(
                      onTap: _nextMonth,
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        child: const Icon(
                          Icons.chevron_right_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Weekday Labels
          Padding(
            padding: const EdgeInsets.only(top: 12, left: 10, right: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: ['M', 'T', 'W', 'T', 'F', 'S', 'S'].map((day) {
                return SizedBox(
                  width: 36,
                  child: Center(
                    child: Text(
                      day,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: colors.textSubtle,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          // Days Grid
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 42,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                mainAxisSpacing: 6,
                crossAxisSpacing: 4,
              ),
              itemBuilder: (context, index) {
                final dayNumber = index - (firstDayWeekday - 1) + 1;
                if (dayNumber < 1 || dayNumber > daysInMonth) {
                  return const SizedBox.shrink();
                }

                final date = DateTime(_displayedMonth.year, _displayedMonth.month, dayNumber);
                final isPast = date.isBefore(today);
                final isSelected = DateUtils.isSameDay(date, widget.selectedDate);
                final isToday = DateUtils.isSameDay(date, today);

                return GestureDetector(
                  onTap: isPast ? null : () => widget.onDateSelected(date),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      gradient: isSelected ? AppColors.primaryGradient : null,
                      color: isSelected
                          ? null
                          : (isToday ? colors.primaryTint : Colors.transparent),
                      border: isToday && !isSelected
                          ? Border.all(color: colors.primary.withValues(alpha: 0.5))
                          : null,
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: colors.primary.withValues(alpha: 0.4),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '$dayNumber',
                      style: GoogleFonts.inter(
                        fontSize: 12.5,
                        fontWeight: isSelected || isToday ? FontWeight.w800 : FontWeight.w500,
                        color: isSelected
                            ? Colors.white
                            : (isPast
                                ? colors.textSubtle.withValues(alpha: 0.4)
                                : colors.textPrimary),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeSlotsWrap() {
    final colors = context.colors;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: widget.availableSlots.map((slot) {
        final isSelected = slot == widget.selectedSlot;

        return GestureDetector(
          onTap: () => widget.onSlotSelected(slot),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            decoration: BoxDecoration(
              gradient: isSelected ? AppColors.primaryGradient : null,
              color: isSelected ? null : colors.surface,
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
            child: Text(
              slot,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected ? Colors.white : colors.textPrimary,
              ),
            ),
          ),
        );
      }).toList(),
    );
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
