import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/clinic_staff_entity.dart';

class ClinicStaffModel extends ClinicStaffEntity {
  const ClinicStaffModel({
    required super.uid,
    required super.email,
    required super.name,
    super.role,
    super.clinicName,
  });

  factory ClinicStaffModel.fromFirebaseUser(
    User user, {
    String? fallbackName,
    String role = 'Clinic Admin',
    String clinicName = 'Sunrise Health Clinic',
  }) {
    return ClinicStaffModel(
      uid: user.uid,
      email: user.email ?? '',
      name: user.displayName ?? fallbackName ?? 'Clinic Staff',
      role: role,
      clinicName: clinicName,
    );
  }
}
