import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../domain/entities/clinic_doctor_profile_entity.dart';
import '../../domain/entities/doctor_plan_entity.dart';
import 'doctor_card.dart';
import 'doctor_slot_card.dart';

class DoctorsCardsGrid extends StatelessWidget {
  static const double _spacing = 16;

  final List<ClinicDoctorProfileEntity> doctors;
  final DoctorPlanEntity plan;
  final ValueChanged<ClinicDoctorProfileEntity> onCallNext;
  final ValueChanged<ClinicDoctorProfileEntity> onViewQueue;
  final ValueChanged<ClinicDoctorProfileEntity>? onSelectDoctor;
  final void Function(ClinicDoctorProfileEntity doctor, String newStatus) onStatusChange;
  final ValueChanged<ClinicDoctorProfileEntity> onDelete;
  final VoidCallback onAddDoctor;
  final VoidCallback onUpgradePlan;

  const DoctorsCardsGrid({
    super.key,
    required this.doctors,
    required this.plan,
    required this.onCallNext,
    required this.onViewQueue,
    this.onSelectDoctor,
    required this.onStatusChange,
    required this.onDelete,
    required this.onAddDoctor,
    required this.onUpgradePlan,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 1200
            ? 3
            : (constraints.maxWidth >= 640 ? 2 : 1);

        final cards = <Widget>[
          for (final doc in doctors)
            DoctorCard(
              doctor: doc,
              totalDoctors: doctors.length,
              onStatusChange: (status) => onStatusChange(doc, status),
              onCallNext: () => onCallNext(doc),
              onViewQueue: () => onViewQueue(doc),
              onSelectDoctor: onSelectDoctor != null ? () => onSelectDoctor!(doc) : null,
              onDelete: () => onDelete(doc),
            ),
          DoctorSlotCard(
            plan: plan,
            currentCount: doctors.length,
            onAdd: onAddDoctor,
            onUpgrade: onUpgradePlan,
          ),
        ];

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
