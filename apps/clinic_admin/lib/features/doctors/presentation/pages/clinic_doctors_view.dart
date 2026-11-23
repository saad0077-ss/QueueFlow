import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/layout/dashboard_chrome.dart';
import '../../../../core/widgets/app_snack_bar.dart';
import '../../data/repositories/clinic_doctors_repository_impl.dart';
import '../../domain/usecases/call_next_patient_usecase.dart';
import '../../domain/usecases/delete_clinic_doctor_usecase.dart';
import '../../domain/usecases/get_clinic_doctors_usecase.dart';
import '../../domain/usecases/save_clinic_doctor_usecase.dart';
import '../../domain/usecases/update_doctor_status_usecase.dart';
import '../bloc/clinic_doctors_bloc.dart';
import '../bloc/clinic_doctors_event.dart';
import '../bloc/clinic_doctors_state.dart';
import '../widgets/clinic_doctors_body_content.dart';
import '../widgets/doctor_detail_view.dart';

class ClinicDoctorsView extends StatelessWidget {
  final VoidCallback? onNavigateToBilling;
  final VoidCallback? onNavigateToQueue;

  const ClinicDoctorsView({
    super.key,
    this.onNavigateToBilling,
    this.onNavigateToQueue,
  });

  @override
  Widget build(BuildContext context) {
    final repo = ClinicDoctorsRepositoryImpl();

    return BlocProvider(
      create: (_) => ClinicDoctorsBloc(
        getDoctorsUseCase: GetClinicDoctorsUseCase(repo),
        saveDoctorUseCase: SaveClinicDoctorUseCase(repo),
        updateDoctorStatusUseCase: UpdateDoctorStatusUseCase(repo),
        deleteDoctorUseCase: DeleteClinicDoctorUseCase(repo),
        callNextPatientUseCase: CallNextPatientUseCase(repo),
        repository: repo,
      )..add(const DoctorsSubscriptionRequested()),
      child: _ClinicDoctorsBody(
        onNavigateToBilling: onNavigateToBilling,
        onNavigateToQueue: onNavigateToQueue,
      ),
    );
  }
}

class _ClinicDoctorsBody extends StatelessWidget {
  final VoidCallback? onNavigateToBilling;
  final VoidCallback? onNavigateToQueue;

  const _ClinicDoctorsBody({this.onNavigateToBilling, this.onNavigateToQueue});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ClinicDoctorsBloc, ClinicDoctorsState>(
      listener: (context, state) {
        if (state.toastMessage != null) {
          if (state.isErrorToast) {
            AppSnackBar.showError(context, message: state.toastMessage!);
          } else {
            AppSnackBar.showSuccess(context, message: state.toastMessage!);
          }
          context.read<ClinicDoctorsBloc>().add(const DoctorsClearToast());
        }
      },
      builder: (context, state) {
        final bloc = context.read<ClinicDoctorsBloc>();
        DashboardChrome.setDetailOpen('Doctors', state.selectedDoctor != null);

        if (state.selectedDoctor != null) {
          return DoctorDetailView(
            doctor: state.selectedDoctor!,
            departments: state.departments,
            onBack: () => bloc.add(const DoctorSelected(null)),
          );
        }

        return ClinicDoctorsBodyContent(
          state: state,
          bloc: bloc,
          onNavigateToBilling: onNavigateToBilling,
          onNavigateToQueue: onNavigateToQueue,
        );
      },
    );
  }
}
