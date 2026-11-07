import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

class DepartmentsFilterRow extends StatelessWidget {
  final String searchQuery;
  final String selectedStatus;
  final String selectedClinic;
  final int count;
  final int total;
  final ValueChanged<String> onSearch;
  final ValueChanged<String> onStatusChanged;
  final ValueChanged<String> onClinicChanged;
  final VoidCallback onReset;

  const DepartmentsFilterRow({
    super.key,
    required this.searchQuery,
    required this.selectedStatus,
    required this.selectedClinic,
    required this.count,
    required this.total,
    required this.onSearch,
    required this.onStatusChanged,
    required this.onClinicChanged,
    required this.onReset,
  });

  static const _clinicsMap = {
    'All Clinics': 'all',
    'Sunrise Health Clinic': 'sunrise-health',
    'Smile Dental Clinic': 'smile-dental',
    'CityCare General Clinic': 'citycare',
    'Wellness Skin Studio': 'wellness-skin',
  };

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 900;
        final searchBox = _searchBox(colors);
        final statusDropdown = _dropdown(colors, selectedStatus, const ['All Statuses', 'Active Specialties', 'Inactive'], onStatusChanged);
        // State stores the clinic id, so map it back to its display name for the dropdown.
        final clinicName = _clinicsMap.entries.firstWhere((e) => e.value == selectedClinic, orElse: () => _clinicsMap.entries.first).key;
        final clinicDropdown = _dropdown(colors, clinicName, _clinicsMap.keys.toList(), (name) => onClinicChanged(_clinicsMap[name] ?? 'all'));
        final resetBtn = _resetPill(colors);
        final countText = Text('Showing $count of $total departments', style: GoogleFonts.inter(fontSize: 12, color: colors.textMuted));

        final compactContent = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            searchBox,
            const SizedBox(height: 10),
            Row(children: [Expanded(child: statusDropdown), const SizedBox(width: 8), Expanded(child: clinicDropdown)]),
            const SizedBox(height: 10),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [countText, resetBtn]),
          ],
        );

        final desktopContent = Row(
          children: [
            Expanded(flex: 3, child: searchBox),
            const SizedBox(width: 10),
            Expanded(flex: 3, child: statusDropdown),
            const SizedBox(width: 10),
            Expanded(flex: 3, child: clinicDropdown),
            const SizedBox(width: 14),
            countText,
            const SizedBox(width: 10),
            resetBtn,
          ],
        );

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: colors.border),
          ),
          child: isCompact ? compactContent : desktopContent,
        );
      },
    );
  }

  Widget _searchBox(AppColorsExtension colors) {
    OutlineInputBorder outline(Color c, [double w = 1]) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: c, width: w),
        );
    return SizedBox(
      height: 38,
      child: TextField(
        onChanged: onSearch,
        cursorColor: colors.primary,
        textAlignVertical: TextAlignVertical.center,
        style: GoogleFonts.inter(color: colors.textPrimary, fontSize: 12.5),
        decoration: InputDecoration(
          isDense: true,
          filled: true,
          fillColor: colors.surfaceSecondary,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
          hintText: 'Search by name, code, doctor, specialty...',
          hintStyle: GoogleFonts.inter(color: colors.textMuted, fontSize: 12.5),
          prefixIcon: Icon(Icons.search_rounded, color: colors.textMuted, size: 18),
          prefixIconConstraints: const BoxConstraints(minWidth: 38, minHeight: 38),
          border: outline(colors.border),
          enabledBorder: outline(colors.border),
          focusedBorder: outline(colors.primary, 1.5),
        ),
      ),
    );
  }

  Widget _dropdown(AppColorsExtension colors, String value, List<String> items, ValueChanged<String> onChanged) {
    return Container(
      height: 38,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: colors.surfaceSecondary,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colors.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: items.contains(value) ? value : items.first,
          isExpanded: true,
          dropdownColor: colors.surfaceElevated,
          style: GoogleFonts.inter(fontSize: 12.5, fontWeight: FontWeight.bold, color: colors.textPrimary),
          icon: Icon(Icons.keyboard_arrow_down_rounded, color: colors.textMuted, size: 18),
          items: items.map((i) => DropdownMenuItem(value: i, child: Text(i, overflow: TextOverflow.ellipsis, style: TextStyle(color: colors.textPrimary)))).toList(),
          onChanged: (v) => onChanged(v ?? items.first),
        ),
      ),
    );
  }

  Widget _resetPill(AppColorsExtension colors) {
    return InkWell(
      onTap: onReset,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        height: 32,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: colors.surfaceSecondary,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: colors.border),
        ),
        child: Text('Reset Filters', style: GoogleFonts.inter(fontSize: 11.5, fontWeight: FontWeight.bold, color: colors.textPrimary)),
      ),
    );
  }
}
