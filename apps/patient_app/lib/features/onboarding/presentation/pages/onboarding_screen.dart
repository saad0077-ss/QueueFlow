import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

import '../bloc/onboarding_bloc.dart';
import '../bloc/onboarding_state.dart';
import '../widgets/onboarding_laptop_view.dart';
import '../widgets/onboarding_mobile_view.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => OnboardingBloc(),
      child: const _OnboardingScreenView(),
    );
  }
}

class _OnboardingScreenView extends StatelessWidget {
  const _OnboardingScreenView();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: BlocBuilder<OnboardingBloc, OnboardingState>(
          builder: (context, state) {
            return LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth >= 800) {
                  return const OnboardingLaptopView();
                }
                return OnboardingMobileView(state: state);
              },
            );
          },
        ),
      ),
    );
  }
}
