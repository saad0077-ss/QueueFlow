import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_snack_bar.dart';
import '../../../../core/widgets/auth_back_header.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/sign_up_usecase.dart';
import '../bloc/sign_up/sign_up_bloc.dart';
import '../bloc/sign_up/sign_up_state.dart';
import '../widgets/sign_up_footer.dart';
import '../widgets/sign_up_form.dart';
import '../widgets/sign_up_header.dart';
import 'email_verification_screen.dart';

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
                                const SizedBox(height: 12),
                                const AuthBackHeader(),
                                const SizedBox(height: 20),
                                SignUpHeader(
                                  titleSize: titleSize,
                                  subtitleSize: subtitleSize,
                                ),
                                const SizedBox(height: 12),
                                const Spacer(),
                                SignUpForm(
                                  state: state,
                                  labelSize: labelSize,
                                ),
                                const SizedBox(height: 16),
                                const Spacer(),
                                const SignUpFooter(),
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
