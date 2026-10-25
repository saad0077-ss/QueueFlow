import '../entities/department_entity.dart';
import '../entities/dept_expansion_request_entity.dart';
import '../entities/dept_service_request_entity.dart';
import '../entities/standard_service_entity.dart';

abstract class DepartmentRepository {
  Stream<List<DepartmentEntity>> watchDepartments();
  Stream<List<DeptExpansionRequestEntity>> watchExpansionRequests();
  Stream<List<DeptServiceRequestEntity>> watchServiceRequests();

  Future<void> seedDepartmentsIfEmpty();
  Future<void> purgeSampleRequests();
  Future<void> addDepartment(DepartmentEntity department);
  Future<void> updateDepartment(DepartmentEntity department);
  Future<void> toggleDepartmentStatus(String id, bool currentStatus);
  Future<void> deleteDepartment(String id);

  Future<void> addStandardService(String departmentId, StandardServiceEntity service);
  Future<void> updateStandardService(String departmentId, StandardServiceEntity service);
  Future<void> removeStandardService(String departmentId, String serviceId);

  Future<void> approveExpansionRequest(String requestId);
  Future<void> rejectExpansionRequest(String requestId, String reason);

  Future<void> approveServiceRequest(String requestId);
  Future<void> rejectServiceRequest(String requestId, String reason);
}
