import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class HomeSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;

  const HomeSearchBar({
    super.key,
    required this.controller,
    this.onChanged,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.darkBorder, width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Color(0x140F172A),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      margin: const EdgeInsets.only(bottom: 20),
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
              style: const TextStyle(
                color: AppColors.darkInk,
                fontSize: 13.5,
                fontWeight: FontWeight.w500,
              ),
              decoration: const InputDecoration(
                hintText: 'Search clinics, doctors or services...',
                hintStyle: TextStyle(
                  color: AppColors.darkInkFaint,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w400,
                ),
                isDense: true,
                filled: false,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 10),
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
    );
  }
}
