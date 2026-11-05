import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

/// The logo widget displayed at the top of the clinic admin sidebar.
class ClinicSidebarLogo extends StatelessWidget {
  final bool compact;

  const ClinicSidebarLogo({super.key, this.compact = false});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isLight = Theme.of(context).brightness == Brightness.light;

    return Padding(
      padding: compact
          ? const EdgeInsets.symmetric(vertical: 28)
          : const EdgeInsets.fromLTRB(24, 28, 20, 28),
      child: Row(
        mainAxisAlignment: compact
            ? MainAxisAlignment.center
            : MainAxisAlignment.start,
        children: [
          // Light mode uses the patient app's logo, which carries its own
          // rounded blue background.
          if (isLight)
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                'assets/icons/app_logo.png',
                width: 34,
                height: 34,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Icon(
                  Icons.bubble_chart_rounded,
                  color: colors.primary,
                  size: 24,
                ),
              ),
            )
          else
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
          if (!compact) ...[
            const SizedBox(width: 12),
            // App Title "QueueFlow"
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: RichText(
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
              ),
            ),
          ],
        ],
      ),
    );
  }
}
