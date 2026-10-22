import 'package:equatable/equatable.dart';

/// Represents a standard service template inside a department.
class StandardServiceTemplate extends Equatable {
  final String name;
  final int duration;
  final int suggestedPrice;
  final String description;

  const StandardServiceTemplate({
    required this.name,
    this.duration = 20,
    this.suggestedPrice = 500,
    this.description = '',
  });

  @override
  List<Object?> get props => [name, duration, suggestedPrice, description];
}

/// Represents a medical department / specialty catalog item.
class ServiceDepartmentEntity extends Equatable {
  final String id;
  final String code;
  final String name;
  final String icon;
  final List<StandardServiceTemplate> standardServices;

  const ServiceDepartmentEntity({
    required this.id,
    required this.code,
    required this.name,
    this.icon = '🩺',
    this.standardServices = const [],
  });

  @override
  List<Object?> get props => [id, code, name, icon, standardServices];
}
