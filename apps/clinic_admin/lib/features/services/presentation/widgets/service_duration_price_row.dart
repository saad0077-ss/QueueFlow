import 'package:flutter/material.dart';
import 'service_form_text_field.dart';

class ServiceDurationPriceRow extends StatelessWidget {
  final TextEditingController durationController;
  final TextEditingController priceController;

  const ServiceDurationPriceRow({
    super.key,
    required this.durationController,
    required this.priceController,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: ServiceFormTextField(
            label: 'Duration (minutes)',
            controller: durationController,
            numeric: true,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: ServiceFormTextField(
            label: 'Price (₹)',
            controller: priceController,
            numeric: true,
          ),
        ),
      ],
    );
  }
}
