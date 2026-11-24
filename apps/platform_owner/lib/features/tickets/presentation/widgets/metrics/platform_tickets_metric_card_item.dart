import 'package:flutter/material.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

/// Legacy facade wrapping the design system [AppMetricCard]
/// for platform owner support tickets.
class PlatformTicketsMetricCardItem extends StatelessWidget {
  final String tag;
  final Color tagColor;
  final bool hasRedDot;
  final String label;
  final String value;
  final Color? valueColor;
  final Widget bottomWidget;
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final Color borderColor;

  const PlatformTicketsMetricCardItem({
    super.key,
    required this.tag,
    required this.tagColor,
    this.hasRedDot = false,
    required this.label,
    required this.value,
    this.valueColor,
    required this.bottomWidget,
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return AppMetricCard(
      tag: tag,
      tagColor: tagColor,
      hasDot: hasRedDot,
      dotColor: const Color(0xFFEF4444),
      label: label,
      value: value,
      valueColor: valueColor,
      bottomWidget: bottomWidget,
      icon: icon,
      iconColor: iconColor,
      iconBgColor: iconBgColor,
      borderColor: borderColor,
    );
  }
}
