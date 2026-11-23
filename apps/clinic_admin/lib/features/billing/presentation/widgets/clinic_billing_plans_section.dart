import 'package:flutter/material.dart';
import '../../../../core/widgets/app_snack_bar.dart';
import '../../data/services/razorpay_checkout.dart';
import '../../domain/entities/clinic_subscription_entity.dart';
import '../bloc/clinic_billing_bloc.dart';
import '../bloc/clinic_billing_event.dart';
import '../bloc/clinic_billing_state.dart';
import 'billing_cadence_toggle.dart';
import 'billing_pricing_grid.dart';
import 'switch_plan_dialog.dart';

class ClinicBillingPlansSection extends StatelessWidget {
  final ClinicBillingBloc bloc;
  final ClinicBillingState state;
  final ClinicSubscriptionEntity sub;

  const ClinicBillingPlansSection({
    super.key,
    required this.bloc,
    required this.state,
    required this.sub,
  });

  Future<void> _handleSelectTier(BuildContext context, dynamic tier) async {
    final fresh = await bloc.repository.getClinicSubscription();
    if (!context.mounted) return;
    if (fresh.isPlanLocked) {
      AppSnackBar.showInfo(
        context,
        message:
            'Your current plan is active until ${fresh.currentPeriodEnd}. You can change plans after that date.',
      );
      return;
    }
    SwitchPlanDialog.show(
      context,
      targetTier: tier,
      activeCadence: state.activeCadence,
      onConfirm: () async {
        final result = await RazorpayCheckout.pay(
          amount: SwitchPlanDialog.payable(tier, state.activeCadence),
          description:
              '${tier.name} (${state.activeCadence == 'annual' ? 'Annual' : 'Monthly'})',
          reference: 'plan_${tier.id}_${DateTime.now().millisecondsSinceEpoch}',
          name: sub.billingContact.legalName,
          email: sub.billingContact.email,
          phone: sub.billingContact.phone,
          clinicId: sub.clinicId,
        );
        if (!context.mounted) return;
        if (result.success && (result.paymentId ?? '').isNotEmpty) {
          bloc.add(
            ClinicBillingPlanChangeRequested(
              targetTier: tier,
              billingCadence: state.activeCadence,
              paymentId: result.paymentId!,
            ),
          );
        } else {
          AppSnackBar.showError(
            context,
            message: result.message ?? 'Payment failed. No plan was activated.',
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: BillingCadenceToggle(
            activeCadence: state.activeCadence,
            onCadenceChanged: (cadence) =>
                bloc.add(ClinicBillingCadenceToggled(cadence)),
          ),
        ),
        const SizedBox(height: 20),
        BillingPricingGrid(
          tiers: state.tiers,
          subscription: sub,
          activeCadence: state.activeCadence,
          onSelectTier: (tier) => _handleSelectTier(context, tier),
        ),
      ],
    );
  }
}
