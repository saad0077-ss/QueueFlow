import 'package:flutter/material.dart';
import '../../../../core/widgets/app_snack_bar.dart';
import '../../../appointments/presentation/widgets/create_appointment_modal.dart';
import '../../../services/data/repositories/clinic_services_repository_impl.dart';
import '../../../services/domain/entities/clinic_doctor_entity.dart';
import '../../../services/domain/entities/clinic_service_entity.dart';
import '../../../services/domain/entities/service_department_entity.dart';

class ClinicCreateAppointmentLauncher {
  static Future<void> open(
    BuildContext context, {
    required ClinicServicesRepositoryImpl servicesRepo,
  }) async {
    ClinicBookingCatalog catalog;
    try {
      final results = await Future.wait([
        servicesRepo.getDepartments(),
        servicesRepo.watchServices().first,
        servicesRepo.getDoctors(),
      ]);
      catalog = ClinicBookingCatalog(
        departments: results[0] as List<ServiceDepartmentEntity>,
        services: results[1] as List<ClinicServiceEntity>,
        doctors: results[2] as List<ClinicDoctorEntity>,
      );
    } catch (_) {
      catalog = const ClinicBookingCatalog();
    }

    if (!context.mounted) return;
    CreateAppointmentModal.show(
      context,
      catalog: catalog,
      onCreate: (newAppt) {
        AppSnackBar.showSuccess(
          context,
          message: 'Appointment #${newAppt.bookingId} booked successfully!',
        );
      },
    );
  }
}
