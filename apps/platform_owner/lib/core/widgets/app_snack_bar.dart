import 'package:flutter/material.dart';

/// Semantic types of feedback for [AppSnackBar].
enum SnackBarType {
  success,
  error,
  warning,
  info,
}

/// QueueFlow Design System Compact Corner Toast / SnackBar
/// Renders a small, responsive single-line pill notification in the bottom-right corner.
class AppSnackBar {
  static void showSuccess(
    BuildContext context, {
    required String message,
    String? title,
    Duration duration = const Duration(milliseconds: 2800),
  }) {
    _show(
      context,
      type: SnackBarType.success,
      message: message,
      duration: duration,
    );
  }

  static void showError(
    BuildContext context, {
    required String message,
    String? title,
    Duration duration = const Duration(milliseconds: 3200),
  }) {
    _show(
      context,
      type: SnackBarType.error,
      message: _cleanErrorMessage(message),
      duration: duration,
    );
  }

  static void showWarning(
    BuildContext context, {
    required String message,
    String? title,
    Duration duration = const Duration(milliseconds: 2800),
  }) {
    _show(
      context,
      type: SnackBarType.warning,
      message: message,
      duration: duration,
    );
  }

  static void showInfo(
    BuildContext context, {
    required String message,
    String? title,
    Duration duration = const Duration(milliseconds: 2800),
  }) {
    _show(
      context,
      type: SnackBarType.info,
      message: message,
      duration: duration,
    );
  }

  static void _show(
    BuildContext context, {
    required SnackBarType type,
    required String message,
    required Duration duration,
  }) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();

    final config = _getThemeConfig(type);
    final screenWidth = MediaQuery.sizeOf(context).width;
    const double toastWidth = 220;
    final double leftMargin =
        (screenWidth - toastWidth - 24).clamp(16.0, double.infinity);

    messenger.showSnackBar(
      SnackBar(
        content: InkWell(
          onTap: () => messenger.hideCurrentSnackBar(),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: config.gradientColors,
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: config.gradientColors.first.withValues(alpha: 0.32),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.24),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    config.icon,
                    color: Colors.white,
                    size: 11,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      message,
                      maxLines: 1,
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        letterSpacing: 0.1,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        padding: EdgeInsets.zero,
        margin: EdgeInsets.only(
          left: leftMargin,
          right: 24,
          bottom: 20,
        ),
        duration: duration,
      ),
    );
  }

  static _SnackBarThemeConfig _getThemeConfig(SnackBarType type) {
    switch (type) {
      case SnackBarType.success:
        return const _SnackBarThemeConfig(
          gradientColors: [Color(0xFF2563EB), Color(0xFF2DD4BF)],
          icon: Icons.check_rounded,
        );
      case SnackBarType.error:
        return const _SnackBarThemeConfig(
          gradientColors: [Color(0xFFDC2626), Color(0xFFF43F5E)],
          icon: Icons.close_rounded,
        );
      case SnackBarType.warning:
        return const _SnackBarThemeConfig(
          gradientColors: [Color(0xFFD97706), Color(0xFFF59E0B)],
          icon: Icons.priority_high_rounded,
        );
      case SnackBarType.info:
        return const _SnackBarThemeConfig(
          gradientColors: [Color(0xFF2563EB), Color(0xFF06B6D4)],
          icon: Icons.info_outline_rounded,
        );
    }
  }

  static String _cleanErrorMessage(String message) {
    if (message.contains('] ')) {
      return message.split('] ').last.trim();
    }
    return message;
  }
}

class _SnackBarThemeConfig {
  final List<Color> gradientColors;
  final IconData icon;

  const _SnackBarThemeConfig({
    required this.gradientColors,
    required this.icon,
  });
}
