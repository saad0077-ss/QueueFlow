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
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: clinics.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final clinic = clinics[index];
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
      },
    );
  }
}
