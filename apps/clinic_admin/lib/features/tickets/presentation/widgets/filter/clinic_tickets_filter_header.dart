import 'package:flutter/material.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

class ClinicTicketsFilterHeader extends StatelessWidget {
  final VoidCallback onClose;

  const ClinicTicketsFilterHeader({super.key, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return AppFilterHeader(
      title: 'Filter Patient Tickets',
      subtitle: 'Select clinic specialty, urgency level, and inquiry category',
      onClose: onClose,
    );
  }
}
