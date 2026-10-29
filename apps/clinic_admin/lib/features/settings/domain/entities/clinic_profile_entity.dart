import 'dart:typed_data';
import 'package:equatable/equatable.dart';

class ClinicProfileEntity extends Equatable {
  final String name;
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
    this.address = '',
    this.phone = '',
    this.email = '',
    this.description = '',
    this.imageUrl = '',
    this.imageBytes,
  });

  ClinicProfileEntity copyWith({
    String? name,
    String? address,
    String? phone,
    String? email,
    String? description,
    String? imageUrl,
    Uint8List? imageBytes,
  }) {
    return ClinicProfileEntity(
      name: name ?? this.name,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      imageBytes: imageBytes ?? this.imageBytes,
    );
  }

  @override
  List<Object?> get props => [name, address, phone, email, description, imageUrl, imageBytes];
}
