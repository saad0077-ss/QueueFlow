import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../domain/entities/department_entity.dart';
import 'specialty_form_inputs.dart';

class DepartmentSettingsTab extends StatefulWidget {
  final DepartmentEntity department;
  final ValueChanged<DepartmentEntity> onSave;

  const DepartmentSettingsTab({super.key, required this.department, required this.onSave});

  @override
  State<DepartmentSettingsTab> createState() => _DepartmentSettingsTabState();
}

class _DepartmentSettingsTabState extends State<DepartmentSettingsTab> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _codeCtrl;
  late final TextEditingController _durationCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _doctorsCtrl;
  late String _icon;
  late String _color;
  late String _status;

  @override
  void initState() {
    super.initState();
    final d = widget.department;
    _nameCtrl = TextEditingController(text: d.name);
    _codeCtrl = TextEditingController(text: d.code);
    _durationCtrl = TextEditingController(text: d.avgConsultationTime);
    _descCtrl = TextEditingController(text: d.description);
    _doctorsCtrl = TextEditingController(text: d.doctorCount.toString());
    _icon = d.icon;
    _color = d.color;
    _status = d.isActive ? 'active' : 'inactive';
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _codeCtrl.dispose();
    _durationCtrl.dispose();
    _descCtrl.dispose();
    _doctorsCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topLeft,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 790),
        child: Container(
          padding: const EdgeInsets.fromLTRB(26, 24, 26, 26),
          decoration: BoxDecoration(
            color: const Color(0xFF111A2E),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFF1E293B)),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 520;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Specialty Configuration & Triage Rules',
                    style: GoogleFonts.inter(fontSize: 16.5, fontWeight: FontWeight.w800, color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  _pair(
                    isNarrow,
                    SpecialtyLabeled(
                      label: 'Department Name',
                      child: SpecialtyTextInput(controller: _nameCtrl),
                    ),
                    SpecialtyLabeled(
                      label: 'Department Code',
                      child: SpecialtyTextInput(controller: _codeCtrl),
                    ),
                    leftFlex: 2,
                  ),
                  const SizedBox(height: 14),
                  _pair(
                    isNarrow,
                    SpecialtyLabeled(
                      label: 'Specialty Icon / Emoji',
                      child: SpecialtyIconPicker(value: _icon, onChanged: (v) => setState(() => _icon = v)),
                    ),
                    SpecialtyLabeled(
                      label: 'Accent Color',
                      child: SpecialtyColorPicker(value: _color, onChanged: (v) => setState(() => _color = v)),
                    ),
                  ),
                  const SizedBox(height: 14),
                  SpecialtyLabeled(
                    label: 'Avg Consultation Duration',
                    child: SpecialtyTextInput(controller: _durationCtrl),
                  ),
                  const SizedBox(height: 14),
                  SpecialtyLabeled(
                    label: 'Department Overview & Triage Rules',
                    child: SpecialtyTextInput(controller: _descCtrl, minLines: 2, maxLines: 5),
                  ),
                  const SizedBox(height: 14),
                  _pair(
                    isNarrow,
                    SpecialtyLabeled(
                      label: 'Status',
                      child: SpecialtyDropdown(
                        value: _status,
                        items: const {'active': Text('Active'), 'inactive': Text('Inactive')},
                        onChanged: (v) => setState(() => _status = v),
                      ),
                    ),
                    SpecialtyLabeled(
                      label: 'Active Doctors Count',
                      child: Tooltip(
                        message: 'Synced from clinic staff rosters — read only',
                        child: SpecialtyTextInput(
                          controller: _doctorsCtrl,
                          readOnly: true,
                          suffix: const Icon(Icons.lock_outline_rounded, size: 16, color: Color(0xFF64748B)),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  GradientPillButton(
                    label: 'Save Specialty Settings',
                    glow: true,
                    padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 12),
                    onPressed: _save,
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _pair(bool isNarrow, Widget left, Widget right, {int leftFlex = 1}) {
    if (isNarrow) return Column(children: [left, const SizedBox(height: 14), right]);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: leftFlex, child: left),
        const SizedBox(width: 16),
        Expanded(child: right),
      ],
    );
  }

  void _save() {
    if (_nameCtrl.text.trim().isEmpty || _codeCtrl.text.trim().isEmpty) return;
    widget.onSave(
      widget.department.copyWith(
        name: _nameCtrl.text.trim(),
        code: _codeCtrl.text.trim().toUpperCase(),
        icon: _icon,
        color: _color,
        avgConsultationTime: _durationCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        status: _status,
      ),
    );
  }
}
