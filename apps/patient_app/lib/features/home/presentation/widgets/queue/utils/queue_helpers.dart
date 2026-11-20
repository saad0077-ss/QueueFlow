import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../domain/entities/clinic_entity.dart';

FirebaseFirestore? safeFirestore() {
  try {
    if (Firebase.apps.isNotEmpty) return FirebaseFirestore.instance;
  } catch (_) {}
  return null;
}

FirebaseAuth? safeAuth() {
  try {
    if (Firebase.apps.isNotEmpty) return FirebaseAuth.instance;
  } catch (_) {}
  return null;
}

Future<void> openGoogleMaps(
  BuildContext context,
  ClinicEntity clinic,
) async {
  final messenger = ScaffoldMessenger.of(context);
  final address = clinic.address;
  final query = [
    clinic.name,
    address,
    clinic.city,
  ].where((e) => e.trim().isNotEmpty).join(', ');
  final uri = Uri.https('www.google.com', '/maps/dir/', {
    'api': '1',
    'destination': query,
    'travelmode': 'driving',
  });
  try {
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Could not open Google Maps')),
      );
    }
  } catch (_) {
    messenger.showSnackBar(
      const SnackBar(content: Text('Could not open Google Maps')),
    );
  }
}
