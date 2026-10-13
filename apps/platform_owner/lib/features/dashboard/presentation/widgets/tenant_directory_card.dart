import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dashboard_dialogs.dart';

class TenantDirectoryCard extends StatelessWidget {
  final List<QueryDocumentSnapshot> docs;

  const TenantDirectoryCard({super.key, required this.docs});

  @override
  Widget build(BuildContext context) {
    final firestore = FirebaseFirestore.instance;
    return Card(
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
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
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
                    Icon(
                      Icons.store_mall_directory_outlined,
                      size: 48,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No clinics onboarded yet.',
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 16,
                      ),
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
                    DataColumn(
                      label: Text(
                        'Clinic Name',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Category',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Subscription Tier',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Status',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Actions',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
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
                        DataCell(
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 14,
                                backgroundColor: Colors.blue.shade100,
                                child: Text(
                                  name.substring(0, 1).toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.blue.shade900,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        DataCell(Text(category)),
                        DataCell(_buildPlanBadge(planId)),
                        DataCell(
                          Chip(
                            label: Text(
                              isActive ? 'Active' : 'Suspended',
                              style: TextStyle(
                                fontSize: 12,
                                color: isActive
                                    ? Colors.green.shade900
                                    : Colors.red.shade900,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            backgroundColor: isActive
                                ? Colors.green.shade100
                                : Colors.red.shade100,
                            side: BorderSide.none,
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                          ),
                        ),
                        DataCell(
                          Row(
                            children: [
                              IconButton(
                                tooltip: isActive
                                    ? 'Suspend Clinic'
                                    : 'Activate Clinic',
                                icon: Icon(
                                  isActive
                                      ? Icons.pause_circle_outline_rounded
                                      : Icons.play_circle_outline_rounded,
                                  color: isActive
                                      ? Colors.orange.shade800
                                      : Colors.green.shade800,
                                ),
                                onPressed: () => firestore
                                    .collection('clinics')
                                    .doc(clinicId)
                                    .update({
                                  'status': isActive ? 'suspended' : 'active',
                                  'updatedAt': FieldValue.serverTimestamp(),
                                }),
                              ),
                              IconButton(
                                tooltip: 'Upgrade Plan Tier',
                                icon: const Icon(
                                  Icons.upgrade_rounded,
                                  color: Color(0xFF0369A1),
                                ),
                                onPressed: () =>
                                    DashboardDialogs.showUpgradePlanDialog(
                                  context,
                                  clinicId,
                                  planId,
                                ),
                              ),
                              IconButton(
                                tooltip: 'Delete Clinic',
                                icon: const Icon(
                                  Icons.delete_outline_rounded,
                                  color: Colors.red,
                                ),
                                onPressed: () => firestore
                                    .collection('clinics')
                                    .doc(clinicId)
                                    .delete(),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }).toList(),
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
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: text,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
