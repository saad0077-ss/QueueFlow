import 'package:flutter/material.dart';

enum SnackBarType { success, error, warning, info }

/// Compact bottom-right corner gradient toast for Clinic Admin Portal.
class AppSnackBar {
  static void showSuccess(BuildContext context, {required String message}) {
    _show(context, type: SnackBarType.success, message: message);
  }

  static void showError(BuildContext context, {required String message}) {
    _show(
      context,
      type: SnackBarType.error,
      message: message.contains('] ') ? message.split('] ').last.trim() : message,
    );
  }

  static void showInfo(BuildContext context, {required String message}) {
    _show(context, type: SnackBarType.info, message: message);
  }

  static void _show(
    BuildContext context, {
    required SnackBarType type,
    required String message,
  }) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();

    final colors = _colorsFor(type);
    final icon = _iconFor(type);
    final screenWidth = MediaQuery.sizeOf(context).width;
    const double toastWidth = 230;
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
              gradient: LinearGradient(colors: colors),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: colors.first.withValues(alpha: 0.32),
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
                  child: Icon(icon, color: Colors.white, size: 11),
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
        margin: EdgeInsets.only(left: leftMargin, right: 24, bottom: 20),
        duration: const Duration(milliseconds: 3000),
      ),
    );
  }

  static List<Color> _colorsFor(SnackBarType type) {
    switch (type) {
      case SnackBarType.success:
        return const [Color(0xFF2563EB), Color(0xFF2DD4BF)];
      case SnackBarType.error:
        return const [Color(0xFFDC2626), Color(0xFFF43F5E)];
      case SnackBarType.warning:
        return const [Color(0xFFD97706), Color(0xFFF59E0B)];
      case SnackBarType.info:
        return const [Color(0xFF2563EB), Color(0xFF06B6D4)];
    }
  }

  static IconData _iconFor(SnackBarType type) {
    switch (type) {
      case SnackBarType.success:
        return Icons.check_rounded;
      case SnackBarType.error:
        return Icons.close_rounded;
      case SnackBarType.warning:
        return Icons.priority_high_rounded;
      case SnackBarType.info:
        return Icons.info_outline_rounded;
    }
  }
}
