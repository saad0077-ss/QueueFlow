import 'package:flutter/material.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

import '../../features/onboarding/presentation/pages/welcome_screen.dart';
import 'app_logo.dart';

/// Clean Auth App Bar showing rounded back chevron button and QueueFlow logo.
/// Matches user design specifications with zero extraneous buttons or toggles.
class AuthAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback? onBack;

  const AuthAppBar({super.key, this.onBack});

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return AppBar(
      backgroundColor: colors.background,
      elevation: 0,
      scrolledUnderElevation: 0,
      automaticallyImplyLeading: false,
      toolbarHeight: 64,
      leadingWidth: 56,
      centerTitle: false,
      leading: Padding(
        padding: const EdgeInsets.only(left: 16.0, top: 12.0, bottom: 12.0),
        child: Container(
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
      ),
      titleSpacing: 8,
      title: const AppLogo(fontSize: 20),
    );
  }
}
