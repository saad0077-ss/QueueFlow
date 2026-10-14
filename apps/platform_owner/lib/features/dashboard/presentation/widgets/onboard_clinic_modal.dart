import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/widgets/app_snack_bar.dart';
import '../../data/repositories/tenant_repository_impl.dart';
import 'onboard_modal_fields.dart';

class OnboardClinicModal {
  static void show(BuildContext context) {
    final nameCtrl = TextEditingController();
    final addressCtrl = TextEditingController();
    final adminNameCtrl = TextEditingController();
    final adminEmailCtrl = TextEditingController();
    String selectedPlan = 'solo';

    showDialog(
      context: context,
      builder: (ctx) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Container(
            width: 450,
            padding: const EdgeInsets.fromLTRB(26, 22, 26, 24),
            decoration: BoxDecoration(
              color: const Color(0xFF0D1527),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF1E293B), width: 1.2),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.65), blurRadius: 40, offset: const Offset(0, 16)),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Onboard New Clinic', style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 17.5)),
                    InkWell(
                      onTap: () => Navigator.pop(ctx),
                      borderRadius: BorderRadius.circular(6),
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(color: const Color(0xFF1A253C), borderRadius: BorderRadius.circular(6)),
                        child: const Icon(Icons.close_rounded, size: 14, color: Color(0xFF94A3B8)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                OnboardTextField(label: 'Practice / Clinic Name', controller: nameCtrl, hint: 'e.g. Green Valley Clinic'),
                const SizedBox(height: 13),
                OnboardTextField(label: 'Address & City', controller: addressCtrl, hint: 'Street, City, State'),
                const SizedBox(height: 13),
                Row(
                  children: [
                    Expanded(child: OnboardTextField(label: 'Admin Full Name', controller: adminNameCtrl, hint: 'Dr. Ayesha Khan')),
                    const SizedBox(width: 12),
                    Expanded(child: OnboardTextField(label: 'Admin Email', controller: adminEmailCtrl, hint: 'admin@clinic.com')),
                  ],
                ),
                const SizedBox(height: 13),
                OnboardPlanDropdown(value: selectedPlan, onChanged: (v) => selectedPlan = v),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 44,
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(ctx),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: const Color(0xFF1A253C),
                            foregroundColor: const Color(0xFFE2E8F0),
                            side: const BorderSide(color: Color(0xFF2A3B59)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                          ),
                          child: Text('Cancel', style: GoogleFonts.inter(fontSize: 13.5, fontWeight: FontWeight.w600)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        height: 44,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [Color(0xFF2563EB), Color(0xFF06B6D4)]),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(color: const Color(0xFF06B6D4).withValues(alpha: 0.35), blurRadius: 16, offset: const Offset(0, 4)),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: () => _handleSubmit(ctx, context, nameCtrl, addressCtrl, adminNameCtrl, adminEmailCtrl, selectedPlan),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                          ),
                          child: Text('Onboard & Send Invite', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700)),
                        ),
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

  static Future<void> _handleSubmit(
    BuildContext ctx,
    BuildContext rootCtx,
    TextEditingController name,
    TextEditingController addr,
    TextEditingController aName,
    TextEditingController aEmail,
    String plan,
  ) async {
    final cleanName = name.text.trim();
    final cleanEmail = aEmail.text.trim();
    if (cleanName.isEmpty || cleanEmail.isEmpty) return;

    final repo = TenantRepositoryImpl();
    try {
      final result = await repo.onboardClinic(
        name: cleanName,
        address: addr.text.trim(),
        adminName: aName.text.trim(),
        adminEmail: cleanEmail,
        planId: plan,
      );

      if (ctx.mounted) {
        Navigator.pop(ctx);
        await Clipboard.setData(ClipboardData(text: result.inviteUrl));

        if (rootCtx.mounted) {
          if (result.emailDelivered) {
            AppSnackBar.showSuccess(
              rootCtx,
              message: 'Clinic onboarded! Invite email sent to $cleanEmail.',
            );
          } else {
            AppSnackBar.showWarning(
              rootCtx,
              message:
                  '${result.emailFeedback}\nActivation link copied to clipboard!',
            );
          }
        }
      }
    } catch (e) {
      if (ctx.mounted) {
        AppSnackBar.showError(
          ctx,
          message: e.toString().replaceFirst('Exception: ', ''),
        );
      }
    }
  }
}
