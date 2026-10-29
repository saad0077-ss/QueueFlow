import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/widgets/app_snack_bar.dart';
import '../../../dashboard/presentation/pages/platform_clinics_page.dart';
import '../../../dashboard/presentation/widgets/console_sidebar.dart';
import '../../../dashboard/presentation/widgets/console_top_bar.dart';
import '../../../departments/presentation/pages/platform_departments_page.dart';
import '../../data/repositories/platform_billing_repository_impl.dart';
import '../bloc/platform_billing_bloc.dart';
import '../bloc/platform_billing_event.dart';
import '../bloc/platform_billing_state.dart';
import '../widgets/issue_invoice_dialog.dart';
import '../widgets/platform_billing_content_view.dart';
import '../widgets/platform_billing_header.dart';
import '../widgets/platform_billing_kpi_strip.dart';
import '../widgets/platform_billing_tab_bar.dart';

class PlatformBillingPage extends StatelessWidget {
  const PlatformBillingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PlatformBillingBloc(
        repository: PlatformBillingRepositoryImpl(),
      )..add(const PlatformBillingStarted()),
      child: const _PlatformBillingView(),
    );
  }
}

class _PlatformBillingView extends StatefulWidget {
  const _PlatformBillingView();

  @override
  State<_PlatformBillingView> createState() => _PlatformBillingViewState();
}

class _PlatformBillingViewState extends State<_PlatformBillingView> {
  void _onSidebarNav(int i) {
    if (i == 0) {
      Navigator.pushReplacement(context, PageRouteBuilder(pageBuilder: (_, _, _) => const PlatformClinicsPage(), transitionDuration: Duration.zero));
    } else if (i == 1) {
      Navigator.pushReplacement(context, PageRouteBuilder(pageBuilder: (_, _, _) => const PlatformDepartmentsPage(), transitionDuration: Duration.zero));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.sizeOf(context).width >= 1000;

    return BlocConsumer<PlatformBillingBloc, PlatformBillingState>(
      listener: (context, state) {
        if (state.feedbackMessage != null) {
          if (state.isError) {
            AppSnackBar.showError(context, message: state.feedbackMessage!);
          } else {
            AppSnackBar.showSuccess(context, message: state.feedbackMessage!);
          }
          context.read<PlatformBillingBloc>().add(const PlatformBillingFeedbackDismissed());
        }
      },
      builder: (context, state) {
        final bloc = context.read<PlatformBillingBloc>();

        return Scaffold(
          backgroundColor: const Color(0xFF070B14),
          drawer: isDesktop ? null : Drawer(child: ConsoleSidebar(activeIndex: 4, onIndexChanged: _onSidebarNav)),
          body: Row(
            children: [
              if (isDesktop) ConsoleSidebar(activeIndex: 4, onIndexChanged: _onSidebarNav),
              Expanded(
                child: Builder(
                  builder: (ctx) => Column(
                    children: [
                      ConsoleTopBar(onMenuPressed: isDesktop ? null : () => Scaffold.of(ctx).openDrawer()),
                      Expanded(
                        child: state.isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : SingleChildScrollView(
                                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    PlatformBillingHeader(
                                      onIssueInvoice: () => IssueInvoiceDialog.show(
                                        context,
                                        clinics: state.subscriptions,
                                        onSubmit: ({required amount, required clinicId, required clinicName, required dueDate, required plan}) {
                                          bloc.add(PlatformBillingIssueInvoiceSubmitted(
                                            clinicId: clinicId,
                                            clinicName: clinicName,
                                            plan: plan,
                                            amount: amount,
                                            dueDate: dueDate,
                                          ));
                                        }, 
                                      ), 
                                      onExportCsv: () => AppSnackBar.showInfo(context, message: 'Exporting queueflow_billing_report.csv...'),
                                      onSync: () => bloc.add(const PlatformBillingStarted()),
                                    ),
                                    const SizedBox(height: 24),
                                    PlatformBillingKpiStrip(kpis: state.kpis),
                                    const SizedBox(height: 24),
                                    PlatformBillingTabBar(
                                      activeIndex: state.activeTab,
                                      onTabSelected: (tab) => bloc.add(PlatformBillingTabChanged(tab)),
                                    ),
                                    const SizedBox(height: 20),
                                    PlatformBillingContentView(state: state, bloc: bloc),
                                  ],
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
