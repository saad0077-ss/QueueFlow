import 'package:flutter/material.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

class ClinicAppointmentsFilterServiceSection extends StatelessWidget {
  final String selectedService;
  final List<String> availableServices;
  final ValueChanged<String> onSelectService;

  const ClinicAppointmentsFilterServiceSection({
    super.key,
    required this.selectedService,
    required this.availableServices,
    required this.onSelectService,
  });

  @override
  Widget build(BuildContext context) {
    final services = ['all', ...availableServices.where((s) => s != 'all')];

    return LayoutBuilder(
      builder: (context, c) {
        final w = (c.maxWidth - 20) / 3;
        final itemWidth = w < 140 ? (c.maxWidth - 10) / 2 : w;
        return Wrap(
          spacing: 10,
          runSpacing: 10,
          children: services.map((srv) {
            final isSel = selectedService == srv;
            final isAll = srv == 'all';
            return SizedBox(
              width: itemWidth,
              child: AppFilterSelectableCard(
                isSelected: isSel,
                onTap: () => onSelectService(srv),
                emojiIcon: isAll ? '🔬' : '💊',
                title: isAll ? 'All Services' : srv,
                subtitle: isAll ? 'All procedures' : 'Service filter',
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
