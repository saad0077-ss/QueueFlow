import 'package:flutter/material.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

import 'filter/platform_users_filter_activity_section.dart';
import 'filter/platform_users_filter_options.dart';
import 'filter/platform_users_filter_status_section.dart';
import 'filter/platform_users_filter_type_section.dart';
import 'filter/platform_users_filter_verification_section.dart';

export 'filter/platform_users_filter_options.dart';

class PlatformUsersFilterModal extends StatefulWidget {
  final PlatformUsersFilterOptions currentOptions;
  final ValueChanged<PlatformUsersFilterOptions> onApply;

  const PlatformUsersFilterModal({
    super.key,
    required this.currentOptions,
    required this.onApply,
  });

  static Future<void> show(
    BuildContext context, {
    required PlatformUsersFilterOptions currentOptions,
    required ValueChanged<PlatformUsersFilterOptions> onApply,
  }) {
    return AppFilterDialogScaffold.show(
      context,
      builder: (_) => PlatformUsersFilterModal(
        currentOptions: currentOptions,
        onApply: onApply,
      ),
    );
  }

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
    return AppFilterDialogScaffold(
      header: AppFilterHeader(
        title: 'Filter Users',
        subtitle:
            'Select registration type, account status, and queue activity',
        onClose: () => Navigator.of(context).pop(),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AppFilterSectionTitle('REGISTRATION TYPE'),
            const SizedBox(height: 10),
            PlatformUsersFilterTypeSection(
              selectedType: _userType,
              onSelectType: (v) => setState(() => _userType = v),
            ),
            const SizedBox(height: 20),
            const AppFilterSectionTitle('ACCOUNT STATUS'),
            const SizedBox(height: 10),
            PlatformUsersFilterStatusSection(
              selectedStatus: _status,
              onSelectStatus: (v) => setState(() => _status = v),
            ),
            const SizedBox(height: 20),
            const AppFilterSectionTitle('QUEUE ACTIVITY'),
            const SizedBox(height: 10),
            PlatformUsersFilterActivitySection(
              selectedActivity: _queueActivity,
              onSelectActivity: (v) => setState(() => _queueActivity = v),
            ),
            const SizedBox(height: 20),
            const AppFilterSectionTitle('VERIFICATION STATUS'),
            const SizedBox(height: 10),
            PlatformUsersFilterVerificationSection(
              selectedVerification: _verification,
              onSelectVerification: (v) => setState(() => _verification = v),
            ),
          ],
        ),
      ),
      footer: AppFilterFooter(
        onResetAll: _reset,
        onCancel: () => Navigator.of(context).pop(),
        onApply: _apply,
      ),
    );
  }
}
