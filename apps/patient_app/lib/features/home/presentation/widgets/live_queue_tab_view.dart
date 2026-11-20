import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:queueflow_ui/queueflow_ui.dart';
import '../bloc/home_bloc.dart';
import '../bloc/home_event.dart';
import '../bloc/home_state.dart';
import 'cancel_queue_dialog.dart';
import 'join_queue_dialog.dart';
import 'queue/active_ticket/active_ticket_view.dart';
import 'queue/live_queue_tab_app_bar.dart';
import 'queue/radar/queue_radar_view.dart';
import 'queue/utils/queue_helpers.dart';

/// Digital Queue Tab matching Screen 9 (`#scr-queue-tracker`) of the QueueFlow prototype.
class LiveQueueTabView extends StatelessWidget {
  const LiveQueueTabView({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        final bloc = context.read<HomeBloc>();
        final ticket = state.activeTicket;
        final hasActiveTicket = ticket != null && ticket.isActive;

        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: LiveQueueTabAppBar(hasActiveTicket: hasActiveTicket),
          body: LayoutBuilder(
            builder: (context, constraints) {
              final double width = constraints.maxWidth;
              final bool isTablet = width >= 640 && width < 960;
              final bool isDesktop = width >= 960;
              final double horizontalPadding = isDesktop
                  ? 32
                  : (isTablet ? 24 : 18);
              final double maxContentWidth = isDesktop
                  ? 960
                  : (isTablet ? 720 : double.infinity);

              return RefreshIndicator(
                color: colors.primary,
                backgroundColor: colors.surface,
                onRefresh: () async {
                  bloc.add(const HomeRefreshRequested());
                  await Future.delayed(const Duration(milliseconds: 600));
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: maxContentWidth),
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(
                          horizontalPadding,
                          14,
                          horizontalPadding,
                          24,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (hasActiveTicket)
                              ActiveTicketView(
                                ticket: ticket,
                                allClinics: state.allClinics,
                                onCancelSpot: () async {
                                  final confirmed =
                                      await CancelQueueDialog.show(context);
                                  if (confirmed == true && context.mounted) {
                                    bloc.add(
                                      HomeCancelTicketRequested(ticket.id),
                                    );
                                  }
                                },
                                onGetDirections: (clinic) =>
                                    openGoogleMaps(context, clinic),
                              )
                            else
                              QueueRadarView(
                                allClinics: state.allClinics,
                                userName: state.userName,
                                onJoinClinic: (clinic, live) {
                                  JoinQueueDialog.show(
                                    context,
                                    clinic: clinic,
                                    service: live?.service,
                                    department: live?.department,
                                    onJoinSuccess: (service, department) {
                                      bloc.add(
                                        HomeJoinQueueRequested(
                                          clinic: clinic,
                                          patientName: state.userName,
                                          serviceName: service,
                                          departmentName: department,
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
