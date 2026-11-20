import 'package:flutter_test/flutter_test.dart';
import 'package:clinic_admin/features/queue/domain/utils/clinic_token_generator.dart';

void main() {
  group('ClinicTokenGenerator', () {
    test('extracts clinic prefix correctly', () {
      expect(
        ClinicTokenGenerator.extractClinicPrefix('Sunrise Health Clinic'),
        'SH',
      );
      expect(
        ClinicTokenGenerator.extractClinicPrefix('Smile Dental Clinic'),
        'SD',
      );
      expect(
        ClinicTokenGenerator.extractClinicPrefix('CityCare General Clinic'),
        'CG',
      );
      expect(ClinicTokenGenerator.extractClinicPrefix('Apollo Hospital'), 'AH');
      expect(ClinicTokenGenerator.extractClinicPrefix('Care'), 'CA');
      expect(ClinicTokenGenerator.extractClinicPrefix(''), 'QF');
    });

    test('extracts service code correctly', () {
      expect(
        ClinicTokenGenerator.extractServiceCode('General Consultation'),
        'GC',
      );
      expect(
        ClinicTokenGenerator.extractServiceCode('Dental Checkup & Cleaning'),
        'DC',
      );
      expect(
        ClinicTokenGenerator.extractServiceCode('Follow-up Visit & Review'),
        'FV',
      );
      expect(
        ClinicTokenGenerator.extractServiceCode('Pediatric Health Checkup'),
        'PH',
      );
      expect(
        ClinicTokenGenerator.extractServiceCode(
          'Skin Allergy & Rash Assessment',
        ),
        'SA',
      );
      expect(ClinicTokenGenerator.extractServiceCode('Consultation'), 'CON');
      expect(ClinicTokenGenerator.extractServiceCode(''), 'GEN');
    });

    test(
      'generates full structured tokens with independent service sequence',
      () {
        final tokenGC1 = ClinicTokenGenerator.generateToken(
          clinicName: 'Sunrise Health Clinic',
          serviceName: 'General Consultation',
          sequenceNumber: 1,
        );
        expect(tokenGC1, 'SH-GC-001');

        final tokenGC2 = ClinicTokenGenerator.generateToken(
          clinicName: 'Sunrise Health Clinic',
          serviceName: 'General Consultation',
          sequenceNumber: 2,
        );
        expect(tokenGC2, 'SH-GC-002');

        final tokenDC1 = ClinicTokenGenerator.generateToken(
          clinicName: 'Sunrise Health Clinic',
          serviceName: 'Dental Checkup & Cleaning',
          sequenceNumber: 1,
        );
        expect(tokenDC1, 'SH-DC-001');

        final tokenSD1 = ClinicTokenGenerator.generateToken(
          clinicName: 'Smile Dental Clinic',
          serviceName: 'Dental Checkup & Cleaning',
          sequenceNumber: 1,
        );
        expect(tokenSD1, 'SD-DC-001');
      },
    );

    test('parses sequence numbers from tokens', () {
      expect(ClinicTokenGenerator.parseSequenceNumber('SH-GC-001'), 1);
      expect(ClinicTokenGenerator.parseSequenceNumber('SH-GC-025'), 25);
      expect(ClinicTokenGenerator.parseSequenceNumber('A-021'), 21);
      expect(ClinicTokenGenerator.parseSequenceNumber('INVALID'), null);
    });
  });
}
