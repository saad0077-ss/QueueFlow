import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

class ClinicProfileHeader extends StatelessWidget {
  final String clinicName;
  final String imageUrl;
  final Uint8List? imageBytes;
  final Uint8List? pickedBytes;
  final bool isUploadingImage;
  final VoidCallback onPickImage;

  const ClinicProfileHeader({
    super.key,
    required this.clinicName,
    required this.imageUrl,
    this.imageBytes,
    required this.pickedBytes,
    required this.isUploadingImage,
    required this.onPickImage,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final name = clinicName.trim();
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'C';

    Widget image;
    final bytes = pickedBytes ?? imageBytes;
    if (bytes != null) {
      image = Image.memory(bytes, fit: BoxFit.cover, width: double.infinity, height: double.infinity, gaplessPlayback: true);
    } else if (imageUrl.trim().isNotEmpty) {
      image = Image.network(
        imageUrl.trim(),
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (context, error, stackTrace) => _initialAvatar(context, initial),
      );
    } else {
      image = _initialAvatar(context, initial);
    }

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.surfaceSecondary,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border),
      ),
      child: Wrap(
        spacing: 18,
        runSpacing: 14,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 88,
                height: 88,
                clipBehavior: Clip.antiAlias,
                // No background colour: it showed as a dark fringe around the photo.
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                ),
                foregroundDecoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: colors.accent.withAlpha(140), width: 2),
                ),
                child: SizedBox.expand(child: image),
              ),
              if (isUploadingImage)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(20)),
                    child: Center(
                      child: SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2.4, color: colors.primary),
                      ),
                    ),
                  ),
                ),
              Positioned(
                right: -6,
                bottom: -6,
                child: Material(
                  color: colors.primary,
                  shape: CircleBorder(side: BorderSide(color: colors.surface, width: 3)),
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: isUploadingImage ? null : onPickImage,
                    child: const Padding(
                      padding: EdgeInsets.all(7),
                      child: Icon(Icons.camera_alt_rounded, size: 15, color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          ),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name.isEmpty ? 'Your Clinic' : name,
                  style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800, color: colors.textPrimary),
                ),
                const SizedBox(height: 4),
                Text(
                  'This photo is shown to patients on the clinic card and details page.',
                  style: GoogleFonts.inter(fontSize: 12, color: colors.textMuted),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: isUploadingImage ? null : onPickImage,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colors.textPrimary,
                    side: BorderSide(color: colors.border),
                    backgroundColor: colors.surface,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: const Icon(Icons.upload_rounded, size: 16),
                  label: Text(
                    isUploadingImage ? 'Uploading...' : (imageUrl.isEmpty && bytes == null ? 'Upload Photo' : 'Change Photo'),
                    style: GoogleFonts.inter(fontSize: 12.5, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _initialAvatar(BuildContext context, String initial) {
    final colors = context.colors;
    return Container(
      color: colors.primaryTint,
      alignment: Alignment.center,
      child: Text(
        initial,
        style: GoogleFonts.inter(fontSize: 32, fontWeight: FontWeight.w800, color: colors.primary),
      ),
    );
  }
}
