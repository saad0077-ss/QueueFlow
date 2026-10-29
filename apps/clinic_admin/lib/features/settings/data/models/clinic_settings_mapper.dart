import '../../domain/entities/clinic_location_entity.dart';
import '../../domain/entities/clinic_operating_schedule_entity.dart';
import '../../domain/entities/clinic_profile_entity.dart';
import '../../domain/entities/clinic_queue_rules_entity.dart';
import '../../domain/entities/clinic_settings_entity.dart';
import '../../domain/entities/operating_hours_day_entity.dart';
import 'clinic_schedule_defaults.dart';

class ClinicSettingsMapper {
  /// Reads a field as text, tolerating numbers (e.g. coordinates saved as doubles).
  static String _str(Map<String, dynamic> m, String key, [String fallback = '']) {
    final v = m[key];
    if (v == null) return fallback;
    final s = v.toString().trim();
    return s.isEmpty ? fallback : s;
  }

  static ClinicSettingsEntity fromFirestore(String clinicId, Map<String, dynamic> data) {
    final profile = ClinicProfileEntity(
      name: _str(data, 'name'),
      address: _str(data, 'address'),
      phone: _str(data, 'phone'),
      email: _str(data, 'email', _str(data, 'adminEmail')),
      imageUrl: _str(data, 'imageUrl'),
      description: _str(data, 'description'),
    );

    final rawLoc = data['location'];
    final locData = rawLoc is Map ? Map<String, dynamic>.from(rawLoc) : <String, dynamic>{};
    final location = ClinicLocationEntity(
      building: _str(locData, 'building'),
      street: _str(locData, 'street'),
      area: _str(locData, 'area'),
      city: _str(locData, 'city', _str(data, 'city')),
      state: _str(locData, 'state'),
      pincode: _str(locData, 'pincode'),
      landmark: _str(locData, 'landmark'),
      googleMapsUrl: _str(locData, 'googleMapsUrl'),
      latitude: _str(locData, 'latitude'),
      longitude: _str(locData, 'longitude'),
      parking: _str(locData, 'parking'),
      directions: _str(locData, 'directions'),
    );

    final rawHours = data['operatingHours'] as Map<String, dynamic>? ?? {};
    final daysMap = <String, OperatingHoursDayEntity>{};
    for (final def in ClinicScheduleDefaults.dayDefinitions) {
      final k = def['key']!;
      final n = def['name']!;
      if (rawHours.containsKey(k)) {
        final dData = rawHours[k] as Map<String, dynamic>;
        daysMap[k] = OperatingHoursDayEntity(
          dayKey: k,
          dayName: n,
          isOpen: dData['isOpen'] as bool? ?? true,
          openTime: dData['openTime'] as String? ?? '09:00',
          closeTime: dData['closeTime'] as String? ?? '20:00',
          hasBreak: dData['hasBreak'] as bool? ?? false,
          breakStart: dData['breakStart'] as String? ?? '13:00',
          breakEnd: dData['breakEnd'] as String? ?? '14:00',
        );
      } else {
        daysMap[k] = ClinicScheduleDefaults.defaultDays[k]!;
      }
    }

    final schedule = ClinicOperatingScheduleEntity(
      days: daysMap,
      queueCutoffMin: (data['queueCutoffMin'] as num?)?.toInt() ?? 30,
      slotDurationMin: (data['slotDurationMin'] as num?)?.toInt() ?? 20,
      emergencyOnCall: data['emergencyOnCall'] as bool? ?? true,
      emergencyPhone: _str(data, 'emergencyPhone'),
      holidayNotice: _str(data, 'holidayNotice'),
    );

    final queueRules = ClinicQueueRulesEntity(
      maxQueueCapacity: (data['maxQueueCapacity'] as num?)?.toInt() ?? 30,
      avgConsultationTimeMin: (data['avgConsultationTimeMin'] as num?)?.toInt() ?? 20,
      allowWalkIns: data['allowWalkIns'] as bool? ?? true,
    );

    return ClinicSettingsEntity(
      clinicId: clinicId,
      profile: profile,
      location: location,
      schedule: schedule,
      queueRules: queueRules,
      security: ClinicSecuritySettingsEntity(requireTwoFactor: data['requireTwoFactor'] as bool? ?? true),
      planName: _str(data, 'planName'),
      renewalDate: _str(data, 'currentPeriodEnd'),
    );
  }
}
