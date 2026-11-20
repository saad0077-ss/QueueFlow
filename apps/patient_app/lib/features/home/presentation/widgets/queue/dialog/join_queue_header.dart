import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

class JoinQueueHeader extends StatelessWidget {
  final String clinicName;

  const JoinQueueHeader({super.key, required this.clinicName});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1E40AF), Color(0xFF38BDF8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF2563EB).withValues(alpha: 0.4),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: const Icon(
            Icons.bolt_rounded,
            color: Colors.white,
            size: 28,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Join Live Queue',
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: colors.textPrimary,
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(height: 8),
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: colors.textMuted,
              height: 1.4,
            ),
            children: [
              const TextSpan(
                text: 'You will be assigned the next digital triage token at ',
              ),
              TextSpan(
                text: clinicName,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: colors.textPrimary,
                ),
              ),
              const TextSpan(text: '.'),
            ],
          ),
        ),
      ],
    );
  }
}
