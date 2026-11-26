import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

import '../../../../home/presentation/bloc/home_bloc.dart';
import '../../../../home/presentation/widgets/home_notification_bell.dart';
import 'my_bookings_filter_bar.dart';

class MyBookingsHeader extends StatelessWidget {
  final bool isLaptop;
  final int selectedFilterIndex;
  final ValueChanged<int> onFilterChanged;

  const MyBookingsHeader({
    super.key,
    required this.isLaptop,
    required this.selectedFilterIndex,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    var unreadCount = 0;
    try {
      unreadCount = context.select<HomeBloc, int>(
        (b) => b.state.unreadNotificationsCount,
      );
    } catch (_) {}

    return Column(
      children: [
        if (!isLaptop) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'My Bookings',
                style: GoogleFonts.inter(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: colors.textPrimary,
                ),
              ),
              HomeNotificationBell(unreadCount: unreadCount),
            ],
          ),
          const SizedBox(height: 16),
        ],
        MyBookingsFilterBar(
          selectedFilterIndex: selectedFilterIndex,
          onFilterChanged: onFilterChanged,
        ),
      ],
    );
  }
}
