import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../dashboard/data/repositories/tenant_repository_impl.dart';
import '../../domain/entities/platform_report_entity.dart';
import '../../domain/repositories/platform_reports_repository.dart';
import 'platform_reports_data_calculator.dart';

class PlatformReportsRepositoryImpl implements PlatformReportsRepository {
  final FirebaseFirestore _firestore;

  PlatformReportsRepositoryImpl({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<PlatformReportEntity> getPlatformReport({
    String timeRange = '30d',
    String tierFilter = 'all',
    DateTimeRange? customRange,
  }) async {
    final rawClinics = <Map<String, dynamic>>[];
    final ticketCounts = <String, int>{};

    try {
      final snap = await _firestore.collection('clinics').get();
      for (final doc in snap.docs) {
        final d = doc.data();
        final name = (d['name'] ?? '').toString();
        final email = (d['adminEmail'] ?? '').toString();
        if (TenantRepositoryImpl.isDummyClinicName(name, email)) {
          continue;
        }

        final docsList = (d['doctors'] as List<dynamic>?) ?? [];
        final docCount = docsList.isNotEmpty
            ? docsList.length
            : (d['practicingDoctors'] as int? ?? 1);

        rawClinics.add({
          'id': doc.id,
          'name': name,
          'rating': (d['rating'] as num?)?.toDouble() ?? 4.9,
          'category': (d['category'] ?? 'General').toString(),
          'planId': (d['planId'] ?? 'solo').toString(),
          'doctorsCount': docCount,
          'avgWaitTime': (d['avgWaitTime'] ?? '12m').toString(),
          'monthlyVisits': (d['monthlyVisits'] as int?) ?? 0,
        });
      }
    } catch (_) {}

    try {
      final ticketsSnap = await _firestore.collection('tickets').get();
      for (final doc in ticketsSnap.docs) {
        final data = doc.data();
        if (customRange != null) {
          final ts = data['createdAt'];
          if (ts is Timestamp) {
            final dt = ts.toDate();
            if (dt.isBefore(customRange.start) ||
                dt.isAfter(customRange.end.add(const Duration(days: 1)))) {
              continue;
            }
          }
        }
        final clinicId = (data['clinicId'] ?? '').toString();
        if (clinicId.isNotEmpty) {
          ticketCounts[clinicId] = (ticketCounts[clinicId] ?? 0) + 1;
        }
      }
    } catch (_) {}

    return PlatformReportsDataCalculator.calculate(
      rawClinics: rawClinics,
      ticketCounts: ticketCounts,
      timeRange: timeRange,
      tierFilter: tierFilter,
    );
  }
}
