import '../entities/clinic_doctor_profile_entity.dart';
import '../entities/doctor_daily_schedule.dart';
import '../entities/doctor_plan_entity.dart';

abstract class ClinicDoctorsRepository {
  /// Real-time stream of practicing doctors on the clinic roster.
  Stream<List<ClinicDoctorProfileEntity>> watchDoctors();

  /// Retrieves active plan quota (Solo, Multi, Unlimited) for the clinic.
  Future<DoctorPlanEntity> getDoctorPlan();

  /// Retrieves medical specialties / approved departments from Super Admin catalog.
  Future<List<String>> getDepartmentSpecialties();

  /// Adds a new practicing doctor to the roster.
  Future<void> addDoctor(ClinicDoctorProfileEntity doctor);

  /// Updates full profile details of an existing doctor.
  Future<void> updateDoctorProfile(ClinicDoctorProfileEntity doctor);

  /// Updates weekly schedule and slot duration for a doctor.
  Future<void> updateDoctorSchedule({
    required String doctorId,
    required Map<String, DoctorDailySchedule> schedule,
    required int slotDuration,
  });

  /// Updates account status ('active', 'inactive', 'pending') for a doctor.
  Future<void> setDoctorAccountStatus(String doctorId, String accountStatus);

  /// Updates live outpatient status ('available', 'busy', 'off-duty') for a doctor.
  Future<void> updateDoctorStatus(String doctorId, String status);

  /// Removes a doctor from the roster.
  Future<void> deleteDoctor(String doctorId);

  /// Calls the next patient in live queue for this doctor.
  Future<String?> callNextPatient(String doctorName);

  /// Gets the count of patients waiting in live queue.
  Future<int> getQueueWaitingCount();
}
