import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class ProfileMenuItem {
  final Widget icon;
  final Color iconBgColor;
  final String title;
  final Color? titleColor;
  final Widget? trailing;
  final VoidCallback? onTap;

  const ProfileMenuItem({
    required this.icon,
    required this.iconBgColor,
    required this.title,
    this.titleColor,
    this.trailing,
    this.onTap,
  });
}

class ProfileMenuSection extends StatelessWidget {
  final String? title;
  final List<ProfileMenuItem> items;
  final double bottomMargin;

  const ProfileMenuSection({
    super.key,
    this.title,
    required this.items,
    this.bottomMargin = 18,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null && title!.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              title!.toUpperCase(),
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.6,
                color: AppColors.darkInkFaint,
              ),
            ),
          ),
        ],
        Container(
          margin: EdgeInsets.only(bottom: bottomMargin),
          decoration: BoxDecoration(
            color: AppColors.darkSurface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.darkBorder, width: 1),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: List.generate(items.length, (index) {
              final item = items[index];
              final isLast = index == items.length - 1;

              return Column(
                children: [
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: item.onTap,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                        child: Row(
                          children: [
                            // Icon Box
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: item.iconBgColor,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              alignment: Alignment.center,
                              child: item.icon,
                            ),
                            const SizedBox(width: 12),

                            // Title Label
                            Expanded(
                              child: Text(
                                item.title,
                                style: TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w600,
                                  color: item.titleColor ?? AppColors.darkInk,
                                ),
                              ),
                            ),

                            // Trailing
                            if (item.trailing != null) ...[
                              item.trailing!,
                            ] else ...[
                              Icon(
                                Icons.chevron_right_rounded,
                                size: 18,
                                color: item.titleColor ?? AppColors.darkInkFaint,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (!isLast)
                    const Divider(
                      color: AppColors.darkBorder,
                      height: 1,
                      thickness: 1,
                      indent: 62,
                    ),
                ],
              );
            }),
          ),
        ),
      ],
    );
  }
}
