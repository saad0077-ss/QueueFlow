import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';
import '../../bloc/walk_in_cubit.dart';
import 'walk_in_department_picker.dart';
import 'walk_in_patient_fields.dart';
import 'walk_in_service_picker.dart';
import 'walk_in_triage_notes_field.dart';

class WalkInFormBody extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController phoneController;
  final TextEditingController emailController;
  final TextEditingController noteController;

  const WalkInFormBody({
    super.key,
    required this.nameController,
    required this.phoneController,
    required this.emailController,
    required this.noteController,
  });

  Widget _label(BuildContext context, String text) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(
      text,
      style: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: context.colors.textPrimary,
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WalkInCubit, WalkInState>(
      builder: (context, state) {
        final cubit = context.read<WalkInCubit>();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            WalkInPatientFields(
              nameController: nameController,
              phoneController: phoneController,
              emailController: emailController,
              noteController: noteController,
            ),
            const SizedBox(height: 14),
            _label(context, 'Department *'),
            WalkInDepartmentPicker(
              departments: state.departments,
              selectedDeptKey: state.deptKey,
              onDepartmentChanged: cubit.selectDepartment,
            ),
            const SizedBox(height: 14),
            _label(context, 'Clinical Service *'),
            WalkInServicePicker(
              deptServices: state.departmentServices,
              selectedServiceId: state.selectedService?.id,
              deptKey: state.deptKey,
              onServiceChanged: cubit.selectService,
            ),
            const SizedBox(height: 14),
            WalkInTriageNotesField(controller: noteController),
          ],
        );
      },
    );
  }
}
