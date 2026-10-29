import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../domain/entities/platform_plan_tier_entity.dart';

class EditPlatformPlanDialog {
  static const _fieldFill = Color(0xFF1A2B4A);
  static const _border = Color(0xFF334E7A);

  static void show(
    BuildContext context, {
    PlatformPlanTierEntity? existingTier,
    required ValueChanged<PlatformPlanTierEntity> onSave,
  }) {
    final nameCtrl = TextEditingController(text: existingTier?.name ?? '');
    final badgeCtrl = TextEditingController(text: existingTier?.badge ?? '');
    final taglineCtrl = TextEditingController(text: existingTier?.tagline ?? '');
    final descCtrl = TextEditingController(text: existingTier?.description ?? '');
    final mPriceCtrl = TextEditingController(text: existingTier?.monthlyPrice.toString() ?? '');
    final aPriceCtrl = TextEditingController(text: existingTier?.annualPrice.toString() ?? '');
    final docLimCtrl = TextEditingController(text: existingTier?.doctorLimit.toString() ?? '1');
    final featuresCtrl = TextEditingController(text: existingTier?.features.join('\n') ?? '');
    var isPopular = existingTier?.isPopular ?? false;

    // Auto-calc annual monthly price at 20% off whenever monthly price changes.
    var lastMonthly = mPriceCtrl.text;
    mPriceCtrl.addListener(() { 
      if (mPriceCtrl.text == lastMonthly) return;
      lastMonthly = mPriceCtrl.text;
      final m = int.tryParse(mPriceCtrl.text.trim());
      if (m != null) aPriceCtrl.text = (m * 0.8).round().toString();
    });

    final title = existingTier != null ? 'Edit ${existingTier.name} Configuration & Pricing' : 'Create Custom Tier Configuration & Pricing';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: Container(
              width: 600,
              padding: const EdgeInsets.fromLTRB(24, 22, 24, 24),
              decoration: BoxDecoration(
                color: const Color(0xFF0F1A30),
                borderRadius: BorderRadius.circular(26),
                border: Border.all(color: const Color(0xFF1E293B)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(child: Text(title, style: GoogleFonts.inter(fontWeight: FontWeight.w800, color: Colors.white, fontSize: 19))),
                        IconButton(icon: const Icon(Icons.close_rounded, color: Colors.white, size: 16), onPressed: () => Navigator.pop(ctx)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(child: _field('Plan Tier Name', nameCtrl)),
                        const SizedBox(width: 12),
                        Expanded(child: _field('Badge / Ribbon (Optional)', badgeCtrl)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _field('Marketing Tagline', taglineCtrl),
                    const SizedBox(height: 12),
                    _field('Description & Target Practice', descCtrl, maxLines: 2),
                    const SizedBox(height: 14),
                    _section(
                      icon: Icons.payments_outlined,
                      iconColor: const Color(0xFFF59E0B),
                      title: 'PRICING ARCHITECTURE',
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E293B),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: _border),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.bolt_rounded, size: 12, color: Color(0xFFF97316)),
                            const SizedBox(width: 4),
                            Text('Auto-Calc 20% Annual', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white)),
                          ],
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(child: _field('Monthly Price (₹)', mPriceCtrl, numeric: true)),
                          const SizedBox(width: 12),
                          Expanded(child: _field('Annual Monthly Price (₹)', aPriceCtrl, numeric: true)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    _section(
                      icon: Icons.bar_chart_rounded,
                      iconColor: const Color(0xFF60A5FA),
                      title: 'DOCTOR CAPACITY ALLOCATION',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _field('Doctor Limit (1 for Solo, 10 for Multi, 999 for Unlimited)', docLimCtrl, numeric: true),
                          const SizedBox(height: 8),
                          Text('Enter 1 for Solo Doctor, 10 for Multi-Doctor Clinic, or 999 for Unlimited Doctors',
                              style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF94A3B8))),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    InkWell(
                      onTap: () => setState(() => isPopular = !isPopular),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF132241),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: _border),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Highlight as "Most Popular" / Recommended Tier', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white)),
                                  Text('Adds the highlighted border and featured badge on clinic billing screens',
                                      style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF94A3B8))),
                                ],
                              ),
                            ),
                            Checkbox(
                              value: isPopular,
                              onChanged: (v) => setState(() => isPopular = v ?? false),
                              activeColor: const Color(0xFF2563EB),
                              fillColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? const Color(0xFF2563EB) : Colors.white),
                              side: BorderSide.none,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(child: Text('Features & Value Proposition (One item per line)', style: _labelStyle)),
                        Text('Checkmarks rendered automatically', style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF94A3B8))),
                      ],
                    ),
                    const SizedBox(height: 6),
                    _input(featuresCtrl, maxLines: 6),
                    const SizedBox(height: 22),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(ctx),
                            style: OutlinedButton.styleFrom(
                              backgroundColor: const Color(0xFF1E293B),
                              foregroundColor: Colors.white,
                              side: const BorderSide(color: Color(0xFF334155)),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                            ),
                            child: Text('Cancel', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(24),
                              onTap: () {
                                final name = nameCtrl.text.trim();
                                if (name.isEmpty) return;
                                final mPrice = int.tryParse(mPriceCtrl.text.trim()) ?? 0;
                                final aPrice = int.tryParse(aPriceCtrl.text.trim()) ?? (mPrice * 0.8).round();
                                final docLim = int.tryParse(docLimCtrl.text.trim()) ?? 1;
                                final features = featuresCtrl.text.split('\n').map((f) => f.trim()).where((f) => f.isNotEmpty).toList();
                                onSave(PlatformPlanTierEntity(
                                  id: existingTier?.id ?? name.toLowerCase().replaceAll(RegExp(r'\s+'), '-'),
                                  name: name,
                                  tagline: taglineCtrl.text.trim(),
                                  monthlyPrice: mPrice,
                                  annualPrice: aPrice,
                                  badge: badgeCtrl.text.trim(),
                                  isPopular: isPopular,
                                  doctorLimit: docLim,
                                  serviceLimit: docLim,
                                  staffLimit: existingTier?.staffLimit ?? 1,
                                  description: descCtrl.text.trim(),
                                  features: features,
                                ));
                                Navigator.pop(ctx);
                              },
                              child: Ink(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(colors: [Color(0xFF2563EB), Color(0xFF14B8A6)]),
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                child: Center(
                                  child: Text('Save Tier Configuration', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
                                ),
                              ),
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
        ),
      ),
    );
  }

  static TextStyle get _labelStyle => GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white);

  static Widget _section({
    required IconData icon,
    required Color iconColor,
    required String title,
    Widget? trailing,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      decoration: BoxDecoration(
        color: const Color(0xFF132241),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 15, color: iconColor),
              const SizedBox(width: 6),
              Expanded(child: Text(title, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: 0.5))),
              ?trailing,
            ],
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }

  static Widget _field(String label, TextEditingController ctrl, {int maxLines = 1, bool numeric = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: _labelStyle),
        const SizedBox(height: 6),
        _input(ctrl, maxLines: maxLines, numeric: numeric),
      ],
    );
  }

  static Widget _input(TextEditingController ctrl, {int maxLines = 1, bool numeric = false}) {
    return TextField(
      controller: ctrl,
      maxLines: maxLines,
      keyboardType: numeric ? TextInputType.number : null,
      inputFormatters: numeric ? [FilteringTextInputFormatter.digitsOnly] : null,
      style: GoogleFonts.inter(fontSize: 14, color: Colors.white, height: 1.25),
      decoration: InputDecoration(
        isDense: true,
        filled: true,
        fillColor: _fieldFill,
        contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _border)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF3B82F6))),
      ),
    );
  }
}
