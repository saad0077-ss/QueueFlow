import 'package:flutter/material.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

class OnboardingSlide extends StatelessWidget {
  final Widget card;
  final String? title;
  final Widget? titleWidget;
  final String subtitle;

  const OnboardingSlide({
    super.key,
    required this.card,
    this.title,
    this.titleWidget,
    required this.subtitle,
  }) : assert(title != null || titleWidget != null, 'Provide either title or titleWidget');

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 26),
      child: Center(
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              card,
              const SizedBox(height: 38),
              if (titleWidget != null)
                titleWidget!
              else
                Text(
                  title!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontSize: 34,
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                    letterSpacing: -0.5,
                  ),
                ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: colors.textMuted,
                    fontSize: 14,
                    height: 1.45,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
