import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/clinic_services_repository_impl.dart';
import '../../domain/entities/clinic_service_entity.dart';
import '../../domain/usecases/delete_clinic_service_usecase.dart';
import '../../domain/usecases/get_clinic_services_usecase.dart';
import '../../domain/usecases/save_clinic_service_usecase.dart';
import '../../domain/usecases/toggle_service_status_usecase.dart';
import '../bloc/clinic_services_bloc.dart';
import '../bloc/clinic_services_event.dart';
import '../bloc/clinic_services_state.dart';
import '../widgets/service_capacity_quota_card.dart';
import '../widgets/service_delete_dialog.dart';
import '../widgets/service_edit_dialog.dart';
import '../widgets/services_cards_grid.dart';
import '../widgets/services_catalog_section_header.dart';
import '../widgets/services_view_header.dart';

class ClinicServicesView extends StatelessWidget {
  final VoidCallback onNavigateToBilling;

  const ClinicServicesView({super.key, required this.onNavigateToBilling});

  @override
  Widget build(BuildContext context) {
    final repo = ClinicServicesRepositoryImpl();
    return BlocProvider(
      create: (_) => ClinicServicesBloc(
        getServicesUseCase: GetClinicServicesUseCase(repo),
        saveServiceUseCase: SaveClinicServiceUseCase(repo),
        toggleServiceStatusUseCase: ToggleServiceStatusUseCase(repo),
        deleteServiceUseCase: DeleteClinicServiceUseCase(repo),
        repository: repo,
      )..add(const ServicesSubscriptionRequested()),
      child: _ClinicServicesBody(onNavigateToBilling: onNavigateToBilling),
    );
  }
}

class _ClinicServicesBody extends StatelessWidget {
  final VoidCallback onNavigateToBilling;

  const _ClinicServicesBody({required this.onNavigateToBilling});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ClinicServicesBloc, ClinicServicesState>(
      listener: (context, state) {
        if (state.toastMessage != null) {
          final color = state.isErrorToast
              ? Colors.red
              : const Color(0xFF1E58F5);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.toastMessage!),
              backgroundColor: color,
            ),
          );
          context.read<ClinicServicesBloc>().add(const ServicesClearToast());
        }
      },
      builder: (context, state) {
        final bloc = context.read<ClinicServicesBloc>();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ServicesViewHeader(
              planPill: state.plan.planPill,
              planName: state.plan.planName,
            ),
            const SizedBox(height: 18),
            ServiceCapacityQuotaCard(
              currentCount: state.services.length,
              limit: state.plan.servicesLimit,
              isUnlimited: state.plan.isUnlimited,
              planName: state.plan.planName,
              onUpgrade: onNavigateToBilling,
            ),
            const SizedBox(height: 22),
            ServicesCatalogSectionHeader(count: state.services.length),
            const SizedBox(height: 14),
            if (state.status == ServicesStatus.initial ||
                state.status == ServicesStatus.loading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 48),
                child: Center(
                  child: CircularProgressIndicator(color: Color(0xFF38BDF8)),
                ),
              )
            else
              ServicesCardsGrid(
                services: state.services,
                isLimitReached: state.isLimitReached,
                availableSlots: state.availableSlots,
                planName: state.plan.planName,
                isUnlimited: state.plan.isUnlimited,
                onEdit: (s) => _openServiceModal(context, state, s),
                onToggle: (s) =>
                    bloc.add(ServiceStatusTogglePressed(s.id, s.status)),
                onDelete: (s) => ServiceDeleteDialog.show(
                  context,
                  serviceName: s.name,
                  onConfirm: () => bloc.add(ServiceDeletePressed(s.id)),
                ),
                onAdd: () => _openServiceModal(context, state, null),
                onUpgrade: onNavigateToBilling,
              ),
          ],
        );
      },
    );
  }

  void _openServiceModal(  
    BuildContext context,
    ClinicServicesState state,
    ClinicServiceEntity? service,
  ) {
    if (service == null && state.isLimitReached) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Service limit reached (${state.services.length}/${state.plan.servicesLimit}). 1 doctor can only provide 1 active service. Upgrade plan to add more.',
          ),
          backgroundColor: const Color(0xFFF59E0B),
        ),
      );
      return;
    }
    ServiceEditDialog.show(
      context,
      service: service,
      departments: state.departments,
      doctors: state.doctors,
      onSave: (svc) =>
          context.read<ClinicServicesBloc>().add(ServiceSaveSubmitted(svc)),
    );
  }
}
