import 'package:equatable/equatable.dart';

/// A practicing doctor registered on the clinic, assignable to services.
class ClinicDoctorEntity extends Equatable {
  final String name;
  final String specialty;
  final String department;
  final String room;

  const ClinicDoctorEntity({
    required this.name,
    this.specialty = '',
    this.department = '',
    this.room = '',
  });

  /// Secondary line shown next to the doctor's name, e.g. "Room 1 • Dental & Oral Surgery".
  String get detail {
    final deptOrSpec = department.isNotEmpty ? department : specialty;
    final parts = [if (room.isNotEmpty) room, if (deptOrSpec.isNotEmpty) deptOrSpec];
    return parts.join(' • ');
  }

  @override
  List<Object?> get props => [name, specialty, department, room];
}
