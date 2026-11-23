import 'package:flutter/material.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

class PatientSearchActiveTags extends StatelessWidget {
  final String selectedDepartment;
  final String selectedService;
  final Set<String> activeQuickFilters;
  final VoidCallback onClearDepartment;
  final VoidCallback onClearService;
  final ValueChanged<String> onRemoveQuickFilter;
  final double horizontalPadding;
  final AppColorsExtension colors;

  const PatientSearchActiveTags({
    super.key,
    required this.selectedDepartment,
    required this.selectedService,
    required this.activeQuickFilters,
    required this.onClearDepartment,
    required this.onClearService,
    required this.onRemoveQuickFilter,
    required this.horizontalPadding,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 6),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: [
            if (selectedDepartment != 'all')
              _buildTag(label: selectedDepartment, onClear: onClearDepartment),
            if (selectedService != 'all')
              _buildTag(label: selectedService, onClear: onClearService),
            if (activeQuickFilters.contains('open'))
              _buildTag(
                label: 'Open Now',
                onClear: () => onRemoveQuickFilter('open'),
              ),
            if (activeQuickFilters.contains('rating'))
              _buildTag(
                label: '4.5+ Rating',
                onClear: () => onRemoveQuickFilter('rating'),
              ),
            if (activeQuickFilters.contains('near'))
              _buildTag(
                label: '< 2 km',
                onClear: () => onRemoveQuickFilter('near'),
              ),
            if (activeQuickFilters.contains('queue'))
              _buildTag(
                label: 'Live Queue',
                onClear: () => onRemoveQuickFilter('queue'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTag({required String label, required VoidCallback onClear}) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.fromLTRB(10, 4, 6, 4),
      decoration: BoxDecoration(
        color: colors.primaryTint,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.primary.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: colors.primary,
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onClear,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.all(2),
              child: Icon(Icons.close_rounded, size: 14, color: colors.primary),
            ),
          ),
        ],
      ),
    );
  }
}
