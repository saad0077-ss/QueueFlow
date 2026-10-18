import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class PatientBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final bool hasActiveQueueTicket;

  const PatientBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.hasActiveQueueTicket = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 68 + MediaQuery.of(context).padding.bottom,
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
      decoration: const BoxDecoration(
        color: AppColors.darkSurface,
        border: Border(
          top: BorderSide(color: AppColors.darkBorder, width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(
            index: 0,
            label: 'Home',
            icon: Icons.home_outlined,
            selectedIcon: Icons.home_rounded,
          ),
          _buildNavItem(
            index: 1,
            label: 'Live Queue',
            assetIcon: 'assets/images/queue_nav_icon.png',
            icon: Icons.people_outline_rounded,
            selectedIcon: Icons.people_rounded,
          ),
          _buildNavItem(
            index: 2,
            label: 'Bookings',
            assetIcon: 'assets/images/booking_nav_icon.png',
            icon: Icons.confirmation_number_outlined,
            selectedIcon: Icons.confirmation_number_rounded,
          ),
          _buildNavItem(
            index: 3,
            label: 'Profile',
            icon: Icons.person_outline_rounded,
            selectedIcon: Icons.person_rounded,
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required String label,
    IconData? icon,
    IconData? selectedIcon,
    String? assetIcon,
  }) {
    final isSelected = currentIndex == index;
    final color = isSelected ? const Color(0xFF38BDF8) : AppColors.darkInkFaint;

    Widget iconWidget;
    if (assetIcon != null) {
      iconWidget = Image.asset(
        assetIcon,
        key: ValueKey(isSelected),
        width: 50,
        height: 50,
        fit: BoxFit.contain, 
        color: color,
        errorBuilder: (_, _, _) => Icon(
          isSelected ? selectedIcon : icon,
          key: ValueKey(isSelected),
          color: color,
          size: 24,
        ),
      );
    } else {
      iconWidget = Icon(
        isSelected ? selectedIcon : icon,
        key: ValueKey(isSelected),
        color: color,
        size: 24,
      );
    }

    return Expanded(
      child: InkWell(
        onTap: () => onTap(index),
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                SizedBox(
                  height: 24,
                  child: Center(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 180),
                      child: iconWidget,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
