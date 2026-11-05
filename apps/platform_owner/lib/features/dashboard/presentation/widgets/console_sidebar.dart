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
      width: 230,
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(right: BorderSide(color: colors.border, width: 1)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 20),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                clipBehavior: Clip.antiAlias,
                child: Image.asset('assets/icons/app_icon_128.png', fit: BoxFit.contain),
              ),
              const SizedBox(width: 10),
              Text('QueueFlow', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: colors.textPrimary)),
            ],
          ),
          const SizedBox(height: 28),
          Expanded(
            child: ListView.separated(
              itemCount: items.length,
              separatorBuilder: (_, _) => const SizedBox(height: 4),
              itemBuilder: (context, i) {
                final it = items[i];
                final sel = i == activeIndex;
                return InkWell(
                  onTap: () => onIndexChanged?.call(i),
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      gradient: sel ? const LinearGradient(colors: [Color(0xFF2563EB), Color(0xFF06B6D4)]) : null,
                    ),
                    child: Row(
                      children: [
                        Icon(it['icon'] as IconData, size: 18, color: sel ? Colors.white : colors.textMuted),
                        const SizedBox(width: 10),
                        Text(
                          it['label'] as String,
                          style: GoogleFonts.inter(fontSize: 13, fontWeight: sel ? FontWeight.w600 : FontWeight.w500, color: sel ? Colors.white : colors.textMuted),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: colors.surfaceSecondary,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: colors.border),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: colors.primary,
                  child: const Text('MS', style: TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Muhammed Saad', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: colors.textPrimary), overflow: TextOverflow.ellipsis),
                    Text('Platform Owner', style: GoogleFonts.inter(fontSize: 10, color: colors.textMuted)),
                  ]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
