import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:patient_app/core/widgets/app_snack_bar.dart';

import '../../../domain/entities/favorite_clinic_entity.dart';
import 'favorite_clinic_card.dart';

class FavoriteClinicsList extends StatelessWidget {
  final List<FavoriteClinicEntity> clinics;
  final ValueChanged<String> onUnfavorite;
  final ValueChanged<String>? onBookClinic;
  final ValueChanged<String>? onQueueClinic;

  const FavoriteClinicsList({
    super.key,
    required this.clinics,
    required this.onUnfavorite,
    this.onBookClinic,
    this.onQueueClinic,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isGrid = constraints.maxWidth >= 768;
        if (!isGrid) {
          return ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: clinics.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (ctx, idx) => _buildCard(ctx, clinics[idx]),
          );
        }

        final maxCols = constraints.maxWidth >= 1150 ? 3 : 2;
        final columns = clinics.length < maxCols
            ? math.max(1, clinics.length)
            : maxCols;
        final rows = <List<FavoriteClinicEntity>>[];
        for (var i = 0; i < clinics.length; i += columns) {
          rows.add(
            clinics.sublist(i, (i + columns).clamp(0, clinics.length)),
          );
        }

        return Column(
          children: rows.map((row) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (var j = 0; j < columns; j++) ...[
                    if (j > 0) const SizedBox(width: 16),
                    Expanded(
                      child: j < row.length
                          ? _buildCard(context, row[j])
                          : const SizedBox.shrink(),
                    ),
                  ],
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildCard(BuildContext context, FavoriteClinicEntity clinic) {
    return FavoriteClinicCard(
      clinic: clinic,
      onUnfavorite: () {
        onUnfavorite(clinic.id);
        AppSnackBar.showSuccess(
          context,
          message: 'Removed ${clinic.name} from favorites',
        );
      },
      onBook: () {
        if (onBookClinic != null) {
          Navigator.of(context).pop();
          onBookClinic!(clinic.id);
        } else {
          AppSnackBar.showSuccess(
            context,
            message: 'Selected ${clinic.name} for booking',
          );
        }
      },
      onLiveQueue: () {
        if (onQueueClinic != null) {
          Navigator.of(context).pop();
          onQueueClinic!(clinic.id);
        } else {
          AppSnackBar.showSuccess(
            context,
            message: 'Opening Live Queue for ${clinic.name}',
          );
        }
      },
      onCall: () {
        AppSnackBar.showSuccess(
          context,
          message: 'Dialing ${clinic.name} (${clinic.phone})...',
        );
      },
    );
  }
}
