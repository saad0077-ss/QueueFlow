import 'package:flutter/material.dart';
import 'clinic_sidebar_logo.dart';
import 'clinic_sidebar_nav_item.dart';

/// Navigation sidebar on the left side of the Clinic Admin portal.
class ClinicSidebar extends StatelessWidget {
  final String activeItem;
  final ValueChanged<String>? onItemTap;

  const ClinicSidebar({
    super.key,
    this.activeItem = 'Dashboard',
    this.onItemTap,
  });

  static const List<Map<String, dynamic>> _navItems = [
    {'title': 'Dashboard', 'icon': Icons.grid_view_rounded},
    {'title': 'Live Queue', 'icon': Icons.confirmation_number_outlined},
    {'title': 'Appointments', 'icon': Icons.calendar_month_outlined},
    {'title': 'Services', 'icon': Icons.medical_services_outlined},
    {'title': 'Doctors', 'icon': Icons.people_outline_rounded},
    {'title': 'Reports', 'icon': Icons.bar_chart_rounded},
    {'title': 'Clinic Settings', 'icon': Icons.settings_outlined},
    {'title': 'Plan & Billing', 'icon': Icons.credit_card_outlined},
    {'title': 'Patient Tickets', 'icon': Icons.help_outline_rounded},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      color: const Color(0xFF090E1A),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Branding Header
          const ClinicSidebarLogo(),

          // Navigation Links
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              itemCount: _navItems.length,
              separatorBuilder: (context, index) => const SizedBox(height: 4),
              itemBuilder: (context, index) {
                final item = _navItems[index];
                final title = item['title'] as String;
                final icon = item['icon'] as IconData;

                return ClinicSidebarNavItem(
                  title: title,
                  icon: icon,
                  isActive: activeItem == title,
                  onTap: () => onItemTap?.call(title),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
