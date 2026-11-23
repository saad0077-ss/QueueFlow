import 'package:flutter/material.dart';
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
    return showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.65),
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
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        width: 580,
        constraints: const BoxConstraints(maxHeight: 700),
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF1E293B)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              blurRadius: 28,
              offset: const Offset(0, 14),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClinicTicketsFilterHeader(onClose: () => Navigator.pop(context)),
            const Divider(height: 1, color: Color(0xFF1E293B)),
            Flexible(
              child: ClinicTicketsFilterBody(
                selectedService: _selectedService,
                onSelectService: (s) => setState(() => _selectedService = s),
                selectedUrgency: _selectedUrgency,
                onSelectUrgency: (u) => setState(() => _selectedUrgency = u),
                selectedCategory: _selectedCategory,
                onSelectCategory: (c) => setState(() => _selectedCategory = c),
              ),
            ),
            const Divider(height: 1, color: Color(0xFF1E293B)),
            ClinicTicketsFilterFooter(
              onReset: _resetAll,
              onApply: _apply,
              onCancel: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}
