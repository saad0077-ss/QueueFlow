import 'package:flutter/material.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

class QueueFilterModalHeader extends StatelessWidget {
  const QueueFilterModalHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return AppFilterHeader(
      title: 'Filter Live Queues',
      subtitle: 'Select department, queue load, and sorting preferences',
      onClose: () => Navigator.of(context).pop(),
    );
  }
}
