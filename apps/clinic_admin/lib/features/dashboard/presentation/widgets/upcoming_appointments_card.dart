import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'appointment_item_model.dart';
import 'appointment_table_row.dart';

/// Card showing the table of upcoming appointments in the clinic dashboard.
class UpcomingAppointmentsCard extends StatelessWidget {
  final VoidCallback? onViewAll;

  const UpcomingAppointmentsCard({
    super.key,
    this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF10192D),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF1E293B).withValues(alpha: 0.8),
        ),
      ),
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Title and "View all" action
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Upcoming appointments',
                style: GoogleFonts.inter(
                  fontSize: 15.5,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              InkWell(
                onTap: onViewAll ??
                    () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Viewing all appointments'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                borderRadius: BorderRadius.circular(4),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  child: Row(
                    children: [
                      Text(
                        'View all',
                        style: GoogleFonts.inter(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF38BDF8),
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.arrow_forward_rounded,
                        size: 14,
                        color: Color(0xFF38BDF8),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // Column Headers Row
          const _AppointmentTableHeader(),

          const Divider(height: 1, color: Color(0xFF1E293B)),

          // Appointment Rows List
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: AppointmentItem.defaultList.length,
            separatorBuilder: (context, index) => const Divider(
              height: 1,
              color: Color(0x331E293B),
            ),
            itemBuilder: (context, index) {
              return AppointmentTableRow(
                appointment: AppointmentItem.defaultList[index],
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          _headerText('TIME', flex: 2),
          _headerText('CUSTOMER', flex: 3),
          _headerText('SERVICE', flex: 4),
          _headerText('DOCTOR', flex: 3),
          _headerText('STATUS', flex: 3, alignRight: true),
        ],
      ),
    );
  }

  Widget _headerText(String title, {required int flex, bool alignRight = false}) {
    final text = Text(
      title,
      style: GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF64748B),
        letterSpacing: 0.6,
      ),
    );
    return Expanded(
      flex: flex,
      child: alignRight ? Align(alignment: Alignment.centerRight, child: text) : text,
    );
  }
}
