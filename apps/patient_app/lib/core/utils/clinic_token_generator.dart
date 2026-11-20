/// Utility for generating structured, service-specific queue tokens.
///
/// Token format: `<ClinicPrefix>-<ServiceCode>-<3-DigitSequenceNumber>`
/// Examples:
/// - Sunrise Health Clinic + General Consultation -> `SH-GC-001`
/// - Sunrise Health Clinic + Dental Checkup & Cleaning -> `SH-DC-001`
/// - Smile Dental Clinic + Dental Checkup -> `SD-DC-001`
/// - CityCare General Clinic + Pediatric Health -> `CC-PH-001`
class ClinicTokenGenerator {
  const ClinicTokenGenerator._();

  /// Extracts a 2-3 character uppercase prefix representing the clinic name.
  ///
  /// Examples:
  /// - "Sunrise Health Clinic" -> "SH"
  /// - "CityCare General Clinic" -> "CC"
  /// - "Smile Dental Clinic" -> "SD"
  /// - "Apollo Clinic" -> "AC"
  /// - "Care" -> "CA"
  static String extractClinicPrefix(String clinicName) {
    final clean = clinicName.trim();
    if (clean.isEmpty) return 'QF';

    final words = clean
        .split(RegExp(r'[\s\-_]+'))
        .where((w) => w.isNotEmpty)
        .toList();

    if (words.length >= 2) {
      // First letters of the first two significant words
      final first = words[0][0].toUpperCase();
      final second = words[1][0].toUpperCase();
      return '$first$second';
    } else if (words.isNotEmpty) {
      final w = words.first
          .replaceAll(RegExp(r'[^a-zA-Z0-9]'), '')
          .toUpperCase();
      return w.length >= 2 ? w.substring(0, 2) : w.padRight(2, 'X');
    }
    return 'CL';
  }

  /// Extracts a 2-3 character uppercase code representing the service name.
  ///
  /// Stopwords like "and", "&", "the", "for", "with" are stripped.
  /// Examples:
  /// - "General Consultation" -> "GC"
  /// - "Dental Checkup & Cleaning" -> "DC"
  /// - "Follow-up Visit & Review" -> "FV"
  /// - "Pediatric Health Checkup" -> "PC"
  /// - "Skin Allergy & Rash Assessment" -> "SA"
  /// - "Consultation" -> "CON"
  static String extractServiceCode(String serviceName) {
    final clean = serviceName.trim();
    if (clean.isEmpty) return 'GEN';

    const stopWords = {
      'and',
      '&',
      'the',
      'for',
      'with',
      'of',
      'in',
      'to',
      'at',
      'by',
      'up',
      'on',
      'an',
      'a',
    };

    final words = clean
        .split(RegExp(r'[\s\-_/]+'))
        .where((w) => w.isNotEmpty && !stopWords.contains(w.toLowerCase()))
        .toList();

    if (words.length >= 2) {
      final first = words[0][0].toUpperCase();
      final second = words[1][0].toUpperCase();
      return '$first$second';
    } else if (words.isNotEmpty) {
      final w = words.first
          .replaceAll(RegExp(r'[^a-zA-Z0-9]'), '')
          .toUpperCase();
      return w.length >= 3 ? w.substring(0, 3) : w.padRight(2, 'S');
    }
    return 'GEN';
  }

  /// Combines clinic prefix, service code, and zero-padded sequence number.
  ///
  /// Every service tracks its own separate sequence number starting from 1 (e.g. 001).
  static String generateToken({
    required String clinicName,
    required String serviceName,
    required int sequenceNumber,
  }) {
    final clinicPrefix = extractClinicPrefix(clinicName);
    final serviceCode = extractServiceCode(serviceName);
    final seq = sequenceNumber.toString().padLeft(3, '0');
    return '$clinicPrefix-$serviceCode-$seq';
  }

  /// Parses the trailing integer number from any token.
  ///
  /// Matches both new format (e.g. 'SH-GC-005' -> 5)
  /// and legacy formats (e.g. 'A-021' -> 21).
  static int? parseSequenceNumber(String token) {
    final parts = token.trim().split('-');
    if (parts.isNotEmpty) {
      final last = parts.last.replaceAll(RegExp(r'[^0-9]'), '');
      return int.tryParse(last);
    }
    return null;
  }
}
