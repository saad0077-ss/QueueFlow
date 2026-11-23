import 'package:flutter/material.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

import 'clinic_tickets_filter_category_section.dart';
import 'clinic_tickets_filter_services_section.dart';
import 'clinic_tickets_filter_urgency_section.dart';

class ClinicTicketsFilterBody extends StatelessWidget {
  final String selectedService;
  final ValueChanged<String> onSelectService;
  final String selectedUrgency;
  final ValueChanged<String> onSelectUrgency;
  final String selectedCategory;
  final ValueChanged<String> onSelectCategory;

  const ClinicTicketsFilterBody({
    super.key,
    required this.selectedService,
    required this.onSelectService,
    required this.selectedUrgency,
    required this.onSelectUrgency,
    required this.selectedCategory,
    required this.onSelectCategory,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppFilterSectionTitle('CLINICAL SERVICE & SPECIALTY'),
          const SizedBox(height: 10),
          ClinicTicketsFilterServicesSection(
            selectedService: selectedService,
            onSelectService: onSelectService,
          ),
          const SizedBox(height: 20),
          const AppFilterSectionTitle('URGENCY & QUEUE PRIORITY'),
          const SizedBox(height: 10),
          ClinicTicketsFilterUrgencySection(
            selectedUrgency: selectedUrgency,
            onSelectUrgency: onSelectUrgency,
          ),
          const SizedBox(height: 20),
          const AppFilterSectionTitle('ISSUE CATEGORY'),
          const SizedBox(height: 10),
          ClinicTicketsFilterCategorySection(
            selectedCategory: selectedCategory,
            onSelectCategory: onSelectCategory,
          ),
        ],
      ),
    );
  }
}
