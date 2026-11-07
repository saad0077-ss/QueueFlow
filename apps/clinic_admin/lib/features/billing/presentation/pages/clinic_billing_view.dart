import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/widgets/app_snack_bar.dart';
import '../../data/repositories/clinic_billing_repository_impl.dart';
import '../../data/services/billing_receipt_pdf.dart';
import '../../data/services/razorpay_checkout.dart';
import '../bloc/clinic_billing_bloc.dart';
import '../bloc/clinic_billing_event.dart';
import '../bloc/clinic_billing_state.dart';
import '../widgets/billing_cadence_toggle.dart';
import '../widgets/billing_invoices_table_card.dart';
import '../widgets/billing_pricing_grid.dart';
import '../widgets/billing_upper_section.dart';
import '../widgets/clinic_billing_header.dart';
import '../widgets/switch_plan_dialog.dart';

class ClinicBillingView extends StatelessWidget {
  const ClinicBillingView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ClinicBillingBloc(
        repository: ClinicBillingRepositoryImpl(),
      )..add(const ClinicBillingStarted()),
      child: const _ClinicBillingBody(),
    );
  }
}

class _ClinicBillingBody extends StatelessWidget {
  const _ClinicBillingBody();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ClinicBillingBloc, ClinicBillingState>(
      listener: (context, state) {
        if (state.feedbackMessage != null) {
          if (state.isError) {
            AppSnackBar.showError(context, message: state.feedbackMessage!);
          } else {
            AppSnackBar.showSuccess(context, message: state.feedbackMessage!);
          }
          context.read<ClinicBillingBloc>().add(const ClinicBillingFeedbackDismissed());
        }
      },
      builder: (context, state) {
        if (state.isLoading) {
          return const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator()));
        }
        final sub = state.subscription;
        if (sub == null) {
          return const Center(child: Text('Subscription details could not be loaded.', style: TextStyle(color: Colors.white70)));
        }
        final bloc = context.read<ClinicBillingBloc>();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClinicBillingHeader(
              clinicName: sub.clinicName,
              planName: sub.planName,
              renewalDate: sub.currentPeriodEnd,
              onChangePlan: () {},
            ),
            const SizedBox(height: 24),
            BillingUpperSection(
              subscription: sub,
              currentTier: state.currentTier,
            ),
            const SizedBox(height: 36),
            Center(
              child: BillingCadenceToggle(
                activeCadence: state.activeCadence,
                onCadenceChanged: (cadence) => bloc.add(ClinicBillingCadenceToggled(cadence)),
              ),
            ),
            const SizedBox(height: 20),
            BillingPricingGrid(
              tiers: state.tiers,
              subscription: sub,
              activeCadence: state.activeCadence,
              onSelectTier: (tier) async {
                // Re-read the subscription from the server so a stale screen can't bypass the lock.
                final fresh = await bloc.repository.getClinicSubscription();
                if (!context.mounted) return;
                if (fresh.isPlanLocked) {
                  AppSnackBar.showInfo(context, message: 'Your current plan is active until ${fresh.currentPeriodEnd}. You can change plans after that date.');
                  return;
                }
                SwitchPlanDialog.show(
                  context,
                  targetTier: tier,
                  activeCadence: state.activeCadence,
                  onConfirm: () async {
                    final result = await RazorpayCheckout.pay(
                      amount: SwitchPlanDialog.payable(tier, state.activeCadence),
                      description: '${tier.name} (${state.activeCadence == 'annual' ? 'Annual' : 'Monthly'})',
                      reference: 'plan_${tier.id}_${DateTime.now().millisecondsSinceEpoch}',
                      name: sub.billingContact.legalName,
                      email: sub.billingContact.email,
                      phone: sub.billingContact.phone,
                      clinicId: sub.clinicId,
                    );
                    if (!context.mounted) return;
                    if (result.success && (result.paymentId ?? '').isNotEmpty) {
                      // The plan is activated by the backend only after it verifies this payment.
                      bloc.add(ClinicBillingPlanChangeRequested(
                        targetTier: tier,
                        billingCadence: state.activeCadence,
                        paymentId: result.paymentId!,
                      ));
                    } else {
                      AppSnackBar.showError(context, message: result.message ?? 'Payment failed. No plan was activated.');
                    }
                  },
                );
              },
            ),
            const SizedBox(height: 32),
            BillingInvoicesTableCard(
              clinicName: sub.clinicName,
              invoices: state.invoices,
              onRefresh: () => bloc.add(const ClinicBillingInvoicesRefreshed()),
              onDownloadInvoice: (inv) async {
                try {
                  await BillingReceiptPdf.download(inv);
                } catch (_) {
                  if (context.mounted) AppSnackBar.showError(context, message: 'Could not generate the receipt PDF.');
                }
              },
              // No Razorpay checkout is wired up yet; say so rather than pretend to charge.
              onPayInvoice: (inv) => AppSnackBar.showInfo(context, message: 'Online payment via Razorpay is not set up yet. Please contact QueueFlow support to pay invoice ${inv.number}.'),
            ),
          ],
        );
      },
    );
  }
}
