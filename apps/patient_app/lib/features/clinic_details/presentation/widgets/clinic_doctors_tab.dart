import 'package:flutter/material.dart';
import 'package:queueflow_ui/queueflow_ui.dart';
import '../../domain/entities/clinic_doctor_item.dart';
import 'clinic_doctor_item_tile.dart';

class ClinicDoctorsTab extends StatelessWidget {
  final List<ClinicDoctorItem> doctors;
  final ValueChanged<ClinicDoctorItem>? onDoctorSelected;
  final ValueChanged<ClinicDoctorItem>? onRateDoctor;

  const ClinicDoctorsTab({
    super.key,
    required this.doctors,
    this.onDoctorSelected,
    this.onRateDoctor,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    if (doctors.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Text(
            'No doctors listed for this clinic.',
            style: TextStyle(color: colors.textMuted, fontSize: 13),
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: doctors.length,
      itemBuilder: (context, index) {
        final doctor = doctors[index];
        return ClinicDoctorItemTile(
          doctor: doctor,
          onTap: () => onDoctorSelected?.call(doctor),
          onRate: onRateDoctor == null ? null : () => onRateDoctor!(doctor),
        );
      },
    );
  }
}
