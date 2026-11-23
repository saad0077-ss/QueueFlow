import 'package:flutter/material.dart';
import '../../../../core/utils/clinic_pdf_exporter.dart';
import '../../../../core/widgets/app_snack_bar.dart';
import '../../../services/data/repositories/clinic_services_repository_impl.dart';
import '../../../services/domain/entities/clinic_doctor_entity.dart';
import '../../../services/domain/entities/clinic_service_entity.dart';
import '../../../services/domain/entities/service_department_entity.dart';
import '../../domain/entities/clinic_appointment_entity.dart';
import '../bloc/clinic_appointments_bloc.dart';
import '../bloc/clinic_appointments_event.dart';
import 'create_appointment_modal.dart';
import 'reschedule_appointment_dialog.dart';

class ClinicAppointmentsActionsHelper {
  static Future<ClinicBookingCatalog?> loadCatalog(BuildContext context) async {
    final repo = ClinicServicesRepositoryImpl();
    try {
      final results = await Future.wait([
        repo.getDepartments(),
        repo.watchServices().first,
        repo.getDoctors(),
      ]);
      return ClinicBookingCatalog(
        departments: results[0] as List<ServiceDepartmentEntity>,
        services: results[1] as List<ClinicServiceEntity>,
        doctors: results[2] as List<ClinicDoctorEntity>,
      );
    } catch (_) {
      if (context.mounted) {
        AppSnackBar.showError(
          context,
          message: 'Could not load clinic departments and services.',
        );
      }
      return null;
    }
  }

  static void exportPdf(BuildContext context, ClinicAppointmentsBloc bloc) {
    ClinicPdfExporter.exportAppointments(
      context,
      bloc.state.filteredAppointments,
    );
  }

  static void handleCheckIn(
    BuildContext context,
    ClinicAppointmentsBloc bloc,
    ClinicAppointmentEntity appt,
  ) {
    bloc.add(CheckInAppointment(appt.id));
    AppSnackBar.showSuccess(
      context,
      message: 'Patient #${appt.bookingId} checked in.',
    );
  }

  static void handleComplete(
    BuildContext context,
    ClinicAppointmentsBloc bloc,
    ClinicAppointmentEntity appt,
  ) {
    bloc.add(CompleteAppointment(appt.id));
    AppSnackBar.showSuccess(
      context,
      message: 'Appointment #${appt.bookingId} marked as completed.',
    );
  }

  static void handleReschedule(
    BuildContext context,
    ClinicAppointmentsBloc bloc,
    ClinicAppointmentEntity appt,
  ) {
    RescheduleAppointmentDialog.show(
      context,
      appointment: appt,
      onReschedule: (newDate, newTime) {
        bloc.add(
          RescheduleAppointment(
            id: appt.id,
            newDate: newDate,
            newTime: newTime,
          ),
        );
        AppSnackBar.showSuccess(
          context,
          message:
              'Appointment #${appt.bookingId} rescheduled to $newDate · $newTime',
        );
      },
    );
  }

  static Future<void> handleCreateAppointment(
    BuildContext context,
    ClinicAppointmentsBloc bloc,
  ) async {
    final catalog = await loadCatalog(context);
    if (catalog == null || !context.mounted) return;
    CreateAppointmentModal.show(
      context,
      catalog: catalog,
      onCreate: (newAppt) {
        bloc.add(CreateAppointment(newAppt));
        AppSnackBar.showSuccess(
          context,
          message: 'Appointment #${newAppt.bookingId} scheduled successfully!',
        );
      },
    );
  }
}
