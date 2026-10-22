import 'package:equatable/equatable.dart';

/// A practicing doctor registered on the clinic, assignable to services.
class ClinicDoctorEntity extends Equatable {
  final String name;
  final String specialty;
  final String room;

  const ClinicDoctorEntity({
    required this.name,
    this.specialty = 'General & Family Medicine',
    this.room = 'Room 1 (Consultation)',
  });

  /// Secondary line shown next to the doctor's name, e.g. "Room 1 • Dental".
  String get detail => '$room • $specialty';

  @override
  List<Object?> get props => [name, specialty, room];
}
