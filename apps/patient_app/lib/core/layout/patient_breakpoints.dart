import 'package:flutter/widgets.dart';

/// Screen width breakpoints for the Patient Application.
///
/// Follows standard responsive form factor classifications:
/// - Mobile: < 680 px (Phones)
/// - Tablet: 680 px - 1099 px (iPads, Android tablets, foldable devices in tablet view)
/// - Laptop / Desktop: >= 1100 px (Laptops, MacBooks, PC displays)
class PatientBreakpoints {
  PatientBreakpoints._();

  /// Maximum width for mobile layout.
  static const double mobileMax = 680;

  /// Width at or above which desktop/laptop layout activates.
  static const double laptopMin = 1100;

  /// Returns true if the screen is a mobile phone width.
  static bool isMobile(BuildContext context) =>
      MediaQuery.sizeOf(context).width < mobileMax;

  /// Returns true if the screen is a tablet / tab view.
  static bool isTablet(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    return w >= mobileMax && w < laptopMin;
  }

  /// Returns true if the screen is a laptop or desktop viewport.
  static bool isLaptop(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= laptopMin;

  /// Content max width based on breakpoint.
  static double contentMaxWidth(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    if (w >= laptopMin) return 1320;
    if (w >= mobileMax) return 860;
    return double.infinity;
  }
}
