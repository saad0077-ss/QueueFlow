import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/clinic_tickets_bloc_factory.dart';
import '../bloc/clinic_tickets_event.dart';
import '../widgets/clinic_tickets_workspace.dart';

class ClinicPatientTicketsView extends StatelessWidget {
  final String clinicId;
  final String clinicName;
  final String staffName;
  final int liveWaitingCount;
  final String liveNowServing;
  final VoidCallback onNavigateToQueue;

  const ClinicPatientTicketsView({
    super.key,
    required this.clinicId,
    required this.clinicName,
    this.staffName = 'Reception Care Desk',
    this.liveWaitingCount = 0,
    this.liveNowServing = '',
    required this.onNavigateToQueue,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ClinicTicketsBlocFactory.create()
        ..add(
          WatchClinicTicketsStarted(clinicId: clinicId, clinicName: clinicName),
        ),
      child: ClinicTicketsWorkspace(
        clinicId: clinicId,
        clinicName: clinicName,
        staffName: staffName,
        liveWaitingCount: liveWaitingCount,
        liveNowServing: liveNowServing,
        onNavigateToQueue: onNavigateToQueue,
      ),
    );
  }
}
