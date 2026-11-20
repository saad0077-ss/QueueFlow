import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

class QueueFilterFooter extends StatelessWidget {
  final VoidCallback onReset;
  final VoidCallback onCancel;
  final VoidCallback onApply;

  const QueueFilterFooter({
    super.key,
    required this.onReset,
    required this.onCancel,
    required this.onApply,
  });

  Widget _pillOutlined(BuildContext context, String label, VoidCallback onTap) {
    final colors = context.colors;
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        foregroundColor: colors.textPrimary,
        side: BorderSide(color: colors.border),
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
        shape: const StadiumBorder(),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 14, 22, 18),
      child: Row(
        children: [
          _pillOutlined(context, 'Reset All', onReset),
          const Spacer(),
          _pillOutlined(context, 'Cancel', onCancel),
          const SizedBox(width: 10),
          Container(
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(999),
            ),
            child: ElevatedButton(
              onPressed: onApply,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 14,
                ),
                shape: const StadiumBorder(),
              ),
              child: Text(
                'Apply Filters',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
