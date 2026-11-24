import 'package:flutter/material.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

import '../../features/onboarding/presentation/pages/welcome_screen.dart';
import 'app_logo.dart';

/// Clean inline auth header showing rounded back button and QueueFlow logo.
class AuthBackHeader extends StatelessWidget {
  final VoidCallback? onBack;

  const AuthBackHeader({super.key, this.onBack});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colors.border, width: 1.2),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: onBack ??
                  () {
                    if (Navigator.of(context).canPop()) {
                      Navigator.of(context).pop();
                    } else {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (_) => const WelcomeScreen(),
                        ),
                      );
                    }
                  },
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.only(left: 4.0),
                  child: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 16,
                    color: colors.textPrimary,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 14),
        const AppLogo(fontSize: 20),
      ],
    );
  }
}
