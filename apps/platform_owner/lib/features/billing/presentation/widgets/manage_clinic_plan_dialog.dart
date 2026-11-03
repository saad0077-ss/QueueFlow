import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
                color: const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF1E293B)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Manage Clinic Subscription', style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 17)),
                      IconButton(icon: const Icon(Icons.close_rounded, color: Colors.white54, size: 18), onPressed: () => Navigator.pop(ctx)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: const Color(0xFF162238), borderRadius: BorderRadius.circular(10)),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Text('PRACTICE', style: TextStyle(color: Color(0xFF64748B), fontSize: 10, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 2),
                      Text(clinic.clinicName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                    ]),
                  ),
                  const SizedBox(height: 14),
                  _dropdown('Subscription Tier', selectedPlan, const [
                    DropdownMenuItem(value: 'solo', child: Text('Solo Doctor Plan (₹999/mo)')),
                    DropdownMenuItem(value: 'multi', child: Text('Multi-Doctor Clinic Plan (₹2,999/mo)')),
                    DropdownMenuItem(value: 'enterprise', child: Text('Unlimited Doctors Plan (₹6,999/mo)')),
                  ], (v) => setState(() => selectedPlan = v)),
                  const SizedBox(height: 12),
                  _dropdown('Billing Cadence', selectedCadence, const [
                    DropdownMenuItem(value: 'Monthly Auto-Debit', child: Text('Monthly Auto-Debit')),
                    DropdownMenuItem(value: 'Annual Billing (20% off)', child: Text('Annual Billing (20% off)')),
                  ], (v) => setState(() => selectedCadence = v)),
                  const SizedBox(height: 12),
                  _dropdown('Subscription Status', selectedStatus, const [
                    DropdownMenuItem(value: 'ACTIVE', child: Text('Active (Paid)')),
                    DropdownMenuItem(value: 'TRIAL', child: Text('Trial Period')),
                    DropdownMenuItem(value: 'SUSPENDED', child: Text('Suspended')),
                  ], (v) => setState(() => selectedStatus = v)),
                  const SizedBox(height: 22),
                  Row(
                    children: [
                      Expanded(child: OutlinedButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel'))),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2563EB), foregroundColor: Colors.white),
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

  static Widget _dropdown(String label, String value, List<DropdownMenuItem<String>> items, ValueChanged<String> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.inter(fontSize: 11.5, fontWeight: FontWeight.w600, color: const Color(0xFF94A3B8))),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(color: const Color(0xFF162238), borderRadius: BorderRadius.circular(10)),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: items.any((i) => i.value == value) ? value : items.first.value,
              dropdownColor: const Color(0xFF162238),
              isExpanded: true,
              style: const TextStyle(color: Colors.white, fontSize: 13),
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
