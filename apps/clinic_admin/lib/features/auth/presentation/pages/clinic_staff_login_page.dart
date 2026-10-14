import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/widgets/app_snack_bar.dart';
import '../../../../core/widgets/gradient_submit_button.dart';
import '../../../queue/presentation/pages/clinic_dashboard_page.dart';
import '../../data/repositories/clinic_auth_repository_impl.dart';
import '../../domain/usecases/clinic_sign_in_usecase.dart';
import '../../domain/usecases/reset_clinic_password_usecase.dart';
import '../bloc/sign_in/clinic_sign_in_bloc.dart';
import '../bloc/sign_in/clinic_sign_in_event.dart';
import '../bloc/sign_in/clinic_sign_in_state.dart';
import '../widgets/clinic_hero_banner.dart';
import '../widgets/clinic_input_field.dart';

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
        builder: (context, state) => Row(
          children: [
            if (isDesktop) const Expanded(flex: 5, child: ClinicHeroBanner()),
            Expanded(flex: isDesktop ? 6 : 1, child: _buildForm(context, state, isDesktop)),
          ],
        ),
      ),
    );
  }

  Widget _buildForm(BuildContext context, ClinicSignInState state, bool isDesktop) {
    final bloc = context.read<ClinicSignInBloc>();
    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: isDesktop ? 64 : 24, vertical: 36),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Clinic Staff Login',
                style: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 6),
              Text(
                'Access your clinic appointments and live queue.',
                style: GoogleFonts.inter(fontSize: 13.5, color: const Color(0xFF94A3B8)),
              ),
              const SizedBox(height: 26),
              ClinicInputField(
                label: 'Email address',
                hintText: 'you@clinic.com',
                prefixIcon: Icons.mail_outline_rounded,
                keyboardType: TextInputType.emailAddress,
                errorText: state.emailError,
                helperText: 'Enter a valid email address.',
                isValid: state.isEmailValid,
                validText: 'Email verified',
                onChanged: (v) => bloc.add(ClinicSignInEmailChanged(v)),
              ),
              const SizedBox(height: 18),
              ClinicInputField(
                label: 'Password',
                hintText: '••••••••••',
                prefixIcon: Icons.lock_outline_rounded,
                obscureText: state.isPasswordObscured,
                errorText: state.passwordError,
                onChanged: (v) => bloc.add(ClinicSignInPasswordChanged(v)),
                onFieldSubmitted: (_) => bloc.add(const ClinicSignInSubmitted()),
                onToggleObscure: () => bloc.add(const ClinicSignInTogglePassword()),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => bloc.add(const ClinicSignInForgotPasswordRequested()),
                  child: Text(
                    'Forgot password?',
                    style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: const Color(0xFF3B82F6)),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              GradientSubmitButton(
                text: 'Sign In',
                isLoading: state.isLoading,
                onPressed: () => bloc.add(const ClinicSignInSubmitted()),
              ),
              const SizedBox(height: 20),
              Center(
                child: Text(
                  'Access is restricted to authorized clinic staff. Contact your clinic\nadministrator if you need an account.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(fontSize: 11.5, color: const Color(0xFF64748B), height: 1.5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
