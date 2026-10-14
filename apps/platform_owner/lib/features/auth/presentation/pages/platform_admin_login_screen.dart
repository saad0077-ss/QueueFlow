import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/widgets/app_snack_bar.dart';
import '../../../../core/widgets/gradient_submit_button.dart';
import '../../../dashboard/presentation/pages/platform_clinics_page.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/sign_in_usecase.dart';
import '../bloc/sign_in_bloc.dart';
import '../bloc/sign_in_event.dart';
import '../bloc/sign_in_state.dart';
import '../widgets/admin_input_field.dart';
import '../widgets/hero_analytics_banner.dart';

class PlatformAdminLoginScreen extends StatelessWidget {
  final AuthRepository? authRepository;

  const PlatformAdminLoginScreen({super.key, this.authRepository});

  @override
  Widget build(BuildContext context) {
    final repo = authRepository ?? AuthRepositoryImpl();
    return BlocProvider(
      create: (_) => SignInBloc(signInUseCase: SignInUseCase(repo)),
      child: const _PlatformAdminLoginView(),
    );
  }
}

class _PlatformAdminLoginView extends StatelessWidget {
  const _PlatformAdminLoginView();

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.sizeOf(context).width >= 900;
    return Scaffold(
      backgroundColor: const Color(0xFF070B14),
      body: BlocConsumer<SignInBloc, SignInState>(
        listener: (context, state) {
          if (state.admin != null) {
            AppSnackBar.showSuccess(context, message: 'Signed in.');
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const PlatformClinicsPage()),
            );
          }
          if (state.errorMessage != null) {
            AppSnackBar.showError(context, message: state.errorMessage!);
          }
        },
        builder: (context, state) => Row(
          children: [
            if (isDesktop) const Expanded(flex: 5, child: HeroAnalyticsBanner()),
            Expanded(flex: isDesktop ? 6 : 1, child: _buildForm(context, state, isDesktop)),
          ],
        ),
      ),
    );
  }

  Widget _buildForm(BuildContext context, SignInState state, bool isDesktop) {
    final bloc = context.read<SignInBloc>();
    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: isDesktop ? 64 : 24, vertical: 36),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 430),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Platform Owner Console',
                style: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 6),
              Text(
                'Manage tenant registry, SaaS plan tiers, financial intelligence, and audit logs.',
                style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF94A3B8), height: 1.4),
              ),
              const SizedBox(height: 28),
              AdminInputField(
                label: 'Email address',
                hintText: 'admin@queueflow.com',
                prefixIcon: Icons.mail_outline_rounded,
                keyboardType: TextInputType.emailAddress,
                errorText: state.emailError,
                isValid: state.isEmailValid,
                validText: 'Email verified',
                onChanged: (val) => bloc.add(SignInEmailChanged(val)),
              ),
              const SizedBox(height: 20),
              AdminInputField(
                label: 'Password',
                hintText: 'Enter your password',
                prefixIcon: Icons.lock_outline_rounded,
                obscureText: state.isPasswordObscured,
                errorText: state.passwordError,
                onChanged: (val) => bloc.add(SignInPasswordChanged(val)),
                onFieldSubmitted: (_) => bloc.add(const SignInSubmitted()),
                suffixIcon: IconButton(
                  icon: Icon(
                    state.isPasswordObscured ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                    color: const Color(0xFF64748B),
                    size: 20,
                  ),
                  onPressed: () => bloc.add(const SignInTogglePasswordVisibility()),
                ),
              ),
              const SizedBox(height: 28),
              GradientSubmitButton(
                text: 'Sign In',
                isLoading: state.isLoading,
                onPressed: () => bloc.add(const SignInSubmitted()),
              ),
              const SizedBox(height: 24),
              Center(
                child: Text(
                  'Access is restricted to authorized platform owners.\nContact system security if you require administrative access.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF64748B), height: 1.5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
