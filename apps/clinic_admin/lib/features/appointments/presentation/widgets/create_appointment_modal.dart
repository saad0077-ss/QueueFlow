import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';
import '../../../services/domain/entities/clinic_doctor_entity.dart';
import '../../../services/domain/entities/clinic_service_entity.dart';
import '../../../services/domain/entities/service_department_entity.dart';
import '../../domain/entities/clinic_appointment_entity.dart';

/// The clinic's own catalog used to populate the booking form.
class ClinicBookingCatalog {
  final List<ServiceDepartmentEntity> departments;
  final List<ClinicServiceEntity> services;
  final List<ClinicDoctorEntity> doctors;

  const ClinicBookingCatalog({
    this.departments = const [],
    this.services = const [],
    this.doctors = const [],
  });

  List<String> get departmentNames {
    final names = departments.map((d) => d.name).toList();
    for (final s in services) {
      if (s.departmentName.isNotEmpty && !names.contains(s.departmentName)) {
        names.add(s.departmentName);
      }
    }
    return names;
  }

  List<ClinicServiceEntity> servicesFor(String dept) => services
      .where((s) => s.isActive && s.departmentName == dept)
      .toList();

  /// Doctors assigned to the service, else the department's doctors, else all.
  List<String> doctorsFor(String dept, ClinicServiceEntity? service) {
    final all = doctors.map((d) => d.name).toList();
    if (service != null) {
      final assigned = service.assignedStaff.where(all.contains).toList();
      if (assigned.isNotEmpty) return assigned;
    }
    final inDept = doctors
        .where((d) => d.department == dept || d.specialty == dept)
        .map((d) => d.name)
        .toList();
    return inDept.isNotEmpty ? inDept : all;
  }
}

class CreateAppointmentModal extends StatefulWidget {
  final ClinicBookingCatalog catalog;
  final ValueChanged<ClinicAppointmentEntity> onCreate;

  const CreateAppointmentModal({
    super.key,
    required this.catalog,
    required this.onCreate,
  });

  static Future<void> show(
    BuildContext context, {
    required ClinicBookingCatalog catalog,
    required ValueChanged<ClinicAppointmentEntity> onCreate,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) =>
          CreateAppointmentModal(catalog: catalog, onCreate: onCreate),
    );
  }

  @override
  State<CreateAppointmentModal> createState() => _CreateAppointmentModalState();
}

