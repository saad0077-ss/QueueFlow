import 'package:flutter/material.dart';
import '../../../../core/widgets/app_snack_bar.dart';
import '../bloc/platform_billing_bloc.dart';
import '../bloc/platform_billing_event.dart';
import '../bloc/platform_billing_state.dart';
import 'edit_platform_plan_dialog.dart';
import 'issue_invoice_dialog.dart';
import 'manage_clinic_plan_dialog.dart';
import 'platform_invoices_ledger_view.dart';
import 'platform_plan_tiers_view.dart';
import 'platform_tenant_subscriptions_view.dart';

class PlatformBillingContentView extends StatelessWidget {
  final PlatformBillingState state;
  final PlatformBillingBloc bloc;

  const PlatformBillingContentView({
    super.key,
    required this.state,
    required this.bloc,
  });

  @override
  Widget build(BuildContext context) {
    switch (state.activeTab) {
      case 1:
        return PlatformPlanTiersView(
          tiers: state.tiers,
          subscriptions: state.subscriptions,
          onAddCustomTier: () => EditPlatformPlanDialog.show(
            context,
            onSave: (tier) => bloc.add(PlatformBillingPlanTierSaved(tier)),
          ),
          onEditTier: (tier) => EditPlatformPlanDialog.show(
            context,
            existingTier: tier,
            onSave: (updated) => bloc.add(PlatformBillingPlanTierSaved(updated)),
          ),
        );
      case 2:
        return PlatformInvoicesLedgerView(
          invoices: state.filteredInvoices,
          activeFilter: state.invoiceFilter,
          onFilterChanged: (filter) => bloc.add(PlatformBillingInvoiceFilterChanged(filter)),
          onDownloadInvoice: (inv) => AppSnackBar.showInfo(context, message: 'Downloading invoice ${inv.number}...'),
          onMarkPaid: (inv) => bloc.add(PlatformBillingInvoiceMarkedPaid(inv)),
          onRemind: (inv) => AppSnackBar.showInfo(context, message: 'Payment reminder sent to ${inv.clinicName} for ${inv.number}.'),
        );
      case 0:
      default:
        return PlatformTenantSubscriptionsView(
          subscriptions: state.filteredSubscriptions,
          onSearchChanged: (q) => bloc.add(PlatformBillingSearchChanged(q)),
          onIssueInvoice: (clinic) => IssueInvoiceDialog.show(
            context,
            clinics: [clinic],
            onSubmit: ({required clinicId, required clinicName, required plan, required amount, required dueDate}) {
              bloc.add(PlatformBillingIssueInvoiceSubmitted(
                clinicId: clinicId,
                clinicName: clinicName,
                plan: plan,
                amount: amount,
                dueDate: dueDate,
              ));
            },
          ),
          onManageSubscription: (clinic) => ManageClinicPlanDialog.show(
            context,
            clinic: clinic,
            onSave: ({required billingCadence, required clinicId, required planId, required status}) {
              bloc.add(PlatformBillingSubscriptionUpdated(
                clinicId: clinicId,
                planId: planId,
                billingCadence: billingCadence,
                status: status,
              ));
            },
          ),
        );
    }
  }
}
