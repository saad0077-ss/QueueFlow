import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:patient_app/core/theme/app_colors.dart';
import 'package:patient_app/features/clinic_details/domain/entities/clinic_doctor_item.dart';
import 'package:patient_app/features/clinic_details/domain/entities/clinic_service_item.dart';
import 'package:patient_app/features/home/domain/entities/clinic_entity.dart';
import 'package:patient_app/features/booking/data/repositories/booking_repository_impl.dart';
import 'package:patient_app/features/booking/domain/repositories/booking_repository.dart';
import 'package:patient_app/features/booking/domain/usecases/create_appointment_usecase.dart';
import 'package:patient_app/features/booking/presentation/bloc/booking_bloc.dart';
import 'package:patient_app/features/booking/presentation/bloc/booking_event.dart';
import 'package:patient_app/features/booking/presentation/bloc/booking_state.dart';
import 'package:patient_app/features/booking/presentation/widgets/booking_stepper_header.dart';
import 'package:patient_app/features/booking/presentation/widgets/booking_step1_service.dart';
import 'package:patient_app/features/booking/presentation/widgets/booking_step2_doctor.dart';
import 'package:patient_app/features/booking/presentation/widgets/booking_step3_schedule.dart';
import 'package:patient_app/features/booking/presentation/widgets/booking_step4_confirm.dart';
import 'package:patient_app/features/booking/presentation/widgets/booking_step5_receipt.dart';
import 'package:patient_app/core/services/razorpay_payment_service.dart';
import 'package:patient_app/core/widgets/app_snack_bar.dart';

class BookingWizardScreen extends StatelessWidget {
  final ClinicEntity clinic;
  final ClinicServiceItem? initialService;
  final ClinicDoctorItem? initialDoctor;
  final BookingRepository? bookingRepository;

  const BookingWizardScreen({
    super.key,
    required this.clinic,
    this.initialService,
    this.initialDoctor,
    this.bookingRepository,
  });

  static Future<bool?> push(
    BuildContext context, {
    required ClinicEntity clinic,
    ClinicServiceItem? initialService,
    ClinicDoctorItem? initialDoctor,
    BookingRepository? bookingRepository,
  }) {
    return Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => BookingWizardScreen(
          clinic: clinic,
          initialService: initialService,
          initialDoctor: initialDoctor,
          bookingRepository: bookingRepository,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final repo = bookingRepository ?? BookingRepositoryImpl();

    return BlocProvider(
      create: (_) => BookingBloc(
        bookingRepository: repo,
        createAppointmentUseCase: CreateAppointmentUseCase(repo),
      )..add(
          InitBookingWizard(
            clinic: clinic,
            preselectedService: initialService,
            preselectedDoctor: initialDoctor,
          ),
        ),
      child: const _BookingWizardView(),
    );
  }
}

class _BookingWizardView extends StatefulWidget {
  const _BookingWizardView();

  @override
  State<_BookingWizardView> createState() => _BookingWizardViewState();
}

class _BookingWizardViewState extends State<_BookingWizardView> {
  late final RazorpayPaymentService _razorpayService;

  @override
  void initState() {
    super.initState();
    _razorpayService = RazorpayPaymentService()..initialize();
  }

