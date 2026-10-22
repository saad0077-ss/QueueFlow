import 'package:flutter/material.dart';
import 'service_ui_kit.dart';

class ServiceCardActions extends StatelessWidget {
  final bool isPending;
  final bool isActive;
  final VoidCallback onEdit;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const ServiceCardActions({
    super.key,
    required this.isPending,
    required this.isActive,
    required this.onEdit,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final toggleColor = isPending
        ? ServiceColors.subtle
        : (isActive ? ServiceColors.amber : ServiceColors.green);

    return Row(
      children: [
        Expanded(
          child: ServiceOutlinedPill(label: 'Edit', onPressed: onEdit),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ServiceOutlinedPill(
            label: isPending
                ? 'In Review'
                : (isActive ? 'Deactivate' : 'Activate'),
            onPressed: isPending ? null : onToggle,
            borderColor: toggleColor,
            textColor: toggleColor,
          ),
        ),
        const SizedBox(width: 8),
        Tooltip(
          message: 'Delete Service',
          child: InkWell(
            onTap: onDelete,
            customBorder: const CircleBorder(),
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: ServiceColors.red, width: 1.2),
              ),
              child: const Icon(
                Icons.delete_outline_rounded,
                size: 17,
                color: ServiceColors.red,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
