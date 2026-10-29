import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF090E1A),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF1E293B)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Queue & Slot Policies', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
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
                  Text('24/7 Emergency On-Call Duty', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 2),
                  Text('Mark clinic as available for urgent triage during off-hours', style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF64748B))),
                ],
              ),
              Switch(value: emergencyOnCall, activeTrackColor: const Color(0xFF10B981), onChanged: onEmergencyToggled),
            ],
          ),
          if (emergencyOnCall) ...[
            const SizedBox(height: 12),
            _inputField(
              title: 'Emergency Hotline Number (Displayed to patients when clinic is closed)',
              controller: emergencyPhoneCtrl,
              icon: Icons.phone_in_talk_rounded,
            ),
          ],
          const SizedBox(height: 16),
          _inputField(
            title: 'Holiday / Special Notice for Patients (Optional banner)',
            subtitle: 'Visible at the top of the clinic profile in the Patient Mobile App',
            controller: holidayNoticeCtrl,
            maxLines: 2,
          ),
        ],
      ),
    );
  }

  Widget _inputField({required String title, String? subtitle, required TextEditingController controller, IconData? icon, int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF94A3B8))),
        if (subtitle != null) ...[
          const SizedBox(height: 2),
          Text(subtitle, style: GoogleFonts.inter(fontSize: 10.5, color: const Color(0xFF64748B))),
        ],
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          maxLines: maxLines,
          style: GoogleFonts.inter(fontSize: 13, color: Colors.white),
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFF162238),
            prefixIcon: icon != null ? Icon(icon, size: 16, color: const Color(0xFF38BDF8)) : null,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF1E293B))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF1E293B))),
          ),
        ),
      ],
    );
  }
}
