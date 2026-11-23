import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:patient_app/core/widgets/app_snack_bar.dart';

import '../../../../clinic_details/data/models/clinic_doctor_model.dart';
import '../../../../clinic_details/data/repositories/clinic_details_repository_impl.dart';
import '../../../../clinic_details/presentation/widgets/doctor_rate_dialog.dart';
import '../../../../home/data/models/clinic_model.dart';
import '../../../../home/data/repositories/home_repository_impl.dart'
    show allocateClinicToken;
import '../../../../home/presentation/bloc/home_bloc.dart';
import '../../../../home/presentation/bloc/home_event.dart';
import '../../../domain/entities/appointment_entity.dart';
import '../../pages/booking_wizard_screen.dart';

class MyBookingsActionsHelper {
  static bool isTodayApt(AppointmentEntity apt) {
    final now = DateTime.now();
    final todayIso =
        '${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    return apt.dateRaw == todayIso;
  }

  static Future<void> rateDoctor(
    BuildContext context,
    AppointmentEntity apt,
  ) async {
    if (apt.doctorId.isEmpty) {
      AppSnackBar.showInfo(
        context,
        message: 'This visit has no doctor profile to rate.',
      );
      return;
    }
    await showDialog<void>(
      context: context,
      builder: (_) => DoctorRateDialog(
        doctorName: apt.doctorName,
        onSubmit: (rating, comment) async {
          try {
            await ClinicDetailsRepositoryImpl().submitDoctorReview(
              clinicId: apt.clinicId,
              doctorId: apt.doctorId,
              rating: rating,
              comment: comment,
            );
            if (context.mounted) {
              AppSnackBar.showSuccess(
                context,
                title: 'Rating Submitted',
                message: 'Thank you! Your verified rating has been submitted.',
              );
            }
          } catch (e) {
            if (context.mounted) {
              AppSnackBar.showError(
                context,
                message: 'Could not submit rating: $e',
              );
            }
          }
        },
      ),
    );
  }

  static Future<void> bookAgain(
    BuildContext context,
    AppointmentEntity apt,
  ) async {
    try {
      final fs = FirebaseFirestore.instance;
      final doc = await fs.collection('clinics').doc(apt.clinicId).get();
      if (!doc.exists) {
        if (context.mounted) {
          AppSnackBar.showError(
            context,
            message: 'This clinic is no longer available.',
          );
        }
        return;
      }
      final clinic = ClinicModel.fromFirestore(doc);
      ClinicDoctorModel? doctor;
      try {
        final doctors = await ClinicDoctorModel.fetchForClinic(
          fs,
          apt.clinicId,
        );
        doctor = doctors.where((d) => d.id == apt.doctorId).firstOrNull;
      } catch (_) {}
      if (!context.mounted) return;
      await BookingWizardScreen.push(
        context,
        clinic: clinic,
        initialDoctor: doctor,
      );
    } catch (e) {
      if (context.mounted) {
        AppSnackBar.showError(context, message: 'Could not open booking: $e');
      }
    }
  }

  static Future<void> trackLiveQueue(
    BuildContext context,
    AppointmentEntity apt,
    VoidCallback? onTrackLiveQueue,
  ) async {
    if (!apt.isCheckedIn) {
      try {
        await FirebaseFirestore.instance
            .collection('appointments')
            .doc(apt.id)
            .update({
              'status': 'checkedin',
              'checkedInAt': FieldValue.serverTimestamp(),
            });
      } catch (_) {}
    }
    try {
      final user = FirebaseAuth.instance.currentUser;
      final fs = FirebaseFirestore.instance;
      final ticketRef = fs.collection('tickets').doc(apt.id);
      final existing = await ticketRef.get();
      if (!existing.exists) {
        final token = await allocateClinicToken(
          fs,
          clinicId: apt.clinicId,
          clinicName: apt.clinicName,
          serviceName: apt.serviceName,
        );
        await ticketRef.set({
          'token': token,
          'clinicId': apt.clinicId,
          'clinicName': apt.clinicName,
          'serviceName': apt.serviceName,
          'doctorName': apt.doctorName,
          'patientName': apt.customerName,
          'patientEmail':
              (apt.customerEmail.isNotEmpty
                      ? apt.customerEmail
                      : user?.email ?? '')
                  .trim()
                  .toLowerCase(),
          'position': 0,
          'estWaitMin': 0,
          'nowServing': '',
          'status': 'waiting',
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (_) {}

    if (context.mounted) {
      if (onTrackLiveQueue != null) {
        onTrackLiveQueue();
      } else {
        context.read<HomeBloc>().add(const HomeRefreshRequested());
        context.read<HomeBloc>().add(const HomeNavTabChanged(1));
      }
    }
  }
}
