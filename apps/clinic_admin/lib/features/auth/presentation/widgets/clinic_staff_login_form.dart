import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/widgets/gradient_submit_button.dart';
import '../bloc/sign_in/clinic_sign_in_bloc.dart';
import '../bloc/sign_in/clinic_sign_in_event.dart';
import '../bloc/sign_in/clinic_sign_in_state.dart';
import '../pages/clinic_account_activation_page.dart';
import 'clinic_input_field.dart';

/// The form widget used inside ClinicStaffLoginPage.
class ClinicStaffLoginForm extends StatelessWidget {
  final ClinicSignInState state;

  const ClinicStaffLoginForm({
    super.key,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<ClinicSignInBloc>();

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 420),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Text
          Text(
            'Clinic Staff Login',
            style: GoogleFonts.inter(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Access your clinic appointments and live queue.',
            style: GoogleFonts.inter(fontSize: 13.5, color: const Color(0xFF94A3B8)),
          ),
          const SizedBox(height: 26),

          // Email Input Field
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
            onFieldSubmitted: (_) => bloc.add(const ClinicSignInSubmitted()),
          ),
          const SizedBox(height: 18),

          // Password Input Field
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

          // Forgot Password Link
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => bloc.add(const ClinicSignInForgotPasswordRequested()),
              child: Text(
                'Forgot password?',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF3B82F6),
                ),
              ),
            ),
          ),

          // Inline Error Message Banner
          if (state.errorMessage != null) ...[
            _buildErrorMessage(state.errorMessage!),
            const SizedBox(height: 14),
          ],

          const SizedBox(height: 6),

          // Submit Button
          GradientSubmitButton(
            text: 'Sign In',
            isLoading: state.isLoading,
            onPressed: () => bloc.add(const ClinicSignInSubmitted()),
          ),
          const SizedBox(height: 16),

          // Activate Account Link
          Center(
            child: TextButton(
              onPressed: () => Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const ClinicAccountActivationPage()),
              ),
              child: Text(
                'Have an invite link? Activate clinic account',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: const Color(0xFF38BDF8),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Footer Notice
          Center(
            child: Text(
              'Access is restricted to authorized clinic staff. Contact your clinic\nadministrator if you need an account.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 11.5,
                color: const Color(0xFF64748B),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorMessage(String message) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF451A1A),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFEF4444).withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded, color: Color(0xFFEF4444), size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFFFCA5A5)),
            ),
          ),
        ],
      ),
    );
  }
}
