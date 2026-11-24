import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

import '../bloc/onboarding_bloc.dart';
import '../bloc/onboarding_event.dart';
import '../bloc/onboarding_state.dart';
import 'calendar_preview_card.dart';
import 'onboarding_bottom_controls.dart';
import 'onboarding_slide.dart';
import 'onboarding_top_bar.dart';
import 'queue_preview_card.dart';
import 'ticket_preview_card.dart';

class OnboardingMobileView extends StatefulWidget {
  final OnboardingState state;

  const OnboardingMobileView({super.key, required this.state});

  @override
  State<OnboardingMobileView> createState() => _OnboardingMobileViewState();
}

class _OnboardingMobileViewState extends State<OnboardingMobileView> {
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

  void _onSkipPressed() {
    _pageController.animateToPage(
      2,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            OnboardingTopBar(
              currentPage: widget.state.currentPage,
              onSkip: _onSkipPressed,
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  context.read<OnboardingBloc>().add(
                        OnboardingPageChanged(index),
                      );
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
                      text: TextSpan(
                        style: const TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.w800,
                          height: 1.2,
                          letterSpacing: -0.5,
                        ),
                        children: [
                          TextSpan(
                            text: 'Book smarter.\n',
                            style: TextStyle(color: colors.textPrimary),
                          ),
                          TextSpan(
                            text: 'Wait less.',
                            style: TextStyle(color: colors.accent),
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
              isFinalScreen: widget.state.currentPage >= 2,
              currentPage: widget.state.currentPage,
              onNextPressed: () => _onNextPressed(widget.state.currentPage),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
