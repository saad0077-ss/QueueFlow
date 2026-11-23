import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

import '../../../../core/navigation/platform_navigation_helper.dart';
import '../../../../core/utils/pdf_exporter.dart';
import '../../../dashboard/presentation/widgets/console_sidebar.dart';
import '../../../dashboard/presentation/widgets/console_top_bar.dart';
import '../bloc/platform_revenue_bloc.dart';
import '../bloc/platform_revenue_event.dart';
import '../bloc/platform_revenue_state.dart';
import '../widgets/platform_revenue_charts_grid.dart';
import '../widgets/platform_revenue_header.dart';
import '../widgets/platform_revenue_kpi_cards.dart';

class PlatformRevenuePage extends StatelessWidget {
  const PlatformRevenuePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PlatformRevenueBloc()..add(const PlatformRevenueStarted()),
      child: const _PlatformRevenueView(),
    );
  }
}

class _PlatformRevenueView extends StatelessWidget {
  const _PlatformRevenueView();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDesktop = MediaQuery.sizeOf(context).width >= 1000;

    return BlocBuilder<PlatformRevenueBloc, PlatformRevenueState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: colors.background,
          drawer: isDesktop
              ? null
              : Drawer(
                  child: ConsoleSidebar(
                    activeIndex: 4,
                    onIndexChanged: (i) =>
                        PlatformNavigationHelper.navigateTo(context, i, 4),
                  ),
                ),
          body: Row(
            children: [
              if (isDesktop)
                ConsoleSidebar(
                  activeIndex: 4,
                  onIndexChanged: (i) =>
                      PlatformNavigationHelper.navigateTo(context, i, 4),
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
                            PlatformRevenueHeader(
                              onExportLedger: () {
                                PdfExporter.exportRevenueLedger(
                                  context,
                                  invoices: state.recentInvoices,
                                  totalMrr: state.totalMrr,
                                  timeframe: state.timeframe,
                                );
                              },
                            ),
                            const SizedBox(height: 16),
                            PlatformRevenueKpiCards(state: state),
                            const SizedBox(height: 20),
                            PlatformRevenueChartsGrid(
                              clinicRevenueItems: state.clinicRevenueItems,
                              recentInvoices: state.recentInvoices,
                              totalMrr: state.totalMrr,
                              enterpriseAmount: state.enterpriseAmount,
                              enterpriseCount: state.enterpriseCount,
                              multiAmount: state.multiAmount,
                              multiCount: state.multiCount,
                              soloAmount: state.soloAmount,
                              soloCount: state.soloCount,
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
