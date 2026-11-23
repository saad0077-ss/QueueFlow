import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/platform_support_ticket_entity.dart';
import 'platform_tickets_filter_modal.dart';

class PlatformTicketsFilterModalHelper {
  static Future<void> openFilterModal({
    required BuildContext context,
    required List<PlatformSupportTicketEntity> allTickets,
    required String selectedClinicFilter,
    required String selectedSlaFilter,
    required String selectedCategoryFilter,
    required void Function({
      required String clinic,
      required String sla,
      required String category,
    })
    onApply,
  }) async {
    final clinicMap = <String, FilterClinicItem>{};

    final defaultClinics = [
      const FilterClinicItem(
        id: 'c_sunrise',
        name: 'Sunrise Health Clinic',
        subtitle: 'Kochi',
      ),
      const FilterClinicItem(
        id: 'c_smile',
        name: 'Smile Dental Clinic',
        subtitle: 'Kochi',
      ),
      const FilterClinicItem(
        id: 'c_citycare',
        name: 'CityCare General Clinic',
        subtitle: 'Kochi',
      ),
      const FilterClinicItem(
        id: 'c_wellness',
        name: 'Wellness Skin Studio',
        subtitle: 'Kochi',
      ),
      const FilterClinicItem(
        id: 'c_kochi_fam',
        name: 'Kochi Family Clinic',
        subtitle: 'Kochi',
      ),
    ];
    for (final dc in defaultClinics) {
      clinicMap[dc.id] = dc;
    }

    for (final t in allTickets) {
      if (t.clinicId.isNotEmpty) {
        clinicMap[t.clinicId] = FilterClinicItem(
          id: t.clinicId,
          name: t.clinicName.isNotEmpty ? t.clinicName : 'Clinic ${t.clinicId}',
          subtitle: 'Kochi',
        );
      }
    }

    try {
      final snap = await FirebaseFirestore.instance.collection('clinics').get();
      for (final doc in snap.docs) {
        final data = doc.data();
        final name = (data['name'] ?? doc.id).toString();
        final city = (data['city'] ?? data['address'] ?? 'Kochi').toString();
        clinicMap[doc.id] = FilterClinicItem(
          id: doc.id,
          name: name,
          subtitle: city,
        );
      }
    } catch (_) {}

    if (!context.mounted) return;

    await PlatformTicketsFilterModal.show(
      context,
      initialClinic: selectedClinicFilter,
      initialSla: selectedSlaFilter,
      initialCategory: selectedCategoryFilter,
      availableClinics: clinicMap.values.toList(),
      onApply: onApply,
    );
  }
}
