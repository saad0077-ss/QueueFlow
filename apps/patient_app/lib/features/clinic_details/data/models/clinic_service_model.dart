import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/clinic_service_item.dart';

class ClinicServiceModel extends ClinicServiceItem {
  const ClinicServiceModel({
    required super.id,
    required super.name,
    super.description,
    super.duration,
    super.price,
    super.status,
    super.departmentName,
  });

  factory ClinicServiceModel.fromFirestore(DocumentSnapshot doc) {
    final map = (doc.data() as Map<String, dynamic>?) ?? {};
    return ClinicServiceModel.fromMap(map, id: doc.id);
  }

  factory ClinicServiceModel.fromMap(Map<String, dynamic> map, {String? id}) {
    return ClinicServiceModel(
      id: id ?? map['id'] ?? '',
      name: (map['name'] ?? 'Consultation').toString(),
      description: (map['description'] ?? '').toString(),
      duration: (map['duration'] as num?)?.toInt() ?? 20,
      price: (map['price'] as num?)?.toInt() ?? 500,
      status: (map['status'] ?? 'active').toString().toLowerCase(),
      departmentName: (map['departmentName'] ?? 'General').toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'duration': duration,
      'price': price,
      'status': status,
      'departmentName': departmentName,
    };
  }
}
