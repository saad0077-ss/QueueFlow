import 'package:equatable/equatable.dart';

class ClinicStaffEntity extends Equatable {
  final String uid;
  final String email;
  final String name;
  final String role;
  final String clinicName;

  const ClinicStaffEntity({
    required this.uid,
    required this.email,
    required this.name,
    this.role = 'Clinic Admin',
    this.clinicName = 'Sunrise Health Clinic',
  });

  @override
  List<Object?> get props => [uid, email, name, role, clinicName];
}
