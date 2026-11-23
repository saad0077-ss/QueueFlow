import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppFilterHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final VoidCallback onClose;

  const AppFilterHeader({
    super.key,
    required this.title,
    this.subtitle,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 18, 16, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: -0.2,
                  ),
                ),
                if (subtitle != null && subtitle!.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(
                    subtitle!,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: const Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            onPressed: onClose,
            icon: const Icon(
              Icons.close_rounded,
              size: 20,
              color: Color(0xFF94A3B8),
            ),
            splashRadius: 18,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            tooltip: 'Close',
          ),
        ],
      ),
    );
  }
}
