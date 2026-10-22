import 'package:flutter/material.dart';

import '../../../../core/widgets/app_snack_bar.dart';
import '../../domain/entities/department_entity.dart';
import '../../domain/entities/dept_service_request_entity.dart';
import '../../domain/repositories/department_repository.dart';
import '../widgets/department_catalog_tab.dart';
import '../widgets/department_details_header.dart';
import '../widgets/department_requests_tab.dart';
import '../widgets/department_settings_tab.dart';
import '../widgets/dept_details_tab_bar.dart';
import '../widgets/dept_details_top_bar.dart';
import '../widgets/edit_service_dialog.dart';

class DepartmentDetailsPage extends StatefulWidget {
  final DepartmentEntity department;
  final DepartmentRepository repository;
  final VoidCallback onBack;

  const DepartmentDetailsPage({super.key, required this.department, required this.repository, required this.onBack});

  @override
  State<DepartmentDetailsPage> createState() => _DepartmentDetailsPageState();
}

class _DepartmentDetailsPageState extends State<DepartmentDetailsPage> {
  int _activeTab = 0;
  late DepartmentEntity _dept;

  @override
  void initState() {
    super.initState();
    _dept = widget.department;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DeptDetailsTopBar(department: _dept, onBack: widget.onBack, onToggleStatus: _toggleStatus),
          const SizedBox(height: 20),
          DepartmentDetailsHeader(department: _dept),
          const SizedBox(height: 20),
          StreamBuilder<List<DeptServiceRequestEntity>>(
            stream: widget.repository.watchServiceRequests(),
            builder: (context, snap) {
              final pending = (snap.data ?? []).where((r) => r.departmentId == _dept.id && r.isPending).length;
              return DeptDetailsTabBar(
                activeTab: _activeTab,
                onTabChanged: (idx) => setState(() => _activeTab = idx),
                catalogCount: _dept.standardServices.length,
                pendingRequestsCount: pending,
              );
            },
          ),
          const SizedBox(height: 20),
          if (_activeTab == 0)
            DepartmentCatalogTab(
              services: _dept.standardServices,
              onAddService: (s) async {
                await widget.repository.addStandardService(_dept.id, s);
                setState(() => _dept = _dept.copyWith(standardServices: [..._dept.standardServices, s]));
                if (context.mounted) AppSnackBar.showSuccess(context, message: 'Added "${s.name}" to catalog.');
              },
              onEditService: (s) => EditServiceDialog.show(
                context,
                service: s,
                existingServices: _dept.standardServices,
                onSave: (up) async {
                  await widget.repository.updateStandardService(_dept.id, up);
                  setState(() => _dept = _dept.copyWith(standardServices: _dept.standardServices.map((x) => x.id == up.id ? up : x).toList()));
                  if (context.mounted) AppSnackBar.showSuccess(context, message: 'Updated "${up.name}".');
                },
              ),
              onRemoveService: (sid) async {
                await widget.repository.removeStandardService(_dept.id, sid);
                setState(() => _dept = _dept.copyWith(standardServices: _dept.standardServices.where((x) => x.id != sid).toList()));
                if (context.mounted) AppSnackBar.showSuccess(context, message: 'Removed procedure.');
              },
            )
          else if (_activeTab == 1)
            StreamBuilder<List<DeptServiceRequestEntity>>(
              stream: widget.repository.watchServiceRequests(),
              builder: (context, snap) {
                final list = (snap.data ?? []).where((r) => r.departmentId == _dept.id && r.isPending).toList();
                return DepartmentRequestsTab(
                  requests: list,
                  onApprove: (r) async {
                    await widget.repository.approveServiceRequest(r.id);
                    if (context.mounted) AppSnackBar.showSuccess(context, message: 'Approved "${r.serviceName}".');
                  },
                  onReject: (r) async {
                    await widget.repository.rejectServiceRequest(r.id, 'Standard catalog guidelines.');
                    if (context.mounted) AppSnackBar.showWarning(context, message: 'Request rejected.');
                  },
                );
              },
            )
          else
            DepartmentSettingsTab(
              department: _dept,
              onSave: (up) async {
                await widget.repository.updateDepartment(up);
                setState(() => _dept = up);
                if (context.mounted) AppSnackBar.showSuccess(context, message: 'Specialty rules updated.');
              },
            ),
        ],
      ),
    );
  }

  void _toggleStatus() async {
    await widget.repository.toggleDepartmentStatus(_dept.id, _dept.isActive);
    setState(() => _dept = _dept.copyWith(status: _dept.isActive ? 'inactive' : 'active'));
    if (mounted) AppSnackBar.showSuccess(context, message: 'Status updated.');
  }
}
