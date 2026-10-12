import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_snack_bar.dart';
import '../../../../core/widgets/auth_back_header.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/google_sign_in_button.dart';
import '../../../../core/widgets/gradient_button.dart';
import '../../../../main.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/sign_in_usecase.dart';
import '../bloc/sign_in/sign_in_bloc.dart';
import '../bloc/sign_in/sign_in_event.dart';
import '../bloc/sign_in/sign_in_state.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'email_verification_screen.dart';
import 'forgot_password_screen.dart';
import 'sign_up_screen.dart';

class SignInScreen extends StatelessWidget {
  final AuthRepository? authRepository;

  const SignInScreen({super.key, this.authRepository});

  @override
  Widget build(BuildContext context) {
    final repo = authRepository ?? AuthRepositoryImpl();
    return BlocProvider(
      create: (_) => SignInBloc(
        signInUseCase: SignInUseCase(repo),
        authRepository: repo,
      ),
      child: const _SignInView(),
    );
  }
}

class _SignInView extends StatelessWidget {
  const _SignInView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: BlocConsumer<SignInBloc, SignInState>(
          listener: (context, state) {
            if (state.user != null) {
              final currentUser = FirebaseAuth.instance.currentUser;
              if (currentUser != null && !currentUser.emailVerified) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (_) => EmailVerificationScreen(
                      email: state.user!.email,
                    ),
                  ),
                  (route) => false,
                );
              } else {
                AppSnackBar.showSuccess(
                  context,
                  message: 'Signed in successfully.',
                );
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const PatientHomeScreen()),
                  (route) => false,
                );
              }
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
                // Responsive font sizing based on available width
                final double screenWidth = constraints.maxWidth;
                final double scale = (screenWidth / 390.0).clamp(0.85, 1.15);

                final double titleSize = (28.0 * scale).clamp(23.0, 32.0);
                final double subtitleSize = (14.0 * scale).clamp(12.5, 16.0);
                final double labelSize = (13.5 * scale).clamp(12.0, 15.0);
                final double forgotPasswordSize =
                    (13.0 * scale).clamp(11.5, 14.5);
                final double dividerTextSize =
                    (12.5 * scale).clamp(11.0, 14.0);
                final double bottomLinkSize =
                    (13.5 * scale).clamp(12.0, 15.0);

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
                                const SizedBox(height: 12),
                                const AuthBackHeader(),
                                const SizedBox(height: 34),
                                Text(
                                  'Welcome back',
                                  style: TextStyle(
                                    color: AppColors.textWhite,
                                    fontSize: titleSize,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Sign in to manage your bookings and\nkeep an eye on live queue status.',
                                  style: TextStyle(
                                    color: AppColors.textMuted,
                                    fontSize: subtitleSize,
                                    height: 1.45,
                                  ),
                                ),
                                const Spacer(flex: 5),
                                const SizedBox(height: 16),
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
                                      .read<SignInBloc>()
                                      .add(SignInEmailChanged(email)),
                                ),
                                const SizedBox(height: 18),
                                CustomTextField(
                                  label: 'Password',
                                  hintText: 'Enter your password',
                                  prefixIcon: Icons.lock_outline_rounded,
                                  obscureText: state.isPasswordObscured,
                                  textInputAction: TextInputAction.done,
                                  autofillHints: const [AutofillHints.password],
                                  labelFontSize: labelSize,
                                  onChanged: (pwd) => context
                                      .read<SignInBloc>()
                                      .add(SignInPasswordChanged(pwd)),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      state.isPasswordObscured
                                          ? Icons.visibility_outlined
                                          : Icons.visibility_off_outlined,
                                      color: AppColors.textSubtle,
                                      size: 20,
                                    ),
                                    onPressed: () => context
                                        .read<SignInBloc>()
                                        .add(const SignInTogglePasswordVisibility()),
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: GestureDetector(
                                      onTap: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (_) => ForgotPasswordScreen(
                                              initialEmail: state.email.trim().isNotEmpty
                                                  ? state.email.trim()
                                                  : null,
                                            ),
                                          ),
                                        );
                                      },
                                      child: Text(
                                        'Forgot password?',
                                        style: TextStyle(
                                          color: AppColors.textLink,
                                          fontSize: forgotPasswordSize,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const Spacer(flex: 4),
                                const SizedBox(height: 16),
                                GradientButton(
                                  text: 'Sign In',
                                  isLoading: state.isLoading,
                                  onPressed: () {
                                    final email = state.email.trim();
                                    final password = state.password;
                                    if (email.isEmpty && password.isEmpty) {
                                      AppSnackBar.showWarning(
                                        context,
                                        title: 'Missing Details',
                                        message: 'Please enter your email and password.',
                                      );
                                      return;
                                    }
                                    if (email.isEmpty) {
                                      AppSnackBar.showWarning(
                                        context,
                                        title: 'Email Required',
                                        message: 'Please enter your email address.',
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
                                    if (password.isEmpty) {
                                      AppSnackBar.showWarning(
                                        context,
                                        title: 'Password Required',
                                        message: 'Please enter your password.',
                                      );
                                      return;
                                    }
                                    context
                                        .read<SignInBloc>()
                                        .add(const SignInSubmitted());
                                  },
                                ),
                                const SizedBox(height: 20),
                                Row(
                                  children: [
                                    const Expanded(
                                      child: Divider(
                                        color: AppColors.cardBorder,
                                        thickness: 1,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 14),
                                      child: Text(
                                        'or continue with',
                                        style: TextStyle(
                                          color: AppColors.textSubtle,
                                          fontSize: dividerTextSize,
                                        ),
                                      ),
                                    ),
                                    const Expanded(
                                      child: Divider(
                                        color: AppColors.cardBorder,
                                        thickness: 1,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                GoogleSignInButton(
                                  onPressed: () => context
                                      .read<SignInBloc>()
                                      .add(const SignInWithGoogleSubmitted()),
                                ),
                                const SizedBox(height: 28),
                                Center(
                                  child: GestureDetector(
                                    onTap: () => Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => const SignUpScreen(),
                                      ),
                                    ),
                                    child: RichText(
                                      text: TextSpan(
                                        text: "Don't have an account? ",
                                        style: TextStyle(
                                          color: AppColors.textMuted,
                                          fontSize: bottomLinkSize,
                                        ),
                                        children: [
                                          TextSpan(
                                            text: 'Create one',
                                            style: TextStyle(
                                              color: AppColors.textLink,
                                              fontSize: bottomLinkSize,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20),
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
