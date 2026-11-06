import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';
import '../../../../core/widgets/app_snack_bar.dart';
import '../../../services/data/repositories/clinic_services_repository_impl.dart';
import '../../../services/domain/entities/clinic_doctor_entity.dart';
import '../../../services/domain/entities/clinic_service_entity.dart';
import '../../../services/domain/entities/service_department_entity.dart';
import '../../data/repositories/clinic_appointments_repository_impl.dart';
import '../../domain/entities/clinic_appointment_entity.dart';
import '../bloc/clinic_appointments_bloc.dart';
import '../bloc/clinic_appointments_event.dart';
import '../bloc/clinic_appointments_state.dart';
import 'appointment_detail_page.dart';
import '../widgets/appointments_calendar_view.dart';
import '../widgets/appointments_filter_bar.dart';
import '../widgets/appointments_header_bar.dart';
import '../widgets/appointments_list_table.dart';
import '../widgets/appointments_stats_row.dart';
import '../widgets/create_appointment_modal.dart';
import '../widgets/reschedule_appointment_dialog.dart';

class ClinicAppointmentsView extends StatelessWidget {
  const ClinicAppointmentsView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ClinicAppointmentsBloc(
        repository: ClinicAppointmentsRepositoryImpl(),
      ),
      child: const _ClinicAppointmentsBody(),
    );
  }
}

class _ClinicAppointmentsBody extends StatelessWidget {
  const _ClinicAppointmentsBody();

