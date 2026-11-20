import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

class ClinicLiveQueueEmptyView extends StatelessWidget {
  final String searchQuery;
  final bool hasActiveFilters;
  final VoidCallback onResetFilters;

  const ClinicLiveQueueEmptyView({
    super.key,
    required this.searchQuery,
    required this.hasActiveFilters,
    required this.onResetFilters,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 20),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: colors.primaryTint,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: const Text('🏥', style: TextStyle(fontSize: 26)),
          ),
          const SizedBox(height: 16),
          Text(
            'No Departments Found',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            searchQuery.isNotEmpty
                ? 'No departments matching "$searchQuery" were found.'
                : 'No departments configured for this clinic.',
            style: GoogleFonts.inter(fontSize: 13, color: colors.textMuted),
          ),
          if (hasActiveFilters || searchQuery.isNotEmpty) ...[
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: onResetFilters,
              style: OutlinedButton.styleFrom(
                foregroundColor: colors.primary,
                side: BorderSide(color: colors.primary.withValues(alpha: 0.4)),
              ),
              child: const Text('Reset All Filters'),
            ),
          ],
        ],
      ),
    );
  }
}
