import 'dart:math' as math;

import 'package:flutter/material.dart';
import '../../domain/entities/clinic_service_entity.dart';
import 'service_item_card.dart';
import 'service_slot_card.dart';

class ServicesCardsGrid extends StatelessWidget {
  static const double _spacing = 16;

  final List<ClinicServiceEntity> services;
  final bool isLimitReached;
  final int availableSlots;
  final String planName;
  final bool isUnlimited;
  final ValueChanged<ClinicServiceEntity> onEdit;
  final ValueChanged<ClinicServiceEntity> onToggle;
  final ValueChanged<ClinicServiceEntity> onDelete;
  final VoidCallback onAdd;
  final VoidCallback onUpgrade;

  const ServicesCardsGrid({
    super.key,
    required this.services,
    required this.isLimitReached,
    required this.availableSlots,
    required this.planName,
    this.isUnlimited = false,
    required this.onEdit,
    required this.onToggle,
    required this.onDelete,
    required this.onAdd,
    required this.onUpgrade,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 960
            ? 3
            : (constraints.maxWidth >= 600 ? 2 : 1);

        final cards = <Widget>[
          for (final service in services)
            ServiceItemCard(
              service: service,
              onEdit: () => onEdit(service),
              onToggle: () => onToggle(service),
              onDelete: () => onDelete(service),
            ),
          ServiceSlotCard(
            isLimitReached: isLimitReached,
            isUnlimited: isUnlimited,
            availableSlots: availableSlots,
            planName: planName,
            onAdd: onAdd,
            onUpgrade: onUpgrade,
          ),
        ];

        // Rows size to their tallest card instead of a fixed extent, so
        // cards with extra content (pending banner, many doctors) never
        // overflow and cards in the same row stay equal height.
        final rows = <Widget>[];
        for (var i = 0; i < cards.length; i += columns) {
          final rowCards = cards.sublist(
            i,
            math.min(i + columns, cards.length),
          );
          rows.add(
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (var j = 0; j < columns; j++) ...[
                    if (j > 0) const SizedBox(width: _spacing),
                    Expanded(
                      child: j < rowCards.length
                          ? rowCards[j]
                          : const SizedBox.shrink(),
                    ),
                  ],
                ],
              ),
            ),
          );
        }

        return Column(
          children: [
            for (var i = 0; i < rows.length; i++) ...[
              if (i > 0) const SizedBox(height: _spacing),
              rows[i],
            ],
          ],
        );
      },
    );
  }
}
