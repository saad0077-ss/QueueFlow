import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/repositories/department_repository_impl.dart';
import '../../domain/entities/department_entity.dart';
import '../bloc/departments_bloc.dart';
import '../bloc/departments_event.dart';

class DepartmentsStreamListener extends StatelessWidget {
  final DepartmentRepositoryImpl repo;
  final Widget child;

  const DepartmentsStreamListener({
    super.key,
    required this.repo,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<DepartmentEntity>>(
      stream: repo.watchDepartments(),
      builder: (context, dSnap) {
        if (dSnap.hasData && dSnap.data != null) {
          context.read<DepartmentsBloc>().add(
            DepartmentsListUpdated(dSnap.data!),
          );
        }
        return StreamBuilder(
          stream: repo.watchExpansionRequests(),
          builder: (context, eSnap) {
            if (eSnap.hasData && eSnap.data != null) {
              context.read<DepartmentsBloc>().add(
                ExpansionRequestsUpdated(eSnap.data!),
              );
            }
            return StreamBuilder(
              stream: repo.watchServiceRequests(),
              builder: (context, sSnap) {
                if (sSnap.hasData && sSnap.data != null) {
                  context.read<DepartmentsBloc>().add(
                    ServiceRequestsUpdated(sSnap.data!),
                  );
                }
                return child;
              },
            );
          },
        );
      },
    );
  }
}
