import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/clinic_doctor_item.dart';

class ClinicDoctorModel extends ClinicDoctorItem {
  const ClinicDoctorModel({
    required super.id,
    required super.name,
    required super.initials,
    required super.title,
    super.specialty,
    super.schedule,
    super.isAvailable,
    super.services,
  });

  factory ClinicDoctorModel.fromFirestore(DocumentSnapshot doc) {
    final map = (doc.data() as Map<String, dynamic>?) ?? {};
    return ClinicDoctorModel.fromMap(map, id: doc.id);
  }

  factory ClinicDoctorModel.fromMap(Map<String, dynamic> map, {String? id}) {
    final name = (map['name'] ?? 'Doctor').toString().trim();
    String initials = 'DR';
    final parts = name.split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.length >= 2) {
      initials = '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    } else if (parts.isNotEmpty) {
      initials = parts[0].substring(0, parts[0].length >= 2 ? 2 : 1).toUpperCase();
    }

    final rawServices = (map['services'] as List<dynamic>?) ?? [];

    return ClinicDoctorModel(
      id: id ?? map['id'] ?? '',
      name: name,
      initials: (map['initials'] ?? initials).toString(),
      title: (map['title'] ?? map['specialty'] ?? 'Senior Consultant').toString(),
      specialty: (map['specialty'] ?? 'General Medicine').toString(),
      schedule: (map['schedule'] ?? 'Mon–Sat, 9:00 AM – 5:00 PM').toString(),
      isAvailable: map['isAvailable'] as bool? ?? true,
      services: rawServices.map((e) => e.toString()).toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'initials': initials,
      'title': title,
      'specialty': specialty,
      'schedule': schedule,
      'isAvailable': isAvailable,
      'services': services,
    };
  }
}
