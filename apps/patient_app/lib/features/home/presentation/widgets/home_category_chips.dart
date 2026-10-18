import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class CategoryItem {
  final String id;
  final String label;
  final IconData icon;
  final Color tintColor;
  final Color iconColor;

  const CategoryItem({
    required this.id,
    required this.label,
    required this.icon,
    required this.tintColor,
    required this.iconColor,
  });
}

class HomeCategoryChips extends StatelessWidget {
  final String selectedCategory;
  final ValueChanged<String> onCategorySelected;

  const HomeCategoryChips({
    super.key,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  static const List<CategoryItem> categories = [
    CategoryItem(
      id: 'all',
      label: 'All',
      icon: Icons.grid_view_rounded,
      tintColor: Color(0xFF16233F),
      iconColor: AppColors.primaryLight,
    ),
    CategoryItem(
      id: 'General',
      label: 'General',
      icon: Icons.medical_services_rounded,
      tintColor: Color(0xFF16233F),
      iconColor: Color(0xFF38BDF8),
    ),
    CategoryItem(
      id: 'Dental',
      label: 'Dental',
      icon: Icons.health_and_safety_rounded,
      tintColor: Color(0xFF10302C),
      iconColor: AppColors.accent,
    ),
    CategoryItem(
      id: 'Dermatology',
      label: 'Dermatology',
      icon: Icons.water_drop_rounded,
      tintColor: Color(0xFF302410),
      iconColor: AppColors.warning,
    ),
    CategoryItem(
      id: 'Diagnostics',
      label: 'Diagnostics',
      icon: Icons.biotech_rounded,
      tintColor: Color(0xFF251B3D),
      iconColor: AppColors.violet,
    ),
    CategoryItem(
      id: 'Pediatrics',
      label: 'Pediatrics',
      icon: Icons.child_care_rounded,
      tintColor: Color(0xFF351319),
      iconColor: Color(0xFFF43F5E),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 22),
        child: Row(
          children: categories.map((cat) {
            final isSelected = selectedCategory.toLowerCase() == cat.id.toLowerCase();

            return Padding(
              padding: const EdgeInsets.only(right: 14),
              child: GestureDetector(
                onTap: () => onCategorySelected(cat.id),
                child: SizedBox(
                  width: 72,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        width: 54,
                        height: 54,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? cat.iconColor.withValues(alpha: 0.22)
                              : cat.tintColor,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: isSelected
                                ? cat.iconColor
                                : AppColors.darkBorder.withValues(alpha: 0.5),
                            width: isSelected ? 2 : 1,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: cat.iconColor.withValues(alpha: 0.35),
                                    blurRadius: 10,
                                    offset: const Offset(0, 3),
                                  ),
                                ]
                              : null,
                        ),
                        child: Icon(
                          cat.icon,
                          color: isSelected ? cat.iconColor : cat.iconColor.withValues(alpha: 0.9),
                          size: 24,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        cat.label,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11, 
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                          color: isSelected ? AppColors.textWhite : AppColors.darkInkMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
