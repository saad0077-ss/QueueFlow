import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'accent_border_card.dart';
import 'catalog_validation.dart';
import 'specialty_form_inputs.dart';

import '../../domain/entities/standard_service_entity.dart';

class AddProcedureFormCard extends StatefulWidget {
  final ValueChanged<StandardServiceEntity> onAddService;
  final List<StandardServiceEntity> existingServices;

  const AddProcedureFormCard({super.key, required this.onAddService, this.existingServices = const []});

  @override
  State<AddProcedureFormCard> createState() => _AddProcedureFormCardState();
}

class _AddProcedureFormCardState extends State<AddProcedureFormCard> {
  final _nameCtrl = TextEditingController();
  final _durationCtrl = TextEditingController(text: '30');
  final _priceCtrl = TextEditingController(text: '500');
  final _descCtrl = TextEditingController();
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
    return AccentBorderCard(
      accent: const Color(0xFF2563EB),
      radius: 16,
      padding: const EdgeInsets.fromLTRB(22, 20, 22, 20),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 650;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '+ Add Standard Procedure / Service to Department',
                style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white),
              ),
              const SizedBox(height: 4),
              Text(
                'Define a standard clinical procedure for this department. Any clinic assigned this medical specialty can offer it.',
                style: GoogleFonts.inter(fontSize: 12.5, color: const Color(0xFFCBD5E1)),
              ),
              const SizedBox(height: 18),
              if (isNarrow) ...[
                _field('Procedure / Service Name', _nameCtrl, 'e.g. Laser Teeth Whitening, Root Canal Therapy, Retina Scan', autofocus: true),
                const SizedBox(height: 12),
                _field('Standard Duration (Mins)', _durationCtrl, '30'),
                const SizedBox(height: 12),
                _field('Suggested Baseline Fee (₹)', _priceCtrl, '500'),
              ] else
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: _field('Procedure / Service Name', _nameCtrl, 'e.g. Laser Teeth Whitening, Root Canal Therapy, Retina Scan', autofocus: true),
                    ),
                    const SizedBox(width: 14),
                    Expanded(flex: 1, child: _field('Standard Duration (Mins)', _durationCtrl, '30')),
                    const SizedBox(width: 14),
                    Expanded(flex: 1, child: _field('Suggested Baseline Fee (₹)', _priceCtrl, '500')),
                  ],
                ),
              const SizedBox(height: 14),
              _field(
                'Clinical Description, Preparation & Scope',
                _descCtrl,
                'e.g. Diagnostic endodontic treatment using rotary files and radiographic apex locator.',
              ),
              if (_error != null) ...[const SizedBox(height: 14), FormErrorText(_error!)],
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: GradientPillButton(label: '+ Add Procedure to Department Catalog', onPressed: _submit),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _field(String label, TextEditingController ctrl, String hint, {bool autofocus = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: const Color(0xFFE2E8F0)),
        ),
        const SizedBox(height: 7),
        _GlowTextField(controller: ctrl, hint: hint, autofocus: autofocus),
      ],
    );
  }

  void _submit() {
    final name = _nameCtrl.text.trim().replaceAll(RegExp(r'\s+'), ' ');
    final error = name.isEmpty
        ? 'Procedure / service name is required.'
        : widget.existingServices.any((s) => catalogKey(s.name) == catalogKey(name))
            ? '"$name" already exists in this department\'s catalog.'
            : null;
    setState(() => _error = error);
    if (error != null) return;
    widget.onAddService(
      StandardServiceEntity(
        id: 'svc-${DateTime.now().millisecondsSinceEpoch}',
        name: name,
        duration: int.tryParse(_durationCtrl.text) ?? 30,
        suggestedPrice: int.tryParse(_priceCtrl.text) ?? 500,
        description: _descCtrl.text.trim().isNotEmpty ? _descCtrl.text.trim() : '$name standard clinical procedure.',
      ),
    );
    _nameCtrl.clear();
    _descCtrl.clear();
  }
}

/// Input with a soft blue halo while focused, matching the console's web styling.
class _GlowTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hint;
  final bool autofocus;

  const _GlowTextField({required this.controller, required this.hint, this.autofocus = false});

  @override
  State<_GlowTextField> createState() => _GlowTextFieldState();
}

class _GlowTextFieldState extends State<_GlowTextField> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    return Focus(
      onFocusChange: (f) => setState(() => _focused = f),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          boxShadow: _focused ? [BoxShadow(color: const Color(0xFF3B82F6).withValues(alpha: 0.35), blurRadius: 0, spreadRadius: 3)] : null,
        ),
        child: TextField(
          controller: widget.controller,
          autofocus: widget.autofocus,
          cursorColor: Colors.white,
          style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white),
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF94A3B8)),
            isDense: true,
            filled: true,
            fillColor: const Color(0xFF15213A),
            contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFF2A3A57)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFF2A3A57)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 1.5),
            ),
          ),
        ),
      ),
    );
  }
}
