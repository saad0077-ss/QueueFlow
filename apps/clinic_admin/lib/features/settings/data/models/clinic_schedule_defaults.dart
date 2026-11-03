import '../../domain/entities/operating_hours_day_entity.dart';

/// Default weekly hours for clinics that have not saved a schedule, plus the
/// one-click schedule presets.
class ClinicScheduleDefaults {
  static const List<Map<String, String>> dayDefinitions = [
    {'key': 'monday', 'name': 'Monday'},
    {'key': 'tuesday', 'name': 'Tuesday'},
    {'key': 'wednesday', 'name': 'Wednesday'},
    {'key': 'thursday', 'name': 'Thursday'},
    {'key': 'friday', 'name': 'Friday'},
    {'key': 'saturday', 'name': 'Saturday'},
    {'key': 'sunday', 'name': 'Sunday'},
  ];

  static Map<String, OperatingHoursDayEntity> get defaultDays => {
    'monday': const OperatingHoursDayEntity(dayKey: 'monday', dayName: 'Monday', isOpen: true, openTime: '09:00', closeTime: '20:00', hasBreak: true, breakStart: '13:00', breakEnd: '14:00'),
    'tuesday': const OperatingHoursDayEntity(dayKey: 'tuesday', dayName: 'Tuesday', isOpen: true, openTime: '09:00', closeTime: '20:00', hasBreak: true, breakStart: '13:00', breakEnd: '14:00'),
    'wednesday': const OperatingHoursDayEntity(dayKey: 'wednesday', dayName: 'Wednesday', isOpen: true, openTime: '09:00', closeTime: '20:00', hasBreak: true, breakStart: '13:00', breakEnd: '14:00'),
    'thursday': const OperatingHoursDayEntity(dayKey: 'thursday', dayName: 'Thursday', isOpen: true, openTime: '09:00', closeTime: '20:00', hasBreak: true, breakStart: '13:00', breakEnd: '14:00'),
    'friday': const OperatingHoursDayEntity(dayKey: 'friday', dayName: 'Friday', isOpen: true, openTime: '09:00', closeTime: '20:00', hasBreak: true, breakStart: '13:00', breakEnd: '14:00'),
    'saturday': const OperatingHoursDayEntity(dayKey: 'saturday', dayName: 'Saturday', isOpen: true, openTime: '10:00', closeTime: '18:00', hasBreak: false),
    'sunday': const OperatingHoursDayEntity(dayKey: 'sunday', dayName: 'Sunday', isOpen: false, openTime: '10:00', closeTime: '14:00', hasBreak: false),
  };

  static Map<String, OperatingHoursDayEntity> getPreset(String key) {
    final m = <String, OperatingHoursDayEntity>{};
    for (final d in dayDefinitions) {
      final k = d['key']!;
      final n = d['name']!;
      final isSun = k == 'sunday';
      final isSat = k == 'saturday';

      if (key == 'seven_days') {
        m[k] = OperatingHoursDayEntity(dayKey: k, dayName: n, isOpen: true, openTime: '09:00', closeTime: '21:00');
      } else if (key == 'weekdays') {
        m[k] = OperatingHoursDayEntity(dayKey: k, dayName: n, isOpen: !isSun && !isSat, openTime: '08:00', closeTime: '17:00');
      } else if (key == 'split') {
        m[k] = OperatingHoursDayEntity(dayKey: k, dayName: n, isOpen: !isSun, openTime: '09:00', closeTime: '20:00', hasBreak: true, breakStart: '13:00', breakEnd: '15:00');
      } else {
        // standard
        m[k] = OperatingHoursDayEntity(dayKey: k, dayName: n, isOpen: !isSun, openTime: isSat ? '10:00' : '09:00', closeTime: isSat ? '18:00' : '20:00');
      }
    }
    return m;
  }
}
