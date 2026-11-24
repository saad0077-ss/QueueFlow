import 'package:flutter/material.dart';
import 'package:patient_app/features/booking/domain/entities/appointment_entity.dart';

import '../../bloc/booking_history_bloc.dart';
import 'booking_history_dialog_helper.dart';
import 'booking_history_empty_state.dart';
import 'booking_history_filter_tabs.dart';
import 'booking_history_list.dart';
import 'booking_history_search_bar.dart';
import 'booking_history_stats_bar.dart';

class BookingHistoryContent extends StatelessWidget {
  final BookingHistoryState state;
  final BookingHistoryBloc bloc;
  final List<AppointmentEntity> filtered;
  final ValueChanged<String>? onBookClinic;
  final VoidCallback? onTrackLiveQueue;

  const BookingHistoryContent({
    super.key,
    required this.state,
    required this.bloc,
    required this.filtered,
    this.onBookClinic,
    this.onTrackLiveQueue,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        BookingHistoryStatsBar(
          totalVisits: state.totalVisits,
          completedCount: state.completedCount,
          upcomingCount: state.upcomingCount,
        ),
        BookingHistorySearchBar(
          controller: TextEditingController(text: state.searchQuery)
            ..selection =
                TextSelection.collapsed(offset: state.searchQuery.length),
          onChanged: bloc.setSearchQuery,
          onClear: () => bloc.setSearchQuery(''),
        ),
        BookingHistoryFilterTabs(
          selectedIndex: state.filterIndex,
          allCount: state.totalVisits,
          onFilterChanged: bloc.setFilter,
        ),
        if (filtered.isEmpty)
          const BookingHistoryEmptyState()
        else
          BookingHistoryList(
            appointments: filtered,
            onBookAgain: (id) {
              Navigator.of(context).pop();
              onBookClinic?.call(id);
            },
            onRateVisit: (apt) =>
                BookingHistoryDialogHelper.openRating(context, apt),
            onTrackQueue: () {
              Navigator.of(context).pop();
              onTrackLiveQueue?.call();
            },
          ),
      ],
    );
  }
}
