import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

import 'clinic_option_model.dart';
import 'raise_concern_category_selector.dart';
import 'raise_concern_clinic_picker.dart';
import 'raise_concern_clinic_toggle.dart';
import 'raise_concern_form_inputs.dart';
import 'raise_concern_platform_notice.dart';
import 'raise_concern_presets_section.dart';
import 'raise_concern_priority_selector.dart';
import 'raise_concern_submit_button.dart';
import 'raise_concern_technical_bug_notice.dart';
import 'raise_concern_token_card.dart';

class RaiseConcernFormBody extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final String selectedCategory;
  final ValueChanged<String> onCategorySelected;
  final bool isClinicRelated;
  final ValueChanged<bool> onClinicRelatedChanged;
  final List<ClinicOption> availableClinics;
  final String selectedClinicId;
  final String selectedClinicName;
  final bool isLoadingClinics;
  final VoidCallback onOpenSearch;
  final String? initialTokenNumber;
  final bool attachToken;
  final ValueChanged<bool?> onAttachTokenChanged;
  final String selectedPriority;
  final ValueChanged<String> onPriorityChanged;
  final TextEditingController subjectController;
  final TextEditingController descController;
  final bool isSubmitting;
  final VoidCallback onSubmit;
  final OnApplyPreset onApplyPreset;
  final AppColorsExtension colors;

  const RaiseConcernFormBody({
    super.key,
    required this.formKey,
    required this.selectedCategory,
    required this.onCategorySelected,
    required this.isClinicRelated,
    required this.onClinicRelatedChanged,
    required this.availableClinics,
    required this.selectedClinicId,
    required this.selectedClinicName,
    required this.isLoadingClinics,
    required this.onOpenSearch,
    this.initialTokenNumber,
    required this.attachToken,
    required this.onAttachTokenChanged,
    required this.selectedPriority,
    required this.onPriorityChanged,
    required this.subjectController,
    required this.descController,
    required this.isSubmitting,
    required this.onSubmit,
    required this.onApplyPreset,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Raise a Support Concern',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            'Directly alert the clinic coordination team and receive SLA-backed resolution.',
            style: GoogleFonts.inter(
              fontSize: 12,
              color: colors.textMuted,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 14),
          RaiseConcernPresetsSection(
            colors: colors,
            onApplyPreset: onApplyPreset,
          ),
          const SizedBox(height: 16),
          RaiseConcernCategorySelector(
            selectedCategory: selectedCategory,
            onCategorySelected: onCategorySelected,
            colors: colors,
          ),
          const SizedBox(height: 16),
          if (selectedCategory == 'technical') ...[
            RaiseConcernTechnicalBugNotice(colors: colors),
            const SizedBox(height: 16),
          ] else ...[
            RaiseConcernClinicToggle(
              isClinicRelated: isClinicRelated,
              onToggle: onClinicRelatedChanged,
              colors: colors,
            ),
            const SizedBox(height: 12),
            if (isClinicRelated) ...[
              RaiseConcernClinicPicker(
                availableClinics: availableClinics,
                selectedClinicId: selectedClinicId,
                selectedClinicName: selectedClinicName,
                isLoadingClinics: isLoadingClinics,
                onOpenSearch: onOpenSearch,
                colors: colors,
              ),
              const SizedBox(height: 12),
              if (initialTokenNumber?.isNotEmpty == true) ...[
                RaiseConcernTokenCard(
                  tokenNumber: initialTokenNumber,
                  clinicName: selectedClinicName,
                  attachToken: attachToken,
                  onToggleAttach: onAttachTokenChanged,
                  colors: colors,
                ),
                const SizedBox(height: 12),
              ],
            ] else ...[
              RaiseConcernPlatformNotice(colors: colors),
              const SizedBox(height: 12),
            ],
          ],
          RaiseConcernPrioritySelector(
            selectedPriority: selectedPriority,
            onPriorityChanged: onPriorityChanged,
            colors: colors,
          ),
          const SizedBox(height: 16),
          RaiseConcernFormInputs(
            subjectController: subjectController,
            descController: descController,
            colors: colors,
          ),
          const SizedBox(height: 16),
          RaiseConcernSubmitButton(
            isSubmitting: isSubmitting,
            onSubmit: onSubmit,
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
