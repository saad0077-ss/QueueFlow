import 'package:flutter/material.dart';
import '../../domain/entities/billing_plan_tier_entity.dart';
import '../../domain/entities/clinic_subscription_entity.dart';
import 'billing_hero_card.dart';
import 'billing_quotas_card.dart';

class BillingUpperSection extends StatelessWidget {
  final ClinicSubscriptionEntity subscription;
  final BillingPlanTierEntity? currentTier;
  final String activeCadence;
  final VoidCallback onToggleCadence;
  final VoidCallback onUpgrade;

  const BillingUpperSection({
    super.key,
    required this.subscription,
    required this.currentTier,
    required this.activeCadence,
    required this.onToggleCadence,
    required this.onUpgrade,
  });

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.sizeOf(context).width >= 1050;

    if (isDesktop) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: BillingHeroCard(
              subscription: subscription,
              currentTier: currentTier,
              activeCadence: activeCadence,
              onToggleCadence: onToggleCadence,
              onUpgrade: onUpgrade,
            ),
          ),
          const SizedBox(width: 18),
          Expanded(flex: 6, child: BillingQuotasCard(subscription: subscription)),
        ],
      );
    }

    return Column(
      children: [
        BillingHeroCard(
          subscription: subscription,
          currentTier: currentTier,
          activeCadence: activeCadence,
          onToggleCadence: onToggleCadence,
          onUpgrade: onUpgrade,
        ),
        const SizedBox(height: 18),
        BillingQuotasCard(subscription: subscription),
      ],
    );
  }
}
