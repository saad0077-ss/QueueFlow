import '../entities/clinic_doctor_entity.dart';
import '../entities/clinic_service_entity.dart';
import '../entities/service_department_entity.dart';
import '../entities/service_plan_entity.dart';

/// Repository contract for clinic services feature.
abstract class ClinicServicesRepository {
  /// Watches real-time list of clinic services.
  Stream<List<ClinicServiceEntity>> watchServices();

  /// Gets the active departments the platform admin assigned to this clinic,
  /// along with their standard service catalog.
  Future<List<ServiceDepartmentEntity>> getDepartments();

  /// Gets current clinic service quota and subscription plan info.
  Future<ServicePlanEntity> getServicePlan();

  /// Gets the practicing doctors registered on this clinic.
  Future<List<ClinicDoctorEntity>> getDoctors();

  /// Creates a new service or updates an existing one.
  Future<void> saveService(ClinicServiceEntity service);

  /// Toggles service status between active and inactive.
  Future<void> toggleServiceStatus(String serviceId, String currentStatus);

  /// Deletes a service permanently.
  Future<void> deleteService(String serviceId);
}
