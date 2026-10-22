/// Preset icon / accent-color choices offered in the specialty forms.
/// Each map is `value -> display label`.
const Map<String, String> kSpecialtyIconOptions = {
  '🩺': 'General Medicine',
  '🦷': 'Dental Care',
  '👶': 'Pediatrics',
  '✨': 'Dermatology',
  '❤️': 'Cardiology',
  '🦴': 'Orthopedics',
  '👂': 'ENT',
  '👁️': 'Ophthalmology',
  '🧠': 'Neurology',
  '🔬': 'Pathology & Lab',
  '🩻': 'Radiology',
};

const Map<String, String> kSpecialtyColorOptions = {
  '#2563EB': 'Blue',
  '#0D9488': 'Teal',
  '#F59E0B': 'Amber',
  '#EC4899': 'Pink',
  '#EF4444': 'Red',
  '#8B5CF6': 'Violet',
  '#06B6D4': 'Cyan',
};

/// Sentinel dropdown value that switches a picker into custom-entry mode.
const String kCustomOptionValue = '__custom__';
