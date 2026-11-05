import 'package:flutter/material.dart';
import 'package:queueflow_ui/queueflow_ui.dart';
import 'app_icon_badge.dart';

class AppLogo extends StatelessWidget {
  final double fontSize;
  final bool showIcon;

  const AppLogo({
    super.key,
    this.fontSize = 20,
    this.showIcon = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (showIcon) ...[
          AppIconBadge(size: fontSize * 1.2),
          const SizedBox(width: 8),
        ],
        RichText(
          text: TextSpan(
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
            ),
            children: [
              TextSpan(
                text: 'Queue',
                style: TextStyle(color: colors.textPrimary),
              ),
              const TextSpan(
                text: 'Flow',
                style: TextStyle(color: Color(0xFF2563EB)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
