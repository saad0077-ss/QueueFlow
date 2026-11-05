import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:queueflow_ui/queueflow_ui.dart';
import '../../../../core/widgets/app_snack_bar.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../widgets/forgot_password_form_view.dart';
import '../widgets/forgot_password_success_view.dart';

class ForgotPasswordScreen extends StatefulWidget {
  final String? initialEmail;
  final AuthRepository? authRepository;

  const ForgotPasswordScreen({super.key, this.initialEmail, this.authRepository});

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
      if (!mounted) return timer.cancel();
      if (_resendCooldown <= 1) {
        timer.cancel();
        setState(() => _resendCooldown = 0);
      } else {
        setState(() => _resendCooldown--);
      }
    });
  }

  String _firebaseErrorMessage(FirebaseAuthException e) {
    return switch (e.code) {
      'user-not-found' => 'No account found with this email address.',
      'invalid-email' => 'The email address format is invalid.',
      'too-many-requests' => 'Too many attempts. Please try again in a few minutes.',
      _ => e.message?.isNotEmpty == true ? e.message! : 'Failed to send password reset email.',
    };
  }

  Future<void> _handleSendResetLink() async {
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@') || !email.contains('.')) {
      setState(() => _emailError = 'Please enter a valid email address.');
      AppSnackBar.showWarning(context, title: 'Invalid Email', message: 'Please enter a valid email address.');
      return;
    }

    setState(() { _emailError = null; _isLoading = true; });
    try {
      await _authRepository.sendPasswordResetEmail(email);
      if (!mounted) return;
      setState(() { _isEmailSent = true; _sentEmail = email; });
      _startCooldown(60);
      AppSnackBar.showSuccess(context, title: 'Reset Link Sent', message: 'A password reset link has been sent to $email.');
    } on FirebaseAuthException catch (e) {
      if (mounted) AppSnackBar.showError(context, message: _firebaseErrorMessage(e));
    } catch (_) {
      if (mounted) AppSnackBar.showError(context, message: 'Something went wrong. Please check your internet connection.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final scale = (constraints.maxWidth / 390.0).clamp(0.85, 1.15);
            return Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 440, minHeight: constraints.maxHeight),
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight - 32),
                    child: _isEmailSent
                        ? ForgotPasswordSuccessView(
                            sentEmail: _sentEmail,
                            scale: scale,
                            resendCooldown: _resendCooldown,
                            onResend: _handleSendResetLink,
                          )
                        : ForgotPasswordFormView(
                            controller: _emailController,
                            errorText: _emailError,
                            isLoading: _isLoading,
                            scale: scale,
                            onSubmit: _handleSendResetLink,
                          ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
