import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

import '../../../../core/layout/patient_breakpoints.dart';
import '../../../../core/widgets/app_snack_bar.dart';
import '../../../../core/widgets/auth_app_bar.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/sign_up_usecase.dart';
import '../bloc/sign_up/sign_up_bloc.dart';
import '../bloc/sign_up/sign_up_state.dart';
import '../widgets/auth_showcase_panel.dart';
import '../widgets/sign_up_card_body.dart';
import 'email_verification_screen.dart';

class SignUpScreen extends StatelessWidget {
  final AuthRepository? authRepository;

  const SignUpScreen({super.key, this.authRepository});

  @override
  Widget build(BuildContext context) {
    final repo = authRepository ?? AuthRepositoryImpl();
    return BlocProvider(
      create: (_) => SignUpBloc(signUpUseCase: SignUpUseCase(repo)),
      child: const _SignUpView(),
    );
  }
}

class _SignUpView extends StatelessWidget {
  const _SignUpView();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isLaptop = PatientBreakpoints.isLaptop(context);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: isLaptop ? null : const AuthAppBar(),
      body: SafeArea(
        child: BlocConsumer<SignUpBloc, SignUpState>(
          listener: (context, state) {
            if (state.user != null) {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (_) =>
                      EmailVerificationScreen(email: state.user!.email),
                ),
                (route) => false,
              );
            }
            if (state.errorMessage != null) {
              AppSnackBar.showError(context, message: state.errorMessage!);
            }
          },
          builder: (context, state) {
            if (isLaptop) {
              return Row(
                children: [
                  const Expanded(
                    flex: 48,
                    child: AuthShowcasePanel(
                      title: 'Join QueueFlow.\nSkip Waiting Rooms.',
                      subtitle:
                          'Join thousands of patients who book doctors, track queues in real time, and get instant consultation passes.',
                      highlightTag: 'PATIENT REGISTRATION',
                    ),
                  ),
                  Expanded(
                    flex: 52,
                    child: Center(
                      child: SignUpCardBody(state: state),
                    ),
                  ),
                ],
              );
            }

            return Center(
              child: SignUpCardBody(state: state),
            );
          },
        ),
      ),
    );
  }
}
