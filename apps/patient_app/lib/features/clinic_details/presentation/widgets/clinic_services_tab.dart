import 'package:flutter/material.dart';
import 'package:queueflow_ui/queueflow_ui.dart';
import '../../domain/entities/clinic_service_item.dart';
import 'clinic_service_item_tile.dart';

class ClinicServicesTab extends StatelessWidget {
  final List<ClinicServiceItem> services;
  final ValueChanged<ClinicServiceItem>? onServiceSelected;

  const ClinicServicesTab({
    super.key,
    required this.services,
    this.onServiceSelected,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    if (services.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Text(
            'No services listed for this clinic.',
            style: TextStyle(color: colors.textMuted, fontSize: 13),
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: services.length,
      itemBuilder: (context, index) {
        final service = services[index];
        return ClinicServiceItemTile(
          service: service,
          onTap: () => onServiceSelected?.call(service),
        );
      },
    );
  }
}
