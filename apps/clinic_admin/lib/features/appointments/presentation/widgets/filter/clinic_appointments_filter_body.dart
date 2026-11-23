import 'package:flutter/material.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

import 'clinic_appointments_filter_date_section.dart';
import 'clinic_appointments_filter_dept_section.dart';
import 'clinic_appointments_filter_doctor_section.dart';
import 'clinic_appointments_filter_payment_section.dart';
import 'clinic_appointments_filter_service_section.dart';
import 'clinic_appointments_filter_status_section.dart';

class ClinicAppointmentsFilterBody extends StatelessWidget {
  final String date;
  final String dept;
  final String service;
  final String doctor;
  final String status;
  final String payment;
  final List<String> availableDepts;
  final List<String> availableServices;
  final List<String> availableDoctors;
  final ValueChanged<String> onSelectDate;
  final ValueChanged<String> onSelectDept;
  final ValueChanged<String> onSelectService;
  final ValueChanged<String> onSelectDoctor;
  final ValueChanged<String> onSelectStatus;
  final ValueChanged<String> onSelectPayment;

  const ClinicAppointmentsFilterBody({
    super.key,
    required this.date,
    required this.dept,
    required this.service,
    required this.doctor,
    required this.status,
    required this.payment,
    required this.availableDepts,
    required this.availableServices,
    required this.availableDoctors,
    required this.onSelectDate,
    required this.onSelectDept,
    required this.onSelectService,
    required this.onSelectDoctor,
    required this.onSelectStatus,
    required this.onSelectPayment,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppFilterSectionTitle('DATE SCHEDULE'),
          const SizedBox(height: 10),
          ClinicAppointmentsFilterDateSection(
            selectedDate: date,
            onSelectDate: onSelectDate,
          ),
          const SizedBox(height: 20),
          const AppFilterSectionTitle('APPOINTMENT STATUS'),
          const SizedBox(height: 10),
          ClinicAppointmentsFilterStatusSection(
            selectedStatus: status,
            onSelectStatus: onSelectStatus,
          ),
          const SizedBox(height: 20),
          const AppFilterSectionTitle('PAYMENT STATUS'),
          const SizedBox(height: 10),
          ClinicAppointmentsFilterPaymentSection(
            selectedPayment: payment,
            onSelectPayment: onSelectPayment,
          ),
          if (availableDepts.isNotEmpty) ...[
            const SizedBox(height: 20),
            const AppFilterSectionTitle('HEALTHCARE DEPARTMENT'),
            const SizedBox(height: 10),
            ClinicAppointmentsFilterDeptSection(
              selectedDept: dept,
              availableDepts: availableDepts,
              onSelectDept: onSelectDept,
            ),
          ],
          if (availableDoctors.isNotEmpty) ...[
            const SizedBox(height: 20),
            const AppFilterSectionTitle('ATTENDING DOCTOR'),
            const SizedBox(height: 10),
            ClinicAppointmentsFilterDoctorSection(
              selectedDoctor: doctor,
              availableDoctors: availableDoctors,
              onSelectDoctor: onSelectDoctor,
            ),
          ],
          if (availableServices.isNotEmpty) ...[
            const SizedBox(height: 20),
            const AppFilterSectionTitle('CLINICAL SERVICE'),
            const SizedBox(height: 10),
            ClinicAppointmentsFilterServiceSection(
              selectedService: service,
              availableServices: availableServices,
              onSelectService: onSelectService,
            ),
          ],
        ],
      ),
    );
  }
}
