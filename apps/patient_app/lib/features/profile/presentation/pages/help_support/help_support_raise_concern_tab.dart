import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

import '../../widgets/raise_concern/clinic_option_model.dart';
import '../../widgets/raise_concern/clinic_search_bottom_sheet.dart';
import '../../widgets/raise_concern/raise_concern_clinics_service.dart';
import '../../widgets/raise_concern/raise_concern_form_body.dart';
import '../../widgets/raise_concern/raise_concern_submit_handler.dart';
import '../../widgets/raise_concern/raise_concern_tab_listener.dart';

class HelpSupportRaiseConcernTab extends StatefulWidget {
  final String? initialClinicId;
  final String? initialClinicName;
  final String? initialTokenNumber;
  final VoidCallback? onConcernSubmitted;

  const HelpSupportRaiseConcernTab({
    super.key,
    this.initialClinicId,
    this.initialClinicName,
    this.initialTokenNumber,
    this.onConcernSubmitted,
  });

  @override
  State<HelpSupportRaiseConcernTab> createState() =>
      _HelpSupportRaiseConcernTabState();
}

class _HelpSupportRaiseConcernTabState
    extends State<HelpSupportRaiseConcernTab> {
  final _formKey = GlobalKey<FormState>();
  final _subjectController = TextEditingController();
  final _descController = TextEditingController();
  String _selectedCategory = 'queue';
  bool _isClinicRelated = true;
  String _selectedClinicId = 'smile-dental';
  String _selectedClinicName = 'Smile Dental Clinic (Dr. Rahul Sharma)';
  bool _attachToken = true;
  String _selectedPriority = 'medium';
  bool _isSubmitting = false;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _clinicsSub;
  List<ClinicOption> _availableClinics =
      RaiseConcernClinicsService.defaultClinics;
  bool _isLoadingClinics = true;

  @override
  void initState() {
    super.initState();
    if (widget.initialClinicId?.isNotEmpty == true) {
      _selectedClinicId = widget.initialClinicId!;
      _selectedClinicName = widget.initialClinicName ?? 'Clinic Care Desk';
    }
    if (widget.initialTokenNumber?.isNotEmpty == true) {
      _attachToken = true;
      _selectedCategory = 'queue';
      _subjectController.text = 'Waiting room delay exceeding 20 minutes';
      _descController.text =
          'Token ${widget.initialTokenNumber} at $_selectedClinicName - waiting past estimated consultation slot.';
    }
    _clinicsSub = RaiseConcernClinicsService.listenToClinics(
      onClinicsLoaded: (loaded) {
        if (!mounted || loaded.isEmpty) return;
        setState(() {
          _availableClinics = loaded;
          final m = _availableClinics.where((c) => c.id == _selectedClinicId);
          if (m.isEmpty && widget.initialClinicId == null) {
            _selectedClinicId = _availableClinics.first.id;
            _selectedClinicName = _availableClinics.first.name;
          } else if (m.isNotEmpty) {
            _selectedClinicName = m.first.name;
          }
          _isLoadingClinics = false;
        });
      },
      onError: () => mounted ? setState(() => _isLoadingClinics = false) : null,
    );
  }

  @override
  void dispose() {
    _clinicsSub?.cancel();
    _subjectController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _applyPreset({
    required String category,
    required String priority,
    required String subject,
    required String desc,
  }) {
    setState(() {
      _selectedCategory = category;
      _selectedPriority = priority;
      _subjectController.text = subject;
      _descController.text = desc;
      if (category == 'technical') _isClinicRelated = false;
    });
  }

  void _submitConcern() {
    RaiseConcernSubmitHandler.submit(
      context,
      formKey: _formKey,
      selectedCategory: _selectedCategory,
      isClinicRelated: _isClinicRelated,
      selectedClinicId: _selectedClinicId,
      selectedClinicName: _selectedClinicName,
      subject: _subjectController.text,
      description: _descController.text,
      selectedPriority: _selectedPriority,
      tokenNumber: widget.initialTokenNumber,
      attachToken: _attachToken,
      onStartSubmitting: () => setState(() => _isSubmitting = true),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return RaiseConcernTabListener(
      isSubmitting: _isSubmitting,
      onError: () => setState(() => _isSubmitting = false),
      onSubmitted: () {
        setState(() => _isSubmitting = false);
        _subjectController.clear();
        _descController.clear();
        widget.onConcernSubmitted?.call();
      },
      child: RaiseConcernFormBody(
        formKey: _formKey,
        selectedCategory: _selectedCategory,
        onCategorySelected: (cat) => setState(() {
          _selectedCategory = cat;
          if (cat == 'technical') _isClinicRelated = false;
        }),
        isClinicRelated: _isClinicRelated,
        onClinicRelatedChanged: (val) => setState(() => _isClinicRelated = val),
        availableClinics: _availableClinics,
        selectedClinicId: _selectedClinicId,
        selectedClinicName: _selectedClinicName,
        isLoadingClinics: _isLoadingClinics,
        onOpenSearch: () => ClinicSearchBottomSheet.show(
          context,
          availableClinics: _availableClinics,
          selectedClinicId: _selectedClinicId,
          colors: colors,
          onClinicSelected: (c) => setState(() {
            _selectedClinicId = c.id;
            _selectedClinicName = c.name;
          }),
        ),
        initialTokenNumber: widget.initialTokenNumber,
        attachToken: _attachToken,
        onAttachTokenChanged: (val) =>
            setState(() => _attachToken = val ?? true),
        selectedPriority: _selectedPriority,
        onPriorityChanged: (p) => setState(() => _selectedPriority = p),
        subjectController: _subjectController,
        descController: _descController,
        isSubmitting: _isSubmitting,
        onSubmit: _submitConcern,
        onApplyPreset: _applyPreset,
        colors: colors,
      ),
    );
  }
}
