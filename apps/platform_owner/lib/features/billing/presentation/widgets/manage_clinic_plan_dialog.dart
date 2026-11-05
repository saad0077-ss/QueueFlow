import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';
import '../../domain/entities/platform_tenant_subscription_entity.dart';

class ManageClinicPlanDialog {
  static void show(
    BuildContext context, {
    required PlatformTenantSubscriptionEntity clinic,
    required void Function({
      required String clinicId,
      required String planId,
      required String billingCadence,
      required String status,
    }) onSave,
  }) {
    final colors = context.colors;
    String selectedPlan = clinic.planId;
    String selectedCadence = clinic.billingCadence;
    String selectedStatus = clinic.status;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: Container(
              width: 440,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: colors.surfaceElevated,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: colors.border),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.35), blurRadius: 40, offset: const Offset(0, 16)),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Manage Clinic Subscription', style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: colors.textPrimary, fontSize: 17)),
                      IconButton(icon: Icon(Icons.close_rounded, color: colors.textMuted, size: 18), onPressed: () => Navigator.pop(ctx)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colors.surfaceSecondary,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: colors.border),
                    ),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('PRACTICE', style: TextStyle(color: colors.textMuted, fontSize: 10, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 2),
                      Text(clinic.clinicName, style: TextStyle(color: colors.textPrimary, fontWeight: FontWeight.bold, fontSize: 14)),
                    ]),
                  ),
                  const SizedBox(height: 14),
                  _dropdown(colors, 'Subscription Tier', selectedPlan, [
                    DropdownMenuItem(value: 'solo', child: Text('Solo Doctor Plan (₹999/mo)', style: TextStyle(color: colors.textPrimary))),
                    DropdownMenuItem(value: 'multi', child: Text('Multi-Doctor Clinic Plan (₹2,999/mo)', style: TextStyle(color: colors.textPrimary))),
                    DropdownMenuItem(value: 'enterprise', child: Text('Unlimited Doctors Plan (₹6,999/mo)', style: TextStyle(color: colors.textPrimary))),
                  ], (v) => setState(() => selectedPlan = v)),
                  const SizedBox(height: 12),
                  _dropdown(colors, 'Billing Cadence', selectedCadence, [
                    DropdownMenuItem(value: 'Monthly Auto-Debit', child: Text('Monthly Auto-Debit', style: TextStyle(color: colors.textPrimary))),
                    DropdownMenuItem(value: 'Annual Billing (20% off)', child: Text('Annual Billing (20% off)', style: TextStyle(color: colors.textPrimary))),
                  ], (v) => setState(() => selectedCadence = v)),
                  const SizedBox(height: 12),
                  _dropdown(colors, 'Subscription Status', selectedStatus, [
                    DropdownMenuItem(value: 'ACTIVE', child: Text('Active (Paid)', style: TextStyle(color: colors.textPrimary))),
                    DropdownMenuItem(value: 'TRIAL', child: Text('Trial Period', style: TextStyle(color: colors.textPrimary))),
                    DropdownMenuItem(value: 'SUSPENDED', child: Text('Suspended', style: TextStyle(color: colors.textPrimary))),
                  ], (v) => setState(() => selectedStatus = v)),
                  const SizedBox(height: 22),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: colors.textPrimary,
                            side: BorderSide(color: colors.border),
                          ),
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colors.primary,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () {
                            onSave(
                              clinicId: clinic.clinicId,
                              planId: selectedPlan,
                              billingCadence: selectedCadence,
                              status: selectedStatus,
                            );
                            Navigator.pop(ctx);
                          },
                          child: const Text('Save Changes'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  static Widget _dropdown(AppColorsExtension colors, String label, String value, List<DropdownMenuItem<String>> items, ValueChanged<String> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.inter(fontSize: 11.5, fontWeight: FontWeight.w600, color: colors.textMuted)),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: colors.surfaceSecondary,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: colors.border),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: items.any((i) => i.value == value) ? value : items.first.value,
              dropdownColor: colors.surfaceElevated,
              isExpanded: true,
              style: TextStyle(color: colors.textPrimary, fontSize: 13),
              items: items,
              onChanged: (v) {
                if (v != null) onChanged(v);
              },
            ),
          ),
        ),
      ],
    );
  }
}
