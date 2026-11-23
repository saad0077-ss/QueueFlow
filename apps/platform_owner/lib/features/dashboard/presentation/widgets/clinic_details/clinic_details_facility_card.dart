import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

import '../../../domain/entities/tenant_clinic_entity.dart';
import '../edit_clinic_modal.dart';
import 'clinic_details_common_widgets.dart';
import 'clinic_details_dialog_helper.dart';

class ClinicDetailsFacilityCard extends StatelessWidget {
  final TenantClinicEntity clinic;
  final dynamic queueSummary;

  const ClinicDetailsFacilityCard({
    super.key,
    required this.clinic,
    this.queueSummary,
  });

  String _orNotSet(String v) => v.trim().isEmpty ? 'Not configured' : v.trim();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClinicDetailsCommonWidgets.sectionHeader(
            colors,
            icon: Icons.business_rounded,
            color: const Color(0xFF38BDF8),
            title: 'Facility & Location Profile',
            trailing: InkWell(
              onTap: () => EditClinicModal.show(context, clinic),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: colors.surfaceSecondary,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: colors.border),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.edit_note_rounded,
                      size: 15,
                      color: colors.primaryLight,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Edit Details',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: colors.primaryLight,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          ClinicDetailsCommonWidgets.detailRow(
            colors,
            icon: Icons.medical_services_outlined,
            label: 'Assigned Departments / Specialties',
            value: _orNotSet(clinic.category),
          ),
          ClinicDetailsCommonWidgets.detailRow(
            colors,
            icon: Icons.location_on_outlined,
            label: 'Physical Facility Address',
            value: _orNotSet(clinic.address),
            onCopy: clinic.address.isEmpty
                ? null
                : () => ClinicDetailsDialogHelper.copyToClipboard(
                    context,
                    clinic.address,
                    'Address',
                  ),
          ),
          ClinicDetailsCommonWidgets.detailRow(
            colors,
            icon: Icons.location_city_outlined,
            label: 'City & Jurisdiction',
            value: _orNotSet(clinic.city),
          ),
          ClinicDetailsCommonWidgets.detailRow(
            colors,
            icon: Icons.phone_outlined,
            label: 'Clinic Contact Line',
            value: _orNotSet(clinic.phone),
            onCopy: clinic.phone.isEmpty
                ? null
                : () => ClinicDetailsDialogHelper.copyToClipboard(
                    context,
                    clinic.phone,
                    'Phone Number',
                  ),
          ),
          ClinicDetailsCommonWidgets.detailRow(
            colors,
            icon: Icons.schedule_rounded,
            label: 'Facility Operating Hours',
            value: _orNotSet(clinic.operatingHours),
          ),
          ClinicDetailsCommonWidgets.detailRow(
            colors,
            icon: Icons.confirmation_number_outlined,
            label: 'Live Queue & Wait Time',
            value: queueSummary == null
                ? 'No queue activity yet'
                : '${queueSummary.status} • ${queueSummary.detail}',
          ),
        ],
      ),
    );
  }
}
