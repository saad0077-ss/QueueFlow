import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class ClinicAddressLookup {
  final String building;
  final String street;
  final String area;
  final String city;
  final String state;
  final String pincode;

  const ClinicAddressLookup({
    required this.building,
    required this.street,
    required this.area,
    required this.city,
    required this.state,
    required this.pincode,
  });
}

class ClinicGpsService {
  static Future<Position> determinePosition() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Device GPS location services are disabled. Please enable GPS.');
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions were denied by user.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permissions are permanently denied. Please enable them in system settings.');
    }

    return await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 15),
      ),
    );
  }

  static String buildMapsUrl(double lat, double lng) {
    final latStr = lat.toStringAsFixed(6);
    final lngStr = lng.toStringAsFixed(6);
    return 'https://www.google.com/maps/search/?api=1&query=$latStr,$lngStr';
  }

  /// Reverse-geocodes coordinates into address parts using OpenStreetMap Nominatim.
  static Future<ClinicAddressLookup> reverseGeocode(double lat, double lng) async {
    final uri = Uri.https('nominatim.openstreetmap.org', '/reverse', {
      'format': 'jsonv2',
      'lat': lat.toString(),
      'lon': lng.toString(),
      'addressdetails': '1',
      'accept-language': 'en',
    });

    final http.Response res;
    try {
      res = await http.get(uri).timeout(const Duration(seconds: 15));
    } catch (_) {
      throw Exception('Unable to reach the address lookup service. Check your connection.');
    }
    if (res.statusCode != 200) {
      throw Exception('Address lookup failed (HTTP ${res.statusCode}). Please try again.');
    }

    final body = jsonDecode(res.body) as Map<String, dynamic>;
    final address = body['address'];
    if (address is! Map<String, dynamic>) {
      throw Exception('No address found for these coordinates.');
    }

    String pick(List<String> keys) {
      for (final k in keys) {
        final v = address[k];
        if (v is String && v.trim().isNotEmpty) return v.trim();
      }
      return '';
    }

    final buildingName = pick(['building', 'amenity', 'office', 'shop', 'healthcare']);
    final houseNumber = pick(['house_number']);
    return ClinicAddressLookup(
      building: [buildingName, houseNumber].where((p) => p.isNotEmpty).join(', '),
      street: pick(['road', 'pedestrian', 'street']),
      area: pick(['suburb', 'neighbourhood', 'quarter', 'city_district', 'hamlet']),
      city: pick(['city', 'town', 'village', 'municipality', 'county', 'state_district']),
      state: pick(['state', 'region']),
      pincode: pick(['postcode']),
    );
  }
}
