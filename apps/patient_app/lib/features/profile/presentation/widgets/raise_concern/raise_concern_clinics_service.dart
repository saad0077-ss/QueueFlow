import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import 'clinic_option_model.dart';

class RaiseConcernClinicsService {
  static const List<ClinicOption> defaultClinics = [
    ClinicOption(
      id: 'smile-dental',
      name: 'Smile Dental Clinic (Dr. Rahul Sharma)',
      category: 'Dental Care',
      city: 'Kochi',
      address: 'Marine Drive, Kochi',
    ),
    ClinicOption(
      id: 'sunrise-health',
      name: 'Sunrise Health Clinic (Dr. Priya Nair)',
      category: 'General Practice',
      city: 'Kochi',
      address: 'MG Road, Kochi',
    ),
    ClinicOption(
      id: 'metro-general',
      name: 'Metro General Clinic (Dr. Amit Verma)',
      category: 'Multispecialty',
      city: 'Kochi',
      address: 'Palarivattom, Kochi',
    ),
    ClinicOption(
      id: 'citycare-clinic',
      name: 'CityCare General Clinic',
      category: 'Family Medicine',
      city: 'Kochi',
      address: 'Kaloor, Kochi',
    ),
  ];

  static StreamSubscription<QuerySnapshot<Map<String, dynamic>>>?
  listenToClinics({
    required ValueChanged<List<ClinicOption>> onClinicsLoaded,
    required VoidCallback onError,
  }) {
    try {
      return FirebaseFirestore.instance
          .collection('clinics')
          .snapshots()
          .listen(
            (snapshot) {
              final List<ClinicOption> loaded = [];
              for (final doc in snapshot.docs) {
                final data = doc.data();
                final status = (data['status'] ?? '').toString().toUpperCase();
                if (status == 'REMOVED' || status == 'DELETED') continue;
                final name = (data['name'] ?? '').toString().trim();
                if (name.isEmpty) continue;

                final category =
                    (data['category'] ?? data['specialty'] ?? 'Healthcare')
                        .toString()
                        .trim();
                final city = (data['city'] ?? 'Kochi').toString().trim();
                final address = (data['address'] ?? '').toString().trim();
                final imageUrl =
                    (data['imageUrl'] ??
                            data['photoUrl'] ??
                            data['image'] ??
                            data['logo'] ??
                            '')
                        .toString()
                        .trim();

                loaded.add(
                  ClinicOption(
                    id: doc.id,
                    name: name,
                    category: category.isNotEmpty ? category : 'Healthcare',
                    city: city.isNotEmpty ? city : 'Kochi',
                    address: address,
                    imageUrl: imageUrl.isNotEmpty ? imageUrl : null,
                  ),
                );
              }
              onClinicsLoaded(loaded);
            },
            onError: (err) {
              debugPrint('Error loading clinics: $err');
              onError();
            },
          );
    } catch (e) {
      debugPrint('Error initializing clinics stream: $e');
      onError();
      return null;
    }
  }
}
