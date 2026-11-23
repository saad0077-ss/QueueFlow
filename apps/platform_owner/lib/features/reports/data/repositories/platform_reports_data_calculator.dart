import '../models/clinic_ranking_model.dart';
import '../models/platform_report_model.dart';

class PlatformReportsDataCalculator {
  static const _clinicPalette = [
    0xFF0284C7,
    0xFF10B981,
    0xFF8B5CF6,
    0xFFF59E0B,
    0xFFEC4899,
    0xFF06B6D4,
    0xFF3B82F6,
  ];

  static PlatformReportModel calculate({
    required List<Map<String, dynamic>> rawClinics,
    required Map<String, int> ticketCounts,
    required String timeRange,
    required String tierFilter,
  }) {
    var filtered = rawClinics;
    if (tierFilter != 'all') {
      filtered = rawClinics
          .where(
            (c) => (c['planId'] ?? '').toString().toLowerCase().contains(
              tierFilter,
            ),
          )
          .toList();
    }

    final totalAppts = filtered.fold<int>(
      0,
      (sum, c) =>
          sum + (ticketCounts[c['id']] ?? (c['monthlyVisits'] as int? ?? 0)),
    );

    int maxAppts = 1;
    for (final c in filtered) {
      final vol = ticketCounts[c['id']] ?? (c['monthlyVisits'] as int? ?? 0);
      if (vol > maxAppts) maxAppts = vol;
    }

    // Sort by appointments descending
    filtered.sort((a, b) {
      final va = ticketCounts[a['id']] ?? (a['monthlyVisits'] as int? ?? 0);
      final vb = ticketCounts[b['id']] ?? (b['monthlyVisits'] as int? ?? 0);
      return vb.compareTo(va);
    });

    final ranked = <ClinicRankingModel>[];
    for (int i = 0; i < filtered.length; i++) {
      final c = filtered[i];
      final appts = ticketCounts[c['id']] ?? (c['monthlyVisits'] as int? ?? 0);
      final sharePct = totalAppts > 0 ? (appts / totalAppts * 100) : 0.0;
      final barWidth = maxAppts > 0 ? ((appts / maxAppts) * 100).round() : 10;
      final color = _clinicPalette[i % _clinicPalette.length];

      final name = (c['name'] ?? 'Clinic').toString();
      final words = name.split(' ').where((w) => w.isNotEmpty).toList();
      final initials = words.length >= 2
          ? '${words[0][0]}${words[1][0]}'.toUpperCase()
          : (name.length >= 2 ? name.substring(0, 2).toUpperCase() : 'QC');

      final waitTime =
          int.tryParse(
            (c['avgWaitTime'] ?? '12').toString().replaceAll(
              RegExp(r'[^0-9]'),
              '',
            ),
          ) ??
          12;

      ranked.add(
        ClinicRankingModel(
          id: (c['id'] ?? 'clinic-$i').toString(),
          rank: i + 1,
          name: name,
          initials: initials,
          colorHex: color,
          rating: (c['rating'] as num?)?.toDouble() ?? 4.8,
          avgWaitMinutes: waitTime,
          appointments: appts,
          sharePercentage: double.parse(sharePct.toStringAsFixed(1)),
          barWidthPercentage: barWidth.clamp(8, 100),
          tierPlan: (c['planId'] ?? 'solo').toString(),
        ),
      );
    }

    int unlimited = 0, multi = 0, solo = 0, activeDocs = 0;
    for (final c in rawClinics) {
      final plan = (c['planId'] ?? 'solo').toString().toLowerCase();
      if (plan.contains('enterprise') || plan.contains('unlimited')) {
        unlimited++;
      } else if (plan.contains('multi')) {
        multi++;
      } else {
        solo++;
      }
      activeDocs += (c['doctorsCount'] as int? ?? 1);
    }

    final totalDoctorSlots = (unlimited * 20) + (multi * 10) + (solo * 1);
    final mrr = (unlimited * 6999) + (multi * 2999) + (solo * 999);

    return PlatformReportModel.fromData(
      totalPatients: totalAppts,
      avgWaitMinutes: 12.5,
      activeDoctors: activeDocs,
      totalDoctorSlots: totalDoctorSlots > 0 ? totalDoctorSlots : 10,
      mrrAmount: mrr,
      rankedClinics: ranked,
      unlimitedTierCount: unlimited,
      multiTierCount: multi,
      soloTierCount: solo,
    );
  }
}
