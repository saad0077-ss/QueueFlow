import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// The logo widget displayed at the top of the clinic admin sidebar.
class ClinicSidebarLogo extends StatelessWidget {
  const ClinicSidebarLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 28, 20, 28),
      child: Row(
        children: [
          // Logo Icon Container with gradient and shadow
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              gradient: const LinearGradient(
                colors: [Color(0xFF0072FF), Color(0xFF00C6FF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF00C6FF).withValues(alpha: 0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Image.asset(
              'assets/icons/app_icon_128.png',
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => const Icon(
                Icons.bubble_chart_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 12),
          // App Title "QueueFlow"
          RichText(
            text: TextSpan(
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.4,
              ),
              children: const [
                TextSpan(
                  text: 'Queue',
                  style: TextStyle(color: Colors.white),
                ),
                TextSpan(
                  text: 'Flow',
                  style: TextStyle(color: Color(0xFF38BDF8)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
