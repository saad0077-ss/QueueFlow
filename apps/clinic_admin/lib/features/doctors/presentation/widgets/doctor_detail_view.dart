import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../domain/entities/clinic_doctor_profile_entity.dart';
import '../bloc/clinic_doctors_bloc.dart';
import '../bloc/clinic_doctors_event.dart';
import 'doctor_detail_account_status_card.dart';
import 'doctor_detail_availability_card.dart';
import 'doctor_detail_back_bar.dart';
import 'doctor_detail_contact_card.dart';
import 'doctor_detail_danger_card.dart';
import 'doctor_detail_header_card.dart';
import 'doctor_detail_notice_banner.dart';
import 'doctor_detail_professional_card.dart';
import 'doctor_detail_reviews_card.dart';
import 'doctor_detail_stats_row.dart';
import 'doctor_ui_kit.dart';
import 'edit_doctor_profile_dialog.dart';
import 'manage_doctor_schedule_dialog.dart';

class DoctorDetailView extends StatelessWidget {
  final ClinicDoctorProfileEntity doctor;
  final List<String> departments;
  final VoidCallback onBack;

  const DoctorDetailView({
    super.key,
    required this.doctor,
    required this.departments,
    required this.onBack,
  });

  void _showRemoveConfirmationDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.65),
      builder: (dialogCtx) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
        child: Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 420),
            decoration: BoxDecoration(
              color: DoctorColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: DoctorColors.border),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.5),
                  blurRadius: 28,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: DoctorColors.danger.withValues(alpha: 0.14),
                    shape: BoxShape.circle,
                    border: Border.all(color: DoctorColors.danger.withValues(alpha: 0.3)),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.delete_outline_rounded,
                    size: 26,
                    color: DoctorColors.danger,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Remove ${doctor.name}?',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'They will be removed from the clinic roster, patient booking and the live queue. This action cannot be undone.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    height: 1.45,
                    color: DoctorColors.muted,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(dialogCtx).pop(),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: DoctorColors.muted,
                          side: const BorderSide(color: DoctorColors.border),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: Text(
                          'Cancel',
                          style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(dialogCtx).pop();
                          context.read<ClinicDoctorsBloc>().add(
                                DoctorDeletePressed(
                                  doctorId: doctor.id,
                                  doctorName: doctor.name,
                                ),
                              );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: DoctorColors.danger,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          elevation: 0,
                        ),
                        child: Text(
                          'Remove Doctor',
                          style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _openEditProfile(BuildContext context) {
    final bloc = context.read<ClinicDoctorsBloc>();
    EditDoctorProfileDialog.show(
      context,
      doctor: doctor,
      departments: departments,
      onSave: (updated) {
        bloc.add(DoctorProfileUpdated(updated));
      },
    );
  }

  void _openManageSchedule(BuildContext context) {
    final bloc = context.read<ClinicDoctorsBloc>();
    ManageDoctorScheduleDialog.show(
      context,
      doctor: doctor,
      onSave: (schedule, slotDuration) {
        bloc.add(DoctorScheduleUpdated(
          doctorId: doctor.id,
          schedule: schedule,
          slotDuration: slotDuration,
        ));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<ClinicDoctorsBloc>();

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 992;
        final hPadding = constraints.maxWidth < 600 ? 12.0 : 20.0;

        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: hPadding, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back bar & Breadcrumb
              DoctorDetailBackBar(
                doctorName: doctor.name,
                onBack: onBack,
              ),
              const SizedBox(height: 16),

              // Header Card
              DoctorDetailHeaderCard(
                doctor: doctor,
                onEditProfile: () => _openEditProfile(context),
                onManageSchedule: () => _openManageSchedule(context),
                onToggleAccount: () => bloc.add(DoctorAccountStatusToggled(doctor.id)),
                onRemoveDoctor: () => _showRemoveConfirmationDialog(context),
              ),

              // Pending / Inactive Notice Banner
              if (doctor.accountStatus != 'active') ...[
                const SizedBox(height: 16),
                DoctorDetailNoticeBanner(doctor: doctor),
              ],

              const SizedBox(height: 16),

              // Stats Row (4 summary metrics)
              DoctorDetailStatsRow(doctor: doctor),
              const SizedBox(height: 20),

              // 2-Column Responsive Grid (or 1-Column on narrower screens)
              if (isWide)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Main Left Column
                    Expanded(
                      flex: 7,
                      child: Column(
                        children: [
                          DoctorDetailProfessionalCard(doctor: doctor),
                          const SizedBox(height: 18),
                          DoctorDetailAvailabilityCard(
                            doctor: doctor,
                            onEditSchedule: () => _openManageSchedule(context),
                          ),
                          const SizedBox(height: 18),
                          DoctorDetailReviewsCard(doctor: doctor),
                        ],
                      ),
                    ),
                    const SizedBox(width: 20),

                    // Side Right Column
                    Expanded(
                      flex: 5,
                      child: Column(
                        children: [
                          DoctorDetailContactCard(doctor: doctor),
                          const SizedBox(height: 18),
                          DoctorDetailAccountStatusCard(
                            doctor: doctor,
                            onChangeStatus: (status) {
                              bloc.add(DoctorAccountStatusChanged(
                                doctorId: doctor.id,
                                accountStatus: status,
                              ));
                            },
                          ),
                          const SizedBox(height: 18),
                          DoctorDetailDangerCard(
                            doctor: doctor,
                            onRemoveDoctor: () => _showRemoveConfirmationDialog(context),
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              else
                Column(
                  children: [
                    DoctorDetailProfessionalCard(doctor: doctor),
                    const SizedBox(height: 18),
                    DoctorDetailAvailabilityCard(
                      doctor: doctor,
                      onEditSchedule: () => _openManageSchedule(context),
                    ),
                    const SizedBox(height: 18),
                    DoctorDetailReviewsCard(doctor: doctor),
                    const SizedBox(height: 18),
                    DoctorDetailContactCard(doctor: doctor),
                    const SizedBox(height: 18),
                    DoctorDetailAccountStatusCard(
                      doctor: doctor,
                      onChangeStatus: (status) {
                        bloc.add(DoctorAccountStatusChanged(
                          doctorId: doctor.id,
                          accountStatus: status,
                        ));
                      },
                    ),
                    const SizedBox(height: 18),
                    DoctorDetailDangerCard(
                      doctor: doctor,
                      onRemoveDoctor: () => _showRemoveConfirmationDialog(context),
                    ),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }
}