class _CreateAppointmentModalState extends State<CreateAppointmentModal> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _feeController;
  late TextEditingController _notesController;

  late String _selectedDept;
  late String _selectedService;
  late String _selectedDoctor;
  late String _selectedDate;
  late String _selectedTime;
  late String _paymentStatus;
  late String _paymentMethod;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _phoneController = TextEditingController(text: '+91 ');
    _emailController = TextEditingController();
    _feeController = TextEditingController();
    _notesController = TextEditingController();

    final depts = widget.catalog.departmentNames;
    _selectedDept = depts.isNotEmpty ? depts.first : '';
    _selectedService = '';
    _selectedDoctor = '';
    _onDeptSelected(_selectedDept);

    final now = DateTime.now();
    _selectedDate =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    _selectedTime = '11:00 AM';
    _paymentStatus = 'paid';
    _paymentMethod = 'Razorpay UPI (Google Pay)';
  }

  ClinicServiceEntity? get _currentService {
    for (final s in widget.catalog.servicesFor(_selectedDept)) {
      if (s.name == _selectedService) return s;
    }
    return null;
  }

  void _onDeptSelected(String dept) {
    _selectedDept = dept;
    final services = widget.catalog.servicesFor(dept);
    _onServiceSelected(services.isNotEmpty ? services.first.name : '');
  }

  /// Picks the service, auto-fills its consultation fee and re-scopes doctors.
  void _onServiceSelected(String name) {
    _selectedService = name;
    final service = _currentService;
    _feeController.text = service != null ? service.price.toString() : '';
    final doctors = widget.catalog.doctorsFor(_selectedDept, service);
    if (!doctors.contains(_selectedDoctor)) {
      _selectedDoctor = doctors.isNotEmpty ? doctors.first : '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _feeController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final idNumber = DateTime.now().millisecondsSinceEpoch % 100000;
    final bookingId = 'QF-$idNumber';
    final fee = double.tryParse(_feeController.text.trim()) ?? 500.0;

    final newAppt = ClinicAppointmentEntity(
      id: 'apt-$idNumber',
      bookingId: bookingId,
      customerName: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      email: _emailController.text.trim().isNotEmpty
          ? _emailController.text.trim()
          : 'patient@queueflow.com',
      service: _selectedService,
      departmentName: _selectedDept,
      servicePrice: fee,
      serviceDuration: '20 mins',
      serviceDescription: 'Consultation & medical evaluation.',
      doctor: _selectedDoctor,
      dateTime: '$_selectedDate · $_selectedTime',
      dateRaw: _selectedDate,
      timeRaw: _selectedTime,
      status: 'confirmed',
      notes: _notesController.text.trim().isNotEmpty
          ? _notesController.text.trim()
          : 'Routine checkup scheduled by clinic desk.',
      payment: AppointmentPaymentEntity(
        status: _paymentStatus,
        amount: fee,
        currency: 'INR',
        gateway: _paymentStatus == 'paid'
            ? 'Razorpay (Online UPI)'
            : 'Pay at Clinic Desk',
        method: _paymentMethod,
        paymentId: 'pay_gen_$idNumber',
        orderId: 'ord_QF$idNumber',
        receiptNo: 'REC-2026-$idNumber',
        paidAt: _paymentStatus == 'paid'
            ? 'Today, just now'
            : 'Due upon arrival',
      ),
    );

    widget.onCreate(newAppt);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    final depts = widget.catalog.departmentNames;
    final services = widget.catalog
        .servicesFor(_selectedDept)
        .map((s) => s.name)
        .toList();
    final doctors = widget.catalog.doctorsFor(_selectedDept, _currentService);

    return Dialog(
      backgroundColor: colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colors.border),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 540, maxHeight: 720),
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Modal Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Schedule Appointment',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: colors.textPrimary,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close_rounded),
                      color: colors.textMuted,
                      splashRadius: 18,
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Form Scrollable Fields
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Patient Full Name
                        _buildLabel(context, 'Patient Full Name *'),
                        TextFormField(
                          controller: _nameController,
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'Please enter patient name'
                              : null,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: colors.textPrimary,
                          ),
                          decoration: _inputDecoration(
                            context,
                            'e.g. Aisha Rahman',
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Phone & Email Row
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildLabel(context, 'Phone *'),
                                  TextFormField(
                                    controller: _phoneController,
                                    validator: (v) =>
                                        (v == null || v.trim().isEmpty)
                                        ? 'Enter phone'
                                        : null,
                                    style: GoogleFonts.inter(
                                      fontSize: 13,
                                      color: colors.textPrimary,
                                    ),
                                    decoration: _inputDecoration(
                                      context,
                                      '+91 98765 00000',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildLabel(context, 'Email'),
                                  TextFormField(
                                    controller: _emailController,
                                    style: GoogleFonts.inter(
                                      fontSize: 13,
                                      color: colors.textPrimary,
                                    ),
                                    decoration: _inputDecoration(
                                      context,
                                      'patient@email.com',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Dept & Service Row
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildLabel(
                                    context,
                                    'Department / Specialty',
                                  ),
                                  _buildDropdown(
                                    context,
                                    value: _selectedDept,
                                    items: depts,
                                    onChanged: (val) {
                                      if (val != null) {
                                        setState(() => _onDeptSelected(val));
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildLabel(context, 'Service Selected *'),
                                  _buildDropdown(
                                    context,
                                    value: _selectedService,
                                    items: services,
                                    onChanged: (val) {
                                      if (val != null) {
                                        setState(() => _onServiceSelected(val));
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Doctor & Fee Row
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildLabel(context, 'Doctor'),
                                  _buildDropdown(
                                    context,
                                    value: _selectedDoctor,
                                    items: doctors,
                                    onChanged: (val) {
                                      if (val != null) {
                                        setState(() => _selectedDoctor = val);
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildLabel(
                                    context,
                                    'Consultation Fee (₹) *',
                                  ),
                                  TextFormField(
                                    controller: _feeController,
                                    keyboardType: TextInputType.number,
                                    validator: (v) =>
                                        (v == null || v.trim().isEmpty)
                                        ? 'Enter fee'
                                        : null,
                                    style: GoogleFonts.jetBrainsMono(
                                      fontSize: 13,
                                      color: colors.textPrimary,
                                    ),
                                    decoration: _inputDecoration(
                                      context,
                                      '500',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Date & Time Row
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildLabel(context, 'Date'),
                                  InkWell(
                                    onTap: () async {
                                      final picked = await showDatePicker(
                                        context: context,
                                        initialDate: DateTime.now(),
                                        firstDate: DateTime.now(),
                                        lastDate: DateTime.now().add(
                                          const Duration(days: 365 * 2),
                                        ),
                                      );
                                      if (picked != null) {
                                        setState(() {
                                          _selectedDate =
                                              '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
                                        });
                                      }
                                    },
                                    child: Container(
                                      height: 42,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                      ),
                                      decoration: BoxDecoration(
                                        color: colors.surfaceSecondary,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: colors.border,
                                        ),
                                      ),
                                      alignment: Alignment.centerLeft,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            _selectedDate,
                                            style: GoogleFonts.jetBrainsMono(
                                              fontSize: 12.5,
                                              color: colors.textPrimary,
                                            ),
                                          ),
                                          Icon(
                                            Icons.calendar_today_outlined,
                                            size: 15,
                                            color: colors.textMuted,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildLabel(context, 'Time'),
                                  _buildDropdown(
                                    context,
                                    value: _selectedTime,
                                    items: const [
                                      '09:00 AM',
                                      '10:00 AM',
                                      '11:00 AM',
                                      '11:30 AM',
                                      '12:00 PM',
                                      '02:30 PM',
                                      '03:30 PM',
                                      '04:30 PM',
                                      '05:00 PM',
                                    ],
                                    onChanged: (val) {
                                      if (val != null) {
                                        setState(() => _selectedTime = val);
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Payment Status & Method Row
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildLabel(context, 'Payment Status'),
                                  _buildDropdown(
                                    context,
                                    value: _paymentStatus,
                                    items: const ['paid', 'pending'],
                                    itemLabels: const {
                                      'paid': 'Paid (Online / UPI / Card)',
                                      'pending': 'Pending (Pay at Desk)',
                                    },
                                    onChanged: (val) {
                                      if (val != null) {
                                        setState(() => _paymentStatus = val);
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildLabel(context, 'Payment Method'),
                                  _buildDropdown(
                                    context,
                                    value: _paymentMethod,
                                    items: const [
                                      'Razorpay UPI (Google Pay)',
                                      'Credit / Debit Card',
                                      'Cash / POS Counter',
                                    ],
                                    onChanged: (val) {
                                      if (val != null) {
                                        setState(() => _paymentMethod = val);
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Symptoms / Clinical Notes
                        _buildLabel(context, 'Symptoms / Clinical Notes'),
                        TextFormField(
                          controller: _notesController,
                          maxLines: 2,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: colors.textPrimary,
                          ),
                          decoration: _inputDecoration(
                            context,
                            'Reason for visit or symptoms described by patient',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                // Form Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          backgroundColor: colors.surfaceSecondary,
                          side: BorderSide(color: colors.border),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: Text(
                          'Cancel',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: colors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: Text(
                          'Book Appointment',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(BuildContext context, String text) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 11.5,
          fontWeight: FontWeight.w700,
          color: colors.textMuted,
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(BuildContext context, String hint) {
    final colors = context.colors;
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.inter(
        fontSize: 12.5,
        color: colors.textMuted.withValues(alpha: 0.6),
      ),
      filled: true,
      fillColor: colors.surfaceSecondary,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: colors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: colors.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: colors.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: colors.error, width: 1.5),
      ),
    );
  }

  Widget _buildDropdown(
    BuildContext context, {
    required String value,
    required List<String> items,
    Map<String, String>? itemLabels,
    required ValueChanged<String?> onChanged,
  }) {
    final colors = context.colors;
    return Container(
      height: 42,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: colors.surfaceSecondary,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colors.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: items.contains(value) ? value : null,
          hint: Text(
            'None available',
            style: GoogleFonts.inter(fontSize: 12.5, color: colors.textMuted),
          ),
          isExpanded: true,
          items: items.map((it) {
            return DropdownMenuItem<String>(
              value: it,
              child: Text(
                itemLabels?[it] ?? it,
                overflow: TextOverflow.ellipsis,
              ),
            );
          }).toList(),
          onChanged: onChanged,
          dropdownColor: colors.surface,
          icon: Icon(
            Icons.arrow_drop_down_rounded,
            size: 18,
            color: colors.textMuted,
          ),
          style: GoogleFonts.inter(
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: colors.textPrimary,
          ),
        ),
      ),
    );
  }
}
