import 'package:flutter/widgets.dart';

/// Width breakpoints shared by the clinic admin layouts.
class ClinicBreakpoints {
  ClinicBreakpoints._();

  /// Below this the sidebar moves into a drawer.
  static const double mobile = 700;

  /// At or above this the sidebar shows full labels.
  static const double desktop = 1100;

  /// Content width at which dashboard sections switch to multi-column.
  static const double wideContent = 760;

  static bool isMobile(BuildContext context) =>
      MediaQuery.sizeOf(context).width < mobile;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= desktop;
}
