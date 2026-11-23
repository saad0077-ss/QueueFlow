import 'package:flutter/material.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

import 'sidebar/console_sidebar_header.dart';
import 'sidebar/console_sidebar_item_tile.dart';
import 'sidebar/console_sidebar_sign_out_button.dart';

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
      {'icon': Icons.receipt_long_outlined, 'label': 'Plan & Billing'},
      {'icon': Icons.trending_up_rounded, 'label': 'Revenue'},
      {'icon': Icons.bar_chart_rounded, 'label': 'Platform Reports'},
      {'icon': Icons.help_outline_rounded, 'label': 'Support Tickets'},
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
          const ConsoleSidebarHeader(),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              itemCount: items.length,
              separatorBuilder: (_, _) => const SizedBox(height: 4),
              itemBuilder: (context, i) {
                return ConsoleSidebarItemTile(
                  item: items[i],
                  isSelected: i == activeIndex,
                  onTap: () => onIndexChanged?.call(i),
                );
              },
            ),
          ),
          const ConsoleSidebarSignOutButton(),
        ],
      ),
    );
  }
}
