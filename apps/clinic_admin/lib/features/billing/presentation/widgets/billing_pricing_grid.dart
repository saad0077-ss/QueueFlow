import 'package:flutter/material.dart';
import '../../domain/entities/billing_plan_tier_entity.dart';
import '../../domain/entities/clinic_subscription_entity.dart';
import 'billing_pricing_card.dart';

class BillingPricingGrid extends StatelessWidget {
  final List<BillingPlanTierEntity> tiers;
  final ClinicSubscriptionEntity subscription;
  final String activeCadence;
  final ValueChanged<BillingPlanTierEntity> onSelectTier;

  const BillingPricingGrid({
    super.key,
    required this.tiers,
    required this.subscription,
    required this.activeCadence,
    required this.onSelectTier,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 900;
        bool isCurrent(BillingPlanTierEntity t) =>
            subscription.planId.toLowerCase() == t.id.toLowerCase() ||
            subscription.planName.toLowerCase().contains(t.id.toLowerCase());
        final currentPrice = tiers.where(isCurrent).map((t) => t.monthlyPrice).firstOrNull ?? 0;

        if (isDesktop) {
          // Equal-height cards so the action buttons line up.
          return IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: tiers.map((tier) {
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: BillingPricingCard(
                      tier: tier,
                      isCurrent: isCurrent(tier),
                      isUpgrade: tier.monthlyPrice > currentPrice,
                      activeCadence: activeCadence,
                      onSelectPlan: () => onSelectTier(tier),
                      expand: true,
                    ),
                  ),
                );
              }).toList(),
            ),
          );
        }

        return Column(
          children: tiers.map((tier) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: BillingPricingCard(
                tier: tier,
                isCurrent: isCurrent(tier),
                isUpgrade: tier.monthlyPrice > currentPrice,
                activeCadence: activeCadence,
                onSelectPlan: () => onSelectTier(tier),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
