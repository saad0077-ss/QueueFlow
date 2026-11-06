import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';
import '../../domain/entities/clinic_department_summary_entity.dart';

/// Header displaying the greeting, current date, clinic name, department tags,
/// and period filter dropdown matching the web-admin design.
class DashboardGreetingHeader extends StatefulWidget {
  final String doctorName;
  final String clinicName;
  final List<ClinicDepartmentSummaryEntity> departments;
  final ValueChanged<String>? onPeriodChanged;

  const DashboardGreetingHeader({
    super.key,
    this.doctorName = '',
    this.clinicName = '',
    this.departments = const [],
    this.onPeriodChanged,
  });

  @override
  State<DashboardGreetingHeader> createState() =>
      _DashboardGreetingHeaderState();
}

class _DashboardGreetingHeaderState extends State<DashboardGreetingHeader> {
  String _selectedPeriod = 'today';

  static const _weekdays = [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
  ];
  static const _months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final now = DateTime.now();
    final greeting = now.hour < 12
        ? 'Good morning'
        : (now.hour < 17 ? 'Good afternoon' : 'Good evening');
    final date =
        '${_weekdays[now.weekday - 1]}, ${now.day} ${_months[now.month - 1]} ${now.year}';

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 720;

        final infoSection = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Greeting H1
            Text(
              widget.doctorName.isEmpty
                  ? greeting
                  : '$greeting, ${widget.doctorName}',
              style: GoogleFonts.inter(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: colors.textPrimary,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 5),

            // Date, Clinic Name & Department Badges
            Wrap(
              spacing: 8,
              runSpacing: 6,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  widget.clinicName.isEmpty ? date : '$date  ·',
                  style: GoogleFonts.inter(
                    fontSize: 12.5,
                    color: colors.textMuted,
                  ),
                ),
                if (widget.clinicName.isNotEmpty)
                  Text(
                    widget.clinicName,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: colors.textPrimary,
                    ),
                  ),
                for (final d in widget.departments)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: colors.primaryTint,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: colors.primary.withValues(alpha: 0.25),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(d.icon, style: const TextStyle(fontSize: 11)),
                        const SizedBox(width: 4),
                        Text(
                          d.name,
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: colors.primary,
                          ),
                        ),
                        const SizedBox(width: 3),
                        Text(
                          '(${d.code})',
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w600,
                            color: colors.primary.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        );

        final periodFilter = Container(
          height: 38,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: colors.surfaceSecondary,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: colors.border),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedPeriod,
              dropdownColor: colors.surface,
              icon: Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 18,
                color: colors.textMuted,
              ),
              items: const [
                DropdownMenuItem(value: 'today', child: Text('Today')),
                DropdownMenuItem(value: 'yesterday', child: Text('Yesterday')),
                DropdownMenuItem(value: 'week', child: Text('This week')),
              ],
              onChanged: (val) {
                if (val != null) {
                  setState(() => _selectedPeriod = val);
                  widget.onPeriodChanged?.call(val);
                }
              },
              style: GoogleFonts.inter(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: colors.textPrimary,
              ),
            ),
          ),
        );

        if (isCompact) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              infoSection,
              const SizedBox(height: 14),
              periodFilter,
            ],
          );
        }

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(child: infoSection),
            const SizedBox(width: 16),
            periodFilter,
          ],
        );
      },
    );
  }
}
