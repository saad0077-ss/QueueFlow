import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/widgets/gradient_submit_button.dart';
import '../bloc/activation/account_activation_bloc.dart';
import '../bloc/activation/account_activation_event.dart';
import '../bloc/activation/account_activation_state.dart';
import '../pages/clinic_staff_login_page.dart';
import 'clinic_input_field.dart';
import 'existing_account_notice.dart';
import 'invite_summary_card.dart';
import 'password_strength_bar.dart';
import 'terms_checkbox_row.dart';

/// The form widget used inside ClinicAccountActivationPage.
class ClinicAccountActivationForm extends StatelessWidget {
  final AccountActivationState state;

  const ClinicAccountActivationForm({
    super.key,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<AccountActivationBloc>();

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 420),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Greeting & Context
          Text(
            'Welcome, ${state.doctorName}',
            style: GoogleFonts.inter(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "You've been invited to manage ${state.clinicName} on\nQueueFlow. Set a password to activate your account.",
            style: GoogleFonts.inter(
              fontSize: 13,
              color: const Color(0xFF94A3B8),
              height: 1.45,
            ),
          ),
          const SizedBox(height: 20),

          // Invite card
          InviteSummaryCard(
            email: state.inviteEmail,
            role: state.role,
            clinicName: state.clinicName,
          ),
          const SizedBox(height: 18),

          // Create Password
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

          // Confirm Password
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

          // Terms
          TermsCheckboxRow(
            agreed: state.agreedToTerms,
            onChanged: (v) => bloc.add(ActivationToggleTerms(v)),
          ),
          const SizedBox(height: 20),

          // Submit Button
          GradientSubmitButton(
            text: 'Activate Account',
            isLoading: state.isLoading,
            onPressed: () => bloc.add(const ActivationSubmitted()),
          ),

          // Existing Account Notice
          if (state.errorMessage != null) ...[
            const SizedBox(height: 14),
            ExistingAccountNotice(email: state.inviteEmail),
          ],

          const SizedBox(height: 10),

          // Login Link
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
    );
  }
}
