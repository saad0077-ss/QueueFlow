import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase with the generated options
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const ClinicAdminApp());
}

class ClinicAdminApp extends StatelessWidget {
  const ClinicAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QueueFlow — Clinic Admin Portal',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF02569B),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: const ClinicDashboardPage(),
    );
  }
}

class ClinicDashboardPage extends StatefulWidget {
  const ClinicDashboardPage({super.key});

  @override
  State<ClinicDashboardPage> createState() => _ClinicDashboardPageState();
}

class _ClinicDashboardPageState extends State<ClinicDashboardPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _clinicId = 'clinic_main_01'; // Default clinic scope

  @override
  Widget build(BuildContext context) {
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
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              border: Border.all(color: Colors.green.shade200),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: Colors.green, size: 16),
                const SizedBox(width: 6),
                Text(
                  'Connected: queueflow-db2e1',
                  style: TextStyle(fontSize: 12, color: Colors.green.shade800),
                ),
              ],
            ),
          ),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: _firestore.collection('queues').doc(_clinicId).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

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

                // Metrics Row
                Row(
                  children: [
                    _buildStatCard('Now Serving', currentToken, Icons.campaign_rounded, Colors.blue),
                    const SizedBox(width: 16),
                    _buildStatCard('Waiting Patients', '$waitingCount', Icons.people_outline_rounded, Colors.orange),
                    const SizedBox(width: 16),
                    _buildStatCard('Total Issued Today', '$totalIssued', Icons.confirmation_number_outlined, Colors.purple),
                  ],
                ),
                const SizedBox(height: 32),

                // Live Caller Action Card
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: Colors.grey.shade200),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Queue Actions',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF02569B),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              onPressed: () => _callNextToken(totalIssued),
                              icon: const Icon(Icons.navigate_next_rounded),
                              label: const Text('Call Next Token', style: TextStyle(fontSize: 16)),
                            ),
                            const SizedBox(width: 12),
                            OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              onPressed: () => _issueWalkInToken(totalIssued, waitingCount),
                              icon: const Icon(Icons.person_add_alt_1_rounded),
                              label: const Text('Issue Walk-In Token', style: TextStyle(fontSize: 16)),
                            ),
                            const SizedBox(width: 12),
                            OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.red.shade700,
                                side: BorderSide(color: Colors.red.shade200),
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              onPressed: _resetQueue,
                              icon: const Icon(Icons.restart_alt_rounded),
                              label: const Text('Reset Queue', style: TextStyle(fontSize: 16)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Atomically call the next token
  Future<void> _callNextToken(int totalIssued) async {
    final queueRef = _firestore.collection('queues').doc(_clinicId);

    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(queueRef);
      if (!snapshot.exists) return;

      final data = snapshot.data()!;
      final waiting = data['waitingCount'] ?? 0;
      final currentNum = int.tryParse((data['currentToken'] ?? 'A-000').replaceAll('A-', '')) ?? 0;

      if (waiting > 0 && currentNum < totalIssued) {
        final nextNum = currentNum + 1;
        final nextToken = 'A-${nextNum.toString().padLeft(3, '0')}';

        transaction.update(queueRef, {
          'currentToken': nextToken,
          'waitingCount': waiting - 1,
          'lastCalledAt': FieldValue.serverTimestamp(),
        });
      }
    });
  }

  // Issue a new walk-in token
  Future<void> _issueWalkInToken(int totalIssued, int waitingCount) async {
    final queueRef = _firestore.collection('queues').doc(_clinicId);
    final nextTotal = totalIssued + 1;
    final tokenString = 'A-${nextTotal.toString().padLeft(3, '0')}';

    await queueRef.set({
      'totalIssued': nextTotal,
      'waitingCount': waitingCount + 1,
      'status': 'open',
    }, SetOptions(merge: true));

    // Also record ticket in tickets collection
    await _firestore.collection('tickets').add({
      'token': tokenString,
      'clinicId': _clinicId,
      'patientName': 'Walk-In Patient #$nextTotal',
      'status': 'waiting',
      'joinedAt': FieldValue.serverTimestamp(),
    });
  }

  // Reset queue for testing
  Future<void> _resetQueue() async {
    final queueRef = _firestore.collection('queues').doc(_clinicId);
    await queueRef.set({
      'currentToken': '---',
      'totalIssued': 0,
      'waitingCount': 0,
      'status': 'open',
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
