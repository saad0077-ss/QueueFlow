import 'package:flutter/material.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

class PlatformTicketsFilterHeader extends StatelessWidget {
  final VoidCallback onClose;

  const PlatformTicketsFilterHeader({super.key, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return AppFilterHeader(
      title: 'Filter Support Tickets',
      subtitle: 'Select clinic facility, SLA urgency, and issue category',
      onClose: onClose,
    );
  }
}
