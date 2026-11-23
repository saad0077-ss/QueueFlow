import 'dart:async';

import 'package:flutter/material.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

import '../../../clinic_details/presentation/pages/clinic_details_screen.dart';
import '../../data/repositories/home_repository_impl.dart';
import '../../domain/entities/clinic_entity.dart';
import '../../domain/repositories/home_repository.dart';
import '../widgets/search/patient_search_content_view.dart';
import '../widgets/search/patient_search_filter_resolver.dart';

class PatientSearchScreen extends StatefulWidget {
  final List<ClinicEntity>? allClinics;
  final String initialQuery;
  final String initialCategory;
  final HomeRepository? repository;

  const PatientSearchScreen({
    super.key,
    this.allClinics,
    this.initialQuery = '',
    this.initialCategory = 'all',
    this.repository,
  });

  @override
  State<PatientSearchScreen> createState() => _PatientSearchScreenState();
}

class _PatientSearchScreenState extends State<PatientSearchScreen> {
  late final TextEditingController _searchCtrl;
  late final HomeRepository _repository;
  StreamSubscription<List<ClinicEntity>>? _clinicsSub;

  List<ClinicEntity> _allClinics = [];
  String _selectedDepartment = 'all';
  String _selectedService = 'all';
  final Set<String> _activeQuickFilters = {};
  final List<String> _recentSearches = [];

  @override
  void initState() {
    super.initState();
    _searchCtrl = TextEditingController(text: widget.initialQuery);
    _repository = widget.repository ?? HomeRepositoryImpl();
    if (widget.initialCategory != 'all') {
      _selectedDepartment = widget.initialCategory;
    }
    if (widget.allClinics != null && widget.allClinics!.isNotEmpty) {
      _allClinics = List<ClinicEntity>.from(widget.allClinics!);
    } else {
      _clinicsSub = _repository.watchFeaturedClinics().listen((clinics) {
        if (mounted) setState(() => _allClinics = clinics);
      });
    }
  }

  @override
  void dispose() {
    _clinicsSub?.cancel();
    _searchCtrl.dispose();
    super.dispose();
  }

  void _recordSearch(String q) {
    final clean = q.trim();
    if (clean.isEmpty) return;
    setState(() {
      _recentSearches.removeWhere(
        (e) => e.toLowerCase() == clean.toLowerCase(),
      );
      _recentSearches.insert(0, clean);
      if (_recentSearches.length > 5) _recentSearches.removeLast();
    });
  }

  void _resetFilters() {
    setState(() {
      _searchCtrl.clear();
      _selectedDepartment = 'all';
      _selectedService = 'all';
      _activeQuickFilters.clear();
    });
  }

  bool get _hasActiveFilters =>
      _selectedDepartment.toLowerCase() != 'all' ||
      _selectedService.toLowerCase() != 'all' ||
      _activeQuickFilters.isNotEmpty;

  void _openDetails(ClinicEntity clinic) async {
    final res = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => ClinicDetailsScreen(clinic: clinic)),
    );
    if (res == true && mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final clinics = PatientSearchFilterResolver.filterClinics(
      allClinics: _allClinics,
      selectedDepartment: _selectedDepartment,
      selectedService: _selectedService,
      activeQuickFilters: _activeQuickFilters,
      query: _searchCtrl.text,
    );
    final int activeCount =
        (_selectedDepartment != 'all' ? 1 : 0) +
        (_selectedService != 'all' ? 1 : 0) +
        _activeQuickFilters.length;

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: PatientSearchContentView(
          searchCtrl: _searchCtrl,
          autoFocus: widget.initialQuery.isEmpty,
          onSearchChanged: (v) => setState(() {}),
          onSearchSubmitted: _recordSearch,
          allClinics: _allClinics,
          onApplyFilters: (d, s, q) => setState(() {
            _selectedDepartment = d;
            _selectedService = s;
            _activeQuickFilters.clear();
            _activeQuickFilters.addAll(q);
          }),
          hasActiveFilters: _hasActiveFilters,
          activeCount: activeCount,
          selectedDepartment: _selectedDepartment,
          selectedService: _selectedService,
          activeQuickFilters: _activeQuickFilters,
          onClearDepartment: () => setState(() {
            _selectedDepartment = 'all';
            _selectedService = 'all';
          }),
          onClearService: () => setState(() => _selectedService = 'all'),
          onRemoveQuickFilter: (k) =>
              setState(() => _activeQuickFilters.remove(k)),
          recentSearches: _recentSearches,
          onSelectRecent: (q) => setState(() {
            _searchCtrl.text = q;
            _searchCtrl.selection = TextSelection.collapsed(offset: q.length);
          }),
          onRemoveRecent: (q) => setState(() => _recentSearches.remove(q)),
          onClearAllRecent: () => setState(() => _recentSearches.clear()),
          isSearching: _searchCtrl.text.trim().isNotEmpty || _hasActiveFilters,
          clinics: clinics,
          onSelectClinic: _openDetails,
          onResetFilters: _resetFilters,
          colors: colors,
        ),
      ),
    );
  }
}
