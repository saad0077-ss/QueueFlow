import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../auth/presentation/pages/clinic_staff_login_page.dart';
import '../../data/repositories/queue_repository_impl.dart';
import '../widgets/queue_stat_card.dart';

class ClinicDashboardPage extends StatelessWidget {
  const ClinicDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = QueueRepositoryImpl();
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Row(
          children: [
            const Icon(Icons.local_hospital_rounded, color: Color(0xFF02569B)),
            const SizedBox(width: 12),
            const Text(
              'QueueFlow',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFE0F2FE),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Clinic Admin',
                style: TextStyle(fontSize: 12, color: Color(0xFF0369A1)),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Sign Out',
            icon: const Icon(Icons.logout_rounded),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (context.mounted) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (_) => const ClinicStaffLoginPage(),
                  ),
                );
              }
            },
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: repo.watchQueue(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final data = snapshot.data?.data() as Map<String, dynamic>? ?? {};
          final currentToken = data['currentToken'] ?? '---';
          final totalIssued = data['totalIssued'] ?? 0;
          final waitingCount = data['waitingCount'] ?? 0;

          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Live Patient Queue Control',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const Text(
                  'Real-time outpatient caller console synchronized with Firestore',
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    QueueStatCard(
                      title: 'Now Serving',
                      value: currentToken,
                      icon: Icons.campaign_rounded,
                      color: Colors.blue,
                    ),
                    const SizedBox(width: 16),
                    QueueStatCard(
                      title: 'Waiting Patients',
                      value: '$waitingCount',
                      icon: Icons.people_outline_rounded,
                      color: Colors.orange,
                    ),
                    const SizedBox(width: 16),
                    QueueStatCard(
                      title: 'Total Issued Today',
                      value: '$totalIssued',
                      icon: Icons.confirmation_number_outlined,
                      color: Colors.purple,
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => repo.callNextToken(totalIssued),
                      icon: const Icon(Icons.navigate_next_rounded),
                      label: const Text('Call Next Token'),
                    ),
                    OutlinedButton.icon(
                      onPressed: () =>
                          repo.issueWalkInToken(totalIssued, waitingCount),
                      icon: const Icon(Icons.person_add_alt_1_rounded),
                      label: const Text('Issue Walk-In Token'),
                    ),
                    OutlinedButton.icon(
                      onPressed: repo.resetQueue,
                      icon: const Icon(Icons.restart_alt_rounded),
                      label: const Text('Reset Queue'),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
