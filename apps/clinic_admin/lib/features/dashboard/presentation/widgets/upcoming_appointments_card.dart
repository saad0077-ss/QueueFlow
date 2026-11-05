import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

import '../../../../core/widgets/app_snack_bar.dart';
import 'appointment_item_model.dart';
import 'appointment_table_row.dart';

/// Card showing the table of upcoming appointments in the clinic dashboard.
class UpcomingAppointmentsCard extends StatelessWidget {
  static const double _minTableWidth = 540;

  final VoidCallback? onViewAll;

  const UpcomingAppointmentsCard({super.key, this.onViewAll});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border),
      ),
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Title and "View all" action
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  'Upcoming appointments',
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w600,
                    color: colors.textPrimary,
                  ),
                ),
              ),
              InkWell(
                onTap:
                    onViewAll ??
                    () {
                      AppSnackBar.showInfo(
                        context,
                        message: 'Viewing all appointments',
                      );
                    },
                borderRadius: BorderRadius.circular(4),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 2,
                  ),
                  child: Row(
                    children: [
                      Text(
                        'View all',
                        style: GoogleFonts.inter(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w500,
                          color: colors.primary,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.arrow_forward_rounded,
                        size: 14,
                        color: colors.primary,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // The table keeps a minimum width and scrolls sideways on
          // narrow screens instead of squashing its five columns.
          LayoutBuilder(
            builder: (context, constraints) {
              final table = Column(
                children: [
                  // Column Headers Row
                  const _AppointmentTableHeader(),

                  Divider(height: 1, color: colors.border),

                  // Appointment Rows List
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: AppointmentItem.defaultList.length,
                    separatorBuilder: (context, index) =>
                        Divider(height: 1, color: colors.borderSubtle),
                    itemBuilder: (context, index) {
                      return AppointmentTableRow(
                        appointment: AppointmentItem.defaultList[index],
                      );
                    },
                  ),
                ],
              );

              if (constraints.maxWidth >= _minTableWidth) return table;
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SizedBox(width: _minTableWidth, child: table),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _AppointmentTableHeader extends StatelessWidget {
  const _AppointmentTableHeader();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          _headerText('TIME', flex: 2, color: colors.textMuted),
          _headerText('CUSTOMER', flex: 3, color: colors.textMuted),
          _headerText('SERVICE', flex: 4, color: colors.textMuted),
          _headerText('DOCTOR', flex: 3, color: colors.textMuted),
          _headerText('STATUS', flex: 3, alignRight: true, color: colors.textMuted),
        ],
      ),
    );
  }

  Widget _headerText(
    String title, {
    required int flex,
    bool alignRight = false,
    required Color color,
  }) {
    final text = Text(
      title,
      style: GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: color,
        letterSpacing: 0.6,
      ),
    );
    return Expanded(
      flex: flex,
      child: alignRight
          ? Align(alignment: Alignment.centerRight, child: text)
          : text,
    );
  }
}
