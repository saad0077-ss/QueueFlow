import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/widgets/app_snack_bar.dart';
import '../bloc/onboard_clinic_bloc.dart';
import '../bloc/onboard_clinic_event.dart';
import '../bloc/onboard_clinic_state.dart';

class DashboardDialogs {
  static Future<void> showUpgradePlanDialog(
    BuildContext context,
    String clinicId,
    String currentPlan,
  ) async {
    final firestore = FirebaseFirestore.instance;
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
                trailing: currentPlan == 'solo'
                    ? const Icon(Icons.check, color: Colors.green)
                    : null,
                onTap: () {
                  firestore
                      .collection('clinics')
                      .doc(clinicId)
                      .update({'planId': 'solo'});
                  Navigator.pop(ctx);
                  AppSnackBar.showSuccess(context, message: 'Plan updated.');
                },
              ),
              ListTile(
                title: const Text('Multi-Doctor Clinic (₹2,999/mo)'),
                subtitle: const Text('Up to 10 Doctors, 10 Services, 5 Staff'),
                trailing: currentPlan == 'multi'
                    ? const Icon(Icons.check, color: Colors.green)
                    : null,
                onTap: () {
                  firestore
                      .collection('clinics')
                      .doc(clinicId)
                      .update({'planId': 'multi'});
                  Navigator.pop(ctx);
                  AppSnackBar.showSuccess(context, message: 'Plan updated.');
                },
              ),
              ListTile(
                title: const Text('Enterprise Practice (₹6,999/mo)'),
                subtitle: const Text('Unlimited Doctors & Services, 20 Staff'),
                trailing: currentPlan == 'enterprise'
                    ? const Icon(Icons.check, color: Colors.green)
                    : null,
                onTap: () {
                  firestore
                      .collection('clinics')
                      .doc(clinicId)
                      .update({'planId': 'enterprise'});
                  Navigator.pop(ctx);
                  AppSnackBar.showSuccess(context, message: 'Plan updated.');
                },
              ),
            ],
          ),
        );
      },
    );
  }

  static Future<void> showAddClinicDialog(BuildContext context) async {
    final firestore = FirebaseFirestore.instance;
    showDialog(
      context: context,
      builder: (ctx) {
        return BlocProvider(
          create: (_) => OnboardClinicBloc(),
          child: BlocBuilder<OnboardClinicBloc, OnboardClinicState>(
            builder: (context, state) {
              final bloc = context.read<OnboardClinicBloc>();
              return AlertDialog(
                title: const Text('Onboard New Healthcare Facility'),
                content: SizedBox(
                  width: 450,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        onChanged: (val) =>
                            bloc.add(OnboardClinicNameChanged(val)),
                        decoration: const InputDecoration(
                          labelText: 'Clinic / Hospital Name',
                          hintText: 'e.g., Apollo Outpatient Clinic',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        initialValue: state.selectedCategory,
                        decoration: const InputDecoration(
                          labelText: 'Specialty Category',
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          'General Medicine',
                          'Dental',
                          'Dermatology',
                          'Diagnostics',
                          'Pediatrics',
                        ]
                            .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) {
                            bloc.add(OnboardClinicCategoryChanged(val));
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        initialValue: state.selectedPlan,
                        decoration: const InputDecoration(
                          labelText: 'Initial Subscription Plan',
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'solo',
                            child: Text('Solo Doctor (₹999/mo)'),
                          ),
                          DropdownMenuItem(
                            value: 'multi',
                            child: Text('Multi-Doctor Clinic (₹2,999/mo)'),
                          ),
                          DropdownMenuItem(
                            value: 'enterprise',
                            child: Text('Enterprise Practice (₹6,999/mo)'),
                          ),
                        ],
                        onChanged: (val) {
                          if (val != null) {
                            bloc.add(OnboardClinicPlanChanged(val));
                          }
                        },
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0F172A),
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () async {
                      if (state.name.trim().isEmpty) return;
                      await firestore.collection('clinics').add({
                        'name': state.name.trim(),
                        'category': state.selectedCategory,
                        'planId': state.selectedPlan,
                        'status': 'active',
                        'createdAt': FieldValue.serverTimestamp(),
                      });
                      if (ctx.mounted) {
                        Navigator.pop(ctx);
                        AppSnackBar.showSuccess(
                          context,
                          message: 'Clinic onboarded.',
                        );
                      }
                    },
                    child: const Text('Register Clinic'),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}
