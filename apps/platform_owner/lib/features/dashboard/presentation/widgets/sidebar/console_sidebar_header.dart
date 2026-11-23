import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

class ConsoleSidebarHeader extends StatelessWidget {
  const ConsoleSidebarHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isLight = Theme.of(context).brightness == Brightness.light;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 28, 20, 28),
      child: Row(
        children: [
          if (isLight)
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                'assets/icons/app_logo.png',
                width: 34,
                height: 34,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Icon(
                  Icons.bubble_chart_rounded,
                  color: colors.primary,
                  size: 24,
                ),
              ),
            )
          else
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
              ),
            ),
          const SizedBox(width: 12),
          RichText(
            text: TextSpan(
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.4,
              ),
              children: [
                TextSpan(
                  text: 'Queue',
                  style: TextStyle(color: colors.textPrimary),
                ),
                TextSpan(
                  text: 'Flow',
                  style: TextStyle(color: colors.primaryLight),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
