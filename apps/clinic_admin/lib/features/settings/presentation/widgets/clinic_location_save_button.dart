import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ClinicLocationSaveButton extends StatelessWidget {
  final VoidCallback onSave;

  const ClinicLocationSaveButton({super.key, required this.onSave});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onSave,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2563EB),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        icon: const Icon(Icons.save_rounded, size: 16),
        label: Text('Save Location & Map Settings', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600)),
      ),
    );
  }
}
