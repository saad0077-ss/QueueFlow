import 'package:flutter/material.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

import 'clinic_appointments_filter_args.dart';
import 'clinic_appointments_filter_body.dart';

export 'clinic_appointments_filter_args.dart';

typedef ClinicAppointmentsApplyCallback =
    void Function({
      required String date,
      required String dept,
      required String service,
      required String doctor,
      required String status,
      required String payment,
    });

class ClinicAppointmentsFilterModal extends StatefulWidget {
  final ClinicAppointmentsFilterArgs args;
  final ClinicAppointmentsApplyCallback onApply;

  const ClinicAppointmentsFilterModal({
    super.key,
    required this.args,
    required this.onApply,
  });

  static Future<void> show(
    BuildContext context, {
    required ClinicAppointmentsFilterArgs args,
    required ClinicAppointmentsApplyCallback onApply,
  }) {
    return AppFilterDialogScaffold.show(
      context,
      builder: (_) =>
          ClinicAppointmentsFilterModal(args: args, onApply: onApply),
    );
  }

  @override
  State<ClinicAppointmentsFilterModal> createState() =>
      _ClinicAppointmentsFilterModalState();
}

class _ClinicAppointmentsFilterModalState
    extends State<ClinicAppointmentsFilterModal> {
  late String _date;
  late String _dept;
  late String _service;
  late String _doctor;
  late String _status;
  late String _payment;

  @override
  void initState() {
    super.initState();
    _date = widget.args.date;
    _dept = widget.args.dept;
    _service = widget.args.service;
    _doctor = widget.args.doctor;
    _status = widget.args.status;
    _payment = widget.args.payment;
  }

  void _resetAll() => setState(() {
    _date = 'all';
    _dept = 'all';
    _service = 'all';
    _doctor = 'all';
    _status = 'all';
    _payment = 'all';
  });

  void _apply() {
    widget.onApply(
      date: _date,
      dept: _dept,
      service: _service,
      doctor: _doctor,
      status: _status,
      payment: _payment,
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AppFilterDialogScaffold(
      header: AppFilterHeader(
        title: 'Filter Appointments',
        subtitle: 'Select date range, clinician, department, and status',
        onClose: () => Navigator.of(context).pop(),
      ),
      body: ClinicAppointmentsFilterBody(
        date: _date,
        dept: _dept,
        service: _service,
        doctor: _doctor,
        status: _status,
        payment: _payment,
        availableDepts: widget.args.availableDepts,
        availableServices: widget.args.availableServices,
        availableDoctors: widget.args.availableDoctors,
        onSelectDate: (v) => setState(() => _date = v),
        onSelectDept: (v) => setState(() => _dept = v),
        onSelectService: (v) => setState(() => _service = v),
        onSelectDoctor: (v) => setState(() => _doctor = v),
        onSelectStatus: (v) => setState(() => _status = v),
        onSelectPayment: (v) => setState(() => _payment = v),
      ),
      footer: AppFilterFooter(
        onResetAll: _resetAll,
        onCancel: () => Navigator.of(context).pop(),
        onApply: _apply,
      ),
    );
  }
}
