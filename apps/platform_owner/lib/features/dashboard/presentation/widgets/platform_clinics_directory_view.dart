import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../departments/domain/entities/department_entity.dart';
import '../../data/models/tenant_clinic_model.dart';
import '../../data/repositories/tenant_repository_impl.dart';
import '../../domain/entities/tenant_clinic_entity.dart';
import '../bloc/clinics_directory_bloc.dart';
import '../bloc/clinics_directory_event.dart';
import '../bloc/clinics_directory_state.dart';
import 'clinics_directory_content.dart';
import 'console_top_bar.dart';

class PlatformClinicsDirectoryView extends StatelessWidget {
  final bool isDesktop;
  final Stream<QuerySnapshot> clinicsStream;
  final Stream<Map<String, int>> appointmentsStream;
  final Stream<List<DepartmentEntity>> departmentsStream;
  final TenantRepositoryImpl repo;
  final ValueChanged<TenantClinicEntity> onDetails;
  final ValueChanged<TenantClinicEntity> onResendInvite;
  final VoidCallback onClinicDeleted;

  const PlatformClinicsDirectoryView({
    super.key,
    required this.isDesktop,
    required this.clinicsStream,
    required this.appointmentsStream,
    required this.departmentsStream,
    required this.repo,
    required this.onDetails,
    required this.onResendInvite,
    required this.onClinicDeleted,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ConsoleTopBar(
          onMenuPressed: isDesktop
              ? null
              : () => Scaffold.of(context).openDrawer(),
          onSearch: (q) => context.read<ClinicsDirectoryBloc>().add(
            ClinicsSearchQueryChanged(q),
          ),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: clinicsStream,
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data != null) {
                final list = snapshot.data!.docs
                    .map((d) => TenantClinicModel.fromFirestore(d))
                    .where((c) => !TenantRepositoryImpl.isDummyClinic(c))
                    .toList();
                context.read<ClinicsDirectoryBloc>().add(
                  ClinicsListUpdated(list),
                );
              }
              return BlocBuilder<ClinicsDirectoryBloc, ClinicsDirectoryState>(
                builder: (context, state) => StreamBuilder<Map<String, int>>(
                  stream: appointmentsStream,
                  builder: (context, apptSnap) =>
                      StreamBuilder<List<DepartmentEntity>>(
                        stream: departmentsStream,
                        builder: (context, deptSnap) => ClinicsDirectoryContent(
                          isDesktop: isDesktop,
                          state: state,
                          appointments: apptSnap.data ?? const <String, int>{},
                          departments: deptSnap.data ?? const [],
                          repo: repo,
                          onDetails: onDetails,
                          onResendInvite: onResendInvite,
                          onClinicDeleted: onClinicDeleted,
                        ),
                      ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
