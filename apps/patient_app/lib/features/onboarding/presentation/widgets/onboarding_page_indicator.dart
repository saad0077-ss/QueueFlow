import 'package:flutter/material.dart';

class OnboardingPageIndicator extends StatelessWidget {
  final int currentPage;
  final int totalPages; 

  const OnboardingPageIndicator({
    super.key,
    required this.currentPage,
    this.totalPages = 2,
  }); 

  @override
  Widget build(BuildContext context) {
    return Row( 
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(totalPages, (index) {
        final bool isActive = index == currentPage;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: isActive ? 26 : 6,
          height: isActive ? 5 : 6,
          decoration: BoxDecoration(
            gradient: isActive
                ? const LinearGradient(
                    colors: [Color(0xFF2563EB), Color(0xFF00BFA5)],
                  )
                : null,
            color: isActive ? null : const Color(0xFF475569),
            borderRadius: BorderRadius.circular(3),
          ),
        );
      }),
    );
  }
}
