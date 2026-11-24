import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';
import '../../domain/entities/clinic_location_entity.dart';
import 'clinic_profile_text_field.dart';
import 'profile_location_summary_card.dart';

class ClinicProfileForm extends StatelessWidget {
  final TextEditingController nameCtrl;
  final TextEditingController adminNameCtrl;
  final TextEditingController addressCtrl;
  final TextEditingController phoneCtrl;
  final TextEditingController emailCtrl;
  final TextEditingController descCtrl;
  final ClinicLocationEntity location;
  final VoidCallback onConfigureLocation;
  final VoidCallback onSave;

  const ClinicProfileForm({
    super.key,
    required this.nameCtrl,
    required this.adminNameCtrl,
    required this.addressCtrl,
    required this.phoneCtrl,
    required this.emailCtrl,
    required this.descCtrl,
    required this.location,
    required this.onConfigureLocation,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isMobile) ...[
              ClinicProfileTextField(label: 'Clinic Name', controller: nameCtrl),
              const SizedBox(height: 14),
              ClinicProfileTextField(
                label: 'Administrator Name',
                controller: adminNameCtrl,
                hintText: 'Enter clinic admin name',
              ),
            ] else
              Row(
                children: [
                  Expanded(
                    child: ClinicProfileTextField(
                      label: 'Clinic Name',
                      controller: nameCtrl,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: ClinicProfileTextField(
                      label: 'Administrator Name',
                      controller: adminNameCtrl,
                      hintText: 'Enter clinic admin name',
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 14),
            ClinicProfileTextField(
              label: 'Address',
              controller: addressCtrl,
              readOnly: true,
              helperText:
                  'Filled from Location tab. Use "Configure Location" below to update.',
            ),
            const SizedBox(height: 14),
            if (isMobile) ...[
              ClinicProfileTextField(label: 'Contact Phone', controller: phoneCtrl),
              const SizedBox(height: 14),
              ClinicProfileTextField(label: 'Email', controller: emailCtrl),
            ] else
              Row(
                children: [
                  Expanded(
                    child: ClinicProfileTextField(
                      label: 'Contact Phone',
                      controller: phoneCtrl,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: ClinicProfileTextField(
                      label: 'Email',
                      controller: emailCtrl,
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 14),
            ClinicProfileTextField(
              label: 'Description',
              controller: descCtrl,
              maxLines: 3,
            ),
            const SizedBox(height: 20),
            ProfileLocationSummaryCard(
              location: location,
              onConfigureLocation: onConfigureLocation,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onSave,
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                'Save Changes',
                style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    );
  }
}
