import 'package:flutter/material.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

class ClinicAppointmentsFilterDoctorSection extends StatelessWidget {
  final String selectedDoctor;
  final List<String> availableDoctors;
  final ValueChanged<String> onSelectDoctor;

  const ClinicAppointmentsFilterDoctorSection({
    super.key,
    required this.selectedDoctor,
    required this.availableDoctors,
    required this.onSelectDoctor,
  });

  @override
  Widget build(BuildContext context) {
    final doctors = ['all', ...availableDoctors.where((d) => d != 'all')];

    return LayoutBuilder(
      builder: (context, c) {
        final w = (c.maxWidth - 20) / 3;
        final itemWidth = w < 140 ? (c.maxWidth - 10) / 2 : w;
        return Wrap(
          spacing: 10,
          runSpacing: 10,
          children: doctors.map((doc) {
            final isSel = selectedDoctor == doc;
            final isAll = doc == 'all';
            return SizedBox(
              width: itemWidth,
              child: AppFilterSelectableCard(
                isSelected: isSel,
                onTap: () => onSelectDoctor(doc),
                emojiIcon: isAll ? '👨‍⚕️' : '🩺',
                title: isAll ? 'All Doctors' : doc,
                subtitle: isAll ? 'Any clinician' : 'Attending doctor',
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
