import 'package:flutter/material.dart';

class AppFilterDialogScaffold extends StatelessWidget {
  final Widget header;
  final Widget body;
  final Widget footer;
  final double maxWidth;
  final double maxHeight;

  const AppFilterDialogScaffold({
    super.key,
    required this.header,
    required this.body,
    required this.footer,
    this.maxWidth = 580,
    this.maxHeight = 700,
  });

  static Future<T?> show<T>(
    BuildContext context, {
    required WidgetBuilder builder,
    bool barrierDismissible = true,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierColor: Colors.black.withValues(alpha: 0.65),
      builder: builder,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        width: maxWidth,
        constraints: BoxConstraints(maxHeight: maxHeight),
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF1E293B)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              blurRadius: 28,
              offset: const Offset(0, 14),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            header,
            const Divider(height: 1, color: Color(0xFF1E293B)),
            Flexible(child: body),
            const Divider(height: 1, color: Color(0xFF1E293B)),
            footer,
          ],
        ),
      ),
    );
  }
}
