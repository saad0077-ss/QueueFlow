import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

class ConsoleTopBar extends StatelessWidget {
  final ValueChanged<String>? onSearch;
  final VoidCallback? onMenuPressed;

  const ConsoleTopBar({super.key, this.onSearch, this.onMenuPressed});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isLight = Theme.of(context).brightness == Brightness.light;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 620;
        final radius = BorderRadius.circular(10);
        OutlineInputBorder outline(Color c, [double w = 1]) =>
            OutlineInputBorder(
              borderRadius: radius,
              borderSide: BorderSide(color: c, width: w),
            );

        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 12 : 24,
            vertical: isMobile ? 10 : 14,
          ),
          decoration: BoxDecoration(
            color: colors.surface,
            border: Border(bottom: BorderSide(color: colors.border, width: 1)),
          ),
          child: Row(
            children: [
              if (onMenuPressed != null) ...[
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: colors.surfaceSecondary,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: colors.border),
                  ),
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    tooltip: 'Menu',
                    icon: Icon(
                      Icons.menu_rounded,
                      color: colors.textPrimary,
                      size: 20,
                    ),
                    onPressed: onMenuPressed,
                  ),
                ),
                SizedBox(width: isMobile ? 8 : 14),
              ],
              SizedBox(
                width: isMobile ? 180 : 260,
                height: 40,
                child: TextField(
                  onChanged: onSearch,
                  cursorColor: colors.primary,
                  textAlignVertical: TextAlignVertical.center,
                  style: GoogleFonts.inter(
                    fontSize: 13.5,
                    color: colors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    isDense: true,
                    filled: true,
                    fillColor: colors.surfaceSecondary,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                    hintText: isMobile
                        ? 'Search...'
                        : 'Search clinics, doctors...',
                    hintStyle: GoogleFonts.inter(
                      fontSize: 13.5,
                      color: colors.textMuted,
                    ),
                    prefixIcon: Icon(
                      Icons.search_rounded,
                      color: colors.textMuted,
                      size: 19,
                    ),
                    prefixIconConstraints: const BoxConstraints(
                      minWidth: 40,
                      minHeight: 40,
                    ),
                    border: outline(colors.border),
                    enabledBorder: outline(colors.border),
                    focusedBorder: outline(colors.primary, 1.5),
                  ),
                ),
              ),
              const Spacer(),
              const ThemeModeToggleButton(),
              SizedBox(width: isMobile ? 4 : 8),
              IconButton(
                tooltip: 'Notifications',
                icon: Icon(
                  Icons.notifications_none_rounded,
                  color: colors.textMuted,
                  size: 22,
                ),
                onPressed: () {},
              ),
              SizedBox(width: isMobile ? 4 : 8),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isLight)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.asset(
                          'assets/icons/app_logo.png',
                          width: 36,
                          height: 36,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(
                                Icons.admin_panel_settings_rounded,
                                color: Color(0xFF2563EB),
                                size: 20,
                              ),
                        ),
                      )
                    else
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          gradient: const LinearGradient(
                            colors: [Color(0xFF0072FF), Color(0xFF00C6FF)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF00C6FF)
                                  .withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Image.asset(
                          'assets/icons/app_icon_128.png',
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(
                                Icons.admin_panel_settings_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                        ),
                      ),
                    if (!isMobile) ...[
                      const SizedBox(width: 10),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Queueflow admin',
                            style: GoogleFonts.inter(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                              color: colors.textPrimary,
                            ),
                          ),
                          Text(
                            'Platform Admin',
                            style: GoogleFonts.inter(
                              fontSize: 11.5,
                              color: colors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
