import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'features/auth/presentation/pages/platform_admin_login_screen.dart';
import 'features/dashboard/data/repositories/tenant_repository_impl.dart';
import 'features/dashboard/presentation/widgets/console_app_bar.dart';
import 'features/dashboard/presentation/widgets/dashboard_dialogs.dart';
import 'features/dashboard/presentation/widgets/kpi_metrics_row.dart';
import 'features/dashboard/presentation/widgets/tenant_directory_card.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    }
  } catch (e) {
    debugPrint('Firebase already initialized: $e');
  }
  runApp(const PlatformOwnerApp());
}

class PlatformOwnerApp extends StatelessWidget {
  const PlatformOwnerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QueueFlow — Platform Owner Console',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1E293B)),
        useMaterial3: true,
      ),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              backgroundColor: Color(0xFF070B14),
              body: Center(child: CircularProgressIndicator(color: Color(0xFF38BDF8))),
            );
          }
          return snapshot.hasData && snapshot.data != null
              ? const PlatformOwnerDashboard()
              : const PlatformAdminLoginScreen();
        },
      ),
    );
  }
}

class PlatformOwnerDashboard extends StatelessWidget {
  const PlatformOwnerDashboard({super.key});

  int _calculateMrr(List<QueryDocumentSnapshot> docs) {
    var totalMrr = 0;
    for (final doc in docs) {
      final data = doc.data() as Map<String, dynamic>;
      if (data['status'] == 'active') {
        final plan = data['planId'] ?? 'solo';
        totalMrr += plan == 'enterprise' ? 6999 : (plan == 'multi' ? 2999 : 999);
      }
    }
    return totalMrr;
  }

  @override
  Widget build(BuildContext context) {
    final repository = TenantRepositoryImpl();

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: const ConsoleAppBar(),
      body: StreamBuilder<QuerySnapshot>(
        stream: repository.watchClinics(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error loading clinics: ${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data?.docs ?? [];
          final activeClinics = docs
              .where((d) => (d.data() as Map<String, dynamic>)['status'] == 'active')
              .length;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(28.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text( 
                          'SaaS Executive Overview',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 4), 
                        Text(
                          'Manage tenant clinics, subscriptions, billing, and platform health',
                          style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                    Row(
                      children: [      
                        if (docs.isEmpty)
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0369A1),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            ),
                            onPressed: repository.seedSampleClinics, 
                            icon: const Icon(Icons.dataset_rounded, size: 18),
                            label: const Text('Seed Sample Clinics'),
                          ),
                        const SizedBox(width: 12), 
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0F172A),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          ),
                          onPressed: () => DashboardDialogs.showAddClinicDialog(context),
                          icon: const Icon(Icons.add_business_rounded, size: 18),
                          label: const Text('Onboard New Clinic'),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                KpiMetricsRow(
                  totalMrr: _calculateMrr(docs),
                  activeClinics: activeClinics,
                  totalClinics: docs.length,
                ),
                const SizedBox(height: 36),
                TenantDirectoryCard(docs: docs),
              ],
            ),
          );
        },
      ),
    );
  }
}
