import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

class PlatformUsersFilterOptions {
  final String
  status; // 'all' | 'in-queue' | 'active' | 'verified' | 'suspended'
  final String userType; // 'all' | 'platform_user' | 'walk-in'
  final String queueActivity; // 'all' | 'has-token' | 'no-token'
  final String verification; // 'all' | 'verified' | 'unverified'

  const PlatformUsersFilterOptions({
    this.status = 'all',
    this.userType = 'all',
    this.queueActivity = 'all',
    this.verification = 'all',
  });

  bool get isDefault =>
      status == 'all' &&
      userType == 'all' &&
      queueActivity == 'all' &&
      verification == 'all';

  int get activeFiltersCount {
    int count = 0;
    if (status != 'all') count++;
    if (userType != 'all') count++;
    if (queueActivity != 'all') count++;
    if (verification != 'all') count++;
    return count;
  }

  PlatformUsersFilterOptions copyWith({
    String? status,
    String? userType,
    String? queueActivity,
    String? verification,
  }) {
    return PlatformUsersFilterOptions(
      status: status ?? this.status,
      userType: userType ?? this.userType,
      queueActivity: queueActivity ?? this.queueActivity,
      verification: verification ?? this.verification,
    );
  }
}

class PlatformUsersFilterModal extends StatefulWidget {
  final PlatformUsersFilterOptions currentOptions;
  final ValueChanged<PlatformUsersFilterOptions> onApply;

  const PlatformUsersFilterModal({
    super.key,
    required this.currentOptions,
    required this.onApply,
  });

  @override
  State<PlatformUsersFilterModal> createState() =>
      _PlatformUsersFilterModalState();
}

class _PlatformUsersFilterModalState extends State<PlatformUsersFilterModal> {
  late String _status;
  late String _userType;
  late String _queueActivity;
  late String _verification;

  @override
  void initState() {
    super.initState();
    _status = widget.currentOptions.status;
    _userType = widget.currentOptions.userType;
    _queueActivity = widget.currentOptions.queueActivity;
    _verification = widget.currentOptions.verification;
  }

  void _reset() {
    setState(() {
      _status = 'all';
      _userType = 'all';
      _queueActivity = 'all';
      _verification = 'all';
    });
  }

  void _apply() {
    widget.onApply(
      PlatformUsersFilterOptions(
        status: _status,
        userType: _userType,
        queueActivity: _queueActivity,
        verification: _verification,
      ),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Dialog(
      backgroundColor: colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: colors.border),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 20, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0072FF).withAlpha(20),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.tune_rounded,
                          color: Color(0xFF0072FF),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Filter Users',
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: colors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(
                      Icons.close_rounded,
                      color: colors.textMuted,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: colors.border),

            // Filter Options Body
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. User Type
                  _buildSectionTitle(colors, 'REGISTRATION TYPE'),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildChip(
                        colors,
                        'All Users',
                        'all',
                        _userType,
                        (v) => setState(() => _userType = v),
                      ),
                      _buildChip(
                        colors,
                        'Platform Users',
                        'platform_user',
                        _userType,
                        (v) => setState(() => _userType = v),
                      ),
                      _buildChip(
                        colors,
                        'Walk-In Patients',
                        'walk-in',
                        _userType,
                        (v) => setState(() => _userType = v),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // 2. Account Status
                  _buildSectionTitle(colors, 'ACCOUNT STATUS'),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildChip(
                        colors,
                        'All Statuses',
                        'all',
                        _status,
                        (v) => setState(() => _status = v),
                      ),
                      _buildChip(
                        colors,
                        'In Live Queue',
                        'in-queue',
                        _status,
                        (v) => setState(() => _status = v),
                      ),
                      _buildChip(
                        colors,
                        'Active Accounts',
                        'active',
                        _status,
                        (v) => setState(() => _status = v),
                      ),
                      _buildChip(
                        colors,
                        'Verified Only',
                        'verified',
                        _status,
                        (v) => setState(() => _status = v),
                      ),
                      _buildChip(
                        colors,
                        'Suspended',
                        'suspended',
                        _status,
                        (v) => setState(() => _status = v),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // 2. Queue Activity
                  _buildSectionTitle(colors, 'LIVE QUEUE ACTIVITY'),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildChip(
                        colors,
                        'All Patients',
                        'all',
                        _queueActivity,
                        (v) => setState(() => _queueActivity = v),
                      ),
                      _buildChip(
                        colors,
                        'Active Tokens',
                        'has-token',
                        _queueActivity,
                        (v) => setState(() => _queueActivity = v),
                      ),
                      _buildChip(
                        colors,
                        'No Active Queue',
                        'no-token',
                        _queueActivity,
                        (v) => setState(() => _queueActivity = v),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // 3. Verification State
                  _buildSectionTitle(colors, 'PROFILE VERIFICATION'),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildChip(
                        colors,
                        'All Profiles',
                        'all',
                        _verification,
                        (v) => setState(() => _verification = v),
                      ),
                      _buildChip(
                        colors,
                        'Verified Only',
                        'verified',
                        _verification,
                        (v) => setState(() => _verification = v),
                      ),
                      _buildChip(
                        colors,
                        'Unverified Only',
                        'unverified',
                        _verification,
                        (v) => setState(() => _verification = v),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Divider(height: 1, color: colors.border),
            // Actions
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _reset,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: colors.textMuted,
                        side: BorderSide(color: colors.border),
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        'Reset Filters',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _apply,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0072FF),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        'Apply Filters',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(AppColorsExtension colors, String title) {
    return Text(
      title,
      style: GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w800,
        color: colors.textMuted,
        letterSpacing: 0.6,
      ),
    );
  }

  Widget _buildChip(
    AppColorsExtension colors,
    String label,
    String value,
    String selectedValue,
    ValueChanged<String> onSelected,
  ) {
    final isSelected = selectedValue == value;

    return InkWell(
      onTap: () => onSelected(value),
      borderRadius: BorderRadius.circular(8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF0072FF).withAlpha(25)
              : colors.surfaceSecondary,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? const Color(0xFF0072FF) : colors.border,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12.5,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? const Color(0xFF0072FF) : colors.textPrimary,
          ),
        ),
      ),
    );
  }
}
