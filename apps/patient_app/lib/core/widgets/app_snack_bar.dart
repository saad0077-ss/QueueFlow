import 'package:flutter/material.dart';

/// Semantic types of feedback for [AppSnackBar].
enum SnackBarType {
  success,
  error,
  warning,
  info,
}

/// QueueFlow Design System SnackBar
/// Provides styled, floating pill feedback notifications with gradient backgrounds.
class AppSnackBar {
  /// Displays a Success SnackBar with blue-to-cyan gradient branding and checkmark icon.
  static void showSuccess(
    BuildContext context, {
    required String message,
    String? title,
    Duration duration = const Duration(milliseconds: 3500),
    VoidCallback? onDismiss,
  }) {
    _show(
      context,
      type: SnackBarType.success,
      message: message,
      title: title,
      duration: duration,
      onDismiss: onDismiss,
    );
  }

  /// Displays an Error SnackBar with red-to-rose gradient branding and alert icon.
  static void showError(
    BuildContext context, {
    required String message,
    String? title,
    Duration duration = const Duration(milliseconds: 4000),
    VoidCallback? onDismiss,
  }) {
    _show(
      context,
      type: SnackBarType.error,
      message: _cleanErrorMessage(message),
      title: title ?? 'Error',
      duration: duration,
      onDismiss: onDismiss,
    );
  }

  /// Displays a Warning SnackBar with amber gradient branding and warning icon.
  static void showWarning(
    BuildContext context, {
    required String message,
    String? title,
    Duration duration = const Duration(milliseconds: 3500),
    VoidCallback? onDismiss,
  }) {
    _show(
      context,
      type: SnackBarType.warning,
      message: message,
      title: title ?? 'Warning',
      duration: duration,
      onDismiss: onDismiss,
    );
  }

  /// Displays an Info SnackBar with brand blue gradient branding and info icon.
  static void showInfo(
    BuildContext context, {
    required String message,
    String? title,
    Duration duration = const Duration(milliseconds: 3500),
    VoidCallback? onDismiss,
  }) {
    _show(
      context,
      type: SnackBarType.info,
      message: message,
      title: title ?? 'Notice',
      duration: duration,
      onDismiss: onDismiss,
    );
  }

  /// Core helper to build and present the floating SnackBar.
  static void _show(
    BuildContext context, {
    required SnackBarType type,
    required String message,
    String? title,
    required Duration duration,
    VoidCallback? onDismiss,
  }) {
    if (!context.mounted) return;

    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;

    messenger.hideCurrentSnackBar();

    final snackBar = buildSnackBar(
      context: context,
      type: type,
      message: message,
      title: title,
      duration: duration,
      onDismiss: onDismiss,
    );

    messenger.showSnackBar(snackBar);
  }

  /// Builds the [SnackBar] widget directly.
  static SnackBar buildSnackBar({
    required BuildContext context,
    required SnackBarType type,
    required String message,
    String? title,
    Duration duration = const Duration(milliseconds: 3500),
    VoidCallback? onDismiss,
  }) {
    final style = _getStyle(type);
    final hasTitle = title != null && title.isNotEmpty;

    return SnackBar(
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      elevation: 0,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      padding: EdgeInsets.zero,
      duration: duration,
      content: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          if (onDismiss != null) onDismiss();
        },
        child: Container(
          constraints: const BoxConstraints(maxWidth: 520),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            gradient: style.gradient,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.18),
              width: 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.35),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
              BoxShadow(
                color: style.glowColor.withValues(alpha: 0.3),
                blurRadius: 14,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Circular badge with white translucent background
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration( 
                  color: Colors.white.withValues(alpha: 0.22),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    style.icon,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Text (Title + Message or single clean line)
              Expanded(
                child: hasTitle
                    ? Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                              letterSpacing: -0.2,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            message,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.95),
                              fontWeight: FontWeight.w500,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      )
                    : Text(
                        message,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 14.5,
                          letterSpacing: -0.2,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static _SnackBarConfig _getStyle(SnackBarType type) {
    switch (type) {
      case SnackBarType.success:
        return const _SnackBarConfig(
          gradient: LinearGradient(
            colors: [Color(0xFF2563EB), Color(0xFF06B6D4)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          glowColor: Color(0xFF06B6D4),
          icon: Icons.check_circle_rounded,
        );
      case SnackBarType.error:
        return const _SnackBarConfig(
          gradient: LinearGradient(
            colors: [Color(0xFFDC2626), Color(0xFFF43F5E)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          glowColor: Color(0xFFDC2626),
          icon: Icons.error_rounded,
        );
      case SnackBarType.warning:
        return const _SnackBarConfig(
          gradient: LinearGradient(
            colors: [Color(0xFFD97706), Color(0xFFF59E0B)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          glowColor: Color(0xFFF59E0B),
          icon: Icons.warning_amber_rounded,
        );
      case SnackBarType.info:
        return const _SnackBarConfig(
          gradient: LinearGradient(
            colors: [Color(0xFF2563EB), Color(0xFF38BDF8)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          glowColor: Color(0xFF2563EB),
          icon: Icons.info_outline_rounded,
        );
    }
  }

  /// Sanitizes raw Firebase/network exception messages into human-friendly messages.
  static String _cleanErrorMessage(String raw) {
    final lower = raw.toLowerCase();

    if (lower.contains('user-not-found')) {
      return 'No account exists with this email. Please sign up first.';
    }
    if (lower.contains('wrong-password') || lower.contains('invalid-credential')) {
      return 'Invalid email or password. Please check your credentials.';
    }
    if (lower.contains('email-already-in-use')) {
      return 'An account already exists with this email address.';
    }
    if (lower.contains('weak-password')) {
      return 'Password is too weak. Please choose a stronger password.';
    }
    if (lower.contains('invalid-email')) {
      return 'Please enter a valid email address.';
    }
    if (lower.contains('network-request-failed')) {
      return 'Network connection error. Please check your internet connection.';
    }
    if (lower.contains('too-many-requests')) {
      return 'Too many attempts. Please try again in a few moments.';
    }
    if (lower.contains('sign_in_canceled') || lower.contains('cancelled') || lower.contains('canceled')) {
      return 'Sign in was cancelled.';
    }

    // Strip "Exception: " prefix if present
    String cleaned = raw;
    if (cleaned.startsWith('Exception: ')) {
      cleaned = cleaned.substring('Exception: '.length);
    }

    // Strip [code] prefixes
    final bracketRegex = RegExp(r'^\[.*?\]\s*');
    cleaned = cleaned.replaceFirst(bracketRegex, '');

    return cleaned.trim().isEmpty ? 'An unexpected error occurred.' : cleaned.trim();
  }
}

class _SnackBarConfig {
  final LinearGradient gradient;
  final Color glowColor;
  final IconData icon;

  const _SnackBarConfig({
    required this.gradient,
    required this.glowColor,
    required this.icon,
  });
}
