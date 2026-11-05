import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

class BookingStepperHeader extends StatelessWidget {
  final int currentStep;
  final ValueChanged<int>? onStepTapped;

  const BookingStepperHeader({
    super.key,
    required this.currentStep,
    this.onStepTapped,
  });

  static const List<String> _stepTitles = [
    'Service',
    'Doctor',
    'Date & Time',
    'Confirm',
  ];

  @override
  Widget build(BuildContext context) {
    if (currentStep > 4) return const SizedBox.shrink();
    final colors = context.colors;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          for (int i = 0; i < _stepTitles.length; i++) ...[
            _buildStepItem(i + 1, _stepTitles[i], colors),
            if (i < _stepTitles.length - 1) _buildStepLine(i + 1, colors),
          ],
        ],
      ),
    );
  }

  Widget _buildStepItem(int stepNumber, String title, AppColorsExtension colors) {
    final bool isDone = stepNumber < currentStep;
    final bool isActive = stepNumber == currentStep;

    return GestureDetector(
      onTap: isDone ? () => onStepTapped?.call(stepNumber) : null,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: isActive ? AppColors.primaryGradient : null,
              color: isDone
                  ? colors.accent
                  : (!isActive ? colors.surfaceSecondary : null),
              border: Border.all(
                color: isDone
                    ? colors.accent
                    : (isActive ? Colors.transparent : colors.border),
                width: 1.5,
              ),
              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color: colors.primary.withValues(alpha: 0.35),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ]
                  : null,
            ),
            child: Center(
              child: isDone
                  ? const Icon(
                      Icons.check_rounded,
                      size: 16,
                      color: Colors.white,
                    )
                  : Text(
                      '$stepNumber',
                      style: GoogleFonts.inter(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                        color: isActive ? Colors.white : colors.textSubtle,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
              color: isActive
                  ? colors.textPrimary
                  : (isDone ? colors.textMuted : colors.textSubtle),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepLine(int stepNumber, AppColorsExtension colors) {
    final bool isDone = stepNumber < currentStep;

    return Expanded(
      child: Container(
        height: 2.5,
        margin: const EdgeInsets.only(bottom: 18, left: 6, right: 6),
        decoration: BoxDecoration(
          color: isDone ? colors.accent : colors.border,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}
