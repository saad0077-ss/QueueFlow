import 'package:flutter/material.dart';

enum SnackBarType { success, error, warning, info }

class AppSnackBar {
  static void showSuccess(BuildContext context, {required String message}) {
    _show(context, SnackBarType.success, message);
  }

  static void showError(BuildContext context, {required String message}) {
    _show(
      context,
      SnackBarType.error,
      message.contains('] ') ? message.split('] ').last.trim() : message,
    );
  }

  static void showWarning(BuildContext context, {required String message}) {
    _show(context, SnackBarType.warning, message);
  }

  static void showInfo(BuildContext context, {required String message}) {
    _show(context, SnackBarType.info, message);
  }

  static void _show(
    BuildContext context,
    SnackBarType type,
    String message,
  ) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();

    final colors = _colors(type);
    final icon = _icon(type);
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isDesktop = screenWidth >= 768;

    messenger.showSnackBar(
      SnackBar(
        content: Align(
          alignment: isDesktop ? Alignment.bottomRight : Alignment.bottomCenter,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => messenger.hideCurrentSnackBar(),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                constraints: BoxConstraints(
                  minWidth: 160,
                  maxWidth: (screenWidth - 48).clamp(260.0, 560.0),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: colors),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: colors.first.withValues(alpha: 0.38),
                      blurRadius: 16,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.25),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Icon(icon, color: Colors.white, size: 13),
                    ),
                    const SizedBox(width: 10),
                    Flexible(
                      child: Text(
                        message,
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          letterSpacing: 0.15,
                          height: 1.25,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        padding: EdgeInsets.zero,
        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        duration: const Duration(milliseconds: 3200),
      ),
    );
  }

  static List<Color> _colors(SnackBarType type) {
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

  static IconData _icon(SnackBarType type) {
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
