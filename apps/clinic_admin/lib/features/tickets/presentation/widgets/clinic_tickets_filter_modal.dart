import 'package:flutter/material.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

import 'filter/clinic_tickets_filter_body.dart';
import 'filter/clinic_tickets_filter_footer.dart';
import 'filter/clinic_tickets_filter_header.dart';

class ClinicTicketsFilterModal extends StatefulWidget {
  final String initialCategory;
  final String initialUrgency;
  final String initialService;
  final void Function({
    required String category,
    required String urgency,
    required String service,
  })
  onApply;

  const ClinicTicketsFilterModal({
    super.key,
    required this.initialCategory,
    required this.initialUrgency,
    required this.initialService,
    required this.onApply,
  });

  static Future<void> show(
    BuildContext context, {
    required String initialCategory,
    required String initialUrgency,
    required String initialService,
    required void Function({
      required String category,
      required String urgency,
      required String service,
    })
    onApply,
  }) {
    return AppFilterDialogScaffold.show(
      context,
      builder: (ctx) => ClinicTicketsFilterModal(
        initialCategory: initialCategory,
        initialUrgency: initialUrgency,
        initialService: initialService,
        onApply: onApply,
      ),
    );
  }

  @override
  State<ClinicTicketsFilterModal> createState() =>
      _ClinicTicketsFilterModalState();
}

class _ClinicTicketsFilterModalState extends State<ClinicTicketsFilterModal> {
  late String _selectedCategory;
  late String _selectedUrgency;
  late String _selectedService;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategory;
    _selectedUrgency = widget.initialUrgency;
    _selectedService = widget.initialService;
  }

  void _resetAll() {
    setState(() {
      _selectedCategory = 'all';
      _selectedUrgency = 'all';
      _selectedService = 'all';
    });
  }

  void _apply() {
    widget.onApply(
      category: _selectedCategory,
      urgency: _selectedUrgency,
      service: _selectedService,
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AppFilterDialogScaffold(
      header: ClinicTicketsFilterHeader(onClose: () => Navigator.pop(context)),
      body: ClinicTicketsFilterBody(
        selectedService: _selectedService,
        onSelectService: (s) => setState(() => _selectedService = s),
        selectedUrgency: _selectedUrgency,
        onSelectUrgency: (u) => setState(() => _selectedUrgency = u),
        selectedCategory: _selectedCategory,
        onSelectCategory: (c) => setState(() => _selectedCategory = c),
      ),
      footer: ClinicTicketsFilterFooter(
        onResetAll: _resetAll,
        onApply: _apply,
        onCancel: () => Navigator.pop(context),
      ),
    );
  }
}
