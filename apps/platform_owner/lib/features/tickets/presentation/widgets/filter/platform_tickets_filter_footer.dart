import 'package:flutter/material.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

class PlatformTicketsFilterFooter extends StatelessWidget {
  final VoidCallback onResetAll;
  final VoidCallback onCancel;
  final VoidCallback onApply;

  const PlatformTicketsFilterFooter({
    super.key,
    required this.onResetAll,
    required this.onCancel,
    required this.onApply,
  });

  @override
  Widget build(BuildContext context) {
    return AppFilterFooter(
      onResetAll: onResetAll,
      onCancel: onCancel,
      onApply: onApply,
    );
  }
}
