import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_snack_bar.dart';
import '../../../../core/widgets/gradient_button.dart';
import '../../../../main.dart';
import 'sign_in_screen.dart';

class EmailVerificationScreen extends StatefulWidget {
  final String email;

  const EmailVerificationScreen({
    super.key,
    required this.email,
  });

  @override
  State<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}
     
class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  bool _isChecking = false;
  bool _isResending = false;
  int _resendCooldown = 0;
  Timer? _cooldownTimer;        

  @override
  void initState() {
    super.initState();
    // Start initial 60-second cooldown because an email was already sent during sign-up
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
      if (!mounted) {
        timer.cancel();
        return;
      }
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
      if (user != null) {
        await user.reload();
      }
      final isVerified =
          FirebaseAuth.instance.currentUser?.emailVerified ?? false;

      if (!mounted) return;

      if (isVerified) {
        AppSnackBar.showSuccess(
          context,
          title: 'Email Verified',
          message: 'Your account is now activated. Welcome to QueueFlow!',
        );
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const PatientHomeScreen()),
          (route) => false,
        );
      } else {
        AppSnackBar.showWarning(
          context,
          title: 'Not Verified Yet',
          message:
              'Please open the verification link sent to ${widget.email} and then tap this button.',
        );
      }
    } catch (e) {
      if (mounted) {
        AppSnackBar.showError(
          context,
          message: 'Could not verify status. Please check your connection.',
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isChecking = false);
      }
    }
  }

  Future<void> _resendVerificationEmail() async {
    if (_resendCooldown > 0 || _isResending) return;

    setState(() => _isResending = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        if (!mounted) return;
        AppSnackBar.showError(context, message: 'No user signed in.');
        return;
      }

      await user.sendEmailVerification();
      if (!mounted) return;

      AppSnackBar.showSuccess(
        context,
        title: 'Email Sent',
        message: 'A fresh verification email has been sent to ${widget.email}.',
      );
      _startCooldown(60);
    } catch (e) {
      if (!mounted) return;
      AppSnackBar.showError(
        context,
        message: 'Failed to resend verification email. Please try again.',
      );
    } finally {
      if (mounted) {
        setState(() => _isResending = false);
      }
    }
  }

  Future<void> _signOutAndSwitchAccount() async {
    try {
      await FirebaseAuth.instance.signOut();
    } catch (_) {}

    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const SignInScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final effectiveEmail = widget.email.isNotEmpty
        ? widget.email
        : (FirebaseAuth.instance.currentUser?.email ?? 'your email address');

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Mail Icon Card
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF334155),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.25),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.mark_email_unread_rounded,
                      size: 46,
                      color: AppColors.primaryLight,
                    ),
                  ),
                ),
                const SizedBox(height: 28),

                // Title
                const Text(
                  'Verify your email',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 12),

                // Subtitle
                Text(
                  'We sent a verification link to:',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 14.5,
                  ),
                ),
                const SizedBox(height: 6),

                // Email pill
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFF334155)),
                  ),
                  child: Text(
                    effectiveEmail,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                Text(
                  'Click the link in the email to finish creating your account. Once verified, tap the button below.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: const Color(0xFF94A3B8),
                    fontSize: 13.5,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 36),

                // Primary Button: "I've Verified My Email"
                GradientButton(
                  text: "I've Verified My Email",
                  isLoading: _isChecking,
                  onPressed: _checkVerificationStatus,
                ),
                const SizedBox(height: 16),

                // Secondary Action: Resend with cooldown
                TextButton.icon(
                  onPressed:
                      (_resendCooldown > 0 || _isResending) ? null : _resendVerificationEmail,
                  icon: _isResending
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.primaryLight,
                          ),
                        )
                      : Icon(
                          Icons.refresh_rounded,
                          size: 18,
                          color: _resendCooldown > 0
                              ? const Color(0xFF64748B)
                              : AppColors.primaryLight,
                        ),
                  label: Text(
                    _resendCooldown > 0
                        ? 'Resend email in ${_resendCooldown}s'
                        : 'Resend Verification Email',
                    style: TextStyle(
                      color: _resendCooldown > 0
                          ? const Color(0xFF64748B)
                          : AppColors.primaryLight,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Switch / Sign out option
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Wrong email? ',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.6),
                        fontSize: 13.5,
                      ),
                    ),
                    GestureDetector(
                      onTap: _signOutAndSwitchAccount,
                      child: const Text(
                        'Sign in with another account',
                        style: TextStyle(
                          color: AppColors.primaryLight,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
