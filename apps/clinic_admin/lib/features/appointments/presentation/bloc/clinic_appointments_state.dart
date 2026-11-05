import 'package:equatable/equatable.dart';
import '../../domain/entities/clinic_appointment_entity.dart';

class ClinicAppointmentsState extends Equatable {
  final List<ClinicAppointmentEntity> allAppointments;
  final String dateRangeFilter; // 'all', 'today', 'week'
  final String departmentFilter; // 'all' or dept name
  final String serviceFilter; // 'all' or service name
  final String doctorFilter; // 'all' or doctor name
  final String
  statusFilter; // 'all', 'confirmed', 'upcoming', 'checkedin', 'completed', 'cancelled'
  final String paymentFilter; // 'all', 'paid', 'refunded', 'due'
  final String searchQuery;
  final String viewMode; // 'list' or 'calendar'
  final ClinicAppointmentEntity? selectedAppointment;
  final DateTime selectedCalendarDate;
  final bool isLoading;
  final String? message;

  ClinicAppointmentsState({
    this.allAppointments = const [],
    this.dateRangeFilter = 'all',
    this.departmentFilter = 'all',
    this.serviceFilter = 'all',
    this.doctorFilter = 'all',
    this.statusFilter = 'all',
    this.paymentFilter = 'all',
    this.searchQuery = '',
    this.viewMode = 'list',
    this.selectedAppointment,
    DateTime? selectedCalendarDate,
    this.isLoading = false,
    this.message,
  }) : selectedCalendarDate = selectedCalendarDate ?? DateTime.now();

  bool get hasActiveFilters =>
      dateRangeFilter != 'all' ||
      departmentFilter != 'all' ||
      serviceFilter != 'all' ||
      doctorFilter != 'all' ||
      statusFilter != 'all' ||
      paymentFilter != 'all' ||
      searchQuery.trim().isNotEmpty;

  List<String> get availableDepartments {
    final depts = allAppointments
        .map((a) => a.departmentName)
        .where((d) => d.isNotEmpty)
        .toSet()
        .toList();
    depts.sort();
    return ['all', ...depts];
  }

  List<String> get availableServices {
    final services = allAppointments
        .map((a) => a.service)
        .where((s) => s.isNotEmpty)
        .toSet()
        .toList();
    services.sort();
    return ['all', ...services];
  }

  List<String> get availableDoctors {
    final doctors = allAppointments
        .map((a) => a.doctor)
        .where((d) => d.isNotEmpty)
        .toSet()
        .toList();
    doctors.sort();
    return ['all', ...doctors];
  }

  List<ClinicAppointmentEntity> get filteredAppointments {
    return allAppointments.where((appt) {
      // Search query filter
      if (searchQuery.trim().isNotEmpty) {
        final q = searchQuery.toLowerCase().trim();
        final match =
            appt.customerName.toLowerCase().contains(q) ||
            appt.bookingId.toLowerCase().contains(q) ||
            appt.doctor.toLowerCase().contains(q) ||
            appt.phone.toLowerCase().contains(q) ||
            appt.service.toLowerCase().contains(q);
        if (!match) return false;
      }

      // Department filter
      if (departmentFilter != 'all' &&
          appt.departmentName.toLowerCase() != departmentFilter.toLowerCase()) {
        return false;
      }

      // Service filter
      if (serviceFilter != 'all' &&
          appt.service.toLowerCase() != serviceFilter.toLowerCase()) {
        return false;
      }

      // Doctor filter
      if (doctorFilter != 'all' &&
          appt.doctor.toLowerCase() != doctorFilter.toLowerCase()) {
        return false;
      }

      // Status filter
      if (statusFilter != 'all') {
        if (appt.status.toLowerCase() != statusFilter.toLowerCase()) {
          return false;
        }
      }

      // Payment filter
      if (paymentFilter != 'all') {
        final pStatus = appt.payment.status.toLowerCase();
        if (paymentFilter == 'due' || paymentFilter == 'pending') {
          if (pStatus != 'pending' && pStatus != 'due') return false;
        } else if (pStatus != paymentFilter.toLowerCase()) {
          return false;
        }
      }

      // Date range filter
      if (dateRangeFilter == 'today' || dateRangeFilter == 'week') {
        final apptDate = DateTime.tryParse(appt.dateRaw);
        if (apptDate == null) return false;
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);
        final day = DateTime(apptDate.year, apptDate.month, apptDate.day);
        if (dateRangeFilter == 'today') {
          if (day != today) return false;
        } else if (day.isBefore(today) ||
            day.isAfter(today.add(const Duration(days: 7)))) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  ClinicAppointmentsState copyWith({
    List<ClinicAppointmentEntity>? allAppointments,
    String? dateRangeFilter,
    String? departmentFilter,
    String? serviceFilter,
    String? doctorFilter,
    String? statusFilter,
    String? paymentFilter,
    String? searchQuery,
    String? viewMode,
    ClinicAppointmentEntity? Function()? selectedAppointment,
    DateTime? selectedCalendarDate,
    bool? isLoading,
    String? Function()? message,
  }) {
    return ClinicAppointmentsState(
      allAppointments: allAppointments ?? this.allAppointments,
      dateRangeFilter: dateRangeFilter ?? this.dateRangeFilter,
      departmentFilter: departmentFilter ?? this.departmentFilter,
      serviceFilter: serviceFilter ?? this.serviceFilter,
      doctorFilter: doctorFilter ?? this.doctorFilter,
      statusFilter: statusFilter ?? this.statusFilter,
      paymentFilter: paymentFilter ?? this.paymentFilter,
      searchQuery: searchQuery ?? this.searchQuery,
      viewMode: viewMode ?? this.viewMode,
      selectedAppointment: selectedAppointment != null
          ? selectedAppointment()
          : this.selectedAppointment,
      selectedCalendarDate: selectedCalendarDate ?? this.selectedCalendarDate,
      isLoading: isLoading ?? this.isLoading,
      message: message != null ? message() : this.message,
    );
  }

  @override
  List<Object?> get props => [
    allAppointments,
    dateRangeFilter,
    departmentFilter,
    serviceFilter,
    doctorFilter,
    statusFilter,
    paymentFilter,
    searchQuery,
    viewMode,
    selectedAppointment,
    selectedCalendarDate,
    isLoading,
    message,
  ];
}
