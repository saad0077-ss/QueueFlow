import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/clinic_reports_repository_impl.dart';
import '../bloc/clinic_reports_bloc.dart';
import '../bloc/clinic_reports_event.dart';
import '../bloc/clinic_reports_state.dart';
import '../utils/clinic_reports_csv_exporter.dart';
import '../widgets/analytics/popular_services_card.dart';
import '../widgets/header/clinic_reports_header.dart';
import '../widgets/summary_cards/clinic_reports_summary_grid.dart';
import '../widgets/register/consultation_register_card.dart';
import '../widgets/toolbar/clinic_reports_toolbar.dart';

class ClinicReportsView extends StatelessWidget {
  const ClinicReportsView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ClinicReportsBloc(
        repository: ClinicReportsRepositoryImpl(),
      )..add(const ClinicReportsStarted()),
      child: const _ClinicReportsViewContent(),
    );
  }
}

class _ClinicReportsViewContent extends StatelessWidget {
  const _ClinicReportsViewContent();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ClinicReportsBloc, ClinicReportsState>(
      builder: (context, state) {
        final bloc = context.read<ClinicReportsBloc>();
        final data = state.data;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
              // 1. Header
              ClinicReportsHeader(
                isRefreshing: state.isLoading,
                onExport: () {
                  if (data != null) {
                    ClinicReportsCsvExporter.exportReportPdf(context, report: data);
                  }
                },
                onRefresh: () => bloc.add(const ClinicReportsRefreshRequested()),
              ),

              const SizedBox(height: 20),

              // 2. Toolbar
              if (data != null)
                ClinicReportsToolbar(
                  activePeriod: state.activePeriod,
                  startDate: data.startDate,
                  endDate: data.endDate,
                  onPeriodChanged: (p) => bloc.add(ClinicReportsPeriodChanged(p)),
                  onCustomRangeSelected: (r) =>
                      bloc.add(ClinicReportsCustomRangeSelected(r)),
                ),

              const SizedBox(height: 22),

              // 3. Body Content
              if (state.isLoading && data == null)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 80),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (state.errorMessage != null && data == null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 80),
                  child: Center(child: Text('Error: ${state.errorMessage}')),
                )
              else if (data != null) ...[
                // Executive Summary Cards
                ClinicReportsSummaryGrid(data: data),

                const SizedBox(height: 22),

                // Popular Services & Revenue Share
                PopularServicesCard(
                  services: data.serviceRevenues,
                  totalRevenue: data.totalRevenue,
                ),

                const SizedBox(height: 24),

                // Consultations Register Table
                ConsultationRegisterCard(
                  consultations: data.recentConsultations,
                ),
              ],
            ],
          );
        },
    );
  }
}
