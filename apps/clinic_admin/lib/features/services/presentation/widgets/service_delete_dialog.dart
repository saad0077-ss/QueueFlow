import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
    return AlertDialog(
      backgroundColor: const Color(0xFF10192D),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      title: Text(
        'Delete Service',
        style: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
      content: Text(
        'Are you sure you want to delete "$serviceName" permanently?',
        style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF94A3B8)),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            'Cancel',
            style: GoogleFonts.inter(color: const Color(0xFF94A3B8)),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
            onConfirm();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFEF4444),
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
