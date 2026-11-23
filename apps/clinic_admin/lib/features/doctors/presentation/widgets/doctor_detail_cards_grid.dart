import 'package:flutter/material.dart';
import '../../domain/entities/clinic_doctor_profile_entity.dart';
import 'doctor_detail_availability_card.dart';
import 'doctor_detail_contact_card.dart';
import 'doctor_detail_danger_card.dart';
import 'doctor_detail_professional_card.dart';
import 'doctor_detail_reviews_card.dart';

class DoctorDetailCardsGrid extends StatelessWidget {
  final ClinicDoctorProfileEntity doctor;
  final bool isWide;
  final VoidCallback onManageSchedule;
  final ValueChanged<List<String>> onLeaveChanged;
  final VoidCallback onRemoveDoctor;

  const DoctorDetailCardsGrid({
    super.key,
    required this.doctor,
    required this.isWide,
    required this.onManageSchedule,
    required this.onLeaveChanged,
    required this.onRemoveDoctor,
  });

  @override
  Widget build(BuildContext context) {
    final leftColumn = Column(
      children: [
        DoctorDetailProfessionalCard(doctor: doctor),
        const SizedBox(height: 18),
        DoctorDetailAvailabilityCard(
          doctor: doctor,
          onEditSchedule: onManageSchedule,
          onLeaveChanged: onLeaveChanged,
        ),
        const SizedBox(height: 18),
        DoctorDetailReviewsCard(doctor: doctor),
      ],
    );

    final rightColumn = Column(
      children: [
        DoctorDetailContactCard(doctor: doctor),
        const SizedBox(height: 18),
        DoctorDetailDangerCard(doctor: doctor, onRemoveDoctor: onRemoveDoctor),
      ],
    );

    if (isWide) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 7, child: leftColumn),
          const SizedBox(width: 20),
          Expanded(flex: 5, child: rightColumn),
        ],
      );
    }

    return Column(
      children: [
        DoctorDetailProfessionalCard(doctor: doctor),
        const SizedBox(height: 18),
        DoctorDetailAvailabilityCard(
          doctor: doctor,
          onEditSchedule: onManageSchedule,
          onLeaveChanged: onLeaveChanged,
        ),
        const SizedBox(height: 18),
        DoctorDetailReviewsCard(doctor: doctor),
        const SizedBox(height: 18),
        DoctorDetailContactCard(doctor: doctor),
        const SizedBox(height: 18),
        DoctorDetailDangerCard(doctor: doctor, onRemoveDoctor: onRemoveDoctor),
      ],
    );
  }
}
