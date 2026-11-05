import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

class BillingCadenceToggle extends StatelessWidget {
  final String activeCadence; // 'monthly' | 'annual'
  final ValueChanged<String> onCadenceChanged;

  const BillingCadenceToggle({
    super.key,
    required this.activeCadence,
    required this.onCadenceChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isMonthly = activeCadence == 'monthly';

    return Column(
      children: [
        Text(
          'QueueFlow Subscription Plans',
          style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w800, color: colors.textPrimary),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 6),
        Text(
          'Doctor-capacity based pricing for clinics of all sizes. Switch or upgrade anytime.',
          style: GoogleFonts.inter(fontSize: 13, color: colors.textMuted),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: colors.surfaceSecondary,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: colors.border),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _toggleOption(
                colors: colors,
                label: 'Monthly',
                isSelected: isMonthly,
                onTap: () => onCadenceChanged('monthly'),
              ),
              _toggleOption(
                colors: colors,
                label: 'Annual',
                badgeText: 'SAVE 20%',
                isSelected: !isMonthly,
                onTap: () => onCadenceChanged('annual'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _toggleOption({
    required AppColorsExtension colors,
    required String label,
    String? badgeText,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? colors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12.5,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? Colors.white : colors.textMuted,
              ),
            ),
            if (badgeText != null) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white.withAlpha(50) : colors.badgeOpenBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  badgeText,
                  style: GoogleFonts.inter(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w800,
                    color: isSelected ? Colors.white : colors.badgeOpenText,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
