import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

import '../../../../core/layout/patient_breakpoints.dart';
import '../../../../core/widgets/app_snack_bar.dart';
import '../../../../main.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/sign_in_usecase.dart';
import '../bloc/sign_in/sign_in_bloc.dart';
import '../bloc/sign_in/sign_in_state.dart';
import '../widgets/auth_showcase_panel.dart';
import '../widgets/sign_in_card_body.dart';
import 'email_verification_screen.dart';

class SignInScreen extends StatelessWidget {
  final AuthRepository? authRepository;

  const SignInScreen({super.key, this.authRepository});

  @override
  Widget build(BuildContext context) {
    final repo = authRepository ?? AuthRepositoryImpl();
    return BlocProvider(
      create: (_) =>
          SignInBloc(signInUseCase: SignInUseCase(repo), authRepository: repo),
      child: const _SignInView(),
    );
  }
}

class _SignInView extends StatelessWidget {
  const _SignInView();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: BlocConsumer<SignInBloc, SignInState>(
          listener: (context, state) {
            if (state.user != null) {
              final currentUser = FirebaseAuth.instance.currentUser;
              if (currentUser != null && !currentUser.emailVerified) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (_) =>
                        EmailVerificationScreen(email: state.user!.email),
                  ),
                  (route) => false,
                );
              } else {
                final name = state.user!.fullName.isNotEmpty
                    ? state.user!.fullName
                    : 'Patient';
                AppSnackBar.showSuccess(
                  context,
                  title: 'Welcome Back',
                  message: 'Welcome back, $name! Signed in successfully.',
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
                final isLaptop =
                    constraints.maxWidth >= PatientBreakpoints.laptopMin;

                if (isLaptop) {
                  return Row(
                    children: [
                      const Expanded(
                        flex: 48,
                        child: AuthShowcasePanel(
                          title: 'Healthcare That Values Your Time.',
                          subtitle:
                              'Access real-time clinic queues, confirmed doctor appointments, and digital consultation passes in one secure portal.',
                          highlightTag: 'PATIENT LOGIN',
                        ),
                      ),
                      Expanded(
                        flex: 52,
                        child: Center(
                          child: SignInCardBody(
                            state: state,
                            showTopBar: false,
                          ),
                        ),
                      ),
                    ],
                  );
                }

                return Center(
                  child: SignInCardBody(state: state),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
