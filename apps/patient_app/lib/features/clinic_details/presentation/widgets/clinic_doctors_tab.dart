import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/clinic_doctor_item.dart';
import 'clinic_doctor_item_tile.dart';

class ClinicDoctorsTab extends StatelessWidget {
  final List<ClinicDoctorItem> doctors;
  final ValueChanged<ClinicDoctorItem>? onDoctorSelected;

  const ClinicDoctorsTab({
    super.key,
    required this.doctors,
    this.onDoctorSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (doctors.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Text(
            'No doctors listed for this clinic.',
            style: TextStyle(color: AppColors.darkInkMuted, fontSize: 13),
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
        );
      },
    );
  }
}
