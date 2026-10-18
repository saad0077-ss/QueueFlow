import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/widgets/app_snack_bar.dart';
import '../../../dashboard/presentation/pages/clinic_dashboard_page.dart';
import '../../data/repositories/clinic_auth_repository_impl.dart';
import '../../domain/usecases/activate_clinic_account_usecase.dart';
import '../bloc/activation/account_activation_bloc.dart';
import '../bloc/activation/account_activation_state.dart';
import '../widgets/clinic_account_activation_form.dart';
import '../widgets/clinic_hero_banner.dart';

/// Account Activation Page for newly invited clinic administrators.
class ClinicAccountActivationPage extends StatelessWidget {
  const ClinicAccountActivationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = ClinicAuthRepositoryImpl();
    final params = Uri.base.queryParameters;
    final email = params['email'] ?? params['adminEmail'];
    final name = params['name'] ?? params['adminName'];
    final clinic = params['clinic'] ?? params['clinicName'];
    final role = params['role'];

    return BlocProvider(
      create: (_) => AccountActivationBloc(
        activateUseCase: ActivateClinicAccountUseCase(repo),
        initialEmail: email,
        initialDoctorName: name,
        initialClinicName: clinic,
        initialRole: role,
      ),
      child: const _AccountActivationView(),
    );
  }
}

class _AccountActivationView extends StatelessWidget {
  const _AccountActivationView();

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.sizeOf(context).width >= 900;

    return Scaffold(
      backgroundColor: const Color(0xFF070B14),
      body: BlocConsumer<AccountActivationBloc, AccountActivationState>(
        listener: (context, state) {
          if (state.activatedStaff != null) {
            AppSnackBar.showSuccess(context, message: 'Account activated.');
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const ClinicDashboardPage()),
            );
          }
          if (state.errorMessage != null) {
            AppSnackBar.showError(context, message: state.errorMessage!);
          }
        },
        builder: (context, state) => Row(
          children: [
            if (isDesktop)
              const Expanded(
                flex: 5,
                child: ClinicHeroBanner(
                  tagline: "You're almost in. Set a password to activate your\naccount.",
                ),
              ),
            Expanded(
              flex: isDesktop ? 6 : 1,
              child: Center(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: isDesktop ? 64 : 24,
                    vertical: 32,
                  ),
                  child: ClinicAccountActivationForm(state: state),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
