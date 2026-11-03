import 'package:equatable/equatable.dart';

class ClinicDoctorItem extends Equatable {
  final String id;
  final String name;
  final String initials;
  final String title;
  final String specialty;
  final String schedule;
  final bool isAvailable;
  final List<String> services;

  const ClinicDoctorItem({
    required this.id,
    required this.name,
    required this.initials,
    required this.title,
    this.specialty = 'General Medicine',
    this.schedule = 'Mon–Sat, 9:00 AM – 5:00 PM',
    this.isAvailable = true,
    this.services = const [],
  });

  @override
  List<Object?> get props => [
        id,
        name,
        initials,
        title,
        specialty,
        schedule,
        isAvailable,
        services,
      ];
}
