import 'package:flutter/material.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

class GradientButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final double? width;
  final double? maxWidth;
  final double height;
  final AlignmentGeometry alignment;

  const GradientButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.width,
    this.maxWidth = 380,
    this.height = 52,
    this.alignment = Alignment.center,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    final buttonWidget = Container(
      width: width ?? double.infinity,
      height: height,
      decoration: BoxDecoration(
        gradient: onPressed == null ? null : AppColors.primaryGradient,
        color: onPressed == null ? colors.border : null,
        borderRadius: BorderRadius.circular(height / 2),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(height / 2),
          onTap: isLoading ? null : onPressed,
          child: Center(
            child: isLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    text,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16.5,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.2,
                    ),
                  ),
          ),
        ),
      ),
    );

    if (maxWidth != null) {
      return Align(
        alignment: alignment,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: maxWidth!,
            minHeight: height,
          ),
          child: buttonWidget,
        ),
      );
    }

    return buttonWidget;
  }
}
