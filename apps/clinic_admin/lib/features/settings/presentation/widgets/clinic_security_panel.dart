import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../domain/entities/clinic_queue_rules_entity.dart';

class ClinicSecurityPanel extends StatefulWidget {
  final ClinicSecuritySettingsEntity security;
  final void Function({
    required String currentPassword,
    required String newPassword,
    required bool requireTwoFactor,
  }) onSave;

  const ClinicSecurityPanel({
    super.key,
    required this.security,
    required this.onSave,
  });

  @override
  State<ClinicSecurityPanel> createState() => _ClinicSecurityPanelState();
}

class _ClinicSecurityPanelState extends State<ClinicSecurityPanel> {
  late final TextEditingController _currentPassCtrl;
  late final TextEditingController _newPassCtrl;
  late bool _requireTwoFactor;

  @override
  void initState() {
    super.initState();
    _currentPassCtrl = TextEditingController();
    _newPassCtrl = TextEditingController();
    _requireTwoFactor = widget.security.requireTwoFactor;
  }

  @override
  void dispose() {
    _currentPassCtrl.dispose();
    _newPassCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _field('Current password', _currentPassCtrl, 'Enter current password'),
        const SizedBox(height: 14),
        _field('New password', _newPassCtrl, 'Enter new password'),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: const BoxDecoration(
            border: Border(
              top: BorderSide(color: Color(0xFF1E293B)),
              bottom: BorderSide(color: Color(0xFF1E293B)),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Require Two-Factor Authentication', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 2),
                  Text('Adds phone verification at staff login', style: GoogleFonts.inter(fontSize: 11.5, color: const Color(0xFF94A3B8))),
                ],
              ),
              Switch(
                value: _requireTwoFactor,
                activeTrackColor: const Color(0xFF2563EB),
                onChanged: (val) => setState(() => _requireTwoFactor = val),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: () {
            widget.onSave(
              currentPassword: _currentPassCtrl.text.trim(),
              newPassword: _newPassCtrl.text.trim(),
              requireTwoFactor: _requireTwoFactor,
            );
            _currentPassCtrl.clear();
            _newPassCtrl.clear();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2563EB),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: Text('Update Security Settings', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }

  Widget _field(String label, TextEditingController ctrl, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF94A3B8))),
        const SizedBox(height: 6),
        TextField(
          controller: ctrl,
          obscureText: true,
          style: GoogleFonts.inter(fontSize: 13, color: Colors.white),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
            filled: true,
            fillColor: const Color(0xFF162238),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF2563EB))),
          ),
        ),
      ],
    );
  }
}
