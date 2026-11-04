import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../widgets/profile_tab_view.dart';

class PatientProfileScreen extends StatelessWidget {
  final VoidCallback? onVisitsTap;

  const PatientProfileScreen({
    super.key,
    this.onVisitsTap,
  }); 
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBgApp,
      appBar: AppBar(
        backgroundColor: AppColors.darkSurface,
        elevation: 0,
        centerTitle: false,
        title: const Text(
          'Profile & Settings',
          style: TextStyle(
            color: AppColors.darkInk,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(color: AppColors.darkBorder, height: 1, thickness: 1),
        ),
      ),
      body: SafeArea(
        child: ProfileTabView(onVisitsTap: onVisitsTap),
      ),
    );
  }
}
