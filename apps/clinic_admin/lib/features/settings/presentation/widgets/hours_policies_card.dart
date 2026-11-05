import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';
import 'hours_policy_dropdown.dart';

class HoursPoliciesCard extends StatelessWidget {
  final int cutoffMin;
  final int slotMin;
  final bool emergencyOnCall;
  final TextEditingController emergencyPhoneCtrl;
  final TextEditingController holidayNoticeCtrl;
  final ValueChanged<int> onCutoffChanged;
  final ValueChanged<int> onSlotChanged;
  final ValueChanged<bool> onEmergencyToggled;

  const HoursPoliciesCard({
    super.key,
    required this.cutoffMin,
    required this.slotMin,
    required this.emergencyOnCall,
    required this.emergencyPhoneCtrl,
    required this.holidayNoticeCtrl,
    required this.onCutoffChanged,
    required this.onSlotChanged,
    required this.onEmergencyToggled,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.surfaceSecondary,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Queue & Slot Policies', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: colors.textPrimary)),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: HoursPolicyDropdown(
                  title: 'Live Queue Token Cutoff',
                  subtitle: 'Stop issuing walk-in & online tokens before closing',
                  icon: Icons.timer_outlined,
                  value: cutoffMin,
                  items: const [
                    DropdownMenuItem(value: 15, child: Text('15 mins before closing')),
                    DropdownMenuItem(value: 30, child: Text('30 mins before closing')),
                    DropdownMenuItem(value: 45, child: Text('45 mins before closing')),
                    DropdownMenuItem(value: 60, child: Text('60 mins before closing')),
                    DropdownMenuItem(value: 0, child: Text('At exact closing time')),
                  ],
                  onChanged: onCutoffChanged,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: HoursPolicyDropdown(
                  title: 'Default Consultation Duration',
                  subtitle: 'Expected average doctor-patient consult time',
                  icon: Icons.access_time_rounded,
                  value: slotMin,
                  items: const [
                    DropdownMenuItem(value: 10, child: Text('10 minutes per patient')),
                    DropdownMenuItem(value: 15, child: Text('15 minutes per patient')),
                    DropdownMenuItem(value: 20, child: Text('20 minutes per patient')),
                    DropdownMenuItem(value: 30, child: Text('30 minutes per patient')),
                    DropdownMenuItem(value: 45, child: Text('45 minutes per patient')),
                    DropdownMenuItem(value: 60, child: Text('60 minutes per patient')),
                  ],
                  onChanged: onSlotChanged,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('24/7 Emergency On-Call Duty', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold, color: colors.textPrimary)),
                  const SizedBox(height: 2),
                  Text('Mark clinic as available for urgent triage during off-hours', style: GoogleFonts.inter(fontSize: 11, color: colors.textMuted)),
                ],
              ),
              Switch(value: emergencyOnCall, activeTrackColor: colors.success, onChanged: onEmergencyToggled),
            ],
          ),
          if (emergencyOnCall) ...[
            const SizedBox(height: 12),
            _inputField(
              context: context,
              title: 'Emergency Hotline Number (Displayed to patients when clinic is closed)',
              controller: emergencyPhoneCtrl,
              icon: Icons.phone_in_talk_rounded,
            ),
          ],
          const SizedBox(height: 16),
          _inputField(
            context: context,
            title: 'Holiday / Special Notice for Patients (Optional banner)',
            subtitle: 'Visible at the top of the clinic profile in the Patient Mobile App',
            controller: holidayNoticeCtrl,
            maxLines: 2,
          ),
        ],
      ),
    );
  }

  Widget _inputField({
    required BuildContext context,
    required String title,
    String? subtitle,
    required TextEditingController controller,
    IconData? icon,
    int maxLines = 1,
  }) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: colors.textMuted)),
        if (subtitle != null) ...[
          const SizedBox(height: 2),
          Text(subtitle, style: GoogleFonts.inter(fontSize: 10.5, color: colors.textSubtle)),
        ],
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          maxLines: maxLines,
          style: GoogleFonts.inter(fontSize: 13, color: colors.textPrimary),
          decoration: InputDecoration(
            filled: true,
            fillColor: colors.surface,
            prefixIcon: icon != null ? Icon(icon, size: 16, color: colors.info) : null,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: colors.border)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: colors.border)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: colors.primary)),
          ),
        ),
      ],
    );
  }
}
