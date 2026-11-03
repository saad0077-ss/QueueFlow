import 'dart:typed_data';
import 'package:equatable/equatable.dart';
import '../../domain/entities/clinic_location_entity.dart';
import '../../domain/entities/clinic_operating_schedule_entity.dart';
import '../../domain/entities/clinic_profile_entity.dart';
import '../../domain/entities/clinic_queue_rules_entity.dart';
import '../../domain/entities/operating_hours_day_entity.dart';

abstract class ClinicSettingsEvent extends Equatable {
  const ClinicSettingsEvent();

  @override
  List<Object?> get props => [];
}

class ClinicSettingsStarted extends ClinicSettingsEvent {
  const ClinicSettingsStarted();
}

class ClinicSettingsTabChanged extends ClinicSettingsEvent {
  final int activeTab; // 0: Profile, 1: Location, 2: Hours, 3: Rules, 4: Security

  const ClinicSettingsTabChanged(this.activeTab);

  @override
  List<Object?> get props => [activeTab];
}

class ClinicSettingsProfileImagePicked extends ClinicSettingsEvent {
  final Uint8List bytes;
  final String fileName;

  const ClinicSettingsProfileImagePicked({required this.bytes, required this.fileName});

  @override
  List<Object?> get props => [fileName, bytes.length];
}

class ClinicSettingsProfileSaved extends ClinicSettingsEvent {
  final ClinicProfileEntity profile;

  const ClinicSettingsProfileSaved(this.profile);

  @override
  List<Object?> get props => [profile];
}

class ClinicSettingsLocationSaved extends ClinicSettingsEvent {
  final ClinicLocationEntity location;

  const ClinicSettingsLocationSaved(this.location);

  @override
  List<Object?> get props => [location];
}

class ClinicSettingsScheduleSaved extends ClinicSettingsEvent {
  final ClinicOperatingScheduleEntity schedule;

  const ClinicSettingsScheduleSaved(this.schedule);

  @override
  List<Object?> get props => [schedule];
}

class ClinicSettingsDayUpdated extends ClinicSettingsEvent {
  final OperatingHoursDayEntity day;

  const ClinicSettingsDayUpdated(this.day);

  @override
  List<Object?> get props => [day];
}

class ClinicSettingsPresetApplied extends ClinicSettingsEvent {
  final String presetKey; // 'standard', 'seven_days', 'weekdays', 'split'

  const ClinicSettingsPresetApplied(this.presetKey);

  @override
  List<Object?> get props => [presetKey];
}

class ClinicSettingsCopyMondayToWeekdays extends ClinicSettingsEvent {
  const ClinicSettingsCopyMondayToWeekdays();
}

class ClinicSettingsQueueRulesSaved extends ClinicSettingsEvent {
  final ClinicQueueRulesEntity rules;

  const ClinicSettingsQueueRulesSaved(this.rules);

  @override
  List<Object?> get props => [rules];
}

class ClinicSettingsSecurityUpdated extends ClinicSettingsEvent {
  final String currentPassword;
  final String newPassword;
  final bool requireTwoFactor;

  const ClinicSettingsSecurityUpdated({
    required this.currentPassword,
    required this.newPassword,
    required this.requireTwoFactor,
  });

  @override
  List<Object?> get props => [currentPassword, newPassword, requireTwoFactor];
}

class ClinicSettingsFeedbackDismissed extends ClinicSettingsEvent {
  const ClinicSettingsFeedbackDismissed();
}
