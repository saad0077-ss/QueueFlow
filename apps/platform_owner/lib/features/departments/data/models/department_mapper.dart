import '../../domain/entities/department_entity.dart';
import '../../domain/entities/standard_service_entity.dart';

extension DepartmentEntityMapper on DepartmentEntity {
  Map<String, dynamic> toFirestoreMap() {
    return {
      'name': name,
      'code': code,
      'icon': icon,
      'color': color,
      'description': description,
      'avgConsultationTime': avgConsultationTime,
      'status': status,
      'doctorCount': doctorCount,
      'totalVisits': totalVisits,
      'assignedClinics': assignedClinics,
      'standardServices': standardServices.map((s) => s.toServiceMap()).toList(),
    };
  }
}

extension StandardServiceEntityMapper on StandardServiceEntity {
  Map<String, dynamic> toServiceMap() {
    return {'id': id, 'name': name, 'duration': duration, 'suggestedPrice': suggestedPrice, 'description': description};
  }
}