  @override
  void dispose() {
    _razorpayService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<BookingBloc, BookingState>(
      listener: (context, state) {
        if (state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      builder: (context, state) {
        final bloc = context.read<BookingBloc>();

        return Scaffold(
          backgroundColor: AppColors.darkBgApp,
          appBar: AppBar(
            backgroundColor: AppColors.darkBgApp,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.chevron_left_rounded, size: 28),
              color: AppColors.darkInk,
              onPressed: () {
                if (state.step > 1 && state.step <= 4) {
                  bloc.add(const PreviousStep());
                } else {
                  Navigator.of(context).pop();
                }
              },
            ),
            centerTitle: true,
            title: Text(
              state.step == 5 ? 'Appointment Confirmed' : 'Book appointment',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.darkInk,
              ),
            ),
            actions: const [
              SizedBox(width: 48), // Balance leading
            ],
          ),
          body: state.status == BookingStatus.loading
              ? const Center(
                  child: CircularProgressIndicator(color: AppColors.primaryLight),
                )
              : SafeArea(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (state.step <= 4)
                          BookingStepperHeader(
                            currentStep: state.step,
                            onStepTapped: (step) => bloc.add(GoToStep(step)),
                          ),
                        const SizedBox(height: 8),
                        _buildStepBody(context, state, bloc),
                      ],
                    ),
                  ),
                ),
        );
      },
    );
  }

  Widget _buildStepBody(
    BuildContext context,
    BookingState state,
    BookingBloc bloc,
  ) {
    switch (state.step) {
      case 1:
        return BookingStep1Service(
          services: state.services,
          selectedService: state.selectedService,
          onServiceSelected: (service) => bloc.add(SelectService(service)),
          onContinue: () => bloc.add(const NextStep()),
        );

      case 2:
        return BookingStep2Doctor(
          doctors: state.filteredDoctors,
          selectedDoctor: state.selectedDoctor,
          onDoctorSelected: (doctor) => bloc.add(SelectDoctor(doctor)),
          onBack: () => bloc.add(const PreviousStep()),
          onContinue: () => bloc.add(const NextStep()),
        );

      case 3:
        return BookingStep3Schedule(
          selectedDate: state.selectedDate,
          availableSlots: state.availableTimeSlots,
          selectedSlot: state.selectedTimeSlot,
          payableFee: state.payableFee,
          onDateSelected: (date) => bloc.add(SelectDate(date)),
          onSlotSelected: (slot) => bloc.add(SelectTimeSlot(slot)),
          onBack: () => bloc.add(const PreviousStep()),
          onContinue: () => bloc.add(const NextStep()),
        );

      case 4:
        return BookingStep4Confirm(
          clinic: state.clinic!,
          service: state.selectedService!,
          doctor: state.selectedDoctor!,
          formattedSchedule: state.formattedSchedule,
          patientName: state.patientName,
          patientPhone: state.patientPhone,
          payableFee: state.payableFee,
          isSubmitting: state.status == BookingStatus.submitting,
          onEditSchedule: () => bloc.add(const GoToStep(3)),
          onBack: () => bloc.add(const PreviousStep()),
          onPayAndConfirm: () {
            _initiateRazorpayPayment(context, state, bloc);
          },
        );

      case 5:
        return BookingStep5Receipt(
          appointment: state.confirmedAppointment!,
          onViewMyBookings: () {
            // Pop with 'goToBookings: true' so caller navigates to My Bookings
            Navigator.of(context).pop(true);
          },
          onBackToHome: () {
            Navigator.of(context).pop(false);
          },
        );

      default:
        return const SizedBox.shrink();
    }
  }

  void _initiateRazorpayPayment(
    BuildContext context,
    BookingState state,
    BookingBloc bloc,
  ) {
    final sName = state.selectedService?.name ?? 'Doctor Visit';
    final cleanTitle = sName.toLowerCase().contains('consultation')
        ? sName
        : '$sName Consultation';
    final ref = '${state.clinic?.name ?? 'Clinic'} • ${state.selectedDoctor?.name ?? 'Doctor'}';

    _razorpayService.openPayment(
      context: context,
      amount: state.payableFee,
      bookingTitle: cleanTitle,
      bookingRef: ref,
      clinicName: state.clinic?.name ?? 'Clinic',
      patientName: state.patientName,
      patientPhone: state.patientPhone,
      patientEmail: state.patientEmail,
      onSuccess: (paymentInfo) {
        bloc.add(ConfirmPaymentAndBook(paymentInfo));
      },
      onFailure: (errorMessage, errorCode) {
        AppSnackBar.showError(
          context,
          message: 'Razorpay payment could not be processed: $errorMessage',
          title: 'Payment Incomplete',
        );
      },
      onExternalWallet: (walletName) {
        AppSnackBar.showInfo(
          context,
          message: 'External wallet selected: $walletName',
        );
      },
    );
  }
}
