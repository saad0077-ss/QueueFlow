import 'package:flutter/material.dart';

import '../../domain/entities/platform_plan_tier_entity.dart';
import '../../domain/entities/platform_tenant_subscription_entity.dart';
import 'platform_plan_tier_card.dart';
import 'platform_plan_tiers_header.dart';

class PlatformPlanTiersView extends StatelessWidget {
  final List<PlatformPlanTierEntity> tiers;
  final List<PlatformTenantSubscriptionEntity> subscriptions;
  final VoidCallback onAddCustomTier;
  final ValueChanged<PlatformPlanTierEntity> onEditTier;

  const PlatformPlanTiersView({
    super.key,
    required this.tiers,
    required this.subscriptions,
    required this.onAddCustomTier,
    required this.onEditTier,
  });

  int _enrolled(PlatformPlanTierEntity tier) => subscriptions
      .where((s) => s.planId == tier.id || s.planName == tier.name)
      .length;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PlatformPlanTiersHeader(
          activeTiersCount: tiers.length,
          onAddCustomTier: onAddCustomTier,
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth >= 900;
            final cards = tiers
                .map(
                  (tier) => PlatformPlanTierCard(
                    tier: tier,
                    enrolledClinics: _enrolled(tier),
                    expand: isDesktop,
                    onEdit: () => onEditTier(tier),
                  ),
                )
                .toList();

            if (isDesktop) {
              return IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (var i = 0; i < cards.length; i++) ...[
                      if (i > 0) const SizedBox(width: 22),
                      Expanded(child: cards[i]),
                    ],
                  ],
                ),
              );
            }

            return Column(
              children: cards
                  .map(
                    (c) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: c,
                    ),
                  )
                  .toList(),
            );
          },
        ),
      ],
    );
  }
}
