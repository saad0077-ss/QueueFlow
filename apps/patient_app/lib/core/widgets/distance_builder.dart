import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../../features/home/domain/entities/clinic_entity.dart';
import '../services/user_location_service.dart';

/// Rebuilds with the clinic's live distance label ("" while unknown).
class DistanceBuilder extends StatelessWidget {
  final ClinicEntity clinic;
  final Widget Function(BuildContext context, String distance) builder;

  const DistanceBuilder({
    super.key,
    required this.clinic,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Position?>(
      valueListenable: UserLocationService.position,
      builder: (ctx, _, __) => builder(ctx, clinic.distanceLabel),
    );
  }
}
