import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';
import '../../domain/entities/clinic_doctor_profile_entity.dart';
import 'doctor_ui_kit.dart';

class DoctorCard extends StatelessWidget {
  final ClinicDoctorProfileEntity doctor;
  final int totalDoctors;
  final ValueChanged<String> onStatusChange;
  final VoidCallback onCallNext;
  final VoidCallback onViewQueue;
  final VoidCallback? onSelectDoctor;
  final VoidCallback onDelete;

  const DoctorCard({
    super.key,
    required this.doctor,
    required this.totalDoctors,
    required this.onStatusChange,
    required this.onCallNext,
    required this.onViewQueue,
    this.onSelectDoctor,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    Color statusColor;
    String statusLabel;
    final isActiveAccount = doctor.isActiveAccount;
    if (doctor.isInactiveAccount) {
      statusColor = colors.error;
      statusLabel = 'INACTIVE';
    } else if (doctor.isPendingAccount) {
      statusColor = colors.warning;
      statusLabel = 'PENDING';
    } else if (doctor.isBusy) {
      statusColor = colors.info;
      statusLabel = 'IN CONSULTATION';
    } else if (doctor.isOffDuty) {
      statusColor = colors.warning;
      statusLabel = 'OFF DUTY';
    } else {
      statusColor = colors.success;
      statusLabel = 'AVAILABLE';
    }

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isActiveAccount
              ? colors.border
              : statusColor.withValues(alpha: 0.4),
        ),
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                onTap: onSelectDoctor,
                borderRadius: BorderRadius.circular(10),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top row: Avatar & Status/Room pills
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          DoctorAvatar(
                            photoUrl: doctor.photoUrl,
                            initials: doctor.initials,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: statusColor.withValues(alpha: 0.18),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: statusColor.withValues(
                                        alpha: 0.35,
                                      ),
                                    ),
                                  ),
                                  child: Text(
                                    statusLabel,
                                    style: GoogleFonts.inter(
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.5,
                                      color: statusColor,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 7,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: colors.surfaceSecondary,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: colors.border,
                                    ),
                                  ),
                                  child: Text(
                                    doctor.room.isNotEmpty
                                        ? doctor.room
                                        : 'Room 1 (Consultation)',
                                    style: GoogleFonts.inter(
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.w600,
                                      color: colors.success,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Doctor Name & Specialty
                      Text(
                        doctor.name,
                        style: GoogleFonts.inter(
                          fontSize: 16.5,
                          fontWeight: FontWeight.w800,
                          color: colors.textPrimary,
                          letterSpacing: -0.3,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        doctor.specialty.isNotEmpty
                            ? doctor.specialty
                            : doctor.title,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: colors.primaryLight,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
              if (!isActiveAccount) ...[
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: statusColor.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        doctor.isPendingAccount
                            ? Icons.hourglass_top_rounded
                            : Icons.block_rounded,
                        size: 14,
                        color: statusColor,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          doctor.isPendingAccount
                              ? 'Verification pending. Patients cannot book this doctor yet.'
                              : 'Inactive. Hidden from patient booking and the live queue.',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: const Color(0xFFE2E8F0),
                            height: 1.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 12),

              // Live Consultation & Queue Line box
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: colors.surfaceSecondary,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: colors.border),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            'LIVE CONSULTATION:',
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: colors.textMuted,
                              letterSpacing: 0.4,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          doctor.nowServing != null &&
                                  doctor.nowServing!.isNotEmpty &&
                                  doctor.nowServing != '—'
                              ? 'Token ${doctor.nowServing}'
                              : 'Ready for next',
                          style: GoogleFonts.inter(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w800,
                            color: colors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            'QUEUE LINE:',
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: colors.textMuted,
                              letterSpacing: 0.4,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: colors.successTint,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${doctor.waitingCount} waiting',
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: colors.success,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              // Metadata rows
              Row(
                children: [
                  Container(
                    width: 4,
                    height: 12,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF97316),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      doctor.room.isNotEmpty
                          ? doctor.room
                          : 'Room 1 (Consultation)',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: colors.textMuted,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(
                    Icons.access_time_rounded,
                    size: 13,
                    color: Color(0xFF94A3B8),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      doctor.schedule.isNotEmpty
                          ? doctor.schedule
                          : 'Mon–Fri, 9:00 AM – 5:00 PM',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: colors.textMuted,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(
                    Icons.phone_outlined,
                    size: 13,
                    color: Color(0xFFEC4899),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      doctor.phone.isNotEmpty
                          ? doctor.phone
                          : '+91 98450 00001',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: colors.textMuted,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Actions section at bottom
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Column(
              children: [
                Divider(color: colors.border, height: 1),
                const SizedBox(height: 10),

                // Real-Time Status Quick Toggles
                Row(
                  children: [
                    Expanded(
                      child: _buildStatusToggleBtn(
                        colors: colors,
                        label: '✓ Available',
                        status: 'available',
                        isActive: doctor.isAvailable,
                        activeColor: colors.success,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: _buildStatusToggleBtn(
                        colors: colors,
                        label: '🩺 In Consult',
                        status: 'busy',
                        isActive: doctor.isBusy,
                        activeColor: colors.info,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: _buildStatusToggleBtn(
                        colors: colors,
                        label: '☕ Off Duty',
                        status: 'off-duty',
                        isActive: doctor.isOffDuty,
                        activeColor: colors.warning,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Queue calling actions
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Opacity(
                        opacity: isActiveAccount ? 1 : 0.4,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF2563EB), Color(0xFF06B6D4)],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ElevatedButton(
                            onPressed: isActiveAccount ? onCallNext : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                vertical: 8,
                                horizontal: 4,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              elevation: 0,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  '📞',
                                  style: TextStyle(fontSize: 11),
                                ),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    'Call Next Patient',
                                    style: GoogleFonts.inter(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      flex: 2,
                      child: OutlinedButton(
                        onPressed: onSelectDoctor ?? onViewQueue,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: colors.textPrimary,
                          side: BorderSide(color: colors.border),
                          backgroundColor: colors.surfaceSecondary,
                          padding: const EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 4,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'View Profile',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    if (totalDoctors > 1) ...[
                      const SizedBox(width: 6),
                      IconButton(
                        onPressed: onDelete,
                        icon: const Text('🗑️', style: TextStyle(fontSize: 13)),
                        tooltip: 'Remove doctor',
                        style: IconButton.styleFrom(
                          backgroundColor: colors.error.withValues(alpha: 0.1),
                          side: BorderSide(
                            color: colors.error.withValues(alpha: 0.3),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.all(6),
                          minimumSize: const Size(34, 34),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusToggleBtn({
    required AppColorsExtension colors,
    required String label,
    required String status,
    required bool isActive,
    required Color activeColor,
  }) {
    final enabled = doctor.isActiveAccount;
    return Opacity(
      opacity: enabled ? 1 : 0.4,
      child: InkWell(
        onTap: enabled ? () => onStatusChange(status) : null,
        borderRadius: BorderRadius.circular(6),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 3),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isActive
                ? activeColor.withValues(alpha: 0.18)
                : colors.surfaceSecondary,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: isActive ? activeColor : colors.border,
              width: isActive ? 1.5 : 1.0,
            ),
          ),
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
              color: isActive ? activeColor : colors.textMuted,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }
}
