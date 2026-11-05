import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';
import '../../domain/entities/clinic_appointment_entity.dart';

class RescheduleAppointmentDialog extends StatefulWidget {
  final ClinicAppointmentEntity appointment;
  final void Function(String newDate, String newTime) onReschedule;

  const RescheduleAppointmentDialog({
    super.key,
    required this.appointment,
    required this.onReschedule,
  });

  static Future<void> show(
    BuildContext context, {
    required ClinicAppointmentEntity appointment,
    required void Function(String newDate, String newTime) onReschedule,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => RescheduleAppointmentDialog(
        appointment: appointment,
        onReschedule: onReschedule,
      ),
    );
  }

  @override
  State<RescheduleAppointmentDialog> createState() =>
      _RescheduleAppointmentDialogState();
}

class _RescheduleAppointmentDialogState
    extends State<RescheduleAppointmentDialog> {
  late DateTime _selectedDate;
  late String _selectedTime;

  final List<String> _slots = [
    '09:00 AM',
    '10:00 AM',
    '11:00 AM',
    '11:30 AM',
    '12:00 PM',
    '02:30 PM',
    '03:30 PM',
    '04:30 PM',
    '05:00 PM',
  ];

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _selectedTime = widget.appointment.timeRaw.isNotEmpty
        ? widget.appointment.timeRaw
        : '11:00 AM';
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    final dateStr =
        '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}';

    return Dialog(
      backgroundColor: colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colors.border),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Reschedule Appointment',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: colors.textPrimary,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded),
                    color: colors.textMuted,
                    splashRadius: 18,
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Select a new consultation date and time slot for #${widget.appointment.bookingId} (${widget.appointment.customerName}).',
                style: GoogleFonts.inter(
                  fontSize: 12.5,
                  color: colors.textMuted,
                ),
              ),
              const SizedBox(height: 18),

              // Date Selector
              Text(
                'DATE',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                  color: colors.textMuted,
                ),
              ),
              const SizedBox(height: 6),
              InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2027, 12, 31),
                  );
                  if (picked != null) {
                    setState(() => _selectedDate = picked);
                  }
                },
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: colors.surfaceSecondary,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: colors.border),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        dateStr,
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: colors.textPrimary,
                        ),
                      ),
                      Icon(
                        Icons.calendar_month_outlined,
                        size: 18,
                        color: colors.primary,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 18),

              // Time Slots
              Text(
                'TIME SLOT',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                  color: colors.textMuted,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _slots.map((slot) {
                  final isSelected = _selectedTime == slot;
                  return InkWell(
                    onTap: () => setState(() => _selectedTime = slot),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? colors.primaryTint
                            : colors.surfaceSecondary,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected ? colors.primary : colors.border,
                        ),
                      ),
                      child: Text(
                        slot,
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 11.5,
                          fontWeight: isSelected
                              ? FontWeight.w800
                              : FontWeight.w600,
                          color: isSelected
                              ? colors.primary
                              : colors.textPrimary,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 24),

              // Actions
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: colors.surfaceSecondary,
                        side: BorderSide(color: colors.border),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: colors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        widget.onReschedule(dateStr, _selectedTime);
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        'Save Reschedule',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
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
  }
}
