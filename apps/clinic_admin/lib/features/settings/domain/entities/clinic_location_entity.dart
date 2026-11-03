import 'package:equatable/equatable.dart';

class ClinicLocationEntity extends Equatable {
  final String building;
  final String street;
  final String area;
  final String city;
  final String state;
  final String pincode;
  final String landmark;
  final String googleMapsUrl;
  final String latitude;
  final String longitude;
  final String parking;
  final String directions;

  const ClinicLocationEntity({
    this.building = '',
    this.street = '',
    this.area = '',
    this.city = '',
    this.state = '',
    this.pincode = '',
    this.landmark = '',
    this.googleMapsUrl = '',
    this.latitude = '',
    this.longitude = '',
    this.parking = '',
    this.directions = '',
  });

  bool get hasCoordinates =>
      latitude.trim().isNotEmpty && longitude.trim().isNotEmpty;

  String get fullAddress {
    final parts = [building, street, area, city, state, pincode]
        .where((s) => s.trim().isNotEmpty)
        .toList();
    return parts.join(', ');
  }

  ClinicLocationEntity copyWith({
    String? building,
    String? street,
    String? area,
    String? city,
    String? state,
    String? pincode,
    String? landmark,
    String? googleMapsUrl,
    String? latitude,
    String? longitude,
    String? parking,
    String? directions,
  }) {
    return ClinicLocationEntity(
      building: building ?? this.building,
      street: street ?? this.street,
      area: area ?? this.area,
      city: city ?? this.city,
      state: state ?? this.state,
      pincode: pincode ?? this.pincode,
      landmark: landmark ?? this.landmark,
      googleMapsUrl: googleMapsUrl ?? this.googleMapsUrl,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      parking: parking ?? this.parking,
      directions: directions ?? this.directions,
    );
  }

  @override
  List<Object?> get props => [
    building,
    street,
    area,
    city,
    state,
    pincode,
    landmark,
    googleMapsUrl,
    latitude,
    longitude,
    parking,
    directions,
  ];
}
