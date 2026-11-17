import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

/// Holds the patient's current position and computes real distances to clinics.
class UserLocationService {
  UserLocationService._();

  /// Latest known position; listeners rebuild when it arrives or changes.
  static final ValueNotifier<Position?> position = ValueNotifier<Position?>(null);
  static bool _loading = false;

  /// Asks for permission (once) and reads the current position. Safe to call often.
  static Future<void> refresh() async {
    if (_loading) return;
    _loading = true;
    try {
      if (!await Geolocator.isLocationServiceEnabled()) return;
      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.denied || perm == LocationPermission.deniedForever) return;
      position.value = await Geolocator.getLastKnownPosition() ?? position.value;
      position.value = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 15),
        ),
      );
    } catch (e) {
      debugPrint('Location unavailable: $e');
    } finally {
      _loading = false;
    }
  }

  static double? distanceKm(double? lat, double? lng) {
    final p = position.value;
    if (p == null || lat == null || lng == null) return null;
    if (lat.abs() > 90 || lng.abs() > 180) return null;
    return Geolocator.distanceBetween(p.latitude, p.longitude, lat, lng) / 1000;
  }

  static String distanceLabel(double? lat, double? lng) {
    final km = distanceKm(lat, lng);
    if (km == null) return '';
    if (km < 1) return '${(km * 1000).round()} m';
    return '${km.toStringAsFixed(km < 10 ? 1 : 0)} km';
  }
}
