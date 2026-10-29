import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
    final name = clinicName.trim();
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'C';

    Widget image;
    final bytes = pickedBytes ?? imageBytes;
    if (bytes != null) {
      image = Image.memory(bytes, fit: BoxFit.cover, gaplessPlayback: true);
    } else if (imageUrl.trim().isNotEmpty) {
      image = Image.network(imageUrl.trim(), fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) => _initialAvatar(initial));
    } else {
      image = _initialAvatar(initial);
    }

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF13233F), Color(0xFF0F1A30)]),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1E3A5F)),
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
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF14B8A6).withAlpha(140), width: 2),
                ),
                child: image,
              ),
              if (isUploadingImage)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(20)),
                    child: const Center(child: SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.4))),
                  ),
                ),
              Positioned(
                right: -6,
                bottom: -6,
                child: Material(
                  color: const Color(0xFF2563EB),
                  shape: const CircleBorder(side: BorderSide(color: Color(0xFF0F172A), width: 3)),
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
                Text(name.isEmpty ? 'Your Clinic' : name, style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white)),
                const SizedBox(height: 4),
                Text(
                  'This photo is shown to patients on the clinic card and details page.',
                  style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF94A3B8)),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: isUploadingImage ? null : onPickImage,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Color(0xFF334E7A)),
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

  Widget _initialAvatar(String initial) {
    return Container(
      color: const Color(0xFF0F3B3A),
      alignment: Alignment.center,
      child: Text(initial, style: GoogleFonts.inter(fontSize: 32, fontWeight: FontWeight.w800, color: const Color(0xFF2DD4BF))),
    );
  }
}
