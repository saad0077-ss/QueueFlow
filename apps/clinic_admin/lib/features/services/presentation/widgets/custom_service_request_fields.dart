import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'service_form_text_field.dart';
import 'service_ui_kit.dart';

class CustomServiceRequestFields extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController justificationController;
  final String? nameError;

  const CustomServiceRequestFields({
    super.key,
    required this.nameController,
    required this.justificationController,
    this.nameError,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: ServiceColors.amber.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ServiceColors.amber.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 6,
            children: [
              Text(
                '📩 Request New Service for Review',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: ServiceColors.amber,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: ServiceColors.amber.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'GOVERNED WORKFLOW',
                  style: GoogleFonts.inter(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w800,
                    color: ServiceColors.amber,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ServiceFormTextField(
            label: 'Proposed Service Name *',
            controller: nameController,
            hint: 'e.g. Invisalign Clear Aligners & 3D Scan',
            errorText: nameError,
          ),
          const SizedBox(height: 12),
          ServiceFormTextField(
            label: 'Clinical Scope / Justification',
            controller: justificationController,
            hint: 'Why should this service be added?',
            maxLines: 2,
          ),
          const SizedBox(height: 8),
          Text(
            'ℹ️ This procedure will be submitted to Super Admin with a ⏳ Pending Approval badge.',
            style: GoogleFonts.inter(
              fontSize: 11.5,
              color: ServiceColors.muted,
            ),
          ),
        ],
      ),
    );
  }
}
