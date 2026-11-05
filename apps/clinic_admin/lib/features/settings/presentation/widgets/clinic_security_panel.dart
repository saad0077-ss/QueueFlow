import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';
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
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _field(context, 'Current password', _currentPassCtrl, 'Enter current password'),
        const SizedBox(height: 14),
        _field(context, 'New password', _newPassCtrl, 'Enter new password'),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(color: colors.border),
              bottom: BorderSide(color: colors.border),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Require Two-Factor Authentication', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold, color: colors.textPrimary)),
                  const SizedBox(height: 2),
                  Text('Adds phone verification at staff login', style: GoogleFonts.inter(fontSize: 11.5, color: colors.textMuted)),
                ],
              ),
              Switch(
                value: _requireTwoFactor,
                activeTrackColor: colors.primary,
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
            backgroundColor: colors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: Text('Update Security Settings', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }

  Widget _field(BuildContext context, String label, TextEditingController ctrl, String hint) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: colors.textMuted)),
        const SizedBox(height: 6),
        TextField(
          controller: ctrl,
          obscureText: true,
          style: GoogleFonts.inter(fontSize: 13, color: colors.textPrimary),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: colors.textMuted, fontSize: 12),
            filled: true,
            fillColor: colors.surfaceSecondary,
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
