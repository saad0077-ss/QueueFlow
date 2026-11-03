import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
    final isMonthly = activeCadence == 'monthly';

    return Column(
      children: [
        Text(
          'QueueFlow Subscription Plans',
          style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 6),
        Text(
          'Doctor-capacity based pricing for clinics of all sizes. Switch or upgrade anytime.',
          style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF94A3B8)),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: const Color(0xFF1E293B)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _toggleOption(
                label: 'Monthly',
                isSelected: isMonthly,
                onTap: () => onCadenceChanged('monthly'),
              ),
              _toggleOption(
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
          color: isSelected ? const Color(0xFF2563EB) : Colors.transparent,
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
                color: isSelected ? Colors.white : const Color(0xFF94A3B8),
              ),
            ),
            if (badgeText != null) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white.withAlpha(50) : const Color(0xFF10B981).withAlpha(40),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  badgeText,
                  style: GoogleFonts.inter(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w800,
                    color: isSelected ? Colors.white : const Color(0xFF34D399),
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
