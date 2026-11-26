import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

/// Filter pills and inline search box for the clinic revenue ledger.
class ClinicRevenueLedgerToolbar extends StatelessWidget {
  final String activeFilter;
  final ValueChanged<String> onFilterChanged;
  final ValueChanged<String> onSearchChanged;

  const ClinicRevenueLedgerToolbar({
    super.key,
    required this.activeFilter,
    required this.onFilterChanged,
    required this.onSearchChanged,
  });

  static const _filters = [
    ('all', 'All'),
    ('paid', 'Paid'),
    ('pending', 'Pending'),
    ('refunded', 'Refunded'),
  ];

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    final pills = Wrap(
      spacing: 6,
      runSpacing: 6,
      children: _filters.map((pair) {
        final selected = activeFilter == pair.$1;
        return InkWell(
          onTap: () => onFilterChanged(pair.$1),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
            decoration: BoxDecoration(
              color: selected
                  ? colors.primary.withValues(alpha: colors.isDark ? 0.25 : 0.12)
                  : colors.background,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: selected ? colors.primaryLight : colors.border,
              ),
            ),
            child: Text(
              pair.$2,
              style: GoogleFonts.inter(
                fontSize: 11.5,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: selected ? colors.primaryLight : colors.textMuted,
              ),
            ),
          ),
        );
      }).toList(),
    );

    final searchBox = SizedBox(
      width: 240,
      height: 36,
      child: TextField(
        onChanged: onSearchChanged,
        style: GoogleFonts.inter(fontSize: 12, color: colors.textPrimary),
        decoration: InputDecoration(
          hintText: 'Search patient, receipt, doctor...',
          hintStyle: GoogleFonts.inter(fontSize: 11.5, color: colors.textMuted),
          prefixIcon: Icon(Icons.search_rounded, size: 16, color: colors.textMuted),
          filled: true,
          fillColor: colors.background,
          contentPadding: EdgeInsets.zero,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(9),
            borderSide: BorderSide(color: colors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(9),
            borderSide: BorderSide(color: colors.border),
          ),
        ),
      ),
    );

    return SizedBox(
      width: double.infinity,
      child: Wrap(
        spacing: 12,
        runSpacing: 10,
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [pills, searchBox],
      ),
    );
  }
}
