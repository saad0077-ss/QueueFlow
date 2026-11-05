import 'package:flutter/material.dart';
import 'package:queueflow_ui/queueflow_ui.dart';
import '../widgets/profile_tab_view.dart';

class PatientProfileScreen extends StatelessWidget {
  final VoidCallback? onVisitsTap;

  const PatientProfileScreen({
    super.key,
    this.onVisitsTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.surface,
        elevation: 0,
        centerTitle: false,
        title: Text(
          'Profile & Settings',
          style: TextStyle(
            color: colors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(color: colors.border, height: 1, thickness: 1),
        ),
      ),
      body: SafeArea(
        child: ProfileTabView(onVisitsTap: onVisitsTap),
      ),
    );
  }
}
