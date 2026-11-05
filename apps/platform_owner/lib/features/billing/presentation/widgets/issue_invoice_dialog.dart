import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';
import '../../domain/entities/platform_tenant_subscription_entity.dart';

class IssueInvoiceDialog {
  static void show(
    BuildContext context, {
    required List<PlatformTenantSubscriptionEntity> clinics,
    required void Function({
      required String clinicId,
      required String clinicName,
      required String plan,
      required String amount,
      required String dueDate,
    }) onSubmit,
  }) {
    if (clinics.isEmpty) return;
    final colors = context.colors;
    PlatformTenantSubscriptionEntity selectedClinic = clinics.first;
    String selectedPlan = selectedClinic.planName;
    final amountCtrl = TextEditingController(text: selectedClinic.mrrAmount.replaceAll('/mo', '').replaceAll('₹', ''));
    final dueCtrl = TextEditingController(text: '15 Nov 2026');

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
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Issue Tenant Tax Invoice', style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: colors.textPrimary, fontSize: 17)),
                        IconButton(icon: Icon(Icons.close_rounded, color: colors.textMuted, size: 18), onPressed: () => Navigator.pop(ctx)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _label(colors, 'Select Target Clinic Practice'),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: colors.surfaceSecondary,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: colors.border),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<PlatformTenantSubscriptionEntity>(
                          value: selectedClinic,
                          dropdownColor: colors.surfaceElevated,
                          isExpanded: true,
                          items: clinics.map((c) => DropdownMenuItem(value: c, child: Text(c.clinicName, style: TextStyle(color: colors.textPrimary, fontSize: 13)))).toList(),
                          onChanged: (c) {
                            if (c != null) {
                              setState(() {
                                selectedClinic = c;
                                selectedPlan = c.planName;
                                amountCtrl.text = c.mrrAmount.replaceAll('/mo', '').replaceAll('₹', '');
                              });
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _label(colors, 'Plan Tier Description'),
                    const SizedBox(height: 6),
                    _input(colors, TextEditingController(text: selectedPlan), enabled: false),
                    const SizedBox(height: 12),
                    _label(colors, 'Invoice Amount (₹ INR)'),
                    const SizedBox(height: 6),
                    _input(colors, amountCtrl),
                    const SizedBox(height: 12),
                    _label(colors, 'Payment Due Date'),
                    const SizedBox(height: 6),
                    _input(colors, dueCtrl),
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
                              onSubmit(
                                clinicId: selectedClinic.clinicId,
                                clinicName: selectedClinic.clinicName,
                                plan: selectedPlan,
                                amount: amountCtrl.text.trim(),
                                dueDate: dueCtrl.text.trim(),
                              );
                              Navigator.pop(ctx);
                            },
                            child: const Text('Issue & Notify'),
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
      ),
    );
  }

  static Widget _label(AppColorsExtension colors, String text) => Text(text, style: GoogleFonts.inter(fontSize: 11.5, fontWeight: FontWeight.w600, color: colors.textMuted));

  static Widget _input(AppColorsExtension colors, TextEditingController ctrl, {bool enabled = true}) {
    return TextField(
      controller: ctrl,
      enabled: enabled,
      style: GoogleFonts.inter(fontSize: 13, color: colors.textPrimary),
      decoration: InputDecoration(
        filled: true,
        fillColor: colors.surfaceSecondary,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: colors.border)),
        disabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: colors.border)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: colors.primary)),
      ),
    );
  }
}
