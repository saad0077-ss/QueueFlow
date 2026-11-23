import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../domain/entities/clinic_entity.dart';
import '../models/live_clinic_queue_info.dart';
import 'clinic_live_bloc.dart';

class ClinicLiveBuilder extends StatelessWidget {
  final ClinicEntity clinic;
  final Widget Function(BuildContext context, LiveInfo info) builder;

  const ClinicLiveBuilder({
    super.key,
    required this.clinic,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ClinicLiveBloc(clinic),
      child: BlocBuilder<ClinicLiveBloc, LiveInfo>(builder: builder),
    );
  }
}
