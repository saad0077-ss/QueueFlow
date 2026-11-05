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

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 620;
        return Container(
          height: 64,
          padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 20),
          decoration: BoxDecoration(
            color: colors.surface,
            border: Border(bottom: BorderSide(color: colors.border, width: 1)),
          ),
          child: Row(
            children: [
              if (onMenuPressed != null) ...[
                IconButton(
                  icon: Icon(Icons.menu_rounded, color: colors.textPrimary, size: 22),
                  onPressed: onMenuPressed,
                  tooltip: 'Open navigation',
                ),
                const SizedBox(width: 4),
              ],
              SizedBox(
                width: isMobile ? 180 : 260,
                height: 40,
                child: Container(
                  decoration: BoxDecoration(
                    color: colors.surfaceSecondary,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: colors.border),
                  ),
                  child: TextField(
                    onChanged: onSearch,
                    style: GoogleFonts.inter(color: colors.textPrimary, fontSize: 13),
                    decoration: InputDecoration(
                      hintText: isMobile ? 'Search...' : 'Search patients, appointments...',
                      hintStyle: GoogleFonts.inter(color: colors.textMuted, fontSize: 13),
                      prefixIcon: Icon(Icons.search_rounded, color: colors.textMuted, size: 18),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // Theme Toggle Button (placed next to search input)
              const ThemeModeToggleButton(),

              const Spacer(),

              IconButton(
                icon: Icon(Icons.notifications_none_rounded, color: colors.textMuted, size: 20),
                onPressed: () {},
              ),
              const SizedBox(width: 6),
              CircleAvatar(
                radius: 15,
                backgroundColor: colors.primary,
                child: const Text('MS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
              if (!isMobile) ...[
                const SizedBox(width: 8),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Muhammed Saad', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: colors.textPrimary)),
                    Text('Platform Admin', style: GoogleFonts.inter(fontSize: 10, color: colors.textMuted)),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
