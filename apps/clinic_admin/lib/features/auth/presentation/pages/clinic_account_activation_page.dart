import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/widgets/app_snack_bar.dart';
import '../../../../core/widgets/gradient_submit_button.dart';
import '../../../queue/presentation/pages/clinic_dashboard_page.dart';
import '../../data/repositories/clinic_auth_repository_impl.dart';
import '../../domain/usecases/activate_clinic_account_usecase.dart';
import '../bloc/activation/account_activation_bloc.dart';
import '../bloc/activation/account_activation_event.dart';
import '../bloc/activation/account_activation_state.dart';
import '../widgets/clinic_hero_banner.dart';
import '../widgets/clinic_input_field.dart';
import '../widgets/invite_summary_card.dart';
import '../widgets/password_strength_bar.dart';
import '../widgets/terms_checkbox_row.dart';
import 'clinic_staff_login_page.dart';

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
            Expanded(flex: isDesktop ? 6 : 1, child: _buildForm(context, state, isDesktop)),
          ],
        ),
      ),
    );
  }

  Widget _buildForm(BuildContext context, AccountActivationState state, bool isDesktop) {
    final bloc = context.read<AccountActivationBloc>();
    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: isDesktop ? 64 : 24, vertical: 32),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome, ${state.doctorName}',
                style: GoogleFonts.inter(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 6),
              Text(
                "You've been invited to manage ${state.clinicName} on\nQueueFlow. Set a password to activate your account.",
                style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF94A3B8), height: 1.45),
              ),
              const SizedBox(height: 20),
              InviteSummaryCard(email: state.inviteEmail, role: state.role, clinicName: state.clinicName),
              const SizedBox(height: 18),
              ClinicInputField(
                label: 'Create password',
                hintText: 'At least 8 characters',
                prefixIcon: Icons.lock_outline_rounded,
                obscureText: state.isPasswordObscured,
                errorText: state.passwordError,
                onChanged: (v) => bloc.add(ActivationPasswordChanged(v)),
                onToggleObscure: () => bloc.add(const ActivationTogglePassword()),
              ),
              PasswordStrengthBar(strength: state.passwordStrength),
              const SizedBox(height: 14),
              ClinicInputField(
                label: 'Confirm password',
                hintText: 'Re-enter your password',
                prefixIcon: Icons.lock_outline_rounded,
                obscureText: state.isConfirmObscured,
                errorText: state.confirmError,
                isValid: state.isConfirmValid,
                validText: 'Passwords match',
                onChanged: (v) => bloc.add(ActivationConfirmPasswordChanged(v)),
                onToggleObscure: () => bloc.add(const ActivationToggleConfirmPassword()),
              ),
              const SizedBox(height: 16),
              TermsCheckboxRow(agreed: state.agreedToTerms, onChanged: (v) => bloc.add(ActivationToggleTerms(v))),
              const SizedBox(height: 20),
              GradientSubmitButton(
                text: 'Activate Account',
                isLoading: state.isLoading,
                onPressed: () => bloc.add(const ActivationSubmitted()),
              ),
              if (state.errorMessage != null) ...[
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFF38BDF8).withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.info_outline_rounded, size: 16, color: Color(0xFF38BDF8)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Email already registered in system',
                              style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'This email already has a password from an earlier test. Enter that existing password above, or click below to receive a password reset link to set a new password.',
                        style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF94A3B8), height: 1.35),
                      ),
                      const SizedBox(height: 8),
                      TextButton.icon(
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(50, 30),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        icon: const Icon(Icons.mail_lock_rounded, size: 15, color: Color(0xFF38BDF8)),
                        label: Text('Send Password Reset Email', style: GoogleFonts.inter(fontSize: 11.5, color: const Color(0xFF38BDF8), fontWeight: FontWeight.w600)),
                        onPressed: () async {
                          try {
                            await FirebaseAuth.instance.sendPasswordResetEmail(email: state.inviteEmail);
                            if (context.mounted) {
                              AppSnackBar.showSuccess(context, message: 'Password reset link sent to ${state.inviteEmail}!');
                            }
                          } catch (e) {
                            if (context.mounted) {
                              AppSnackBar.showError(context, message: 'Failed to send reset email: $e');
                            }
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 10),
              Center(
                child: TextButton(
                  onPressed: () => Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const ClinicStaffLoginPage()),
                  ),
                  child: Text(
                    'Already activated? Sign in to Clinic Portal',
                    style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF3B82F6)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
