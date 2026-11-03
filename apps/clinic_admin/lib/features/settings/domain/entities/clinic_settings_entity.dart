import 'package:equatable/equatable.dart';
import 'clinic_location_entity.dart';
import 'clinic_operating_schedule_entity.dart';
import 'clinic_profile_entity.dart';
import 'clinic_queue_rules_entity.dart';

class ClinicSettingsEntity extends Equatable {
  final String clinicId;
  final ClinicProfileEntity profile;
  final ClinicLocationEntity location;
  final ClinicOperatingScheduleEntity schedule;
  final ClinicQueueRulesEntity queueRules;
  final ClinicSecuritySettingsEntity security;
  final String planName;
  final String renewalDate;

  const ClinicSettingsEntity({
    required this.clinicId,
    required this.profile,
    required this.location,
    required this.schedule,
    required this.queueRules,
    required this.security,
    this.planName = 'Pro Clinic Tier',
    this.renewalDate = '',
  });

  ClinicSettingsEntity copyWith({
    String? clinicId,
    ClinicProfileEntity? profile,
    ClinicLocationEntity? location,
    ClinicOperatingScheduleEntity? schedule,
    ClinicQueueRulesEntity? queueRules,
    ClinicSecuritySettingsEntity? security,
    String? planName,
    String? renewalDate,
  }) {
    return ClinicSettingsEntity(
      clinicId: clinicId ?? this.clinicId,
      profile: profile ?? this.profile,
      location: location ?? this.location,
      schedule: schedule ?? this.schedule,
      queueRules: queueRules ?? this.queueRules,
      security: security ?? this.security,
      planName: planName ?? this.planName,
      renewalDate: renewalDate ?? this.renewalDate,
    );
  }

  @override
  List<Object?> get props => [
    clinicId,
    profile,
    location,
    schedule,
    queueRules,
    security,
    planName,
    renewalDate,
  ];
}
