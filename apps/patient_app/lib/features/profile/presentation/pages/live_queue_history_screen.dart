import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

import '../../../../core/widgets/app_snack_bar.dart';
import '../../data/repositories/profile_repository_impl.dart';
import '../../domain/repositories/profile_repository.dart';
import '../bloc/live_queue_history_bloc.dart';
import '../widgets/queue_history/live_queue_history_list.dart';
import '../widgets/queue_history/queue_history_empty_state.dart';
import '../widgets/queue_history/queue_history_filter_tabs.dart';
import '../widgets/queue_history/queue_history_header.dart';
import '../widgets/queue_history/queue_history_spotlight_card.dart';
import '../widgets/queue_history/queue_history_stats_bar.dart';

class LiveQueueHistoryScreen extends StatelessWidget {
  final ProfileRepository? repository;
  final VoidCallback? onTrackLiveQueue;
  final ValueChanged<String>? onBookClinic;

  const LiveQueueHistoryScreen({
    super.key,
    this.repository,
    this.onTrackLiveQueue,
    this.onBookClinic,
  });

  static Future<void> open(
    BuildContext context, {
    ProfileRepository? repository,
    VoidCallback? onTrackLiveQueue,
    ValueChanged<String>? onBookClinic,
  }) {
    return Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => LiveQueueHistoryScreen(
          repository: repository,
          onTrackLiveQueue: onTrackLiveQueue,
          onBookClinic: onBookClinic,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          LiveQueueHistoryBloc(repository ?? ProfileRepositoryImpl()),
      child: BlocBuilder<LiveQueueHistoryBloc, LiveQueueHistoryState>(
        builder: (context, state) {
          final bloc = context.read<LiveQueueHistoryBloc>();
          final colors = context.colors;
          final activeTicket = state.activeTicket;
          final filtered = state.filteredQueues;

          return Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            body: SafeArea(
              child: Column(
                children: [
                  QueueHistoryHeader(
                    onBack: () => Navigator.of(context).pop(),
                    onRefresh: () async {
                      bloc.load();
                      if (context.mounted) {
                        AppSnackBar.showSuccess(
                          context,
                          message: 'Live queue history refreshed',
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
                                      if (activeTicket != null)
                                        QueueHistorySpotlightCard(
                                          ticket: activeTicket,
                                          onTrackInTracker: () {
                                            Navigator.of(context).pop();
                                            onTrackLiveQueue?.call();
                                          },
                                        ),
                                      QueueHistoryStatsBar(
                                        totalJoined: state.totalJoined,
                                        totalServed: state.totalServed,
                                        avgWait: state.avgWait,
                                      ),
                                      QueueHistoryFilterTabs(
                                        selectedIndex: state.filterIndex,
                                        allCount: state.totalJoined,
                                        activeCount: state.totalActive,
                                        completedCount: state.totalServed,
                                        onFilterChanged: bloc.setFilter,
                                      ),
                                      if (filtered.isEmpty)
                                        QueueHistoryEmptyState(
                                          filterIndex: state.filterIndex,
                                        )
                                      else
                                        LiveQueueHistoryList(
                                          queues: filtered,
                                          onTrackLiveQueue: onTrackLiveQueue,
                                          onBookClinic: onBookClinic,
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
