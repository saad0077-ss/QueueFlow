import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/profile_bloc.dart';
import '../../bloc/profile_event.dart';

class RaiseConcernSubmitHandler {
  static void submit(
    BuildContext context, {
    required GlobalKey<FormState> formKey,
    required String selectedCategory,
    required bool isClinicRelated,
    required String selectedClinicId,
    required String selectedClinicName,
    required String subject,
    required String description,
    required String selectedPriority,
    required String? tokenNumber,
    required bool attachToken,
    required VoidCallback onStartSubmitting,
  }) {
    if (!formKey.currentState!.validate()) return;
    final isTech = selectedCategory == 'technical';
    final isClinic = !isTech && isClinicRelated;
    onStartSubmitting();
    context.read<ProfileBloc>().add(
      ProfileSupportTicketCreated(
        clinicId: isClinic ? selectedClinicId : 'platform',
        clinicName: isClinic
            ? selectedClinicName
            : 'QueueFlow Platform Operations',
        category: selectedCategory,
        subject: subject.trim(),
        description: description.trim(),
        priority: selectedPriority,
        linkedTokenNumber: (isClinic && attachToken) ? tokenNumber : null,
        isClinicRelated: isClinic,
      ),
    );
  }
}
