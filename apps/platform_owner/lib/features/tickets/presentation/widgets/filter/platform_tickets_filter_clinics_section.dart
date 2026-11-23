import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'platform_filter_clinic_item.dart';
import 'platform_tickets_selectable_card.dart';

class PlatformTicketsFilterClinicsSection extends StatelessWidget {
  final String selectedClinic;
  final List<FilterClinicItem> availableClinics;
  final ValueChanged<String> onSelectClinic;

  const PlatformTicketsFilterClinicsSection({
    super.key,
    required this.selectedClinic,
    required this.availableClinics,
    required this.onSelectClinic,
  });

  @override
  Widget build(BuildContext context) {
    const allClinicsItem = FilterClinicItem(
      id: 'all',
      name: '🏥 All Clinics',
      subtitle: 'Network-wide support tickets',
    );
    final clinicItems = [allClinicsItem, ...availableClinics];

    return Container(
      constraints: const BoxConstraints(maxHeight: 180),
      child: Scrollbar(
        thumbVisibility: clinicItems.length > 6,
        child: SingleChildScrollView(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 450;
              final colCount = isNarrow ? 2 : 3;
              final itemWidth =
                  (constraints.maxWidth - ((colCount - 1) * 10)) / colCount;

              return Wrap(
                spacing: 10,
                runSpacing: 10,
                children: clinicItems.map((c) {
                  final isSel = selectedClinic == c.id;
                  return SizedBox(
                    width: itemWidth,
                    child: PlatformTicketsSelectableCard(
                      isSelected: isSel,
                      onTap: () => onSelectClinic(c.id),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            c.name,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: isSel
                                  ? FontWeight.w700
                                  : FontWeight.w600,
                              color: isSel
                                  ? const Color(0xFF60A5FA)
                                  : Colors.white,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 3),
                          Text(
                            c.subtitle,
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              color: isSel
                                  ? const Color(0xFF93C5FD)
                                  : const Color(0xFF64748B),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ),
      ),
    );
  }
}
