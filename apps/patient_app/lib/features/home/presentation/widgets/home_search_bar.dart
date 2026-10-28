import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class HomeSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onClear;
  final VoidCallback? onTap;
  final bool readOnly;
  final bool autoFocus;
  final EdgeInsetsGeometry? margin;

  const HomeSearchBar({
    super.key,
    required this.controller,
    this.onChanged,
    this.onSubmitted,
    this.onClear,
    this.onTap,
    this.readOnly = false,
    this.autoFocus = false,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.darkSurface,
          borderRadius: BorderRadius.circular(9999),
          border: Border.all(color: AppColors.darkBorder, width: 1.5),
          boxShadow: const [
            BoxShadow(
              color: Color(0x140F172A),
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 2),
        margin: margin ?? const EdgeInsets.only(bottom: 16),
        child: Row(
          children: [
            const Icon(
              Icons.search_rounded,
              color: AppColors.darkInkFaint,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: controller,
                onChanged: onChanged,
                onSubmitted: onSubmitted,
                textInputAction: TextInputAction.search,
                onTap: onTap,
                readOnly: readOnly,
                autofocus: autoFocus,
                style: const TextStyle(
                  color: AppColors.darkInk,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                decoration: const InputDecoration(
                  hintText: 'Search clinics, doctors or services...',
                  hintStyle: TextStyle(
                    color: AppColors.darkInkFaint,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                  isDense: true,
                  filled: false,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            if (controller.text.isNotEmpty)
              GestureDetector(
                onTap: () {
                  controller.clear();
                  onClear?.call();
                  onChanged?.call('');
                },
                child: const Padding(
                  padding: EdgeInsets.all(4.0),
                  child: Icon(
                    Icons.close_rounded,
                    color: AppColors.darkInkFaint,
                    size: 18,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
