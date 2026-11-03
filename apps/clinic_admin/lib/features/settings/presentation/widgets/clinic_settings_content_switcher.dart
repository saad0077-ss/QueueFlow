import 'package:flutter/material.dart';
import '../../domain/entities/clinic_settings_entity.dart';
import '../bloc/clinic_settings_bloc.dart';
import '../bloc/clinic_settings_event.dart';
import 'clinic_location_panel.dart';
import 'clinic_operating_hours_panel.dart';
import 'clinic_profile_panel.dart';
import 'clinic_queue_rules_panel.dart';
import 'clinic_security_panel.dart';

class ClinicSettingsContentSwitcher extends StatelessWidget {
  final int activeTab;
  final ClinicSettingsEntity settings;
  final ClinicSettingsBloc bloc;
  final bool isUploadingImage;

  const ClinicSettingsContentSwitcher({
    super.key,
    required this.activeTab,
    required this.settings,
    required this.bloc,
    required this.isUploadingImage,
  });

  @override
  Widget build(BuildContext context) {
    switch (activeTab) {
      case 1:
        return ClinicLocationPanel(
          clinicName: settings.profile.name,
          location: settings.location,
          onSave: (loc) => bloc.add(ClinicSettingsLocationSaved(loc)),
        );
      case 2:
        return ClinicOperatingHoursPanel(
          schedule: settings.schedule,
          onDayChanged: (d) => bloc.add(ClinicSettingsDayUpdated(d)),
          onApplyPreset: (p) => bloc.add(ClinicSettingsPresetApplied(p)),
          onCopyMonday: () => bloc.add(const ClinicSettingsCopyMondayToWeekdays()),
          onSave: (s) => bloc.add(ClinicSettingsScheduleSaved(s)),
          onRevert: () => bloc.add(const ClinicSettingsStarted()),
        );
      case 3:
        return ClinicQueueRulesPanel(
          queueRules: settings.queueRules,
          onSave: (r) => bloc.add(ClinicSettingsQueueRulesSaved(r)),
        );
      case 4:
        return ClinicSecurityPanel(
          security: settings.security,
          onSave: ({required currentPassword, required newPassword, required requireTwoFactor}) {
            bloc.add(ClinicSettingsSecurityUpdated(
              currentPassword: currentPassword,
              newPassword: newPassword,
              requireTwoFactor: requireTwoFactor,
            ));
          },
        );
      case 0:
      default:
        return ClinicProfilePanel(
          profile: settings.profile,
          location: settings.location,
          onJumpToLocationTab: () => bloc.add(const ClinicSettingsTabChanged(1)),
          isUploadingImage: isUploadingImage,
          onImagePicked: (bytes, fileName) => bloc.add(ClinicSettingsProfileImagePicked(bytes: bytes, fileName: fileName)),
          onSave: (p) => bloc.add(ClinicSettingsProfileSaved(p)),
        );
    }
  }
}
