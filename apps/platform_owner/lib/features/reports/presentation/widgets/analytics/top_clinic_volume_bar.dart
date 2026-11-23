import 'package:flutter/material.dart';

class TopClinicVolumeBar extends StatelessWidget {
  final int barWidthPercentage;
  final int colorHex;
  final bool isDark;

  const TopClinicVolumeBar({
    super.key,
    required this.barWidthPercentage,
    required this.colorHex,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 6,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: FractionallySizedBox(
          widthFactor: (barWidthPercentage / 100.0).clamp(0.05, 1.0),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(colorHex).withValues(alpha: 0.8),
                  Color(colorHex),
                ],
              ),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        ),
      ),
    );
  }
}
