import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/widgets/app_icon_badge.dart';
import '../../../../core/widgets/app_logo.dart';
import '../../../../main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../auth/data/repositories/auth_repository_impl.dart';
import '../../../auth/presentation/pages/email_verification_screen.dart';
import '../../../onboarding/presentation/pages/onboarding_screen.dart';
import '../bloc/splash_bloc.dart';
import '../bloc/splash_event.dart';
import '../bloc/splash_state.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SplashBloc(
        authRepository: AuthRepositoryImpl(),
      )..add(const SplashCheckAuthEvent()),
      child: const _SplashScreenView(),
    );
  }
}

class _SplashScreenView extends StatefulWidget {
  const _SplashScreenView();

  @override
  State<_SplashScreenView> createState() => _SplashScreenViewState();
}

class _SplashScreenViewState extends State<_SplashScreenView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.0, 0.7, curve: Curves.easeOutBack),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.3, 0.9, curve: Curves.easeIn),
    );

    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _navigateTo(Widget screen) {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 500),
        pageBuilder: (context, animation, secondaryAnimation) => screen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SplashBloc, SplashState>(
      listener: (context, state) {
        if (state is SplashAuthenticated) {
          final currentUser = FirebaseAuth.instance.currentUser;
          if (currentUser != null && !currentUser.emailVerified) {
            _navigateTo(EmailVerificationScreen(
              email: currentUser.email ?? '',
            ));
          } else {
            _navigateTo(const PatientHomeScreen());
          }
        } else if (state is SplashUnauthenticated) {
          _navigateTo(const OnboardingScreen());
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF070D18),
        body: Center(
          child: AnimatedBuilder(
            animation: _animController,
            builder: (context, _) => Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Clean crisp App Icon Badge without color spread radius
                Transform.scale(
                  scale: _scaleAnimation.value,
                  child: const AppIconBadge(size: 96),
                ),
                const SizedBox(height: 24),
                // Brand Name & Tagline
                Opacity(
                  opacity: _fadeAnimation.value,
                  child: Column(
                    children: const [
                      AppLogo(fontSize: 30),
                      SizedBox(height: 8),
                      Text(
                        'Book smarter. Wait less.',
                        style: TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
