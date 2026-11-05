import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:queueflow_ui/queueflow_ui.dart';
import '../../../clinic_details/presentation/pages/clinic_details_screen.dart';
import '../../data/repositories/home_repository_impl.dart';
import '../../domain/entities/clinic_entity.dart';
import '../../domain/repositories/home_repository.dart';
import '../widgets/home_clinic_card.dart';
import '../widgets/home_search_bar.dart';

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

  static const Map<String, List<String>> _departmentServices = {
    'General Medicine': [
      'General Consultation',
      'Routine Health Checkup',
      'Follow-up Consultation',
      'Blood Pressure Screening',
      'Fever & Infection Care',
      'Prescription Renewal',
    ],
    'Dental & Oral Surgery': [
      'Dental Consultation',
      'Teeth Cleaning & Scaling',
      'Root Canal Treatment',
      'Tooth Extraction',
      'Cavity Filling',
      'Teeth Whitening',
      'Dental Braces Check',
    ],
    'Pediatrics & Child Care': [
      'Pediatric Consultation',
      'Child Immunization / Vaccine',
      'Growth & Nutrition Assessment',
      'Infant Milestone Review',
      'Pediatric Fever Management',
    ],
    'Dermatology & Cosmetology': [
      'Skin Consultation',
      'Acne & Scar Treatment',
      'Eczema & Allergy Care',
      'Chemical Peel',
      'Laser Skin Therapy',
      'Hair Loss Evaluation',
    ],
    'Orthopedics & Sports Rehab': [
      'Orthopedic Consultation',
      'Joint Pain Evaluation',
      'Fracture Care & Splinting',
      'Physical Therapy & Rehab',
      'Spine & Back Pain Care',
    ],
    'Cardiology': [
      'Cardiology Consultation',
      'ECG / EKG Test',
      'Echocardiogram',
      'Blood Pressure & Lipid Review',
      'Heart Health Screening',
    ],
    'Diagnostics': [
      'Complete Blood Count (CBC)',
      'Lipid Profile',
      'Blood Glucose / HbA1c',
      'Digital X-Ray',
      'Ultrasound Scan',
      'Thyroid Panel',
    ],
    'Ear, Nose & Throat (ENT)': [
      'Sinusitis Evaluation',
      'Audiometry Hearing Test',
      'Ear Wax Removal',
      'Throat & Tonsil Checkup',
    ],
  };

  static const List<String> _fallbackDepartments = [
    'General Medicine',
    'Dental & Oral Surgery',
    'Dermatology & Cosmetology',
    'Pediatrics & Child Care',
    'Orthopedics & Sports Rehab',
    'Cardiology',
    'Diagnostics',
    'Ear, Nose & Throat (ENT)',
  ];

  @override
  void initState() {
    super.initState();
    _searchCtrl = TextEditingController(text: widget.initialQuery);
    _selectedDepartment = widget.initialCategory;
    _repository = widget.repository ?? HomeRepositoryImpl();

    if (widget.allClinics != null && widget.allClinics!.isNotEmpty) {
      _allClinics = widget.allClinics!;
    } else {
      _loadClinics();
    }

    _clinicsSub = _repository.watchFeaturedClinics().listen((clinics) {
      if (mounted) {
        setState(() {
          _allClinics = clinics;
        });
      }
    });

    _loadDepartmentsFromFirestore();

    if (widget.initialQuery.trim().isNotEmpty) {
      _recordSearchQuery(widget.initialQuery);
    }
  }

  Future<void> _loadDepartmentsFromFirestore() async {
    try {
      final snap = await FirebaseFirestore.instance.collection('departments').get();
      if (snap.docs.isNotEmpty && mounted) {
        setState(() {});
      }
    } catch (_) {}
  }

  Future<void> _loadClinics() async {
    final clinics = await _repository.getFeaturedClinics();
    if (mounted) {
      setState(() {
        _allClinics = clinics;
      });
    }
  }

  @override
  void dispose() {
    _clinicsSub?.cancel();
    _searchCtrl.dispose();
    super.dispose();
  }

  void _recordSearchQuery(String query) {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return;
    setState(() {
      _recentSearches.remove(trimmed);
      _recentSearches.insert(0, trimmed);
      if (_recentSearches.length > 8) {
        _recentSearches.removeLast();
      }
    });
  }

  void _onSearchSubmitted(String val) {
    _recordSearchQuery(val);
    setState(() {});
  }

  void _onSearchChanged(String val) {
    setState(() {});
  }

  void _onSelectRecentSearch(String query) {
    _searchCtrl.text = query;
    _searchCtrl.selection = TextSelection.fromPosition(
      TextPosition(offset: query.length),
    );
    setState(() {});
  }

  void _removeRecentSearch(String query) {
    setState(() {
      _recentSearches.remove(query);
    });
  }

  void _clearAllRecentSearches() {
    setState(() {
      _recentSearches.clear();
    });
  }

  void _resetAllFiltersAndSearch() {
    _searchCtrl.clear();
    setState(() {
      _selectedDepartment = 'all';
      _selectedService = 'all';
      _activeQuickFilters.clear();
    });
  }

  List<String> get _availableDepartments {
    final Set<String> depts = {'all'};
    for (final clinic in _allClinics) {
      if (clinic.category.isNotEmpty) {
        final parts = clinic.category.split(RegExp(r'[,·•]'));
        for (final p in parts) {
          final clean = p.trim();
          if (clean.isNotEmpty) {
            depts.add(clean);
          }
        }
      }
    }
    for (final def in _fallbackDepartments) {
      depts.add(def);
    }
    return depts.toList();
  }

  List<String> _getServicesForDepartment(String dept) {
    if (dept.toLowerCase() == 'all') return [];

    final dLower = dept.toLowerCase();
    for (final entry in _departmentServices.entries) {
      if (entry.key.toLowerCase().contains(dLower) ||
          dLower.contains(entry.key.toLowerCase())) {
        return entry.value;
      }
    }
    return [
      'General Consultation',
      'Follow-up Consultation',
      'Specialist Consultation',
      'Diagnostic Assessment',
      'Routine Checkup',
    ];
  }

  bool get _hasActiveFilters =>
      _selectedDepartment.toLowerCase() != 'all' ||
      _selectedService.toLowerCase() != 'all' ||
      _activeQuickFilters.isNotEmpty;

  bool get _isSearching =>
      _searchCtrl.text.trim().isNotEmpty || _hasActiveFilters;

  List<ClinicEntity> get _filteredClinics {
    var result = List<ClinicEntity>.from(_allClinics);

    // 1. Department Filter
    if (_selectedDepartment.toLowerCase() != 'all') {
      final deptLower = _selectedDepartment.toLowerCase();
      result = result.where((c) {
        return c.category.toLowerCase().contains(deptLower);
      }).toList();
    }

    // 2. Service Filter
    if (_selectedService.toLowerCase() != 'all') {
      final sLower = _selectedService.toLowerCase();
      result = result.where((c) {
        return c.category.toLowerCase().contains(sLower) ||
            c.name.toLowerCase().contains(sLower);
      }).toList();
    }

    // 3. Quick Filters
    if (_activeQuickFilters.contains('open')) {
      result = result.where((c) => c.isOpen).toList();
    }
    if (_activeQuickFilters.contains('rating')) {
      result = result.where((c) => c.rating >= 4.5).toList();
    }
    if (_activeQuickFilters.contains('near')) {
      result = result.where((c) {
        final match = RegExp(r'([\d\.]+)').firstMatch(c.distance);
        if (match != null) {
          final dist = double.tryParse(match.group(1) ?? '999');
          return dist != null && dist <= 2.0;
        }
        return true;
      }).toList();
    }
    if (_activeQuickFilters.contains('queue')) {
      result = result.where((c) => c.hasLiveQueue).toList();
    }

    // 4. Search Query Filter
    final query = _searchCtrl.text.trim().toLowerCase();
    if (query.isNotEmpty) {
      result = result.where((c) {
        return c.name.toLowerCase().contains(query) ||
            c.category.toLowerCase().contains(query) ||
            c.address.toLowerCase().contains(query) ||
            c.city.toLowerCase().contains(query);
      }).toList();
    }

    return result;
  }

  /// Displays the filter dialog box with department selection, cascading services dropdown, and quick preferences.
  void _showFilterDialog(BuildContext context) {
    final colors = context.colors;
    String tempDept = _selectedDepartment;
    String tempService = _selectedService;
    final Set<String> tempQuick = Set<String>.from(_activeQuickFilters);
    final allDepts = _availableDepartments;

    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.7),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final availableServices = _getServicesForDepartment(tempDept);

            return Dialog(
              backgroundColor: colors.surfaceElevated,
              elevation: 16,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
                side: BorderSide(color: colors.border, width: 1.5),
              ),
              insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Padding(
                  padding: const EdgeInsets.all(22),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 38,
                                  height: 38,
                                  decoration: BoxDecoration(
                                    color: colors.primaryTint,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  alignment: Alignment.center,
                                  child: Icon(
                                    Icons.tune_rounded,
                                    color: colors.primary,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Filter Clinics',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: colors.textPrimary,
                                    letterSpacing: -0.2,
                                  ),
                                ),
                              ],
                            ),
                            IconButton(
                              icon: Icon(Icons.close_rounded, color: colors.textSubtle),
                              onPressed: () => Navigator.of(ctx).pop(),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),

                        // Department Dropdown Label
                        Text(
                          'SELECT DEPARTMENT',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: colors.textMuted,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Department Dropdown
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                          decoration: BoxDecoration(
                            color: colors.surfaceSecondary,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: colors.border),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: allDepts.contains(tempDept) ? tempDept : 'all',
                              isExpanded: true,
                              dropdownColor: colors.surfaceElevated,
                              icon: Icon(
                                Icons.keyboard_arrow_down_rounded,
                                color: colors.textSubtle,
                              ),
                              style: TextStyle(
                                color: colors.textPrimary,
                                fontSize: 13.5,
                                fontWeight: FontWeight.w600,
                              ),
                              items: allDepts.map((d) {
                                return DropdownMenuItem<String>(
                                  value: d,
                                  child: Text(d == 'all' ? 'All Departments' : d),
                                );
                              }).toList(),
                              onChanged: (val) {
                                if (val != null) {
                                  setModalState(() {
                                    tempDept = val;
                                    tempService = 'all';
                                  });
                                }
                              },
                            ),
                          ),
                        ),

                        // Cascading Service Dropdown
                        if (tempDept.toLowerCase() != 'all' && availableServices.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          Text(
                            'SELECT SERVICE',
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: colors.textMuted,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                            decoration: BoxDecoration(
                              color: colors.surfaceSecondary,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: colors.border),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: ['all', ...availableServices].contains(tempService)
                                    ? tempService
                                    : 'all',
                                isExpanded: true,
                                dropdownColor: colors.surfaceElevated,
                                icon: Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  color: colors.textSubtle,
                                ),
                                style: TextStyle(
                                  color: colors.textPrimary,
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w600,
                                ),
                                items: [
                                  const DropdownMenuItem<String>(
                                    value: 'all',
                                    child: Text('All Services'),
                                  ),
                                  ...availableServices.map((s) {
                                    return DropdownMenuItem<String>(
                                      value: s,
                                      child: Text(s),
                                    );
                                  }),
                                ],
                                onChanged: (val) {
                                  if (val != null) {
                                    setModalState(() {
                                      tempService = val;
                                    });
                                  }
                                },
                              ),
                            ),
                          ),
                        ],

                        const SizedBox(height: 18),

                        // Quick Preferences
                        Text(
                          'QUICK PREFERENCES',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: colors.textMuted,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 10),

                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _buildModalFilterChip(
                              label: '🟢 Open Now',
                              isSelected: tempQuick.contains('open'),
                              colors: colors,
                              onTap: () {
                                setModalState(() {
                                  if (tempQuick.contains('open')) {
                                    tempQuick.remove('open');
                                  } else {
                                    tempQuick.add('open');
                                  }
                                });
                              },
                            ),
                            _buildModalFilterChip(
                              label: '★ 4.5+ Rating',
                              isSelected: tempQuick.contains('rating'),
                              colors: colors,
                              onTap: () {
                                setModalState(() {
                                  if (tempQuick.contains('rating')) {
                                    tempQuick.remove('rating');
                                  } else {
                                    tempQuick.add('rating');
                                  }
                                });
                              },
                            ),
                            _buildModalFilterChip(
                              label: '📍 < 2 km',
                              isSelected: tempQuick.contains('near'),
                              colors: colors,
                              onTap: () {
                                setModalState(() {
                                  if (tempQuick.contains('near')) {
                                    tempQuick.remove('near');
                                  } else {
                                    tempQuick.add('near');
                                  }
                                });
                              },
                            ),
                            _buildModalFilterChip(
                              label: '⚡ Live Queue',
                              isSelected: tempQuick.contains('queue'),
                              colors: colors,
                              onTap: () {
                                setModalState(() {
                                  if (tempQuick.contains('queue')) {
                                    tempQuick.remove('queue');
                                  } else {
                                    tempQuick.add('queue');
                                  }
                                });
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Action Buttons
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () {
                                  setModalState(() {
                                    tempDept = 'all';
                                    tempService = 'all';
                                    tempQuick.clear();
                                  });
                                },
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: colors.textMuted,
                                  side: BorderSide(color: colors.border),
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text(
                                  'Reset',
                                  style: TextStyle(fontWeight: FontWeight.w700),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              flex: 2,
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.of(ctx).pop();
                                  setState(() {
                                    _selectedDepartment = tempDept;
                                    _selectedService = tempService;
                                    _activeQuickFilters.clear();
                                    _activeQuickFilters.addAll(tempQuick);
                                  });
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: colors.primary,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 0,
                                ),
                                child: const Text(
                                  'Apply Filters',
                                  style: TextStyle(fontWeight: FontWeight.w700),
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
          },
        );
      },
    );
  }

  Widget _buildModalFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required AppColorsExtension colors,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? colors.primaryTint : colors.surfaceSecondary,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? colors.primary : colors.border,
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
            color: isSelected ? colors.primary : colors.textPrimary,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final clinics = _filteredClinics;
    final int activeCount = (_selectedDepartment != 'all' ? 1 : 0) +
        (_selectedService != 'all' ? 1 : 0) +
        _activeQuickFilters.length;

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final double width = constraints.maxWidth;
            final bool isTablet = width >= 640 && width < 960;
            final bool isDesktop = width >= 960;
            final bool useGrid = width >= 720;
            final double horizontalPadding = isDesktop ? 32 : (isTablet ? 24 : 18);
            final double maxContentWidth = isDesktop ? 960 : (isTablet ? 720 : double.infinity);

            return Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxContentWidth),
                child: Column(
                  children: [
                    // Top Search Bar Row with Back Button and Filter Button
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                        horizontalPadding,
                        12,
                        horizontalPadding,
                        8,
                      ),
                      child: Row(
                        children: [
                          // Rounded Back Button (<)
                          GestureDetector(
                            onTap: () => Navigator.of(context).pop(),
                            child: Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                color: colors.surfaceSecondary,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: colors.border,
                                  width: 1.5,
                                ),
                              ),
                              alignment: Alignment.center,
                              child: Icon(
                                Icons.chevron_left_rounded,
                                color: colors.textPrimary,
                                size: 24,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),

                          // Pill Search Field
                          Expanded(
                            child: HomeSearchBar(
                              controller: _searchCtrl,
                              autoFocus: widget.initialQuery.isEmpty,
                              margin: EdgeInsets.zero,
                              onChanged: _onSearchChanged,
                              onSubmitted: _onSearchSubmitted,
                              onClear: () => _onSearchChanged(''),
                            ),
                          ),
                          const SizedBox(width: 8),

                          // Filter Button (Opens Beautiful Dialog Box)
                          GestureDetector(
                            onTap: () => _showFilterDialog(context),
                            child: Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                color: _hasActiveFilters
                                    ? colors.primaryTint
                                    : colors.surfaceSecondary,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: _hasActiveFilters
                                      ? colors.primary
                                      : colors.border,
                                  width: 1.5,
                                ),
                                boxShadow: _hasActiveFilters
                                    ? [
                                        BoxShadow(
                                          color: colors.primary.withValues(alpha: 0.2),
                                          blurRadius: 6,
                                          offset: const Offset(0, 2),
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Icon(
                                    Icons.tune_rounded,
                                    size: 20,
                                    color: _hasActiveFilters
                                        ? colors.primary
                                        : colors.textPrimary,
                                  ),
                                  if (activeCount > 0)
                                    Positioned(
                                      top: 6,
                                      right: 6,
                                      child: Container(
                                        width: 8,
                                        height: 8,
                                        decoration: BoxDecoration(
                                          color: colors.primary,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Active Filter Tags Row
                    if (_hasActiveFilters)
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: horizontalPadding,
                          vertical: 6,
                        ),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          child: Row(
                            children: [
                              if (_selectedDepartment != 'all')
                                _buildActiveTag(
                                  label: _selectedDepartment,
                                  colors: colors,
                                  onClear: () {
                                    setState(() {
                                      _selectedDepartment = 'all';
                                      _selectedService = 'all';
                                    });
                                  },
                                ),
                              if (_selectedService != 'all')
                                _buildActiveTag(
                                  label: _selectedService,
                                  colors: colors,
                                  onClear: () {
                                    setState(() {
                                      _selectedService = 'all';
                                    });
                                  },
                                ),
                              if (_activeQuickFilters.contains('open'))
                                _buildActiveTag(
                                  label: 'Open Now',
                                  colors: colors,
                                  onClear: () => setState(() => _activeQuickFilters.remove('open')),
                                ),
                              if (_activeQuickFilters.contains('rating'))
                                _buildActiveTag(
                                  label: '4.5+ Rating',
                                  colors: colors,
                                  onClear: () => setState(() => _activeQuickFilters.remove('rating')),
                                ),
                              if (_activeQuickFilters.contains('near'))
                                _buildActiveTag(
                                  label: '< 2 km',
                                  colors: colors,
                                  onClear: () => setState(() => _activeQuickFilters.remove('near')),
                                ),
                              if (_activeQuickFilters.contains('queue'))
                                _buildActiveTag(
                                  label: 'Live Queue',
                                  colors: colors,
                                  onClear: () => setState(() => _activeQuickFilters.remove('queue')),
                                ),
                            ],
                          ),
                        ),
                      ),

                    // Scrollable Search Body
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: EdgeInsets.symmetric(
                          horizontal: horizontalPadding,
                          vertical: 8,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 1. RECENT SEARCHES
                            if (_recentSearches.isNotEmpty) ...[
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Recent Searches',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: colors.textPrimary,
                                      letterSpacing: -0.1,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: _clearAllRecentSearches,
                                    child: Text(
                                      'Clear all',
                                      style: TextStyle(
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w600,
                                        color: colors.primary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: _recentSearches.length,
                                separatorBuilder: (_, _) => Divider(
                                  color: colors.border,
                                  height: 1,
                                ),
                                itemBuilder: (context, i) {
                                  final query = _recentSearches[i];
                                  return InkWell(
                                    onTap: () => _onSelectRecentSearch(query),
                                    borderRadius: BorderRadius.circular(8),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                        horizontal: 4,
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.history_rounded,
                                            size: 18,
                                            color: colors.textSubtle,
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Text(
                                              query,
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                                color: colors.textPrimary,
                                              ),
                                            ),
                                          ),
                                          GestureDetector(
                                            onTap: () => _removeRecentSearch(query),
                                            behavior: HitTestBehavior.opaque,
                                            child: Padding(
                                              padding: const EdgeInsets.all(4),
                                              child: Icon(
                                                Icons.close_rounded,
                                                size: 16,
                                                color: colors.textSubtle,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: 20),
                            ],

                            // 2. RESULTS AREA
                            if (!_isSearching) ...[
                              if (_recentSearches.isEmpty)
                                Center(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 24),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          width: 60,
                                          height: 60,
                                          decoration: BoxDecoration(
                                            color: colors.surfaceSecondary,
                                            borderRadius: BorderRadius.circular(18),
                                            border: Border.all(color: colors.border),
                                          ),
                                          alignment: Alignment.center,
                                          child: Icon(
                                            Icons.search_rounded,
                                            color: colors.textSubtle,
                                            size: 28,
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          'Search clinics & services',
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w700,
                                            color: colors.textPrimary,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          'Type a clinic name above or tap the filter button to choose a department and service.',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 12.5,
                                            color: colors.textMuted,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                            ] else ...[
                              Text(
                                '${clinics.length} clinic${clinics.length == 1 ? '' : 's'} found',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: colors.textMuted,
                                ),
                              ),
                              const SizedBox(height: 12),

                              if (clinics.isEmpty)
                                _buildEmptyState(colors)
                              else if (useGrid)
                                GridView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: clinics.length,
                                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: isDesktop ? 2 : 2,
                                    crossAxisSpacing: 14,
                                    mainAxisSpacing: 14,
                                    mainAxisExtent: 110,
                                  ),
                                  itemBuilder: (ctx, i) {
                                    final clinic = clinics[i];
                                    return HomeClinicCard(
                                      clinic: clinic,
                                      onTap: () => _showClinicDetailsModal(context, clinic),
                                    );
                                  },
                                )
                              else
                                ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: clinics.length,
                                  itemBuilder: (ctx, i) {
                                    final clinic = clinics[i];
                                    return HomeClinicCard(
                                      clinic: clinic,
                                      onTap: () => _showClinicDetailsModal(context, clinic),
                                    );
                                  },
                                ),
                            ],

                            const SizedBox(height: 32),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildActiveTag({
    required String label,
    required VoidCallback onClear,
    required AppColorsExtension colors,
  }) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: colors.primaryTint,
        borderRadius: BorderRadius.circular(9999),
        border: Border.all(color: colors.primary, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: colors.primary,
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onClear,
            behavior: HitTestBehavior.opaque,
            child: Icon(
              Icons.close_rounded,
              size: 13,
              color: colors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(AppColorsExtension colors) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: colors.surfaceSecondary,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: colors.border),
              ),
              alignment: Alignment.center,
              child: const Text('🔍', style: TextStyle(fontSize: 26)),
            ),
            const SizedBox(height: 14),
            Text(
              'No clinics found',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: colors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'We couldn\'t find matches for your search or filters. Try adjusting keywords.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12.5,
                color: colors.textMuted,
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: _resetAllFiltersAndSearch,
              style: TextButton.styleFrom(
                backgroundColor: colors.surfaceSecondary,
                side: BorderSide(color: colors.border),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                'Reset filters & search',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: colors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showClinicDetailsModal(BuildContext context, ClinicEntity clinic) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => ClinicDetailsScreen(clinic: clinic),
      ),
    );
    if (result == true && context.mounted) {
      Navigator.pop(context, true);
    }
  }
}
