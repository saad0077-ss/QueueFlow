import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/widgets/app_snack_bar.dart';
import '../../../dashboard/presentation/pages/clinic_dashboard_page.dart';
import '../../data/repositories/clinic_auth_repository_impl.dart';
import '../../domain/usecases/clinic_sign_in_usecase.dart';
import '../../domain/usecases/reset_clinic_password_usecase.dart';
import '../bloc/sign_in/clinic_sign_in_bloc.dart';
import '../bloc/sign_in/clinic_sign_in_state.dart';
import '../widgets/clinic_hero_banner.dart';
import '../widgets/clinic_staff_login_form.dart';

/// Entry page for Clinic Staff Login.
class ClinicStaffLoginPage extends StatelessWidget {
  const ClinicStaffLoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = ClinicAuthRepositoryImpl();
    return BlocProvider(
      create: (_) => ClinicSignInBloc(
        signInUseCase: ClinicSignInUseCase(repo),
        resetPasswordUseCase: ResetClinicPasswordUseCase(repo),
      ),
      child: const _ClinicStaffLoginView(),
    );
  }
}

class _ClinicStaffLoginView extends StatelessWidget {
  const _ClinicStaffLoginView();

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.sizeOf(context).width >= 900;

    return Scaffold(
      backgroundColor: const Color(0xFF070B14),
      body: BlocConsumer<ClinicSignInBloc, ClinicSignInState>(
        listener: (context, state) {
          if (state.staff != null) {
            AppSnackBar.showSuccess(context, message: 'Signed in.');
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const ClinicDashboardPage()),
            );
          }
          if (state.errorMessage != null) {
            AppSnackBar.showError(context, message: state.errorMessage!);
          }
          if (state.infoMessage != null) {
            AppSnackBar.showInfo(context, message: state.infoMessage!);
          }
        },
        builder: (context, state) {
          return Row(
            children: [
              if (isDesktop) const Expanded(flex: 5, child: ClinicHeroBanner()),
              Expanded(
                flex: isDesktop ? 6 : 1,
                child: Center(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: isDesktop ? 64 : 24,
                      vertical: 36,
                    ),
                    child: ClinicStaffLoginForm(state: state),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
