import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
                color: const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF1E293B)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Issue Tenant Tax Invoice', style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 17)),
                        IconButton(icon: const Icon(Icons.close_rounded, color: Colors.white54, size: 18), onPressed: () => Navigator.pop(ctx)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _label('Select Target Clinic Practice'),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(color: const Color(0xFF162238), borderRadius: BorderRadius.circular(10)),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<PlatformTenantSubscriptionEntity>(
                          value: selectedClinic,
                          dropdownColor: const Color(0xFF162238),
                          isExpanded: true,
                          items: clinics.map((c) => DropdownMenuItem(value: c, child: Text(c.clinicName, style: const TextStyle(color: Colors.white, fontSize: 13)))).toList(),
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
                    _label('Plan Tier Description'),
                    const SizedBox(height: 6),
                    _input(TextEditingController(text: selectedPlan), enabled: false),
                    const SizedBox(height: 12),
                    _label('Invoice Amount (₹ INR)'),
                    const SizedBox(height: 6),
                    _input(amountCtrl),
                    const SizedBox(height: 12),
                    _label('Payment Due Date'),
                    const SizedBox(height: 6),
                    _input(dueCtrl),
                    const SizedBox(height: 22),
                    Row(
                      children: [
                        Expanded(child: OutlinedButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel'))),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2563EB), foregroundColor: Colors.white),
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

  static Widget _label(String text) => Text(text, style: GoogleFonts.inter(fontSize: 11.5, fontWeight: FontWeight.w600, color: const Color(0xFF94A3B8)));

  static Widget _input(TextEditingController ctrl, {bool enabled = true}) {
    return TextField(
      controller: ctrl,
      enabled: enabled,
      style: GoogleFonts.inter(fontSize: 13, color: Colors.white),
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color(0xFF162238),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
      ),
    );
  }
}
