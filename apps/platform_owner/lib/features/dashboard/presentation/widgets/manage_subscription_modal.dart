import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/widgets/app_snack_bar.dart';
import '../../data/repositories/tenant_repository_impl.dart';
import '../../domain/entities/tenant_clinic_entity.dart';

class ManageSubscriptionModal {
  static void show(BuildContext context, TenantClinicEntity clinic) {
    String selectedPlan = clinic.planId;
    String selectedCadence = clinic.billingCadence;
    String selectedStatus = clinic.status;

    showDialog(
      context: context,
      builder: (ctx) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Container(
            width: 440,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF0D1527),
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
                    const Text('SELECTED CLINIC', style: TextStyle(color: Color(0xFF64748B), fontSize: 10, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 2),
                    Text(clinic.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                  ]),
                ),
                const SizedBox(height: 14),
                _dropdown('Subscription Tier', selectedPlan, const [
                  DropdownMenuItem(value: 'solo', child: Text('Solo Doctor Plan (₹999/mo)')),
                  DropdownMenuItem(value: 'multi', child: Text('Multi-Doctor Clinic Plan (₹2,999/mo)')),
                  DropdownMenuItem(value: 'enterprise', child: Text('Enterprise Practice (₹6,999/mo)')),
                ], (v) => selectedPlan = v),
                const SizedBox(height: 12),
                _dropdown('Billing Cadence', selectedCadence, const [
                  DropdownMenuItem(value: 'Monthly Auto-Debit', child: Text('Monthly Billing')),
                  DropdownMenuItem(value: 'Annual Billing (20% off)', child: Text('Annual Billing')),
                ], (v) => selectedCadence = v),
                const SizedBox(height: 12),
                _dropdown('Subscription Status', selectedStatus, const [
                  DropdownMenuItem(value: 'ACTIVE', child: Text('Active (Paid)')),
                  DropdownMenuItem(value: 'TRIAL', child: Text('Trial Period')),
                  DropdownMenuItem(value: 'SUSPENDED', child: Text('Suspended')),
                ], (v) => selectedStatus = v),
                const SizedBox(height: 22),
                Row(
                  children: [
                    Expanded(child: OutlinedButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel'))),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0284C7), foregroundColor: Colors.white),
                        onPressed: () async {
                          final repo = TenantRepositoryImpl();
                          await repo.updateSubscription(
                            clinicId: clinic.id,
                            planId: selectedPlan,
                            billingCadence: selectedCadence,
                            status: selectedStatus,
                          );
                          if (ctx.mounted) {
                            Navigator.pop(ctx);
                            if (context.mounted) {
                              AppSnackBar.showSuccess(context, message: 'Plan updated.');
                            }
                          }
                        },
                        child: const Text('Apply Changes'),
                      ),
                    ),
                  ],
                ),
              ],
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
        Text(label, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: Color(0xFFCBD5E1))),
        const SizedBox(height: 6),
        Container(
          height: 42,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(color: const Color(0xFF162238), borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFF26354D))),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              dropdownColor: const Color(0xFF162238),
              icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF94A3B8), size: 18),
              style: GoogleFonts.inter(color: Colors.white, fontSize: 13),
              items: items,
              onChanged: (v) => onChanged(v ?? value),
            ),
          ),
        ),
      ],
    );
  }
}
