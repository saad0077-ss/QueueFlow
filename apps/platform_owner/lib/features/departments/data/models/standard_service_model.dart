import '../../domain/entities/standard_service_entity.dart';

class StandardServiceModel extends StandardServiceEntity {
  const StandardServiceModel({required super.id, required super.name, required super.duration, required super.suggestedPrice, required super.description});

  factory StandardServiceModel.fromMap(Map<String, dynamic> map, [String? id]) {
    return StandardServiceModel(
      id: id ?? map['id'] ?? 'svc-${DateTime.now().millisecondsSinceEpoch}',
      name: map['name'] ?? '',
      duration: (map['duration'] as num?)?.toInt() ?? 20,
      suggestedPrice: (map['suggestedPrice'] as num?)?.toInt() ?? 500,
      description: map['description'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'duration': duration, 'suggestedPrice': suggestedPrice, 'description': description};
  }
}
