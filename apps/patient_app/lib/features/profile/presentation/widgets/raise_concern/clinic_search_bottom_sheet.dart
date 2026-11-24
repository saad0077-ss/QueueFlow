import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

import 'clinic_option_model.dart';
import 'clinic_search_sheet_header.dart';
import 'clinic_search_tile.dart';

class ClinicSearchBottomSheet extends StatefulWidget {
  final List<ClinicOption> availableClinics;
  final String selectedClinicId;
  final AppColorsExtension colors;
  final ValueChanged<ClinicOption> onClinicSelected;

  const ClinicSearchBottomSheet({
    super.key,
    required this.availableClinics,
    required this.selectedClinicId,
    required this.colors,
    required this.onClinicSelected,
  });

  static Future<void> show(
    BuildContext context, {
    required List<ClinicOption> availableClinics,
    required String selectedClinicId,
    required AppColorsExtension colors,
    required ValueChanged<ClinicOption> onClinicSelected,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => ClinicSearchBottomSheet(
        availableClinics: availableClinics,
        selectedClinicId: selectedClinicId,
        colors: colors,
        onClinicSelected: (clinic) {
          onClinicSelected(clinic);
          Navigator.pop(ctx);
        },
      ),
    );
  }

  @override
  State<ClinicSearchBottomSheet> createState() =>
      _ClinicSearchBottomSheetState();
}

class _ClinicSearchBottomSheetState extends State<ClinicSearchBottomSheet> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchQuery.trim().toLowerCase();
    final filtered = widget.availableClinics.where((c) {
      if (query.isEmpty) return true;
      return c.name.toLowerCase().contains(query) ||
          c.category.toLowerCase().contains(query) ||
          c.city.toLowerCase().contains(query) ||
          c.address.toLowerCase().contains(query);
    }).toList();

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 540,
          maxHeight: MediaQuery.of(context).size.height * 0.78,
        ),
        child: Container(
          decoration: BoxDecoration(
        color: widget.colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClinicSearchSheetHeader(
                clinicsCount: filtered.length,
                searchController: _searchController,
                searchQuery: _searchQuery,
                onSearchChanged: (val) => setState(() => _searchQuery = val),
                onClear: () {
                  _searchController.clear();
                  setState(() => _searchQuery = '');
                },
                colors: widget.colors,
              ),
              Flexible(
                child: filtered.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 36,
                          horizontal: 20,
                        ),
                        child: Text(
                          'No clinics found matching "$_searchQuery"',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: widget.colors.textPrimary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        shrinkWrap: true,
                        itemCount: filtered.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final clinic = filtered[index];
                          return ClinicSearchTile(
                            clinic: clinic,
                            isSelected: clinic.id == widget.selectedClinicId,
                            colors: widget.colors,
                            onTap: () => widget.onClinicSelected(clinic),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    ),
  ),
);
}
}
