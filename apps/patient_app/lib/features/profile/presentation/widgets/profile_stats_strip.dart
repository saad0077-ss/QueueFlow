import 'package:flutter/material.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

class ProfileStatsStrip extends StatelessWidget {
  final int visitsCount;
  final int favoritesCount;
  final VoidCallback onVisitsTap;
  final VoidCallback onFavoritesTap;

  const ProfileStatsStrip({
    super.key,
    required this.visitsCount,
    required this.favoritesCount,
    required this.onVisitsTap,
    required this.onFavoritesTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.border, width: 1),
      ),
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          children: [
            // Stat 1: Visits
            Expanded(
              child: InkWell(
                onTap: onVisitsTap,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '$visitsCount',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF38BDF8),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Visits',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: colors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Divider
            VerticalDivider(
              color: colors.border,
              width: 1,
              thickness: 1,
            ),

            // Stat 2: Favorites
            Expanded(
              child: InkWell(
                onTap: onFavoritesTap,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '$favoritesCount',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF38BDF8),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Favorites',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: colors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
