import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';

/// Lets a page inside the dashboard hide the shared top bar (search, theme,
/// notifications, profile) while it shows a full-screen detail view.
class DashboardChrome {
  DashboardChrome._();

  /// Name of the nav tab (e.g. 'Appointments') currently showing a detail
  /// view, or null. The dashboard only honours it while that tab is active.
  static final ValueNotifier<String?> detailOwner = ValueNotifier<String?>(null);

  /// Safe to call from build: applied after the current frame.
  static void setDetailOpen(String owner, bool open) {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      final next = open ? owner : (detailOwner.value == owner ? null : detailOwner.value);
      if (detailOwner.value != next) detailOwner.value = next;
    });
  }
}
