import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_snack_bar.dart';
import '../../../../main.dart';
import '../widgets/email_verification_actions.dart';
import '../widgets/email_verification_card.dart';
import 'sign_in_screen.dart';

class EmailVerificationScreen extends StatefulWidget {
  final String email;

  const EmailVerificationScreen({super.key, required this.email});

  @override
  State<EmailVerificationScreen> createState() => _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  bool _isChecking = false;
  bool _isResending = false;
  int _resendCooldown = 0;
  Timer? _cooldownTimer;

  @override
  void initState() {
    super.initState();
    _startCooldown(60);
  }

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    super.dispose();
  }

  void _startCooldown(int seconds) {
    setState(() => _resendCooldown = seconds);
    _cooldownTimer?.cancel();
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return timer.cancel();
      if (_resendCooldown <= 1) {
        timer.cancel();
        setState(() => _resendCooldown = 0);
      } else {
        setState(() => _resendCooldown--);
      }
    });
  }

  Future<void> _checkVerificationStatus() async {
    if (_isChecking) return;
    setState(() => _isChecking = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) await user.reload();
      final isVerified = FirebaseAuth.instance.currentUser?.emailVerified ?? false;
      if (!mounted) return;
      if (isVerified) {
        AppSnackBar.showSuccess(context, title: 'Email Verified', message: 'Your account is now activated. Welcome to QueueFlow!');
        Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const PatientHomeScreen()), (route) => false);
      } else {
        AppSnackBar.showError(
          context,
          title: 'Email Not Verified',
          message: 'Your email address is not verified yet. Please verify via the link sent to your inbox before proceeding.',
        );
      }
    } catch (_) {
      if (mounted) AppSnackBar.showError(context, message: 'Could not verify status. Please check your connection.');
    } finally {
      if (mounted) setState(() => _isChecking = false);
    }
  }

  Future<void> _resendVerificationEmail() async {
    if (_resendCooldown > 0 || _isResending) return;
    setState(() => _isResending = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        if (mounted) AppSnackBar.showError(context, message: 'No user signed in.');
        return;
      }
      await user.sendEmailVerification();
      if (!mounted) return;
      AppSnackBar.showSuccess(context, title: 'Email Sent', message: 'A fresh verification email has been sent to ${widget.email}.');
      _startCooldown(60);
    } catch (_) {
      if (mounted) AppSnackBar.showError(context, message: 'Failed to resend verification email. Please try again.');
    } finally {
      if (mounted) setState(() => _isResending = false);
    }
  }

  Future<void> _signOutAndSwitchAccount() async {
    try {
      await FirebaseAuth.instance.signOut();
    } catch (_) {}
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const SignInScreen()), (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final effectiveEmail = widget.email.isNotEmpty
        ? widget.email
        : (FirebaseAuth.instance.currentUser?.email ?? 'your email address');

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        AppSnackBar.showError(context, title: 'Verification Required', message: 'Please verify your email address to access your account.');
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  EmailVerificationCard(effectiveEmail: effectiveEmail),
                  const SizedBox(height: 36),
                  EmailVerificationActions(
                    isChecking: _isChecking,
                    onCheckStatus: _checkVerificationStatus,
                    resendCooldown: _resendCooldown,
                    isResending: _isResending,
                    onResend: _resendVerificationEmail,
                    onSignOutAndSwitch: _signOutAndSwitchAccount,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
