import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

import '../core/services/clinic_session_manager.dart';
import '../features/auth/presentation/pages/clinic_account_activation_page.dart';
import '../features/auth/presentation/pages/clinic_staff_login_page.dart';
import '../features/dashboard/presentation/pages/clinic_dashboard_page.dart';
import 'clinic_admin_providers.dart';

/// Root Application widget for the Clinic Staff & Admin Portal.
class ClinicAdminApp extends StatelessWidget {
  const ClinicAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    final isInviteRoute = Uri.base.queryParameters['invite'] == 'true';

    return ClinicAdminProviders(
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, themeState) {
          return MaterialApp(
            title: 'QueueFlow — Clinic Staff Portal',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeState.themeMode,
            themeAnimationDuration: Duration.zero,
            builder: (context, child) =>
                ThemeWaveScope(child: child ?? const SizedBox.shrink()),
            home: ClinicAuthGate(isInviteRoute: isInviteRoute),
          );
        },
      ),
    );
  }
}

/// Authentication and session gate for Clinic Staff.
class ClinicAuthGate extends StatefulWidget {
  final bool isInviteRoute;

  const ClinicAuthGate({super.key, required this.isInviteRoute});

  @override
  State<ClinicAuthGate> createState() => _ClinicAuthGateState();
}

class _ClinicAuthGateState extends State<ClinicAuthGate> {
  late final Future<bool> _sessionFuture;

  @override
  void initState() {
    super.initState();
    _sessionFuture = ClinicSessionManager.isSessionSaved();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      initialData: FirebaseAuth.instance.currentUser,
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        final user = snapshot.data ?? FirebaseAuth.instance.currentUser;

        if (user != null) {
          return const ClinicDashboardPage();
        }

        return FutureBuilder<bool>(
          future: _sessionFuture,
          builder: (context, sessionSnapshot) {
            final isSessionSaved = sessionSnapshot.data ?? false;

            if (isSessionSaved &&
                (sessionSnapshot.connectionState == ConnectionState.waiting ||
                    snapshot.connectionState == ConnectionState.waiting)) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            if (widget.isInviteRoute) {
              return const ClinicAccountActivationPage();
            }

            return const ClinicStaffLoginPage();
          },
        );
      },
    );
  }
}
