import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

class AppointmentsHeaderBar extends StatelessWidget {
  final String viewMode; // 'list' or 'calendar'
  final ValueChanged<String> onViewModeChanged;
  final VoidCallback onExportCsv;
  final VoidCallback onCreateAppointment;

  const AppointmentsHeaderBar({
    super.key,
    required this.viewMode,
    required this.onViewModeChanged,
    required this.onExportCsv,
    required this.onCreateAppointment,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 720;

        final titleSection = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Appointments',
              style: GoogleFonts.inter(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: colors.textPrimary,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Schedule, filter and manage patient bookings',
              style: GoogleFonts.inter(
                fontSize: 13.5,
                fontWeight: FontWeight.w400,
                color: colors.textMuted,
              ),
            ),
          ],
        );

        final controlsSection = Wrap(
          spacing: 10,
          runSpacing: 10,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            // List / Calendar Toggle Segment
            Container(
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: colors.border, width: 1.2),
              ),
              padding: const EdgeInsets.all(3),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _ToggleButton(
                    title: 'List View',
                    icon: Icons.view_list_rounded,
                    isActive: viewMode == 'list',
                    onTap: () => onViewModeChanged('list'),
                  ),
                  const SizedBox(width: 4),
                  _ToggleButton(
                    title: 'Calendar View',
                    icon: Icons.calendar_month_outlined,
                    isActive: viewMode == 'calendar',
                    onTap: () => onViewModeChanged('calendar'),
                  ),
                ],
              ),
            ),

            // Export CSV Button
            OutlinedButton.icon(
              onPressed: onExportCsv,
              icon: Icon(
                Icons.file_download_outlined,
                size: 16,
                color: colors.textPrimary,
              ),
              label: Text(
                'Export Report',
                style: GoogleFonts.inter(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: colors.textPrimary,
                ),
              ),
              style: OutlinedButton.styleFrom(
                backgroundColor: colors.surface,
                side: BorderSide(color: colors.border, width: 1.2),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),

            // Create Appointment Button
            ElevatedButton.icon(
              onPressed: onCreateAppointment,
              icon: const Icon(
                Icons.add_rounded,
                size: 17,
                color: Colors.white,
              ),
              label: Text(
                'Create Appointment',
                style: GoogleFonts.inter(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.primary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ],
        );

        if (isCompact) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              titleSection,
              const SizedBox(height: 16),
              controlsSection,
            ],
          );
        }

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(child: titleSection),
            const SizedBox(width: 16),
            controlsSection,
          ],
        );
      },
    );
  }
}

class _ToggleButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  const _ToggleButton({
    required this.title,
    required this.icon,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(7),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6.5),
        decoration: BoxDecoration(
          color: isActive ? colors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(7),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14.5,
              color: isActive ? Colors.white : colors.textMuted,
            ),
            const SizedBox(width: 6),
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                color: isActive ? Colors.white : colors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
