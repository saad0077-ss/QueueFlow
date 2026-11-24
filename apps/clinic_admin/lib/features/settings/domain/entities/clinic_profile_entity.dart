import 'dart:typed_data';
import 'package:equatable/equatable.dart';

class ClinicProfileEntity extends Equatable {
  final String name;
  final String adminName;
  final String address;
  final String phone;
  final String email;
  final String description;

  /// Legacy hosted photo URL, used only when no photo is stored in Firestore.
  final String imageUrl;

  /// Clinic photo stored in Firestore (`clinic_images/{clinicId}`).
  final Uint8List? imageBytes;

  const ClinicProfileEntity({
    this.name = '',
    this.adminName = '',
    this.address = '',
    this.phone = '',
    this.email = '',
    this.description = '',
    this.imageUrl = '',
    this.imageBytes,
  });

  ClinicProfileEntity copyWith({
    String? name,
    String? adminName,
    String? address,
    String? phone,
    String? email,
    String? description,
    String? imageUrl,
    Uint8List? imageBytes,
  }) {
    return ClinicProfileEntity(
      name: name ?? this.name,
      adminName: adminName ?? this.adminName,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      imageBytes: imageBytes ?? this.imageBytes,
    );
  }

  @override
  List<Object?> get props => [
    name,
    adminName,
    address,
    phone,
    email,
    description,
    imageUrl,
    imageBytes,
  ];
}
