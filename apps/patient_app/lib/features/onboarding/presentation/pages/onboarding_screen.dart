import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/widgets/app_logo.dart';
import '../bloc/onboarding_bloc.dart';
import '../bloc/onboarding_event.dart';
import '../bloc/onboarding_state.dart';
import '../widgets/calendar_preview_card.dart';
import '../widgets/onboarding_bottom_controls.dart';
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

  void _onNextPressed(int currentPage) {
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
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(left: 20, top: 12, bottom: 4),
                  child: AppLogo(fontSize: 21, showIcon: true),
                ),
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
                OnboardingBottomControls(
                  isFinalScreen: state.currentPage >= 2,
                  currentPage: state.currentPage,
                  onNextPressed: () => _onNextPressed(state.currentPage),
                ),
                const SizedBox(height: 20),
              ],
            );
          },
        ),
      ),
    );
  }
}
