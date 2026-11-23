import 'package:flutter/material.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

import 'filter/platform_filter_clinic_item.dart';
import 'filter/platform_tickets_filter_category_section.dart';
import 'filter/platform_tickets_filter_clinics_section.dart';
import 'filter/platform_tickets_filter_footer.dart';
import 'filter/platform_tickets_filter_header.dart';
import 'filter/platform_tickets_filter_sla_section.dart';

export 'filter/platform_filter_clinic_item.dart';

class PlatformTicketsFilterModal extends StatefulWidget {
  final String initialClinic;
  final String initialSla;
  final String initialCategory;
  final List<FilterClinicItem> availableClinics;
  final void Function({
    required String clinic,
    required String sla,
    required String category,
  })
  onApply;

  const PlatformTicketsFilterModal({
    super.key,
    required this.initialClinic,
    required this.initialSla,
    required this.initialCategory,
    required this.availableClinics,
    required this.onApply,
  });

  static Future<void> show(
    BuildContext context, {
    required String initialClinic,
    required String initialSla,
    required String initialCategory,
    required List<FilterClinicItem> availableClinics,
    required void Function({
      required String clinic,
      required String sla,
      required String category,
    })
    onApply,
  }) {
    return AppFilterDialogScaffold.show(
      context,
      builder: (ctx) => PlatformTicketsFilterModal(
        initialClinic: initialClinic,
        initialSla: initialSla,
        initialCategory: initialCategory,
        availableClinics: availableClinics,
        onApply: onApply,
      ),
    );
  }

  @override
  State<PlatformTicketsFilterModal> createState() =>
      _PlatformTicketsFilterModalState();
}

class _PlatformTicketsFilterModalState
    extends State<PlatformTicketsFilterModal> {
  late String _selectedClinic;
  late String _selectedSla;
  late String _selectedCategory;

  @override
  void initState() {
    super.initState();
    _selectedClinic = widget.initialClinic;
    _selectedSla = widget.initialSla;
    _selectedCategory = widget.initialCategory;
  }

  void _resetAll() => setState(() {
    _selectedClinic = 'all';
    _selectedSla = 'all';
    _selectedCategory = 'all';
  });

  void _apply() {
    widget.onApply(
      clinic: _selectedClinic,
      sla: _selectedSla,
      category: _selectedCategory,
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AppFilterDialogScaffold(
      header: PlatformTicketsFilterHeader(
        onClose: () => Navigator.pop(context),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AppFilterSectionTitle('HEALTHCARE FACILITY / CLINIC'),
            const SizedBox(height: 10),
            PlatformTicketsFilterClinicsSection(
              selectedClinic: _selectedClinic,
              availableClinics: widget.availableClinics,
              onSelectClinic: (id) => setState(() => _selectedClinic = id),
            ),
            const SizedBox(height: 20),
            const AppFilterSectionTitle('SLA URGENCY & PRIORITY'),
            const SizedBox(height: 10),
            PlatformTicketsFilterSlaSection(
              selectedSla: _selectedSla,
              onSelectSla: (sla) => setState(() => _selectedSla = sla),
            ),
            const SizedBox(height: 20),
            const AppFilterSectionTitle('ISSUE CATEGORY'),
            const SizedBox(height: 10),
            PlatformTicketsFilterCategorySection(
              selectedCategory: _selectedCategory,
              onSelectCategory: (cat) =>
                  setState(() => _selectedCategory = cat),
            ),
          ],
        ),
      ),
      footer: PlatformTicketsFilterFooter(
        onResetAll: _resetAll,
        onCancel: () => Navigator.pop(context),
        onApply: _apply,
      ),
    );
  }
}
