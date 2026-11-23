import 'package:flutter/material.dart';

import 'appointments_filter_bar.dart';
import 'filter/clinic_appointments_filter_modal.dart';

class AppointmentsFilterBarHelper {
  static Future<void> openFilterDialog(
    BuildContext context,
    AppointmentsFilterBar bar,
  ) async {
    String valid(String v, List<String> opts) => opts.contains(v) ? v : 'all';

    final args = ClinicAppointmentsFilterArgs(
      date: bar.selectedDateRange,
      dept: valid(bar.selectedDept, bar.availableDepts),
      service: valid(bar.selectedService, bar.availableServices),
      doctor: valid(bar.selectedDoctor, bar.availableDoctors),
      status: bar.selectedStatus,
      payment: bar.selectedPayment,
      availableDepts: bar.availableDepts,
      availableServices: bar.availableServices,
      availableDoctors: bar.availableDoctors,
    );

    await ClinicAppointmentsFilterModal.show(
      context,
      args: args,
      onApply:
          ({
            required String date,
            required String dept,
            required String service,
            required String doctor,
            required String status,
            required String payment,
          }) {
            if (date != bar.selectedDateRange) bar.onDateRangeChanged(date);
            if (dept != bar.selectedDept) bar.onDeptChanged(dept);
            if (service != bar.selectedService) bar.onServiceChanged(service);
            if (doctor != bar.selectedDoctor) bar.onDoctorChanged(doctor);
            if (status != bar.selectedStatus) bar.onStatusChanged(status);
            if (payment != bar.selectedPayment) bar.onPaymentChanged(payment);
          },
    );
  }
}
