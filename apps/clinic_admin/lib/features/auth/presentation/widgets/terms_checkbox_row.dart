import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

class TermsCheckboxRow extends StatelessWidget {
  final bool agreed;
  final ValueChanged<bool> onChanged;

  const TermsCheckboxRow({
    super.key,
    required this.agreed,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 20,
          height: 20,
          child: Checkbox(
            value: agreed,
            onChanged: (val) => onChanged(val ?? false),
            activeColor: colors.primary,
            side: BorderSide(color: colors.border, width: 1.3),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: GestureDetector(
            onTap: () => onChanged(!agreed),
            child: RichText(
              text: TextSpan(
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: colors.textMuted,
                  height: 1.4,
                ),
                children: [
                  const TextSpan(text: "I agree to QueueFlow's "),
                  TextSpan(
                    text: 'Terms of Service',
                    style: TextStyle(
                      color: colors.primaryLight,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const TextSpan(text: ' and '),
                  TextSpan(
                    text: 'Privacy\nPolicy',
                    style: TextStyle(
                      color: colors.primaryLight,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const TextSpan(text: '.'),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
