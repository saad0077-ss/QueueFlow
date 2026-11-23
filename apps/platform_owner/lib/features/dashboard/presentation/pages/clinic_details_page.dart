import 'package:flutter/material.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

import '../../data/repositories/tenant_repository_impl.dart';
import '../../domain/entities/tenant_clinic_entity.dart';
import '../widgets/clinic_details/clinic_details_view.dart';
import '../widgets/console_sidebar.dart';

class ClinicDetailsPage extends StatelessWidget {
  final TenantClinicEntity clinic;
  final TenantRepositoryImpl repo;
  final VoidCallback? onBack;

  const ClinicDetailsPage({
    super.key,
    required this.clinic,
    required this.repo,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final scaffoldKey = GlobalKey<ScaffoldState>();
    final isDesktop = MediaQuery.sizeOf(context).width >= 1000;

    return Scaffold(
      key: scaffoldKey,
      backgroundColor: colors.background,
      drawer: isDesktop
          ? null
          : const Drawer(child: ConsoleSidebar(activeIndex: 0)),
      body: Row(
        children: [
          if (isDesktop) const ConsoleSidebar(activeIndex: 0),
          Expanded(
            child: ClinicDetailsView(
              clinic: clinic,
              repo: repo,
              onBack: onBack ?? () => Navigator.of(context).pop(),
              onOpenDrawer: () => scaffoldKey.currentState?.openDrawer(),
            ),
          ),
        ],
      ),
    );
  }
}
