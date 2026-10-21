import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_snack_bar.dart';
import '../../../../core/widgets/auth_back_header.dart';
import '../../../../main.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/sign_in_usecase.dart';
import '../bloc/sign_in/sign_in_bloc.dart';
import '../bloc/sign_in/sign_in_state.dart';
import '../widgets/sign_in_footer.dart';
import '../widgets/sign_in_form.dart';
import '../widgets/sign_in_header.dart';
import 'email_verification_screen.dart';

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
              AppSnackBar.showError(context, message: state.errorMessage!);
            }
          },
          builder: (context, state) {
            return LayoutBuilder(
              builder: (context, constraints) {
                final double screenWidth = constraints.maxWidth;
                final double scale = (screenWidth / 390.0).clamp(0.85, 1.15);

                return Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: 440,
                      minHeight: constraints.maxHeight,
                    ),
                    child: SingleChildScrollView(
                      physics: const ClampingScrollPhysics(),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(minHeight: constraints.maxHeight),
                        child: IntrinsicHeight(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 12),
                                const AuthBackHeader(),
                                const SizedBox(height: 34),
                                SignInHeader(
                                  titleSize: (28.0 * scale).clamp(23.0, 32.0),
                                  subtitleSize: (14.0 * scale).clamp(12.5, 16.0),
                                ),
                                const Spacer(flex: 5),
                                const SizedBox(height: 16),
                                SignInForm(
                                  state: state,
                                  labelSize: (13.5 * scale).clamp(12.0, 15.0),
                                  forgotPasswordSize: (13.0 * scale).clamp(11.5, 14.5),
                                ),
                                const Spacer(flex: 4),
                                const SizedBox(height: 16),
                                SignInFooter(
                                  dividerTextSize: (12.5 * scale).clamp(11.0, 14.0),
                                  bottomLinkSize: (13.5 * scale).clamp(12.0, 15.0),
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
