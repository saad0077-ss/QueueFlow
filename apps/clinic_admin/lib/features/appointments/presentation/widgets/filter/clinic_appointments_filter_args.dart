class ClinicAppointmentsFilterArgs {
  final String date;
  final String dept;
  final String service;
  final String doctor;
  final String status;
  final String payment;
  final List<String> availableDepts;
  final List<String> availableServices;
  final List<String> availableDoctors;

  const ClinicAppointmentsFilterArgs({
    required this.date,
    required this.dept,
    required this.service,
    required this.doctor,
    required this.status,
    required this.payment,
    required this.availableDepts,
    required this.availableServices,
    required this.availableDoctors,
  });
}
