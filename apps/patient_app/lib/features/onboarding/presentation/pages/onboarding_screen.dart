import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/widgets/app_logo.dart';
import '../../../../core/widgets/gradient_button.dart';
import '../../../auth/presentation/pages/sign_in_screen.dart';
import '../../../auth/presentation/pages/sign_up_screen.dart';
import '../bloc/onboarding_bloc.dart';
import '../bloc/onboarding_event.dart';
import '../bloc/onboarding_state.dart';
import '../widgets/calendar_preview_card.dart';
import '../widgets/onboarding_page_indicator.dart';
import '../widgets/onboarding_slide.dart';
import '../widgets/queue_preview_card.dart';
import '../widgets/ticket_preview_card.dart';

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

class _OnboardingScreenView extends StatefulWidget {
  const _OnboardingScreenView();

  @override
  State<_OnboardingScreenView> createState() => _OnboardingScreenViewState();
}

class _OnboardingScreenViewState extends State<_OnboardingScreenView> {
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onNextPressed(BuildContext context, int currentPage) {
    if (currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF070D18),
      body: SafeArea(
        child: BlocBuilder<OnboardingBloc, OnboardingState>(
          builder: (context, state) {
            final isFinalScreen = state.currentPage >= 2;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top-Left QueueFlow Brand Logo with icon badge
                const Padding(
                  padding: EdgeInsets.only(left: 20, top: 12, bottom: 4),
                  child: AppLogo(fontSize: 21, showIcon: true),
                ),

                // Center Slides
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: (index) {
                      context
                          .read<OnboardingBloc>()
                          .add(OnboardingPageChanged(index));
                    },
                    children: [
                      const OnboardingSlide(
                        card: CalendarPreviewCard(),
                        title: 'Book appointments in\nseconds',
                        subtitle:
                            'Pick a clinic, choose a time that works,\nand you\'re booked. No phone calls, no\nwaiting on hold.',
                      ),
                      const OnboardingSlide(
                        card: QueuePreviewCard(),
                        title: 'Know exactly when it\'s\nyour turn',
                        subtitle:
                            'Join the queue from anywhere and watch\nyour position update live, no need to sit in\na waiting room.',
                      ),
                      OnboardingSlide(
                        card: const TicketPreviewCard(),
                        titleWidget: RichText(
                          textAlign: TextAlign.center,
                          text: const TextSpan(
                            style: TextStyle(
                              fontSize: 34,
                              fontWeight: FontWeight.w800,
                              height: 1.2,
                              letterSpacing: -0.5,
                            ),
                            children: [
                              TextSpan(
                                text: 'Book smarter.\n',
                                style: TextStyle(color: Colors.white),
                              ),
                              TextSpan(
                                text: 'Wait less.',
                                style: TextStyle(color: Color(0xFF38BDF8)),
                              ),
                            ],
                          ),
                        ),
                        subtitle:
                            'Skip the waiting room. Book appointments\nand track your place in line, in real time.',
                      ),
                    ],
                  ),
                ),

                // Bottom Controls: changes smoothly on final screen
                if (!isFinalScreen) ...[
                  OnboardingPageIndicator(
                    currentPage: state.currentPage,
                    totalPages: 2,
                  ),
                  const SizedBox(height: 28),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: GradientButton(
                      text: 'Next',
                      onPressed: () =>
                          _onNextPressed(context, state.currentPage),
                    ),
                  ),
                ] else ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GradientButton(
                          text: 'Create account',
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const SignUpScreen(),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const SignInScreen(),
                                ),
                              );
                            },
                            style: OutlinedButton.styleFrom(
                              backgroundColor: const Color(0xFF0B1220),
                              side: const BorderSide(
                                color: Color(0xFF24324A),
                                width: 1.5,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(27),
                              ),
                            ),
                            child: const Text(
                              'Sign in',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16.5,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 20),
              ],
            );
          },
        ),
      ),
    );
  }
}
