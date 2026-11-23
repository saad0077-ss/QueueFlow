import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

import '../../../../core/navigation/platform_navigation_helper.dart';
import '../../../../core/utils/pdf_exporter.dart';
import '../../../../core/widgets/app_snack_bar.dart';
import '../../../dashboard/presentation/widgets/console_sidebar.dart';
import '../../../dashboard/presentation/widgets/console_top_bar.dart';
import '../../data/repositories/platform_reports_repository_impl.dart';
import '../../domain/usecases/get_platform_reports_usecase.dart';
import '../bloc/platform_reports_bloc.dart';
import '../bloc/platform_reports_event.dart';
import '../bloc/platform_reports_state.dart';
import '../widgets/platform_reports_analytics_grid.dart';
import '../widgets/platform_reports_header.dart';
import '../widgets/platform_reports_kpi_ribbon.dart';
import '../widgets/platform_reports_toolbar.dart';

class PlatformReportsPage extends StatelessWidget {
  const PlatformReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PlatformReportsBloc(
        getReportsUseCase: GetPlatformReportsUseCase(
          PlatformReportsRepositoryImpl(),
        ),
      )..add(const PlatformReportsStarted()),
      child: const _PlatformReportsView(),
    );
  }
}

class _PlatformReportsView extends StatelessWidget {
  const _PlatformReportsView();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDesktop = MediaQuery.sizeOf(context).width >= 1000;

    return BlocConsumer<PlatformReportsBloc, PlatformReportsState>(
      listener: (context, state) {
        if (state.feedbackMessage != null) {
          AppSnackBar.showSuccess(context, message: state.feedbackMessage!);
        }
        if (state.errorMessage != null) {
          AppSnackBar.showError(context, message: state.errorMessage!);
        }
      },
      builder: (context, state) {
        final bloc = context.read<PlatformReportsBloc>();

        return Scaffold(
          backgroundColor: colors.background,
          drawer: isDesktop
              ? null
              : Drawer(
                  child: ConsoleSidebar(
                    activeIndex: 5,
                    onIndexChanged: (i) =>
                        PlatformNavigationHelper.navigateTo(context, i, 5),
                  ),
                ),
          body: Row(
            children: [
              if (isDesktop)
                ConsoleSidebar(
                  activeIndex: 5,
                  onIndexChanged: (i) =>
                      PlatformNavigationHelper.navigateTo(context, i, 5),
                ),
              Expanded(
                child: Column(
                  children: [
                    const ConsoleTopBar(),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            PlatformReportsHeader(
                              onExportPdf: () {
                                if (state.report != null) {
                                  PdfExporter.exportReports(
                                    context,
                                    report: state.report!,
                                    timeRange: state.timeRange,
                                    tierFilter: state.tierFilter,
                                  );
                                } else {
                                  AppSnackBar.showError(
                                    context,
                                    message: 'Reports telemetry is still loading.',
                                  );
                                }
                              },
                            ),
                            const SizedBox(height: 16),
                            PlatformReportsToolbar(
                              activeRange: state.timeRange,
                              customDateRange: state.customDateRange,
                              selectedTier: state.tierFilter,
                              onRangeChanged: (r) =>
                                  bloc.add(PlatformReportsTimeRangeChanged(r)),
                              onCustomRangeSelected: (r) =>
                                  bloc.add(PlatformReportsCustomRangeChanged(r)),
                              onTierChanged: (t) =>
                                  bloc.add(PlatformReportsTierFilterChanged(t)),
                            ),
                            const SizedBox(height: 16),
                            if (state.report != null) ...[
                              PlatformReportsKpiRibbon(report: state.report!),
                              const SizedBox(height: 20),
                              PlatformReportsAnalyticsGrid(
                                report: state.report!,
                              ),
                            ] else
                              const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(40),
                                  child: CircularProgressIndicator(),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
