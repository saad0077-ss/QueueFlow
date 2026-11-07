import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

class ConsoleSidebar extends StatelessWidget {
  final int activeIndex;
  final ValueChanged<int>? onIndexChanged;

  const ConsoleSidebar({super.key, this.activeIndex = 0, this.onIndexChanged});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isLight = Theme.of(context).brightness == Brightness.light;

    const items = [
      {'icon': Icons.grid_view_rounded, 'label': 'Clinics'},
      {'icon': Icons.layers_outlined, 'label': 'Departments'},
      {'icon': Icons.people_outline_rounded, 'label': 'Users'},
      {'icon': Icons.help_outline_rounded, 'label': 'Support Tickets'},
      {'icon': Icons.receipt_long_outlined, 'label': 'Plan & Billing'},
      {'icon': Icons.bar_chart_rounded, 'label': 'Platform Reports'},
      {'icon': Icons.admin_panel_settings_outlined, 'label': 'Admins'},
      {'icon': Icons.settings_outlined, 'label': 'Settings'},
    ];

    return Container(
      width: 240,
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(right: BorderSide(color: colors.border, width: 1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 28, 20, 28),
            child: Row(
              children: [
                if (isLight)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset(
                      'assets/icons/app_logo.png',
                      width: 34,
                      height: 34,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Icon(Icons.bubble_chart_rounded, color: colors.primary, size: 24),
                    ),
                  )
                else
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF0072FF), Color(0xFF00C6FF)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [BoxShadow(color: const Color(0xFF00C6FF).withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 3))],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Image.asset('assets/icons/app_icon_128.png', fit: BoxFit.contain),
                  ),
                const SizedBox(width: 12),
                RichText(
                  text: TextSpan(
                    style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: -0.4),
                    children: [
                      TextSpan(text: 'Queue', style: TextStyle(color: colors.textPrimary)),
                      TextSpan(text: 'Flow', style: TextStyle(color: colors.primaryLight)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              itemCount: items.length,
              separatorBuilder: (_, _) => const SizedBox(height: 4),
              itemBuilder: (context, i) {
                final it = items[i];
                final sel = i == activeIndex;
                return InkWell(
                  onTap: () => onIndexChanged?.call(i),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: sel
                          ? const LinearGradient(
                              colors: [Color(0xFF0284C7), Color(0xFF00D2FF)],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            )
                          : null,
                      boxShadow: sel
                          ? [BoxShadow(color: const Color(0xFF0284C7).withValues(alpha: 0.35), blurRadius: 12, offset: const Offset(0, 4))]
                          : null,
                    ),
                    child: Row(
                      children: [
                        Icon(it['icon'] as IconData, size: 20, color: sel ? Colors.white : colors.textMuted),
                        const SizedBox(width: 14),
                        Flexible(
                          child: Text(
                            it['label'] as String,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                              fontSize: 13.5,
                              fontWeight: sel ? FontWeight.w600 : FontWeight.w400,
                              color: sel ? Colors.white : colors.textMuted,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