  /// Loads the departments assigned to this clinic, its services and doctors.
  Future<ClinicBookingCatalog?> _loadCatalog(BuildContext context) async {
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

  void _exportCsv(BuildContext context, ClinicAppointmentsBloc bloc) async {
    final csvData = await bloc.repository.exportAppointmentsCsv();
    await Clipboard.setData(ClipboardData(text: csvData));
    if (context.mounted) {
      AppSnackBar.showSuccess(
        context,
        message: 'Appointments CSV exported and copied to clipboard!',
      );
    }
  }

  void _confirmCancelAppointment(
    BuildContext context,
    ClinicAppointmentsBloc bloc,
    ClinicAppointmentEntity appt,
  ) {
    final reasonController = TextEditingController();
    final amountController = TextEditingController(
      text: appt.payment.amount.toStringAsFixed(2),
    );
    final colors = context.colors;
    final pay = appt.payment;
    final canRefund = pay.isPaid;

    InputDecoration field(String hint, {String? prefix}) => InputDecoration(
      hintText: hint,
      prefixText: prefix,
      hintStyle: GoogleFonts.inter(fontSize: 12, color: colors.textMuted),
      filled: true,
      fillColor: colors.surfaceSecondary,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: colors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: colors.primary),
      ),
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: colors.border),
        ),
        title: Text(
          'Cancel Appointment?',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w800,
            fontSize: 18,
            color: colors.textPrimary,
          ),
        ),
        content: SizedBox(
          width: 420,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Cancel booking #${appt.bookingId} for ${appt.customerName}?',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: colors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                canRefund
                    ? 'Paid ₹${pay.amount.toStringAsFixed(2)} via ${pay.gateway}. The refund goes back to the original payment method and usually takes 5-7 working days.'
                    : pay.isRefunded
                    ? 'This booking was already refunded. No further refund will be made.'
                    : 'No payment was collected, so there is nothing to refund.',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: canRefund ? colors.warning : colors.textMuted,
                ),
              ),
              if (canRefund) ...[
                const SizedBox(height: 14),
                TextField(
                  controller: amountController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: field('Refund amount', prefix: '₹ '),
                ),
              ],
              const SizedBox(height: 10),
              TextField(
                controller: reasonController,
                decoration: field('Cancellation reason (optional)'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'Keep Booking',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
                color: colors.textMuted,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              final reason = reasonController.text.trim();
              final amount = double.tryParse(amountController.text.trim());
              if (canRefund &&
                  (amount == null || amount < 0 || amount > pay.amount)) {
                AppSnackBar.showError(
                  context,
                  message:
                      'Enter a refund between ₹0 and ₹${pay.amount.toStringAsFixed(2)}.',
                );
                return;
              }
              bloc.add(
                CancelAppointment(
                  appt.id,
                  reason: reason.isNotEmpty ? reason : null,
                  refundAmount: canRefund ? amount : null,
                ),
              );
              Navigator.of(ctx).pop();
              AppSnackBar.showSuccess(
                context,
                message: canRefund
                    ? 'Appointment #${appt.bookingId} cancelled. Refund of ₹${amount!.toStringAsFixed(2)} initiated.'
                    : 'Appointment #${appt.bookingId} cancelled.',
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.error,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              canRefund ? 'Cancel & Refund' : 'Cancel Appointment',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final bloc = context.read<ClinicAppointmentsBloc>();

    return BlocBuilder<ClinicAppointmentsBloc, ClinicAppointmentsState>(
      builder: (context, state) {
        if (state.isLoading) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(40),
              child: CircularProgressIndicator(color: colors.primary),
            ),
          );
        }

        // Detail view replaces the list (not an overlay), so it takes its
        // natural height and the page scrolls instead of being clipped.
        if (state.selectedAppointment != null) {
          return AppointmentDetailPage(
            appointment: state.selectedAppointment!,
            onBack: () => bloc.add(const SelectAppointment(null)),
            onCheckIn: () {
              bloc.add(CheckInAppointment(state.selectedAppointment!.id));
              AppSnackBar.showSuccess(
                context,
                message:
                    'Patient #${state.selectedAppointment!.bookingId} checked in.',
              );
            },
            onComplete: () {
              bloc.add(CompleteAppointment(state.selectedAppointment!.id));
              AppSnackBar.showSuccess(
                context,
                message:
                    'Appointment #${state.selectedAppointment!.bookingId} marked as completed.',
              );
            },
            onReschedule: () {
              RescheduleAppointmentDialog.show(
                context,
                appointment: state.selectedAppointment!,
                onReschedule: (newDate, newTime) {
                  bloc.add(
                    RescheduleAppointment(
                      id: state.selectedAppointment!.id,
                      newDate: newDate,
                      newTime: newTime,
                    ),
                  );
                  AppSnackBar.showSuccess(
                    context,
                    message:
                        'Appointment #${state.selectedAppointment!.bookingId} rescheduled to $newDate · $newTime',
                  );
                },
              );
            },
            onCancel: () {
              _confirmCancelAppointment(
                context,
                bloc,
                state.selectedAppointment!,
              );
            },
          );
        }

        final filtered = state.filteredAppointments;

        return Stack(
          children: [
            // Main Appointments View Body
            SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // View Header
                  AppointmentsHeaderBar(
                    viewMode: state.viewMode,
                    onViewModeChanged: (mode) {
                      bloc.add(ToggleAppointmentViewMode(mode));
                    },
                    onExportCsv: () => _exportCsv(context, bloc),
                    onCreateAppointment: () async {
                      final catalog = await _loadCatalog(context);
                      if (catalog == null || !context.mounted) return;
                      CreateAppointmentModal.show(
                        context,
                        catalog: catalog,
                        onCreate: (newAppt) {
                          bloc.add(CreateAppointment(newAppt));
                          AppSnackBar.showSuccess(
                            context,
                            message:
                                'Appointment #${newAppt.bookingId} scheduled successfully!',
                          );
                        },
                      );
                    },
                  ),

                  const SizedBox(height: 18),

                  AppointmentsStatsRow(appointments: state.allAppointments),

                  const SizedBox(height: 18),

                  // Filters Bar
                  AppointmentsFilterBar(
                    searchQuery: state.searchQuery,
                    onSearchChanged: (val) => bloc.add(ChangeSearchQuery(val)),
                    selectedDateRange: state.dateRangeFilter,
                    selectedDept: state.departmentFilter,
                    selectedService: state.serviceFilter,
                    selectedDoctor: state.doctorFilter,
                    selectedStatus: state.statusFilter,
                    selectedPayment: state.paymentFilter,
                    availableDepts: state.availableDepartments,
                    availableServices: state.availableServices,
                    availableDoctors: state.availableDoctors,
                    totalCount: state.allAppointments.length,
                    filteredCount: filtered.length,
                    hasActiveFilters: state.hasActiveFilters,
                    onDateRangeChanged: (val) =>
                        bloc.add(ChangeDateRangeFilter(val)),
                    onDeptChanged: (val) =>
                        bloc.add(ChangeDepartmentFilter(val)),
                    onServiceChanged: (val) =>
                        bloc.add(ChangeServiceFilter(val)),
                    onDoctorChanged: (val) => bloc.add(ChangeDoctorFilter(val)),
                    onStatusChanged: (val) => bloc.add(ChangeStatusFilter(val)),
                    onPaymentChanged: (val) =>
                        bloc.add(ChangePaymentFilter(val)),
                    onClearFilters: () =>
                        bloc.add(const ResetAppointmentFilters()),
                  ),

                  const SizedBox(height: 18),

                  // List View or Calendar View
                  if (state.viewMode == 'list')
                    AppointmentsListTable(
                      appointments: filtered,
                      onSelectAppointment: (appt) {
                        bloc.add(SelectAppointment(appt));
                      },
                    )
                  else
                    AppointmentsCalendarView(
                      appointments: filtered,
                      selectedDate: state.selectedCalendarDate,
                      onSelectDate: (date) {
                        bloc.add(SelectCalendarDate(date));
                      },
                      onSelectAppointment: (appt) {
                        bloc.add(SelectAppointment(appt));
                      },
                    ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
