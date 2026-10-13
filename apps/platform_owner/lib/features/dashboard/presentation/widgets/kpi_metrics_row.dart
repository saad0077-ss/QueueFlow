import 'package:flutter/material.dart';

class KpiMetricsRow extends StatelessWidget {
  final int totalMrr;
  final int activeClinics;
  final int totalClinics;

  const KpiMetricsRow({
    super.key,
    required this.totalMrr,
    required this.activeClinics,
    required this.totalClinics,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _buildKpiCard(
          'Monthly Recurring Revenue (MRR)',
          '₹$totalMrr',
          Icons.currency_rupee_rounded,
          Colors.green,
        ),
        const SizedBox(width: 16),
        _buildKpiCard(
          'Active Subscribed Clinics',
          '$activeClinics / $totalClinics',
          Icons.local_hospital_rounded,
          Colors.blue,
        ),
        const SizedBox(width: 16),
        _buildKpiCard(
          'Total Registered Facilities',
          '$totalClinics',
          Icons.domain_rounded,
          Colors.purple,
        ),
        const SizedBox(width: 16),
        _buildKpiCard(
          'SaaS Platform Status',
          'Healthy (Free Tier)',
          Icons.health_and_safety_rounded,
          Colors.teal,
        ),
      ],
    );
  }

  Widget _buildKpiCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 26),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
