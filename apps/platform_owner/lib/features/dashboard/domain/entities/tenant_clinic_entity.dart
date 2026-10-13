import 'package:equatable/equatable.dart';

class TenantClinicEntity extends Equatable {
  final String id;
  final String name;
  final String category;
  final String planId;
  final String status;

  const TenantClinicEntity({
    required this.id,
    required this.name,
    required this.category,
    required this.planId,
    required this.status,
  });

  bool get isActive => status == 'active';

  @override
  List<Object?> get props => [id, name, category, planId, status];
}
