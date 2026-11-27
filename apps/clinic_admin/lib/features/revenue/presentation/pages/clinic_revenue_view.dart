import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/clinic_revenue_repository_impl.dart';
import '../../domain/repositories/clinic_revenue_repository.dart';
import '../bloc/clinic_revenue_bloc.dart';
import '../bloc/clinic_revenue_event.dart';
import '../bloc/clinic_revenue_state.dart';
import '../utils/clinic_revenue_exporter.dart';
import '../widgets/clinic_revenue_card_shell.dart';
import '../widgets/clinic_revenue_channels_card.dart';
import '../widgets/clinic_revenue_doctors_card.dart';
import '../widgets/clinic_revenue_equal_height_row.dart';
import '../widgets/clinic_revenue_header.dart';
import '../widgets/clinic_revenue_hero_banner.dart';
import '../widgets/clinic_revenue_ledger_card.dart';
import '../widgets/clinic_revenue_metric_cards.dart';
import '../widgets/clinic_revenue_services_card.dart';
import '../widgets/clinic_revenue_trend_card.dart';

/// Clinic Revenue tab showcasing earnings, channels, breakdowns, and ledger.
class ClinicRevenueView extends StatelessWidget {
  final ClinicRevenueRepository? repository;

  const ClinicRevenueView({super.key, this.repository});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ClinicRevenueBloc(
        repository: repository ?? ClinicRevenueRepositoryImpl(),
      )..add(const ClinicRevenueStarted()),
      child: const _ClinicRevenueContent(),
    );
  }
}

class _ClinicRevenueContent extends StatelessWidget {
  const _ClinicRevenueContent();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ClinicRevenueBloc, ClinicRevenueState>(
      builder: (context, state) {
        final bloc = context.read<ClinicRevenueBloc>();
        final summary = state.summary;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClinicRevenueHeader(
              activePeriod: state.period,
              isRefreshing: state.isLoading,
              onPeriodChanged: (p) => bloc.add(ClinicRevenuePeriodChanged(p)),
              onRefresh: () => bloc.add(const ClinicRevenueRefreshRequested()),
              onExportPdf: summary == null
                  ? null
                  : () => ClinicRevenueExporter.exportLedgerPdf(
                        context,
                        summary: summary,
                        entries: state.filteredLedger,
                      ),
            ),
            const SizedBox(height: 18),
            if (state.isLoading && summary == null)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 80),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (state.errorMessage != null && summary == null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 80),
                child: Center(
                  child: Column(
                    children: [
                      Text('Unable to load revenue: ${state.errorMessage}'),
                      const SizedBox(height: 12),
                      OutlinedButton(
                        onPressed: () => bloc.add(const ClinicRevenueRefreshRequested()),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              )
            else if (summary != null) ...[
              ClinicRevenueHeroBanner(summary: summary),
              const SizedBox(height: 16),
              ClinicRevenueMetricCards(summary: summary),
              const SizedBox(height: 18),
              _ResponsivePair(
                left: ClinicRevenueTrendCard(
                  points: summary.trendPoints,
                  periodLabel: summary.period.label,
                ),
                right: ClinicRevenueChannelsCard(channels: summary.channelStats),
              ),
              const SizedBox(height: 18),
              _ResponsivePair(
                left: ClinicRevenueServicesCard(services: summary.serviceBreakdown),
                right: ClinicRevenueDoctorsCard(doctors: summary.doctorLeaderboard),
              ),
              const SizedBox(height: 18),
              ClinicRevenueLedgerCard(
                entries: state.filteredLedger,
                activeFilter: state.ledgerStatusFilter,
                onFilterChanged: (f) => bloc.add(ClinicRevenueLedgerFilterChanged(f)),
                onSearchChanged: (q) => bloc.add(ClinicRevenueSearchChanged(q)),
              ),
            ],
          ],
        );
      },
    );
  }
}

class _ResponsivePair extends StatelessWidget {
  final Widget left;
  final Widget right;

  const _ResponsivePair({required this.left, required this.right});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 960) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [left, const SizedBox(height: 16), right],
          );
        }
        return ClinicRevenueEqualHeightRow(
          gap: 16,
          decoration: ClinicRevenueCardShell.cardDecoration(context),
          left: left,
          right: right,
        );
      },
    );
  }
}
