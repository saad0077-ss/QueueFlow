import 'package:flutter/material.dart';
import 'service_ui_kit.dart';

class ServiceDialogActionButtons extends StatelessWidget {
  final VoidCallback onCancel;
  final VoidCallback? onSave;

  const ServiceDialogActionButtons({
    super.key,
    required this.onCancel,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ServiceOutlinedPill(
            label: 'Cancel',
            onPressed: onCancel,
            fill: const Color(0xFF1E293B),
            height: 46,
            fontSize: 14,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ServiceGradientButton(
            label: 'Save Service',
            onPressed: onSave,
          ),
        ),
      ],
    );
  }
}
