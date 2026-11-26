import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

class LegalDocumentHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool allExpanded;
  final VoidCallback onBack;
  final VoidCallback onToggleAll;

  const LegalDocumentHeader({
    super.key,
    required this.title,
    required this.subtitle,
    required this.allExpanded,
    required this.onBack,
    required this.onToggleAll,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isWide = MediaQuery.of(context).size.width >= 960;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: isWide ? 32 : 16, vertical: 12),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(bottom: BorderSide(color: colors.border)),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1240),
          child: Row(
            children: [
              _iconBox(
                colors: colors,
                icon: Icons.arrow_back_ios_new_rounded,
                iconSize: 16,
                onTap: onBack,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: colors.textPrimary,
                        letterSpacing: -0.3,
                      ),
                    ),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 11.5,
                        color: colors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Tooltip(
                message: allExpanded ? 'Collapse all' : 'Expand all',
                child: _iconBox(
                  colors: colors,
                  icon: allExpanded
                      ? Icons.unfold_less_rounded
                      : Icons.unfold_more_rounded,
                  iconSize: 18,
                  onTap: onToggleAll,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _iconBox({
    required AppColorsExtension colors,
    required IconData icon,
    required double iconSize,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: colors.surfaceSecondary,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: colors.border),
        ),
        alignment: Alignment.center,
        child: Icon(icon, size: iconSize, color: colors.textPrimary),
      ),
    );
  }
}
