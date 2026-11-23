import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

import '../../../../core/widgets/app_snack_bar.dart';
import '../../../booking/data/repositories/booking_repository_impl.dart';
import '../../../booking/domain/entities/appointment_entity.dart';
import '../../../booking/domain/repositories/booking_repository.dart';
import '../../../clinic_details/presentation/widgets/doctor_rate_dialog.dart';
import '../bloc/booking_history_bloc.dart';
import '../widgets/booking_history/booking_history_empty_state.dart';
import '../widgets/booking_history/booking_history_filter_tabs.dart';
import '../widgets/booking_history/booking_history_header.dart';
import '../widgets/booking_history/booking_history_list.dart';
import '../widgets/booking_history/booking_history_search_bar.dart';
import '../widgets/booking_history/booking_history_stats_bar.dart';

class BookingHistoryScreen extends StatelessWidget {
  final BookingRepository? repository;
  final VoidCallback? onTrackLiveQueue;
  final ValueChanged<String>? onBookClinic;

  const BookingHistoryScreen({
    super.key,
    this.repository,
    this.onTrackLiveQueue,
    this.onBookClinic,
  });

  static Future<void> open(
    BuildContext context, {
    BookingRepository? repository,
    VoidCallback? onTrackLiveQueue,
    ValueChanged<String>? onBookClinic,
  }) {
    return Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BookingHistoryScreen(
          repository: repository,
          onTrackLiveQueue: onTrackLiveQueue,
          onBookClinic: onBookClinic,
        ),
      ),
    );
  }

  void _openDoctorRating(BuildContext context, AppointmentEntity apt) {
    showDialog(
      context: context,
      builder: (_) => DoctorRateDialog(
        doctorName: apt.doctorName,
        onSubmit: (rating, comment) {
          Navigator.of(context).pop();
          AppSnackBar.showSuccess(
            context,
            message: 'Rating ($rating ★) submitted for ${apt.doctorName}',
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => BookingHistoryBloc(repository ?? BookingRepositoryImpl()),
      child: BlocBuilder<BookingHistoryBloc, BookingHistoryState>(
        builder: (context, state) {
          final bloc = context.read<BookingHistoryBloc>();
          final colors = context.colors;
          final filtered = state.filteredAppointments;

          return Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            body: SafeArea(
              child: Column(
                children: [
                  BookingHistoryHeader(
                    onBack: () => Navigator.of(context).pop(),
                    onRefresh: () async {
                      bloc.load();
                      if (context.mounted) {
                        AppSnackBar.showSuccess(
                          context,
                          message: 'Booking history refreshed',
                        );
                      }
                    },
                  ),
                  Expanded(
                    child: RefreshIndicator(
                      color: AppColors.primary,
                      backgroundColor: colors.surface,
                      onRefresh: () async => bloc.load(),
                      child: state.isLoading
                          ? const Center(
                              child: CircularProgressIndicator(
                                color: AppColors.primary,
                              ),
                            )
                          : SingleChildScrollView(
                              physics: const AlwaysScrollableScrollPhysics(
                                parent: BouncingScrollPhysics(),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                              child: Center(
                                child: ConstrainedBox(
                                  constraints: const BoxConstraints(
                                    maxWidth: 640,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      BookingHistoryStatsBar(
                                        totalVisits: state.totalVisits,
                                        completedCount: state.completedCount,
                                        upcomingCount: state.upcomingCount,
                                      ),
                                      BookingHistorySearchBar(
                                        controller:
                                            TextEditingController(
                                                text: state.searchQuery,
                                              )
                                              ..selection =
                                                  TextSelection.collapsed(
                                                    offset: state
                                                        .searchQuery
                                                        .length,
                                                  ),
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
                                          onBookAgain: (clinicId) {
                                            Navigator.of(context).pop();
                                            onBookClinic?.call(clinicId);
                                          },
                                          onRateVisit: (apt) =>
                                              _openDoctorRating(context, apt),
                                          onTrackQueue: () {
                                            Navigator.of(context).pop();
                                            onTrackLiveQueue?.call();
                                          },
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
