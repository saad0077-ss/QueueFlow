import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

class ServiceDeleteDialog extends StatelessWidget {
  final String serviceName;
  final VoidCallback onConfirm;

  const ServiceDeleteDialog({
    super.key,
    required this.serviceName,
    required this.onConfirm,
  });

  static Future<void> show(
    BuildContext context, {
    required String serviceName,
    required VoidCallback onConfirm,
  }) {
    return showDialog(
      context: context,
      builder: (_) =>
          ServiceDeleteDialog(serviceName: serviceName, onConfirm: onConfirm),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return AlertDialog(
      backgroundColor: colors.surfaceElevated,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: colors.border),
      ),
      title: Text(
        'Delete Service',
        style: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: colors.textPrimary,
        ),
      ),
      content: Text(
        'Are you sure you want to delete "$serviceName" permanently?',
        style: GoogleFonts.inter(fontSize: 13, color: colors.textMuted),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            'Cancel',
            style: GoogleFonts.inter(color: colors.textMuted),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
            onConfirm();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: colors.error,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(
            'Delete',
            style: GoogleFonts.inter(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
