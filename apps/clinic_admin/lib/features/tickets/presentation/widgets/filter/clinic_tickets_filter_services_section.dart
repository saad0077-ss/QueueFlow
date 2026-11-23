import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'clinic_tickets_filter_card_item.dart';

class ClinicTicketsFilterServicesSection extends StatelessWidget {
  final String selectedService;
  final ValueChanged<String> onSelectService;

  const ClinicTicketsFilterServicesSection({
    super.key,
    required this.selectedService,
    required this.onSelectService,
  });

  static const services = [
    {'id': 'all', 'title': '🏥 All Services', 'sub': 'Clinic-wide inquiries'},
    {'id': 'general', 'title': 'General Medicine', 'sub': 'OPD Consulting'},
    {'id': 'pediatrics', 'title': 'Pediatrics', 'sub': 'Child Health Desk'},
    {'id': 'orthopedics', 'title': 'Orthopedics', 'sub': 'Specialty Clinic'},
    {'id': 'dental', 'title': 'Dental Care', 'sub': 'Operatory & X-Ray'},
    {'id': 'dermatology', 'title': 'Dermatology', 'sub': 'Procedures & Skin'},
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 450;
        final colCount = isNarrow ? 2 : 3;
        final itemWidth =
            (constraints.maxWidth - ((colCount - 1) * 10)) / colCount;

        return Wrap(
          spacing: 10,
          runSpacing: 10,
          children: services.map((s) {
            final isSel = selectedService == s['id'];
            return SizedBox(
              width: itemWidth,
              child: ClinicTicketsFilterCardItem(
                isSelected: isSel,
                onTap: () => onSelectService(s['id']!),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      s['title']!,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: isSel ? FontWeight.w700 : FontWeight.w600,
                        color: isSel ? const Color(0xFF60A5FA) : Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      s['sub']!,
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
    );
  }
}
