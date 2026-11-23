import 'package:flutter/material.dart';
import 'package:queueflow_ui/queueflow_ui.dart';
import '../../domain/repositories/clinic_support_repository.dart';
import 'dialog/clinic_log_ticket_actions.dart';
import 'dialog/clinic_log_ticket_form_body.dart';
import 'dialog/clinic_log_ticket_header.dart';
import 'dialog/clinic_log_ticket_submit_handler.dart';

class ClinicLogTicketDialog extends StatefulWidget {
  final String clinicId;
  final String clinicName;
  final ClinicSupportRepository repository;
  final VoidCallback onTicketLogged;

  const ClinicLogTicketDialog({
    super.key,
    required this.clinicId,
    required this.clinicName,
    required this.repository,
    required this.onTicketLogged,
  });

  static Future<void> show(
    BuildContext context, {
    required String clinicId,
    required String clinicName,
    required ClinicSupportRepository repository,
    required VoidCallback onTicketLogged,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => ClinicLogTicketDialog(
        clinicId: clinicId,
        clinicName: clinicName,
        repository: repository,
        onTicketLogged: onTicketLogged,
      ),
    );
  }

  @override
  State<ClinicLogTicketDialog> createState() => _ClinicLogTicketDialogState();
}

class _ClinicLogTicketDialogState extends State<ClinicLogTicketDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _tokenCtrl = TextEditingController();
  final _subjectCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  String _category = 'queue';
  String _priority = 'medium';
  bool _isSaving = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _tokenCtrl.dispose();
    _subjectCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _isSaving) return;
    setState(() => _isSaving = true);
    await ClinicLogTicketSubmitHandler.submit(
      context: context,
      repository: widget.repository,
      clinicId: widget.clinicId,
      clinicName: widget.clinicName,
      patientName: _nameCtrl.text.trim(),
      patientPhone: _phoneCtrl.text.trim(),
      patientEmail: _emailCtrl.text.trim().isNotEmpty
          ? _emailCtrl.text.trim()
          : null,
      tokenNumber: _tokenCtrl.text.trim().isNotEmpty
          ? _tokenCtrl.text.trim()
          : null,
      category: _category,
      priority: _priority,
      subject: _subjectCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      onTicketLogged: widget.onTicketLogged,
    );
    if (mounted) setState(() => _isSaving = false);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: context.colors.surface,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(22),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                ClinicLogTicketHeader(
                  onClose: () => Navigator.of(context).pop(),
                ),
                const SizedBox(height: 16),
                ClinicLogTicketFormBody(
                  nameCtrl: _nameCtrl,
                  phoneCtrl: _phoneCtrl,
                  emailCtrl: _emailCtrl,
                  tokenCtrl: _tokenCtrl,
                  subjectCtrl: _subjectCtrl,
                  descCtrl: _descCtrl,
                  category: _category,
                  onCategoryChanged: (c) => setState(() => _category = c),
                  priority: _priority,
                  onPriorityChanged: (p) => setState(() => _priority = p),
                ),
                const SizedBox(height: 20),
                ClinicLogTicketActions(
                  isSaving: _isSaving,
                  onCancel: () => Navigator.of(context).pop(),
                  onSubmit: _submit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
