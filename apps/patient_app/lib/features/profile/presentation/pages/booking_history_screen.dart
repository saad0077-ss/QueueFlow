import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

import '../../../../core/widgets/app_snack_bar.dart';
import '../../../booking/data/repositories/booking_repository_impl.dart';
import '../../../booking/domain/repositories/booking_repository.dart';
import '../bloc/booking_history_bloc.dart';
import '../widgets/booking_history/booking_history_content.dart';
import '../widgets/booking_history/booking_history_header.dart';

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
    return Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => BookingHistoryScreen(
        repository: repository,
        onTrackLiveQueue: onTrackLiveQueue,
        onBookClinic: onBookClinic,
      ),
    ));
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
                        AppSnackBar.showSuccess(context,
                            message: 'Booking history refreshed');
                      }
                    },
                  ),
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final isLaptop = constraints.maxWidth >= 800;
                        return RefreshIndicator(
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
                                  physics:
                                      const AlwaysScrollableScrollPhysics(),
                                  padding: EdgeInsets.symmetric(
                                    horizontal: isLaptop ? 32 : 16,
                                    vertical: 14,
                                  ),
                                  child: Center(
                                    child: ConstrainedBox(
                                      constraints: BoxConstraints(
                                        maxWidth: isLaptop ? 1280 : 640,
                                      ),
                                      child: BookingHistoryContent(
                                        state: state,
                                        bloc: bloc,
                                        filtered: filtered,
                                        onBookClinic: onBookClinic,
                                        onTrackLiveQueue: onTrackLiveQueue,
                                      ),
                                    ),
                                  ),
                                ),
                        );
                      },
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
