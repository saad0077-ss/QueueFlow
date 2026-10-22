import 'package:flutter/material.dart';

import 'specialty_form_inputs.dart';

class AddDepartmentFormFields extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController codeController;
  final TextEditingController durationController;
  final TextEditingController descController;
  /// Null hides the comma-separated services field (used in edit mode).
  final TextEditingController? servicesController;
  final String selectedIcon;
  final String selectedColor;
  final ValueChanged<String> onIconChanged;
  final ValueChanged<String> onColorChanged;

  const AddDepartmentFormFields({
    super.key, 
    required this.nameController,
    required this.codeController,
    required this.durationController,
    required this.descController,
    required this.servicesController,
    required this.selectedIcon,
    required this.selectedColor,
    required this.onIconChanged,     
    required this.onColorChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: SpecialtyLabeled(
                label: 'Department Name',
                child: SpecialtyTextInput(controller: nameController, hint: 'e.g. Ophthalmology & Eye Care'),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: SpecialtyLabeled(
                label: 'Code (3-5 letters)',
                child: SpecialtyTextInput(controller: codeController, hint: 'OPHTH'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: SpecialtyLabeled(
                label: 'Specialty Icon / Emoji',
                child: SpecialtyIconPicker(value: selectedIcon, onChanged: onIconChanged),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: SpecialtyLabeled(
                label: 'Accent Color',
                child: SpecialtyColorPicker(value: selectedColor, onChanged: onColorChanged),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        SpecialtyLabeled(
          label: 'Avg Consultation Duration',
          child: SpecialtyTextInput(controller: durationController, hint: '20 mins'),
        ),
        const SizedBox(height: 14),
        SpecialtyLabeled(
          label: 'Department Overview & Triage Rules',
          child: SpecialtyTextInput(controller: descController, hint: 'Clinical care scope, triage indications and equipment...', minLines: 2, maxLines: 4),
        ),
        if (servicesController != null) ...[
          const SizedBox(height: 14),
          SpecialtyLabeled(
            label: 'Standard Sub-Departments / Services Catalog (Optional)',
            helper: 'Enter comma-separated standard clinical procedures clinics can adopt under this specialty.',
            child: SpecialtyTextInput(controller: servicesController, hint: 'e.g. Tooth Whitening, Root Canal, Ultrasonic Cleaning, Tooth Extraction'),
          ),
        ],
      ],
    );
  }
}
