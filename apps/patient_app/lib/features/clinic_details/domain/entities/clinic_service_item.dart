import 'package:equatable/equatable.dart';

class ClinicServiceItem extends Equatable {
  final String id;
  final String name;
  final String description;
  final int duration;
  final int price;
  final String status;
  final String departmentName;

  const ClinicServiceItem({
    required this.id,
    required this.name,
    this.description = '',
    this.duration = 20,
    this.price = 500,
    this.status = 'active',
    this.departmentName = 'General',
  });

  String get formattedPrice => '₹${price.toString()}';
  String get formattedDuration => '$duration min';

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        duration,
        price,
        status,
        departmentName,
      ];
}
