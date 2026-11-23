import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

class RaiseConcernFormInputs extends StatelessWidget {
  final TextEditingController subjectController;
  final TextEditingController descController;
  final AppColorsExtension colors;

  const RaiseConcernFormInputs({
    super.key,
    required this.subjectController,
    required this.descController,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Concern Subject *',
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: colors.textMuted,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: subjectController,
          style: GoogleFonts.inter(fontSize: 12.5, color: colors.textPrimary),
          decoration: InputDecoration(
            hintText: 'e.g. Waiting room delay exceeding 20 minutes',
            hintStyle: GoogleFonts.inter(fontSize: 12, color: colors.textMuted),
            filled: true,
            fillColor: colors.surface,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: colors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: colors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFF2563EB),
                width: 1.5,
              ),
            ),
          ),
          validator: (val) {
            if (val == null || val.trim().isEmpty) {
              return 'Please enter a concern subject';
            }
            return null;
          },
        ),
        const SizedBox(height: 14),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Concern Description / Details *',
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: colors.textMuted,
              ),
            ),
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: descController,
              builder: (context, value, _) {
                return Text(
                  '${value.text.length} / 500',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    color: colors.textMuted,
                  ),
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: descController,
          maxLines: 4,
          maxLength: 500,
          buildCounter: (
            _, {
            required currentLength,
            required isFocused,
            maxLength,
          }) => const SizedBox.shrink(),
          style: GoogleFonts.inter(
            fontSize: 12.5,
            color: colors.textPrimary,
            height: 1.4,
          ),
          decoration: InputDecoration(
            hintText: 'Describe what happened, token number, doctor name or how clinic reception can help you right away...',
            hintStyle: GoogleFonts.inter(fontSize: 12, color: colors.textMuted),
            filled: true,
            fillColor: colors.surface,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: colors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: colors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFF2563EB),
                width: 1.5,
              ),
            ),
          ),
          validator: (val) {
            if (val == null || val.trim().isEmpty) {
              return 'Please describe your concern';
            }
            return null;
          },
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFF2563EB).withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFF2563EB).withValues(alpha: 0.18),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('🛡️', style: TextStyle(fontSize: 15)),
              const SizedBox(width: 8),
              Expanded(
                child: RichText(
                  text: TextSpan(
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: colors.textPrimary,
                      height: 1.35,
                    ),
                    children: const [
                      TextSpan(
                        text: 'QueueFlow Patient Care SLA: ',
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                      TextSpan(
                        text: 'In-clinic queue and triage concerns are prioritized and routed directly to front desk personnel.',
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
