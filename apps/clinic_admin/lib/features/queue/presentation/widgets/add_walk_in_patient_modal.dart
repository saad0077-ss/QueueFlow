import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../services/domain/entities/clinic_service_entity.dart';
import '../../../services/domain/entities/service_department_entity.dart';
import '../bloc/walk_in_cubit.dart';
import 'walk_in/walk_in_actions_footer.dart';
import 'walk_in/walk_in_form_body.dart';
import 'walk_in/walk_in_modal_header.dart';

typedef WalkInSubmit = void Function({
  required String name,
  required String phone,
  required String service,
  required String department,
  String? email,
  String? note,
});

class AddWalkInPatientModal extends StatelessWidget {
  final List<ServiceDepartmentEntity> departments;
  final List<ClinicServiceEntity> services;
  final String? preselectedService;
  final WalkInSubmit onAdd;

  const AddWalkInPatientModal({
    super.key,
    required this.departments,
    required this.services,
    required this.onAdd,
    this.preselectedService,
  });

  static Future<void> show(
    BuildContext context, {
    required List<ServiceDepartmentEntity> departments,
    required List<ClinicServiceEntity> services,
    required WalkInSubmit onAdd,
    String? preselectedService,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.6),
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 470),
          child: AddWalkInPatientModal(
            departments: departments,
            services: services,
            preselectedService: preselectedService,
            onAdd: onAdd,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => WalkInCubit(
        rawDepartments: departments,
        rawServices: services,
        preselectedService: preselectedService,
      ),
      child: _AddWalkInPatientModalForm(onAdd: onAdd),
    );
  }
}

class _AddWalkInPatientModalForm extends StatefulWidget {
  final WalkInSubmit onAdd;
  const _AddWalkInPatientModalForm({required this.onAdd});

  @override
  State<_AddWalkInPatientModalForm> createState() => _AddWalkInPatientModalFormState();
}

class _AddWalkInPatientModalFormState extends State<_AddWalkInPatientModalForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _noteController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _submit(BuildContext context, WalkInState state) {
    if (_formKey.currentState?.validate() != true) return;
    final dept = state.currentDepartment;
    widget.onAdd(
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      email: _emailController.text.trim(),
      department: dept?.name ?? state.selectedService?.departmentName ?? '',
      service: state.selectedService?.name ?? '',
      note: _noteController.text.trim(),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: BlocBuilder<WalkInCubit, WalkInState>(
        builder: (context, state) {
          return Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const WalkInModalHeader(),
                  const SizedBox(height: 18),
                  WalkInFormBody(
                    nameController: _nameController,
                    phoneController: _phoneController,
                    emailController: _emailController,
                    noteController: _noteController,
                  ),
                  const SizedBox(height: 20),
                  WalkInActionsFooter(
                    onCancel: () => Navigator.of(context).pop(),
                    onSubmit: () => _submit(context, state),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
