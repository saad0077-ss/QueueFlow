import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_snack_bar.dart';
import '../../../../core/widgets/auth_back_header.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/gradient_button.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/sign_up_usecase.dart';
import '../bloc/sign_up/sign_up_bloc.dart';
import '../bloc/sign_up/sign_up_event.dart';
import '../bloc/sign_up/sign_up_state.dart';
import 'email_verification_screen.dart';
import 'sign_in_screen.dart';

class SignUpScreen extends StatelessWidget {
  final AuthRepository? authRepository;

  const SignUpScreen({super.key, this.authRepository});

  @override
  Widget build(BuildContext context) { 
    return BlocProvider(
      create: (_) => SignUpBloc(
        signUpUseCase: SignUpUseCase(authRepository ?? AuthRepositoryImpl()),
      ),
      child: const _SignUpView(), 
    );
  }
}

class _SignUpView extends StatelessWidget {
  const _SignUpView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: BlocConsumer<SignUpBloc, SignUpState>(
          listener: (context, state) {
            if (state.user != null) {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (_) => EmailVerificationScreen(
                    email: state.user!.email,
                  ),
                ),
                (route) => false,
              );
            }
            if (state.errorMessage != null) {
              AppSnackBar.showError(
                context,
                message: state.errorMessage!,
              );
            }
          },
          builder: (context, state) {
            return LayoutBuilder(
              builder: (context, constraints) {
                final double screenWidth = constraints.maxWidth;
                final double scale = (screenWidth / 390.0).clamp(0.85, 1.15);
                final double titleSize = (27.0 * scale).clamp(22.0, 30.0);
                final double subtitleSize = (13.5 * scale).clamp(12.0, 15.0);
                final double labelSize = (13.5 * scale).clamp(12.0, 15.0);

                return Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: 440,
                      minHeight: constraints.maxHeight,
                    ),
                    child: SingleChildScrollView(
                      physics: const ClampingScrollPhysics(),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight,
                        ),
                        child: IntrinsicHeight(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // ==================== TOP: Header & Titles ====================
                                const SizedBox(height: 12),
                                const AuthBackHeader(),
                                const SizedBox(height: 20),

                                // Title: Create your account
                                Text(
                                  'Create your account',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: titleSize,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                const SizedBox(height: 6),

                                // Subtitle
                                Text(
                                  'Create your account to book\nappointments and track live queues.',
                                  style: TextStyle(
                                    color: const Color(0xFF94A3B8),
                                    fontSize: subtitleSize,
                                    height: 1.35,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),

                                const SizedBox(height: 12),
                                const Spacer(),

                                // ==================== CENTER: Input Fields ====================
                                // 1. Full name
                                CustomTextField(
                                  label: 'Full name',
                                  hintText: 'Muhammed saad',
                                  prefixIcon: Icons.person_outline_rounded,
                                  textInputAction: TextInputAction.next,
                                  autofillHints: const [AutofillHints.name],
                                  labelFontSize: labelSize,
                                  onChanged: (name) => context
                                      .read<SignUpBloc>()
                                      .add(SignUpFullNameChanged(name)),
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
                                  onChanged: (email) => context
                                      .read<SignUpBloc>()
                                      .add(SignUpEmailChanged(email)),
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
                                  onChanged: (phone) => context
                                      .read<SignUpBloc>()
                                      .add(SignUpPhoneChanged(phone)),
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
                                  onChanged: (pwd) => context
                                      .read<SignUpBloc>()
                                      .add(SignUpPasswordChanged(pwd)),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      state.isPasswordObscured
                                          ? Icons.visibility_outlined
                                          : Icons.visibility_off_outlined,
                                      color: const Color(0xFF64748B),
                                      size: 20,
                                    ),
                                    onPressed: () => context
                                        .read<SignUpBloc>()
                                        .add(const SignUpTogglePasswordVisibility()),
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
                                  onChanged: (confirm) => context
                                      .read<SignUpBloc>()
                                      .add(SignUpConfirmPasswordChanged(confirm)),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      state.isConfirmObscured
                                          ? Icons.visibility_outlined
                                          : Icons.visibility_off_outlined,
                                      color: const Color(0xFF64748B),
                                      size: 20,
                                    ),
                                    onPressed: () => context
                                        .read<SignUpBloc>()
                                        .add(const SignUpToggleConfirmVisibility()),
                                  ),
                                ),

                                const SizedBox(height: 16),
                                const Spacer(),

                                // ==================== BOTTOM: Action Button & Link ====================
                                GradientButton(
                                  text: 'Create account',
                                  isLoading: state.isLoading,
                                  onPressed: () {
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

                                    context
                                        .read<SignUpBloc>()
                                        .add(const SignUpSubmitted());
                                  },
                                ),
                                const SizedBox(height: 16),

                                // Bottom Sign in link: Already have an account ? Sign in
                                Center(
                                  child: GestureDetector(
                                    onTap: () {
                                      if (Navigator.of(context).canPop()) {
                                        Navigator.of(context).pop();
                                      } else {
                                        Navigator.of(context).pushReplacement(
                                          MaterialPageRoute(
                                            builder: (_) => const SignInScreen(),
                                          ),
                                        );
                                      }
                                    },
                                    child: RichText(
                                      text: const TextSpan(
                                        text: 'Already have an account ? ',
                                        style: TextStyle(
                                          color: Color(0xFF94A3B8),
                                          fontSize: 13,
                                        ),
                                        children: [
                                          TextSpan(
                                            text: 'Sign in',
                                            style: TextStyle(
                                              color: Color(0xFF38BDF8),
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 24),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
