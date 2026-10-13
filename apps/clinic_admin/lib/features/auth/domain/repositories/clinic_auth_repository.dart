import '../entities/clinic_staff_entity.dart';

abstract class ClinicAuthRepository {
  Future<ClinicStaffEntity> signIn({
    required String email,
    required String password,
  });

  Future<ClinicStaffEntity> activateAccount({
    required String email,
    required String password,
    required String doctorName,
    required String role,
    required String clinicName,
  });

  Future<void> sendPasswordReset(String email);

  Future<void> signOut();
}
