import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/clinic_tickets_bloc.dart';
import '../bloc/clinic_tickets_bloc_factory.dart';
import '../bloc/clinic_tickets_event.dart';
import '../widgets/clinic_tickets_workspace.dart';

class ClinicPatientTicketsView extends StatefulWidget {
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
  State<ClinicPatientTicketsView> createState() =>
      _ClinicPatientTicketsViewState();
}

class _ClinicPatientTicketsViewState extends State<ClinicPatientTicketsView> {
  late final ClinicTicketsBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = ClinicTicketsBlocFactory.create()
      ..add(
        WatchClinicTicketsStarted(
          clinicId: widget.clinicId,
          clinicName: widget.clinicName,
        ),
      );
  }

  @override
  void didUpdateWidget(ClinicPatientTicketsView oldWidget) {
    super.didUpdateWidget(oldWidget);
    final idChanged =
        widget.clinicId != oldWidget.clinicId && widget.clinicId.isNotEmpty;
    final nameChanged =
        widget.clinicName != oldWidget.clinicName &&
        widget.clinicName.isNotEmpty;
    if (idChanged || nameChanged) {
      _bloc.add(
        WatchClinicTicketsStarted(
          clinicId: widget.clinicId,
          clinicName: widget.clinicName,
        ),
      );
    }
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: ClinicTicketsWorkspace(
        clinicId: widget.clinicId,
        clinicName: widget.clinicName,
        staffName: widget.staffName,
        liveWaitingCount: widget.liveWaitingCount,
        liveNowServing: widget.liveNowServing,
        onNavigateToQueue: widget.onNavigateToQueue,
      ),
    );
  }
}
