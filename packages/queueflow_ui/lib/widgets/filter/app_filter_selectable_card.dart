import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppFilterSelectableCard extends StatelessWidget {
  final bool isSelected;
  final VoidCallback onTap;
  final Widget? child;
  final String? title;
  final String? subtitle;
  final String? emojiIcon;
  final IconData? iconData;
  final EdgeInsetsGeometry padding;

  const AppFilterSelectableCard({
    super.key,
    required this.isSelected,
    required this.onTap,
    this.child,
    this.title,
    this.subtitle,
    this.emojiIcon,
    this.iconData,
    this.padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: padding,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1E293B) : const Color(0xFF0B0F19),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF2563EB)
                : const Color(0xFF1E293B),
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF2563EB).withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: child ?? _buildDefaultContent(),
      ),
    );
  }

  Widget _buildDefaultContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (emojiIcon != null) ...[
              Text(emojiIcon!, style: const TextStyle(fontSize: 14)),
              const SizedBox(width: 6),
            ],
            if (iconData != null) ...[
              Icon(
                iconData,
                size: 14,
                color: isSelected ? const Color(0xFF60A5FA) : Colors.white70,
              ),
              const SizedBox(width: 6),
            ],
            if (title != null)
              Flexible(
                child: Text(
                  title!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                    color: isSelected ? const Color(0xFF60A5FA) : Colors.white,
                  ),
                ),
              ),
          ],
        ),
        if (subtitle != null && subtitle!.isNotEmpty) ...[
          const SizedBox(height: 2),
          Text(
            subtitle!,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              fontSize: 10,
              color: isSelected
                  ? const Color(0xFF93C5FD)
                  : const Color(0xFF64748B),
            ),
          ),
        ],
      ],
    );
  }
}
