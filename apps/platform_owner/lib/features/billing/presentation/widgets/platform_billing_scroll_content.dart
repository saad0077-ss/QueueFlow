import 'package:flutter/material.dart';

import '../bloc/platform_billing_bloc.dart';
import '../bloc/platform_billing_event.dart';
import '../bloc/platform_billing_state.dart';
import 'issue_invoice_dialog.dart';
import '../../../../core/utils/pdf_exporter.dart';
import 'platform_billing_content_view.dart';
import 'platform_billing_header.dart';
import 'platform_billing_metric_strip.dart';
import 'platform_billing_tab_bar.dart';

class PlatformBillingScrollContent extends StatelessWidget {
  final PlatformBillingState state;
  final PlatformBillingBloc bloc;

  const PlatformBillingScrollContent({
    super.key,
    required this.state,
    required this.bloc,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PlatformBillingHeader(
            onIssueInvoice: () => IssueInvoiceDialog.show(
              context,
              clinics: state.subscriptions,
              onSubmit:
                  ({
                    required amount,
                    required clinicId,
                    required clinicName,
                    required dueDate,
                    required plan,
                  }) {
                    bloc.add(
                      PlatformBillingIssueInvoiceSubmitted(
                        clinicId: clinicId,
                        clinicName: clinicName,
                        plan: plan,
                        amount: amount,
                        dueDate: dueDate,
                      ),
                    );
                  },
            ),
            onExportPdf: () {
              if (state.activeTab == 2) {
                PdfExporter.exportInvoices(context, state.filteredInvoices);
              } else {
                PdfExporter.exportSubscriptions(
                  context,
                  state.filteredSubscriptions,
                );
              }
            },
          ),
          const SizedBox(height: 24),
          PlatformBillingMetricStrip(metrics: state.metrics),
          const SizedBox(height: 24),
          PlatformBillingTabBar(
            activeIndex: state.activeTab,
            onTabSelected: (tab) => bloc.add(PlatformBillingTabChanged(tab)),
          ),
          const SizedBox(height: 20),
          PlatformBillingContentView(state: state, bloc: bloc),
        ],
      ),
    );
  }
}
