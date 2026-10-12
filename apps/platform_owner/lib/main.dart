import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase for Platform Owner Web Console
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
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
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1E293B), // Slate / Executive theme
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: const PlatformOwnerDashboard(),
    );
  }
}

class PlatformOwnerDashboard extends StatefulWidget {
  const PlatformOwnerDashboard({super.key});

  @override
  State<PlatformOwnerDashboard> createState() => _PlatformOwnerDashboardState();
}

class _PlatformOwnerDashboardState extends State<PlatformOwnerDashboard> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A), // Dark navy header
        foregroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            const Icon(Icons.admin_panel_settings_rounded, color: Color(0xFF38BDF8)),
            const SizedBox(width: 12),
            const Text(
              'QueueFlow',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF334155)),
              ),
              child: const Text(
                '👑 Platform Owner Console',
                style: TextStyle(fontSize: 12, color: Color(0xFF38BDF8)),
              ),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green.shade900.withValues(alpha: 0.3),
              border: Border.all(color: Colors.green.shade700),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Row(
              children: [
                Icon(Icons.cloud_done_rounded, color: Colors.greenAccent, size: 16),
                SizedBox(width: 6),
                Text(
                  'Connected: queueflow-db2e1',
                  style: TextStyle(fontSize: 12, color: Colors.greenAccent),
                ),
              ],
            ),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('clinics').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error loading clinics: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data?.docs ?? [];
          final activeClinics = docs.where((d) => (d.data() as Map<String, dynamic>)['status'] == 'active').length;
          
          // Calculate MRR from plan tiers
          int totalMrr = 0;
          for (var doc in docs) {
            final data = doc.data() as Map<String, dynamic>;
            final plan = data['planId'] ?? 'solo';
            if (data['status'] == 'active') {
              if (plan == 'enterprise') {
                totalMrr += 6999;
              } else if (plan == 'multi') {
                totalMrr += 2999;
              } else {
                totalMrr += 999;
              }
            }
          }

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
                          style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
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
                            onPressed: _seedDemoClinics,
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
                          onPressed: () => _showAddClinicDialog(context),
                          icon: const Icon(Icons.add_business_rounded, size: 18),
                          label: const Text('Onboard New Clinic'),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 28),

                // Top KPI Metrics
                Row(
                  children: [
                    _buildKpiCard('Monthly Recurring Revenue (MRR)', '₹$totalMrr', Icons.currency_rupee_rounded, Colors.green),
                    const SizedBox(width: 16),
                    _buildKpiCard('Active Subscribed Clinics', '$activeClinics / ${docs.length}', Icons.local_hospital_rounded, Colors.blue),
                    const SizedBox(width: 16),
                    _buildKpiCard('Total Registered Facilities', '${docs.length}', Icons.domain_rounded, Colors.purple),
                    const SizedBox(width: 16),
                    _buildKpiCard('SaaS Platform Status', 'Healthy (Free Tier)', Icons.health_and_safety_rounded, Colors.teal),
                  ],
                ),
                const SizedBox(height: 36),

                // Multi-Clinic Directory Table
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: Colors.grey.shade300),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Registered Healthcare Facilities',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              '${docs.length} Clinics',
                              style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        if (docs.isEmpty)
                          Container(
                            padding: const EdgeInsets.all(32),
                            alignment: Alignment.center,
                            child: Column(
                              children: [
                                Icon(Icons.store_mall_directory_outlined, size: 48, color: Colors.grey.shade400),
                                const SizedBox(height: 12),
                                Text(
                                  'No clinics onboarded yet.',
                                  style: TextStyle(color: Colors.grey.shade700, fontSize: 16),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Click "Seed Sample Clinics" or "Onboard New Clinic" to populate the database.',
                                  style: TextStyle(color: Colors.grey, fontSize: 13),
                                ),
                              ],
                            ),
                          )
                        else
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: DataTable(
                              headingRowColor: WidgetStateProperty.all(Colors.grey.shade50),
                              columns: const [
                                DataColumn(label: Text('Clinic Name', style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('Category', style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('Subscription Tier', style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold))),
                              ],
                              rows: docs.map((doc) {
                                final data = doc.data() as Map<String, dynamic>;
                                final clinicId = doc.id;
                                final name = data['name'] ?? 'Unnamed Clinic';
                                final category = data['category'] ?? 'General Medicine';
                                final planId = data['planId'] ?? 'solo';
                                final status = data['status'] ?? 'active';
                                final isActive = status == 'active';

                                return DataRow(
                                  cells: [
                                    DataCell(Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 14,
                                          backgroundColor: Colors.blue.shade100,
                                          child: Text(
                                            name.substring(0, 1).toUpperCase(),
                                            style: TextStyle(fontSize: 12, color: Colors.blue.shade900, fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
                                      ],
                                    )),
                                    DataCell(Text(category)),
                                    DataCell(_buildPlanBadge(planId)),
                                    DataCell(
                                      Chip(
                                        label: Text(
                                          isActive ? 'Active' : 'Suspended',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: isActive ? Colors.green.shade900 : Colors.red.shade900,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        backgroundColor: isActive ? Colors.green.shade100 : Colors.red.shade100,
                                        side: BorderSide.none,
                                        padding: const EdgeInsets.symmetric(horizontal: 4),
                                      ),
                                    ),
                                    DataCell(Row(
                                      children: [
                                        IconButton(
                                          tooltip: isActive ? 'Suspend Clinic' : 'Activate Clinic',
                                          icon: Icon(
                                            isActive ? Icons.pause_circle_outline_rounded : Icons.play_circle_outline_rounded,
                                            color: isActive ? Colors.orange.shade800 : Colors.green.shade800,
                                          ),
                                          onPressed: () => _toggleClinicStatus(clinicId, isActive),
                                        ),
                                        IconButton(
                                          tooltip: 'Upgrade Plan Tier',
                                          icon: const Icon(Icons.upgrade_rounded, color: Color(0xFF0369A1)),
                                          onPressed: () => _showUpgradePlanDialog(context, clinicId, planId),
                                        ),
                                        IconButton(
                                          tooltip: 'Delete Clinic',
                                          icon: const Icon(Icons.delete_outline_rounded, color: Colors.red),
                                          onPressed: () => _deleteClinic(clinicId),
                                        ),
                                      ],
                                    )),
                                  ],
                                );
                              }).toList(),
                            ),
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
                  Text(title, style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanBadge(String planId) {
    String label = 'Solo (₹999/mo)';
    Color bg = Colors.blue.shade50;
    Color text = Colors.blue.shade800;

    if (planId == 'enterprise') {
      label = 'Enterprise (₹6,999/mo)';
      bg = Colors.purple.shade50;
      text = Colors.purple.shade800;
    } else if (planId == 'multi') {
      label = 'Multi-Doc (₹2,999/mo)';
      bg = Colors.amber.shade50;
      text = Colors.amber.shade900;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(label, style: TextStyle(fontSize: 12, color: text, fontWeight: FontWeight.w600)),
    );
  }

  // Toggle active / suspended status
  Future<void> _toggleClinicStatus(String clinicId, bool currentActive) async {
    await _firestore.collection('clinics').doc(clinicId).update({
      'status': currentActive ? 'suspended' : 'active',
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Delete clinic
  Future<void> _deleteClinic(String clinicId) async {
    await _firestore.collection('clinics').doc(clinicId).delete();
  }

  // Upgrade / Change Tier
  Future<void> _showUpgradePlanDialog(BuildContext context, String clinicId, String currentPlan) async {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Change Subscription Plan'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('Solo Doctor Plan (₹999/mo)'),
                subtitle: const Text('1 Doctor, 1 Service, 1 Staff'),
                trailing: currentPlan == 'solo' ? const Icon(Icons.check, color: Colors.green) : null,
                onTap: () {
                  _firestore.collection('clinics').doc(clinicId).update({'planId': 'solo'});
                  Navigator.pop(ctx);
                },
              ),
              ListTile(
                title: const Text('Multi-Doctor Clinic (₹2,999/mo)'),
                subtitle: const Text('Up to 10 Doctors, 10 Services, 5 Staff'),
                trailing: currentPlan == 'multi' ? const Icon(Icons.check, color: Colors.green) : null,
                onTap: () {
                  _firestore.collection('clinics').doc(clinicId).update({'planId': 'multi'});
                  Navigator.pop(ctx);
                },
              ),
              ListTile(
                title: const Text('Enterprise Practice (₹6,999/mo)'),
                subtitle: const Text('Unlimited Doctors & Services, 20 Staff'),
                trailing: currentPlan == 'enterprise' ? const Icon(Icons.check, color: Colors.green) : null,
                onTap: () {
                  _firestore.collection('clinics').doc(clinicId).update({'planId': 'enterprise'});
                  Navigator.pop(ctx);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Onboard new clinic dialog
  Future<void> _showAddClinicDialog(BuildContext context) async {
    final nameController = TextEditingController();
    String selectedCategory = 'General Medicine';
    String selectedPlan = 'solo';

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              title: const Text('Onboard New Healthcare Facility'),
              content: SizedBox(
                width: 450,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Clinic / Hospital Name',
                        hintText: 'e.g., Apollo Outpatient Clinic',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: selectedCategory,
                      decoration: const InputDecoration(labelText: 'Specialty Category', border: OutlineInputBorder()),
                      items: ['General Medicine', 'Dental', 'Dermatology', 'Diagnostics', 'Pediatrics']
                          .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                          .toList(),
                      onChanged: (val) => setModalState(() => selectedCategory = val!),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: selectedPlan,
                      decoration: const InputDecoration(labelText: 'Initial Subscription Plan', border: OutlineInputBorder()),
                      items: const [
                        DropdownMenuItem(value: 'solo', child: Text('Solo Doctor (₹999/mo)')),
                        DropdownMenuItem(value: 'multi', child: Text('Multi-Doctor Clinic (₹2,999/mo)')),
                        DropdownMenuItem(value: 'enterprise', child: Text('Enterprise Practice (₹6,999/mo)')),
                      ],
                      onChanged: (val) => setModalState(() => selectedPlan = val!),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F172A), foregroundColor: Colors.white),
                  onPressed: () async {
                    if (nameController.text.trim().isEmpty) return;
                    await _firestore.collection('clinics').add({
                      'name': nameController.text.trim(),
                      'category': selectedCategory,
                      'planId': selectedPlan,
                      'status': 'active',
                      'createdAt': FieldValue.serverTimestamp(),
                    });
                    if (context.mounted) Navigator.pop(ctx);
                  },
                  child: const Text('Register Clinic'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Pre-seed sample clinics
  Future<void> _seedDemoClinics() async {
    final clinics = [
      {'name': 'Metro Health Primary Care', 'category': 'General Medicine', 'planId': 'multi', 'status': 'active'},
      {'name': 'Apex Dental Studio', 'category': 'Dental', 'planId': 'solo', 'status': 'active'},
      {'name': 'CareFirst Dermatology & Laser', 'category': 'Dermatology', 'planId': 'enterprise', 'status': 'active'},
    ];

    for (var clinic in clinics) {
      await _firestore.collection('clinics').add({
        ...clinic,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }
}
