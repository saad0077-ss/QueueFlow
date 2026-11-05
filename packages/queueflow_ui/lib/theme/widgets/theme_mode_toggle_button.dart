import 'package:flutter/material.dart';
import 'theme_wave_scope.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../app_colors_extension.dart';
import '../bloc/theme_bloc.dart';
import '../bloc/theme_event.dart';
import '../bloc/theme_state.dart';

class ThemeModeToggleButton extends StatelessWidget {
  final double size;

  const ThemeModeToggleButton({
    super.key,
    this.size = 38,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, state) {
        final isDark = state.isDark;
        final tooltip = isDark ? 'Switch to Light Mode' : 'Switch to Dark Mode';

        return Tooltip(
          message: tooltip,
          child: InkWell(
            onTap: () {
              final box = context.findRenderObject() as RenderBox;
              final origin = box.localToGlobal(box.size.center(Offset.zero));
              final bloc = context.read<ThemeBloc>();
              ThemeWaveScope.run(
                context,
                origin: origin, 
                applyTheme: () => bloc.add(const ThemeToggleRequested()),
              );
            },
            borderRadius: BorderRadius.circular(10),
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: context.colors.surfaceSecondary,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: context.colors.border, width: 1),
              ),
              alignment: Alignment.center,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                transitionBuilder: (child, anim) => RotationTransition(
                  turns: anim,
                  child: FadeTransition(opacity: anim, child: child),
                ),
                child: Icon(
                  isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                  key: ValueKey<bool>(isDark),
                  size: 19,
                  color: isDark ? const Color(0xFFF59E0B) : const Color(0xFF6366F1),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
