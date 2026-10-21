import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/widgets/app_snack_bar.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/gradient_button.dart';
import '../bloc/sign_up/sign_up_bloc.dart';
import '../bloc/sign_up/sign_up_event.dart';
import '../bloc/sign_up/sign_up_state.dart';

class SignUpForm extends StatelessWidget {
  final SignUpState state;
  final double labelSize;

  const SignUpForm({
    super.key,
    required this.state,
    required this.labelSize,
  });

  void _onCreateAccountPressed(BuildContext context) {
    final fullName = state.fullName.trim();
    final email = state.email.trim();
    final phone = state.phoneNumber.trim();
    final password = state.password;
    final confirmPassword = state.confirmPassword;

    if (fullName.isEmpty ||
        email.isEmpty ||
        phone.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      AppSnackBar.showWarning(
        context,
        title: 'Incomplete Form',
        message: 'Please complete all required fields to register.',
      );
      return;
    }

    if (!email.contains('@') || !email.contains('.')) {
      AppSnackBar.showWarning(
        context,
        title: 'Invalid Email',
        message: 'Please enter a valid email address.',
      );
      return;
    }

    if (password != confirmPassword) {
      AppSnackBar.showWarning(
        context,
        title: 'Password Mismatch',
        message: "Passwords do not match. Please verify and try again.",
      );
      return;
    }

    if (password.length < 6) {
      AppSnackBar.showWarning(
        context,
        title: 'Weak Password',
        message: 'Password must be at least 6 characters long.',
      );
      return;
    }

    context.read<SignUpBloc>().add(const SignUpSubmitted());
  }

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<SignUpBloc>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Full name
        CustomTextField(
          label: 'Full name',
          hintText: 'Muhammed saad',
          prefixIcon: Icons.person_outline_rounded,
          textInputAction: TextInputAction.next,
          autofillHints: const [AutofillHints.name],
          labelFontSize: labelSize,
          onChanged: (name) => bloc.add(SignUpFullNameChanged(name)),
        ),
        const SizedBox(height: 12),

        // 2. Email address with helper/error
        CustomTextField(
          label: 'Email address',
          hintText: 'you@example.com',
          prefixIcon: Icons.mail_outline_rounded,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          autofillHints: const [AutofillHints.email],
          helperText: 'Enter a valid email address.',
          errorText: state.emailError,
          labelFontSize: labelSize,
          onChanged: (email) => bloc.add(SignUpEmailChanged(email)),
        ),
        const SizedBox(height: 12),

        // 3. Phone number
        CustomTextField(
          label: 'Phone number',
          hintText: '+91 9876543510',
          prefixIcon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
          textInputAction: TextInputAction.next,
          autofillHints: const [AutofillHints.telephoneNumber],
          labelFontSize: labelSize,
          onChanged: (phone) => bloc.add(SignUpPhoneChanged(phone)),
        ),
        const SizedBox(height: 12),

        // 4. Password with helper requirements
        CustomTextField(
          label: 'Password',
          hintText: 'Create a password',
          prefixIcon: Icons.lock_outline_rounded,
          obscureText: state.isPasswordObscured,
          textInputAction: TextInputAction.next,
          autofillHints: const [AutofillHints.newPassword],
          helperText: 'At least 8 characters, with  a number',
          labelFontSize: labelSize,
          onChanged: (pwd) => bloc.add(SignUpPasswordChanged(pwd)),
          suffixIcon: IconButton(
            icon: Icon(
              state.isPasswordObscured
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              color: const Color(0xFF64748B),
              size: 20,
            ),
            onPressed: () => bloc.add(const SignUpTogglePasswordVisibility()),
          ),
        ),
        const SizedBox(height: 12),

        // 5. Confirm password
        CustomTextField(
          label: 'Confirm password',
          hintText: 'Re-enter your password',
          prefixIcon: Icons.lock_outline_rounded,
          obscureText: state.isConfirmObscured,
          textInputAction: TextInputAction.done,
          autofillHints: const [AutofillHints.newPassword],
          helperText: state.confirmPasswordError ?? "Passwords don't match.",
          errorText: state.confirmPasswordError,
          labelFontSize: labelSize,
          onChanged: (confirm) => bloc.add(SignUpConfirmPasswordChanged(confirm)),
          suffixIcon: IconButton(
            icon: Icon(
              state.isConfirmObscured
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              color: const Color(0xFF64748B),
              size: 20,
            ),
            onPressed: () => bloc.add(const SignUpToggleConfirmVisibility()),
          ),
        ),
        const SizedBox(height: 24),

        // Action Button
        GradientButton(
          text: 'Create account',
          isLoading: state.isLoading,
          onPressed: () => _onCreateAccountPressed(context),
        ),
      ],
    );
  }
}
