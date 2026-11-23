import 'package:flutter/material.dart';

class ClinicTicketsFilterCardItem extends StatelessWidget {
  final bool isSelected;
  final VoidCallback onTap;
  final Widget child;

  const ClinicTicketsFilterCardItem({
    super.key,
    required this.isSelected,
    required this.onTap,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF2563EB).withValues(alpha: 0.18)
              : const Color(0xFF1E293B).withValues(alpha: 0.55),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF3B82F6)
                : const Color(0xFF334155),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: child,
      ),
    );
  }
}
