import 'package:flutter/material.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

import '../../../domain/entities/tenant_clinic_entity.dart';
import 'clinic_details_common_widgets.dart';
import 'clinic_details_dialog_helper.dart';

class ClinicDetailsGovernanceCard extends StatelessWidget {
  final TenantClinicEntity clinic;

  const ClinicDetailsGovernanceCard({super.key, required this.clinic});

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
            icon: Icons.shield_outlined,
            color: const Color(0xFF10B981),
            title: 'Platform Governance',
          ),
          const SizedBox(height: 10),
          ClinicDetailsCommonWidgets.metaRow(
            colors,
            'Clinic Unique ID:',
            clinic.id,
            onCopy: () => ClinicDetailsDialogHelper.copyToClipboard(
              context,
              clinic.id,
              'Clinic ID',
            ),
          ),
          ClinicDetailsCommonWidgets.metaRow(
            colors,
            'Billing Schedule:',
            '${clinic.planName} (${clinic.billingCadence})',
          ),
          ClinicDetailsCommonWidgets.metaRow(
            colors,
            'Registration Status:',
            clinic.status,
          ),
        ],
      ),
    );
  }
}
