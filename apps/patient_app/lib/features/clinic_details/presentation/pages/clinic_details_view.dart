import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:queueflow_ui/queueflow_ui.dart';
import '../../../booking/presentation/pages/booking_wizard_screen.dart';
import '../../domain/entities/clinic_doctor_item.dart';
import '../../domain/entities/clinic_service_item.dart';
import '../../../home/domain/entities/clinic_entity.dart';
import '../bloc/clinic_details_bloc.dart';
import '../bloc/clinic_details_event.dart';
import '../bloc/clinic_details_state.dart';
import '../widgets/clinic_bottom_actions.dart';
import '../widgets/clinic_cover_hero.dart';
import '../widgets/clinic_doctors_tab.dart';
import '../widgets/clinic_header_info.dart';
import '../widgets/clinic_overview_tab.dart';
import '../widgets/clinic_rate_sheet.dart';
import '../widgets/clinic_reviews_tab.dart';
import '../widgets/clinic_segmented_tabs.dart';
import '../widgets/clinic_services_tab.dart';

class ClinicDetailsView extends StatelessWidget {
  const ClinicDetailsView({super.key});

  void _startBooking(
    BuildContext context, {
    required ClinicEntity clinic,
    ClinicServiceItem? initialService,
    ClinicDoctorItem? initialDoctor,
  }) async {
    final result = await BookingWizardScreen.push(
      context,
      clinic: clinic,
      initialService: initialService,
      initialDoctor: initialDoctor,
    );
    if (result == true && context.mounted) {
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return BlocConsumer<ClinicDetailsBloc, ClinicDetailsState>(
      listener: (context, state) {
        if (state.reviewSubmittedSuccessfully) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Thank you! Your review has been submitted.'),
              backgroundColor: colors.success,
            ),
          );
        }
      },
      builder: (context, state) {
        final details = state.details;
        final clinic = details?.clinic;

        if (clinic == null && state.status == ClinicDetailsStatus.loading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (clinic == null) {
          return Center(
            child: Text('Clinic details unavailable.', style: TextStyle(color: colors.textPrimary)),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClinicCoverHero(
                clinicName: clinic.name,
                clinicId: clinic.id,
                imageVersion: clinic.imageVersion,
                imageUrl: clinic.imageUrl,
                isFavorite: state.isFavorite,
                onBack: () => Navigator.pop(context),
                onToggleFavorite: () {
                  context.read<ClinicDetailsBloc>().add(const ToggleClinicFavorite());
                },
              ),
              ClinicHeaderInfo(
                clinic: clinic,
                holidayNotice: details?.holidayNotice,
              ),
              ClinicSegmentedTabs(
                selectedIndex: state.selectedTabIndex,
                onTabSelected: (idx) {
                  context.read<ClinicDetailsBloc>().add(SelectClinicTab(idx));
                },
              ),
              _buildActiveTab(context, state, clinic),
              const SizedBox(height: 8),
              ClinicBottomActions(
                isQueueOpen: clinic.isQueueOpen,
                onBookAppointment: () => _startBooking(context, clinic: clinic),
                onJoinQueue: () => _showActionSnack(context, 'Joining live queue at ${clinic.name}...'),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActiveTab(
    BuildContext context,
    ClinicDetailsState state,
    ClinicEntity clinic,
  ) {
    final d = state.details!;
    switch (state.selectedTabIndex) {
      case 0:
        return ClinicOverviewTab(description: d.description, features: d.features);
      case 1:
        return ClinicServicesTab(
          services: d.services,
          onServiceSelected: (service) => _startBooking(
            context,
            clinic: clinic,
            initialService: service,
          ),
        );
      case 2:
        return ClinicDoctorsTab(
          doctors: d.doctors,
          onDoctorSelected: (doctor) => _startBooking(
            context,
            clinic: clinic,
            initialDoctor: doctor,
          ),
        );
      case 3:
        return ClinicReviewsTab(
          rating: d.clinic.rating,
          reviewCount: d.clinic.reviewCount,
          starPercents: d.starPercents,
          reviews: d.reviews,
          onRateClinic: () => _showRateModal(context, d.clinic.name),
          onHelpful: (id) => context.read<ClinicDetailsBloc>().add(MarkReviewHelpfulEvent(id)),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  void _showRateModal(BuildContext context, String clinicName) {
    final bloc = context.read<ClinicDetailsBloc>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ClinicRateSheet(
        clinicName: clinicName,
        onSubmit: (r, c, t) => bloc.add(SubmitClinicReviewEvent(rating: r, comment: c, tags: t)),
      ),
    );
  }

  void _showActionSnack(BuildContext context, String message) {
    final colors = context.colors;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: colors.primary),
    );
  }
}
