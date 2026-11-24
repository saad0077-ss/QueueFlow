import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

import '../features/appointments/data/repositories/clinic_appointments_repository_impl.dart';
import '../features/appointments/presentation/bloc/clinic_appointments_bloc.dart';
import '../features/appointments/presentation/bloc/clinic_appointments_event.dart';
import '../features/billing/data/repositories/clinic_billing_repository_impl.dart';
import '../features/billing/presentation/bloc/clinic_billing_bloc.dart';
import '../features/billing/presentation/bloc/clinic_billing_event.dart';
import '../features/doctors/data/repositories/clinic_doctors_repository_impl.dart';
import '../features/doctors/domain/usecases/call_next_patient_usecase.dart';
import '../features/doctors/domain/usecases/delete_clinic_doctor_usecase.dart';
import '../features/doctors/domain/usecases/get_clinic_doctors_usecase.dart';
import '../features/doctors/domain/usecases/save_clinic_doctor_usecase.dart';
import '../features/doctors/domain/usecases/update_doctor_status_usecase.dart';
import '../features/doctors/presentation/bloc/clinic_doctors_bloc.dart';
import '../features/doctors/presentation/bloc/clinic_doctors_event.dart';
import '../features/queue/data/repositories/clinic_queue_repository_impl.dart';
import '../features/queue/presentation/bloc/clinic_queue_bloc.dart';
import '../features/queue/presentation/bloc/clinic_queue_event.dart';
import '../features/reports/data/repositories/clinic_reports_repository_impl.dart';
import '../features/reports/presentation/bloc/clinic_reports_bloc.dart';
import '../features/reports/presentation/bloc/clinic_reports_event.dart';
import '../features/services/data/repositories/clinic_services_repository_impl.dart';
import '../features/services/domain/usecases/delete_clinic_service_usecase.dart';
import '../features/services/domain/usecases/get_clinic_services_usecase.dart';
import '../features/services/domain/usecases/save_clinic_service_usecase.dart';
import '../features/services/domain/usecases/toggle_service_status_usecase.dart';
import '../features/services/presentation/bloc/clinic_services_bloc.dart';
import '../features/services/presentation/bloc/clinic_services_event.dart';
import '../features/settings/data/repositories/clinic_settings_repository_impl.dart';
import '../features/settings/presentation/bloc/clinic_settings_bloc.dart';
import '../features/settings/presentation/bloc/clinic_settings_event.dart';

/// Injects all root-level BLoCs for the Clinic Staff & Admin Portal.
class ClinicAdminProviders extends StatelessWidget {
  final Widget child;

  const ClinicAdminProviders({super.key, required this.child});

  static ClinicDoctorsBloc _createDoctorsBloc() {
    final repo = ClinicDoctorsRepositoryImpl();
    return ClinicDoctorsBloc(
      getDoctorsUseCase: GetClinicDoctorsUseCase(repo),
      saveDoctorUseCase: SaveClinicDoctorUseCase(repo),
      updateDoctorStatusUseCase: UpdateDoctorStatusUseCase(repo),
      deleteDoctorUseCase: DeleteClinicDoctorUseCase(repo),
      callNextPatientUseCase: CallNextPatientUseCase(repo),
      repository: repo,
    )..add(const DoctorsSubscriptionRequested());
  }

  static ClinicServicesBloc _createServicesBloc() {
    final repo = ClinicServicesRepositoryImpl();
    return ClinicServicesBloc(
      getServicesUseCase: GetClinicServicesUseCase(repo),
      saveServiceUseCase: SaveClinicServiceUseCase(repo),
      toggleServiceStatusUseCase: ToggleServiceStatusUseCase(repo),
      deleteServiceUseCase: DeleteClinicServiceUseCase(repo),
      repository: repo,
    )..add(const ServicesSubscriptionRequested());
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ThemeBloc>(create: (_) => ThemeBloc()),
        BlocProvider<ClinicAppointmentsBloc>(
          create: (_) => ClinicAppointmentsBloc(
            repository: ClinicAppointmentsRepositoryImpl(),
          )..add(const StartWatchingAppointments()),
        ),
        BlocProvider<ClinicQueueBloc>(
          create: (_) => ClinicQueueBloc(
            repository: ClinicQueueRepositoryImpl(),
          )..add(const QueueSubscriptionRequested()),
        ),
        BlocProvider<ClinicDoctorsBloc>(create: (_) => _createDoctorsBloc()),
        BlocProvider<ClinicBillingBloc>(
          create: (_) => ClinicBillingBloc(
            repository: ClinicBillingRepositoryImpl(),
          )..add(const ClinicBillingStarted()),
        ),
        BlocProvider<ClinicServicesBloc>(create: (_) => _createServicesBloc()),
        BlocProvider<ClinicReportsBloc>(
          create: (_) => ClinicReportsBloc(
            repository: ClinicReportsRepositoryImpl(),
          )..add(const ClinicReportsStarted()),
        ),
        BlocProvider<ClinicSettingsBloc>(
          create: (_) => ClinicSettingsBloc(
            repository: ClinicSettingsRepositoryImpl(),
          )..add(const ClinicSettingsStarted()),
        ),
      ],
      child: child,
    );
  }
}
