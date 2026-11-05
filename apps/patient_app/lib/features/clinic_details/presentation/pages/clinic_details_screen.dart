import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:queueflow_ui/queueflow_ui.dart';
import '../../../home/domain/entities/clinic_entity.dart';
import '../../data/repositories/clinic_details_repository_impl.dart';
import '../bloc/clinic_details_bloc.dart';
import '../bloc/clinic_details_event.dart';
import 'clinic_details_view.dart';

class ClinicDetailsScreen extends StatelessWidget {
  final ClinicEntity clinic;

  const ClinicDetailsScreen({super.key, required this.clinic});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ClinicDetailsBloc(
        repository: ClinicDetailsRepositoryImpl(),
      )..add(LoadClinicDetails(clinicId: clinic.id, initialClinic: clinic)),
      child: Builder(
        builder: (ctx) {
          return Scaffold(
            backgroundColor: ctx.colors.background,
            body: const SafeArea(
              child: ClinicDetailsView(),
            ),
          );
        },
      ),
    );
  }
}
