import 'package:flutter/material.dart';
import '../../domain/entities/billing_plan_tier_entity.dart';
import '../../domain/entities/clinic_subscription_entity.dart';
import 'billing_hero_card.dart';
import 'billing_quotas_card.dart';

class BillingUpperSection extends StatelessWidget {
  final ClinicSubscriptionEntity subscription;
  final BillingPlanTierEntity? currentTier;

  const BillingUpperSection({
    super.key,
    required this.subscription,
    required this.currentTier,
  });

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.sizeOf(context).width >= 1050;

    if (isDesktop) {
      return IntrinsicHeight(
        child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 4,
            child: BillingHeroCard(
              subscription: subscription,
              currentTier: currentTier,
            ),
          ),
          const SizedBox(width: 18),
          Expanded(flex: 6, child: BillingQuotasCard(subscription: subscription, currentTier: currentTier)),
        ],
      ));
    }

    return Column(
      children: [
        BillingHeroCard(
          subscription: subscription,
          currentTier: currentTier,
        ),
        const SizedBox(height: 18),
        BillingQuotasCard(subscription: subscription, currentTier: currentTier),
      ],
    );
  }
}
