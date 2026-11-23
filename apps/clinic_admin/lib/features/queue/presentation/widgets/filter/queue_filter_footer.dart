import 'package:flutter/material.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

class QueueFilterFooter extends StatelessWidget {
  final VoidCallback onReset;
  final VoidCallback onCancel;
  final VoidCallback onApply;

  const QueueFilterFooter({
    super.key,
    required this.onReset,
    required this.onCancel,
    required this.onApply,
  });

  @override
  Widget build(BuildContext context) {
    return AppFilterFooter(
      onResetAll: onReset,
      onCancel: onCancel,
      onApply: onApply,
    );
  }
}
