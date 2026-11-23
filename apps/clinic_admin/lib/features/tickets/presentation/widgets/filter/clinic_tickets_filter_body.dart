import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.inter(
        fontSize: 10.5,
        fontWeight: FontWeight.w800,
        color: const Color(0xFF94A3B8),
        letterSpacing: 0.6,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('CLINICAL SERVICE & SPECIALTY'),
          const SizedBox(height: 10),
          ClinicTicketsFilterServicesSection(
            selectedService: selectedService,
            onSelectService: onSelectService,
          ),
          const SizedBox(height: 20),
          _buildSectionTitle('URGENCY & QUEUE PRIORITY'),
          const SizedBox(height: 10),
          ClinicTicketsFilterUrgencySection(
            selectedUrgency: selectedUrgency,
            onSelectUrgency: onSelectUrgency,
          ),
          const SizedBox(height: 20),
          _buildSectionTitle('ISSUE CATEGORY'),
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
