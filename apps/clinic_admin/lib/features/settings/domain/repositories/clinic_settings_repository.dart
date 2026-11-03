import 'dart:typed_data';
import '../entities/clinic_location_entity.dart';
import '../entities/clinic_operating_schedule_entity.dart';
import '../entities/clinic_profile_entity.dart';
import '../entities/clinic_queue_rules_entity.dart';
import '../entities/clinic_settings_entity.dart';

abstract class ClinicSettingsRepository {
  Future<ClinicSettingsEntity> getClinicSettings();

  Future<void> saveProfile(ClinicProfileEntity profile);

  /// Stores the clinic photo in Firestore (`clinic_images/{clinicId}`).
  Future<void> uploadProfileImage(Uint8List bytes, String fileName);

  Future<void> saveLocation(ClinicLocationEntity location);

  Future<void> saveOperatingSchedule(ClinicOperatingScheduleEntity schedule);

  Future<void> saveQueueRules(ClinicQueueRulesEntity rules);

  Future<void> updateSecurity({
    required String currentPassword,
    required String newPassword,
    required bool requireTwoFactor,
  });
}
