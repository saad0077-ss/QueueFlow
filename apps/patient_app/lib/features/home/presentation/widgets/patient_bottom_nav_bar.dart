import 'package:flutter/material.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

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
    final colors = context.colors;

    return Container(
      height: 68 + MediaQuery.of(context).padding.bottom,
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
      decoration: BoxDecoration(
        color: colors.navBarBg,
        border: Border(
          top: BorderSide(color: colors.navBarBorder, width: 1),
        ),
      ),
      alignment: Alignment.center,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(
              context: context,
              index: 0,
              label: 'Home',
              icon: Icons.home_outlined,
              selectedIcon: Icons.home_rounded,
            ),
            _buildNavItem(
              context: context,
              index: 1,
              label: 'Live Queue',
              assetIcon: 'assets/images/queue_nav_icon.png',
              icon: Icons.people_outline_rounded,
              selectedIcon: Icons.people_rounded,
              showBadge: hasActiveQueueTicket,
            ),
            _buildNavItem(
              context: context,
              index: 2,
              label: 'Bookings',
              assetIcon: 'assets/images/booking_nav_icon.png',
              icon: Icons.confirmation_number_outlined,
              selectedIcon: Icons.confirmation_number_rounded,
            ),
            _buildNavItem(
              context: context,
              index: 3,
              label: 'Profile',
              icon: Icons.person_outline_rounded,
              selectedIcon: Icons.person_rounded,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required int index,
    required String label,
    IconData? icon,
    IconData? selectedIcon,
    String? assetIcon,
    bool showBadge = false,
  }) {
    final colors = context.colors;
    final isSelected = currentIndex == index;
    final activeColor = context.isDarkMode ? const Color(0xFF38BDF8) : colors.primary;
    final color = isSelected ? activeColor : colors.textSubtle;

    Widget iconWidget;
    if (assetIcon != null) {
      // Asset images carry built-in padding, so render them larger inside the
      // same fixed 28px slot used by the Material icons to keep all items aligned.
      iconWidget = SizedBox(
        width: 28,
        height: 28,
        child: OverflowBox(
          maxWidth: 42,
          maxHeight: 42,
          child: Image.asset(
            assetIcon,
            key: ValueKey(isSelected),
            width: 42,
            height: 42,
            fit: BoxFit.contain,
            color: color,
            errorBuilder: (_, _, _) => Icon(
              isSelected ? selectedIcon : icon,
              key: ValueKey(isSelected),
              color: color,
              size: 24,
            ),
          ),
        ),
      );
    } else {
      iconWidget = SizedBox(
        width: 28,
        height: 28,
        child: Icon(
          isSelected ? selectedIcon : icon,
          key: ValueKey(isSelected),
          color: color,
          size: 24,
        ),
      );
    }

    return Expanded(
      child: InkWell(
        onTap: () => onTap(index),
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: SizedBox(
          height: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  iconWidget,
                  if (showBadge)
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: colors.error,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: colors.navBarBg,
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
