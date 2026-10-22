import 'package:flutter/material.dart';
import '../../../../core/layout/clinic_breakpoints.dart';
import '../../domain/entities/clinic_doctor_entity.dart';
import '../../domain/entities/clinic_service_entity.dart';
import '../../domain/entities/service_department_entity.dart';
import 'service_dialog_header.dart';
import 'service_edit_form.dart';
import 'service_ui_kit.dart';

class ServiceEditDialog extends StatelessWidget {
  final ClinicServiceEntity? initialService;
  final List<ServiceDepartmentEntity> departments;
  final List<ClinicDoctorEntity> doctors;
  final ValueChanged<ClinicServiceEntity> onSave;

  const ServiceEditDialog({
    super.key,
    this.initialService,
    required this.departments,
    required this.doctors,
    required this.onSave,
  });

  static Future<void> show(
    BuildContext context, {
    ClinicServiceEntity? service,
    required List<ServiceDepartmentEntity> departments,
    required List<ClinicDoctorEntity> doctors,
    required ValueChanged<ClinicServiceEntity> onSave,
  }) => showDialog(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.6),
    builder: (_) => ServiceEditDialog(
      initialService: service,
      departments: departments,
      doctors: doctors,
      onSave: onSave,
    ),
  );

  @override
  Widget build(BuildContext context) {
    final isMobile = ClinicBreakpoints.isMobile(context);

    return Dialog(
      backgroundColor: ServiceColors.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: const BorderSide(color: Color(0xFF2A3754)),
      ),
      insetPadding: isMobile
          ? const EdgeInsets.symmetric(horizontal: 12, vertical: 20)
          : const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 540, maxHeight: 760),
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            isMobile ? 18 : 26,
            isMobile ? 18 : 24,
            isMobile ? 18 : 26,
            isMobile ? 18 : 26,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              ServiceDialogHeader(
                isEdit: initialService != null,
                onClose: () => Navigator.pop(context),
              ),
              const SizedBox(height: 20),
              ServiceEditForm(
                initialService: initialService,
                departments: departments,
                doctors: doctors,
                onCancel: () => Navigator.pop(context),
                onSave: (service) {
                  onSave(service);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
