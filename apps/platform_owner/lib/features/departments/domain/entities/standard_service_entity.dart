import 'package:equatable/equatable.dart';

class StandardServiceEntity extends Equatable {
  final String id;
  final String name;
  final int duration;
  final int suggestedPrice;
  final String description;

  const StandardServiceEntity({required this.id, required this.name, required this.duration, required this.suggestedPrice, required this.description});

  @override
  List<Object?> get props => [id, name, duration, suggestedPrice, description];
}
