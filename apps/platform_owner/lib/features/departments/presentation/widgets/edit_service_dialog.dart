import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../domain/entities/standard_service_entity.dart';
import 'catalog_validation.dart';
import 'specialty_form_inputs.dart';

/// Dialog for editing one standard procedure in a department's catalog.
class EditServiceDialog extends StatefulWidget {
  final StandardServiceEntity service;
  final List<StandardServiceEntity> existingServices;
  final Future<void> Function(StandardServiceEntity) onSave;

  const EditServiceDialog({super.key, required this.service, required this.existingServices, required this.onSave});

  static Future<void> show(
    BuildContext context, {
    required StandardServiceEntity service,
    required List<StandardServiceEntity> existingServices,
    required Future<void> Function(StandardServiceEntity) onSave,
  }) {
    return showDialog(
      context: context,
      builder: (_) => EditServiceDialog(service: service, existingServices: existingServices, onSave: onSave),
    );
  }

  @override
  State<EditServiceDialog> createState() => _EditServiceDialogState();
}

class _EditServiceDialogState extends State<EditServiceDialog> {
  late final _nameCtrl = TextEditingController(text: widget.service.name);
  late final _durationCtrl = TextEditingController(text: widget.service.duration.toString());
  late final _priceCtrl = TextEditingController(text: widget.service.suggestedPrice.toString());
  late final _descCtrl = TextEditingController(text: widget.service.description);
  bool _isSaving = false;
  String? _error;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _durationCtrl.dispose();
    _priceCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
      child: Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: 520,
          padding: const EdgeInsets.fromLTRB(26, 24, 26, 28),
          decoration: BoxDecoration(
            color: const Color(0xFF111A2E),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: const Color(0xFF334155)),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 40, offset: const Offset(0, 16))],
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Edit Procedure / Service',
                      style: GoogleFonts.inter(fontSize: 17.5, fontWeight: FontWeight.w800, color: Colors.white),
                    ),
                    InkWell(
                      onTap: () => Navigator.pop(context),
                      borderRadius: BorderRadius.circular(6),
                      child: const Padding(
                        padding: EdgeInsets.all(4),
                        child: Icon(Icons.close_rounded, size: 16, color: Colors.white),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SpecialtyLabeled(
                  label: 'Procedure / Service Name',
                  child: SpecialtyTextInput(controller: _nameCtrl, hint: 'e.g. Root Canal Therapy'),
                ),
                const SizedBox(height: 14),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: SpecialtyLabeled(
                        label: 'Standard Duration (Mins)',
                        child: SpecialtyTextInput(controller: _durationCtrl, hint: '30'),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: SpecialtyLabeled(
                        label: 'Suggested Baseline Fee (₹)',
                        child: SpecialtyTextInput(controller: _priceCtrl, hint: '500'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                SpecialtyLabeled(
                  label: 'Clinical Description, Preparation & Scope',
                  child: SpecialtyTextInput(controller: _descCtrl, hint: 'Clinical scope and preparation...', minLines: 2, maxLines: 4),
                ),
                if (_error != null) ...[const SizedBox(height: 16), FormErrorText(_error!)],
                const SizedBox(height: 22),
                Row(
                  children: [
                    Expanded(
                      child: OutlinePillButton(label: 'Cancel', onPressed: () => Navigator.pop(context)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GradientPillButton(
                        label: 'Save Changes',
                        loading: _isSaving,
                        glow: true,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
                        onPressed: _submit,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _submit() async {
    final name = _nameCtrl.text.trim().replaceAll(RegExp(r'\s+'), ' ');
    final error = name.isEmpty
        ? 'Procedure / service name is required.'
        : widget.existingServices.any((s) => s.id != widget.service.id && catalogKey(s.name) == catalogKey(name))
            ? '"$name" already exists in this department\'s catalog.'
            : null;
    setState(() => _error = error);
    if (error != null) return;
    setState(() => _isSaving = true);
    await widget.onSave(
      StandardServiceEntity(
        id: widget.service.id,
        name: name,
        duration: int.tryParse(_durationCtrl.text.trim()) ?? widget.service.duration,
        suggestedPrice: int.tryParse(_priceCtrl.text.trim()) ?? widget.service.suggestedPrice,
        description: _descCtrl.text.trim().isNotEmpty ? _descCtrl.text.trim() : '$name standard clinical procedure.',
      ),
    );
    if (mounted) Navigator.pop(context);
  }
}
