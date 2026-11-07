import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:queueflow_ui/queueflow_ui.dart';
import '../../domain/entities/tenant_clinic_entity.dart';

/// Asks the platform owner why a clinic is being suspended. Resolves to the
/// reason text, or null if cancelled. The reason is shown to the clinic admin.
class SuspendClinicDialog extends StatefulWidget {
  final TenantClinicEntity clinic;

  const SuspendClinicDialog({super.key, required this.clinic});

  static Future<String?> show(BuildContext context, TenantClinicEntity clinic) {
    return showDialog<String>(
      context: context,
      builder: (_) => SuspendClinicDialog(clinic: clinic),
    );
  }

  @override
  State<SuspendClinicDialog> createState() => _SuspendClinicDialogState();
}

class _SuspendClinicDialogState extends State<SuspendClinicDialog> {
  static const _presets = [
    'Payment overdue',
    'Violation of terms of service',
    'Suspicious or fraudulent activity',
    'Incomplete verification / documents',
    'Requested by the clinic',
  ];

  final _custom = TextEditingController();
  String? _preset;

  @override
  void dispose() {
    _custom.dispose();
    super.dispose();
  }

  String get _reason {
    final extra = _custom.text.trim();
    final parts = [?_preset, if (extra.isNotEmpty) extra];
    return parts.join(' — ');
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Container(
          width: 440,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: colors.surfaceElevated,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: colors.border, width: 1.2),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.35), blurRadius: 40, offset: const Offset(0, 16))],
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: colors.errorTint, shape: BoxShape.circle),
                      child: Icon(Icons.pause_circle_outline_rounded, color: colors.error, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text('Suspend Clinic', style: TextStyle(color: colors.textPrimary, fontSize: 17, fontWeight: FontWeight.bold)),
                    ),
                    IconButton(
                      icon: Icon(Icons.close_rounded, color: colors.textMuted, size: 20),
                      onPressed: () => Navigator.pop(context),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  'Suspending "${widget.clinic.name}" blocks its admin from signing in. They will see the reason below.',
                  style: TextStyle(color: colors.textMuted, fontSize: 13, height: 1.45),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final p in _presets)
                      ChoiceChip(
                        label: Text(p, style: TextStyle(fontSize: 12, color: _preset == p ? colors.primary : colors.textMuted)),
                        selected: _preset == p,
                        selectedColor: colors.primaryTint,
                        backgroundColor: colors.surfaceSecondary,
                        side: BorderSide(color: _preset == p ? colors.primary : colors.border),
                        showCheckmark: false,
                        onSelected: (_) => setState(() => _preset = _preset == p ? null : p),
                      ),
                  ],
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _custom,
                  maxLines: 3,
                  onChanged: (_) => setState(() {}),
                  style: TextStyle(color: colors.textPrimary, fontSize: 13),
                  decoration: InputDecoration(
                    hintText: 'Add more details (optional if a reason is selected)',
                    hintStyle: TextStyle(color: colors.textMuted, fontSize: 13),
                    filled: true,
                    fillColor: colors.surfaceSecondary,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: colors.border)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: colors.border)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: colors.primary, width: 1.5)),
                  ),
                ),
                const SizedBox(height: 22),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel', style: TextStyle(color: colors.textMuted))),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colors.error,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: _reason.isEmpty ? null : () => Navigator.pop(context, _reason),
                      child: const Text('Suspend Clinic'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
