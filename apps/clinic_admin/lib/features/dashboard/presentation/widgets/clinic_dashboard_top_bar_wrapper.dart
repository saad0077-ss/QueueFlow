import 'package:flutter/material.dart';
import 'package:queueflow_ui/queueflow_ui.dart';
import '../../../../core/layout/dashboard_chrome.dart';
import '../bloc/clinic_dashboard_bloc.dart';
import '../bloc/clinic_dashboard_event.dart';
import 'clinic_top_bar.dart';

class ClinicDashboardTopBarWrapper extends StatelessWidget {
  final String activeNav;
  final bool isMobile;
  final double horizontalPadding;
  final ClinicDashboardBloc bloc;

  const ClinicDashboardTopBarWrapper({
    super.key,
    required this.activeNav,
    required this.isMobile,
    required this.horizontalPadding,
    required this.bloc,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return ValueListenableBuilder<String?>(
      valueListenable: DashboardChrome.detailOwner,
      builder: (context, owner, _) {
        if (owner != null && owner == activeNav) {
          return const SizedBox.shrink();
        }
        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: isMobile ? 10 : 14,
          ),
          decoration: BoxDecoration(
            color: colors.surface,
            border: Border(bottom: BorderSide(color: colors.border, width: 1)),
          ),
          child: Builder(
            builder: (scaffoldContext) => ClinicTopBar(
              compact: isMobile,
              onMenuTap: isMobile
                  ? () => Scaffold.of(scaffoldContext).openDrawer()
                  : null,
              onSearchChanged: (q) => bloc.add(DashboardSearchQueryChanged(q)),
              onNavigate: (nav) => bloc.add(DashboardNavTabChanged(nav)),
            ),
          ),
        );
      },
    );
  }
}
