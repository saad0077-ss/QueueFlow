import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_snack_bar.dart';
import '../../../../core/widgets/auth_back_header.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/gradient_button.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';

class ForgotPasswordScreen extends StatefulWidget {
  final String? initialEmail;
  final AuthRepository? authRepository;

  const ForgotPasswordScreen({
    super.key,
    this.initialEmail,
    this.authRepository,
  });

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  late final TextEditingController _emailController;
  late final AuthRepository _authRepository;

  bool _isLoading = false;
  bool _isEmailSent = false;
  String _sentEmail = '';
  String? _emailError;

  int _resendCooldown = 0;
  Timer? _cooldownTimer;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.initialEmail ?? '');
    _authRepository = widget.authRepository ?? AuthRepositoryImpl();
  }

  @override
  void dispose() {
    _emailController.dispose();
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

  Future<void> _handleSendResetLink() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      setState(() => _emailError = 'Please enter your email address.');
      AppSnackBar.showWarning(
        context,
        title: 'Email Required',
        message: 'Please enter your email address to receive the reset link.',
      );
      return;
    }

    if (!email.contains('@') || !email.contains('.')) {
      setState(() => _emailError = 'Please enter a valid email address.');
      AppSnackBar.showWarning(
        context,
        title: 'Invalid Email',
        message: 'Please enter a valid email address.',
      );
      return;
    }

    setState(() {
      _emailError = null;
      _isLoading = true;
    });

    try {
      await _authRepository.sendPasswordResetEmail(email);
      if (!mounted) return;

      setState(() {
        _isEmailSent = true;
        _sentEmail = email;
      });
      _startCooldown(60);

      AppSnackBar.showSuccess(
        context,
        title: 'Reset Link Sent',
        message: 'A password reset link has been sent to $email.',
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      String message = 'Failed to send password reset email.';
      if (e.code == 'user-not-found') {
        message = 'No account found with this email address.';
      } else if (e.code == 'invalid-email') {
        message = 'The email address format is invalid.';
      } else if (e.code == 'too-many-requests') {
        message = 'Too many attempts. Please try again in a few minutes.';
      } else if (e.message != null && e.message!.isNotEmpty) {
        message = e.message!;
      }
      AppSnackBar.showError(context, message: message);
    } catch (e) {
      if (!mounted) return;
      AppSnackBar.showError(
        context,
        message: 'Something went wrong. Please check your internet connection.',
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleResend() async {
    if (_resendCooldown > 0 || _isLoading) return;
    await _handleSendResetLink();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final double screenWidth = constraints.maxWidth;
            final double scale = (screenWidth / 390.0).clamp(0.85, 1.15);
            final double titleSize = (28.0 * scale).clamp(23.0, 32.0);
            final double subtitleSize = (14.0 * scale).clamp(12.5, 16.0);

            return Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: 440,
                  minHeight: constraints.maxHeight,
                ),
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight - 32,
                    ),
                    child: _isEmailSent
                        ? _buildSuccessView(titleSize, subtitleSize)
                        : _buildFormView(titleSize, subtitleSize),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildFormView(double titleSize, double subtitleSize) {
    return IntrinsicHeight(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AuthBackHeader(),
          const SizedBox(height: 32),

          // Title
          Text(
            'Forgot password?',
            style: TextStyle(
              color: AppColors.textWhite,
              fontSize: titleSize,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 10),

          // Subtitle
          Text(
            'Enter your registered email address and we will send you a link to reset your password.',
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: subtitleSize,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 28),

          // Email Field placed directly under the texts
          CustomTextField(
            label: 'Email address',
            hintText: 'you@example.com',
            controller: _emailController,
            prefixIcon: Icons.mail_outline_rounded,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            autofillHints: const [AutofillHints.email],
            helperText: 'We will send a password reset link to this address.',
            errorText: _emailError,
            onChanged: (val) {
              if (_emailError != null) {
                setState(() => _emailError = null);
              }
            },
            onFieldSubmitted: (_) => _handleSendResetLink(),
          ),

          const Spacer(),

          // Bottom Action
          GradientButton(
            text: 'Send Reset Link',
            isLoading: _isLoading,
            onPressed: _handleSendResetLink,
          ),
          const SizedBox(height: 18),

          Center(
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: RichText(
                text: const TextSpan(
                  text: 'Remember your password? ',
                  style: TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 13.5,
                  ),
                  children: [
                    TextSpan(
                      text: 'Sign in',
                      style: TextStyle(
                        color: Color(0xFF38BDF8),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildSuccessView(double titleSize, double subtitleSize) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 16),
        // Mail Sent Icon Card
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
              Icons.mark_email_read_rounded,
              size: 46,
              color: AppColors.primaryLight,
            ),
          ),
        ),
        const SizedBox(height: 28),

        // Title
        const Text(
          'Password reset link sent',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: 25,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 12),

        // Subtitle
        Text(
          'We have sent a password reset link to:',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: 14.5,
          ),
        ),
        const SizedBox(height: 8),

        // Email pill
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFF334155)),
          ),
          child: Text(
            _sentEmail,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 18),

        const Text(
          'Please open your email client and follow the instructions to set up a new password.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xFF94A3B8),
            fontSize: 13.5,
            height: 1.45,
          ),
        ),
        const SizedBox(height: 32),

        // Primary Button: Back to Sign In
        GradientButton(
          text: 'Back to Sign In',
          onPressed: () => Navigator.of(context).pop(),
        ),
        const SizedBox(height: 16),

        // Resend option
        TextButton.icon(
          onPressed: (_resendCooldown > 0 || _isLoading) ? null : _handleResend,
          icon: _isLoading
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
                : 'Resend reset email',
            style: TextStyle(
              color: _resendCooldown > 0
                  ? const Color(0xFF64748B)
                  : AppColors.primaryLight,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Switch email
        GestureDetector(
          onTap: () {
            setState(() {
              _isEmailSent = false;
            });
          },
          child: const Text(
            'Use a different email address',
            style: TextStyle(
              color: AppColors.primaryLight,
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
