import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

class PlatformUsersFilterToolbar extends StatelessWidget {
  final TextEditingController searchController;
  final String selectedClinic;
  final String selectedStatus;
  final List<String> availableClinics;
  final int filteredCount;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String> onClinicChanged;
  final ValueChanged<String> onStatusChanged;
  final VoidCallback onReset;

  const PlatformUsersFilterToolbar({
    super.key,
    required this.searchController,
    required this.selectedClinic,
    required this.selectedStatus,
    required this.availableClinics,
    required this.filteredCount,
    required this.onSearchChanged,
    required this.onClinicChanged,
    required this.onStatusChanged,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 850;

        final searchField = SizedBox(
          width: isMobile ? double.infinity : 280,
          height: 40,
          child: TextField(
            controller: searchController,
            onChanged: onSearchChanged,
            style: GoogleFonts.inter(fontSize: 13, color: colors.textPrimary),
            decoration: InputDecoration(
              isDense: true,
              hintText: 'Search name, phone, email, token...',
              hintStyle: GoogleFonts.inter(fontSize: 12.5, color: colors.textMuted),
              prefixIcon: Icon(Icons.search_rounded, size: 18, color: colors.textMuted),
              filled: true,
              fillColor: colors.surfaceSecondary,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: colors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: colors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: colors.primary),
              ),
            ),
          ),
        );

        final clinicDropdown = Container(
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: colors.surfaceSecondary,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: colors.border),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selectedClinic,
              dropdownColor: colors.surface,
              style: GoogleFonts.inter(fontSize: 12.5, color: colors.textPrimary),
              icon: Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: colors.textMuted),
              items: [
                const DropdownMenuItem(value: 'all', child: Text('All Clinics')),
                for (final c in availableClinics)
                  DropdownMenuItem(value: c, child: Text(c)),
              ],
              onChanged: (val) {
                if (val != null) onClinicChanged(val);
              },
            ),
          ),
        );

        final statusDropdown = Container(
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: colors.surfaceSecondary,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: colors.border),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selectedStatus,
              dropdownColor: colors.surface,
              style: GoogleFonts.inter(fontSize: 12.5, color: colors.textPrimary),
              icon: Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: colors.textMuted),
              items: const [
                DropdownMenuItem(value: 'all', child: Text('All Statuses')),
                DropdownMenuItem(value: 'in-queue', child: Text('In Live Queue')),
                DropdownMenuItem(value: 'active', child: Text('Active Accounts')),
                DropdownMenuItem(value: 'verified', child: Text('Verified Only')),
              ],
              onChanged: (val) {
                if (val != null) onStatusChanged(val);
              },
            ),
          ),
        );

        final countBadge = Container(
          height: 40,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: colors.surfaceSecondary,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: colors.border),
          ),
          child: Text(
            'Showing $filteredCount users',
            style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: colors.textPrimary),
          ),
        );

        final resetBtn = OutlinedButton(
          onPressed: onReset,
          style: OutlinedButton.styleFrom(
            foregroundColor: colors.textMuted,
            side: BorderSide(color: colors.border),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          ),
          child: Text('Reset Filters', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600)),
        );

        if (isMobile) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              searchField,
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: clinicDropdown),
                  const SizedBox(width: 8),
                  Expanded(child: statusDropdown),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  countBadge,
                  resetBtn,
                ],
              ),
            ],
          );
        }

        return Row(
          children: [
            searchField,
            const SizedBox(width: 10),
            clinicDropdown,
            const SizedBox(width: 10),
            statusDropdown,
            const Spacer(),
            countBadge,
            const SizedBox(width: 10),
            resetBtn,
          ],
        );
      },
    );
  }
}
