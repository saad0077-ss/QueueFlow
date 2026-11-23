import 'package:flutter/material.dart';
import 'clinic_log_ticket_dropdowns.dart';
import 'clinic_log_ticket_input_field.dart';

class ClinicLogTicketFormBody extends StatelessWidget {
  final TextEditingController nameCtrl;
  final TextEditingController phoneCtrl;
  final TextEditingController emailCtrl;
  final TextEditingController tokenCtrl;
  final TextEditingController subjectCtrl;
  final TextEditingController descCtrl;
  final String category;
  final ValueChanged<String> onCategoryChanged;
  final String priority;
  final ValueChanged<String> onPriorityChanged;

  const ClinicLogTicketFormBody({
    super.key,
    required this.nameCtrl,
    required this.phoneCtrl,
    required this.emailCtrl,
    required this.tokenCtrl,
    required this.subjectCtrl,
    required this.descCtrl,
    required this.category,
    required this.onCategoryChanged,
    required this.priority,
    required this.onPriorityChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(
              child: ClinicLogTicketInputField(
                controller: nameCtrl,
                label: 'Patient Name *',
                hint: 'e.g. Rahul Sharma',
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Required' : null,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ClinicLogTicketInputField(
                controller: phoneCtrl,
                label: 'Phone Number *',
                hint: 'e.g. +91 98460 12345',
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Required' : null,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: ClinicLogTicketInputField(
                controller: emailCtrl,
                label: 'Email (Optional)',
                hint: 'patient@email.com',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ClinicLogTicketInputField(
                controller: tokenCtrl,
                label: 'Queue Token (Optional)',
                hint: 'e.g. A-024',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ClinicLogTicketDropdowns(
          category: category,
          onCategoryChanged: onCategoryChanged,
          priority: priority,
          onPriorityChanged: onPriorityChanged,
        ),
        const SizedBox(height: 12),
        ClinicLogTicketInputField(
          controller: subjectCtrl,
          label: 'Subject / Issue *',
          hint: 'e.g. Inquired about delay in Room 3',
          validator: (v) =>
              v == null || v.trim().isEmpty ? 'Please enter a subject' : null,
        ),
        const SizedBox(height: 12),
        ClinicLogTicketInputField(
          controller: descCtrl,
          label: 'Detailed Notes (Optional)',
          hint: 'Provide context for doctor, billing desk or platform team...',
          maxLines: 3,
        ),
      ],
    );
  }
}
