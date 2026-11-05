import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:queueflow_ui/queueflow_ui.dart';
import 'features/auth/presentation/pages/clinic_account_activation_page.dart';
import 'features/auth/presentation/pages/clinic_staff_login_page.dart';
import 'features/dashboard/presentation/pages/clinic_dashboard_page.dart';
import 'firebase_options.dart';

void main() async {     
  WidgetsFlutterBinding.ensureInitialized();
  await ThemeBloc.initializePrefs();
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    } 
  } catch (e) { 
    debugPrint('Firebase already initialized: $e');
  }
  runApp(const ClinicAdminApp());
}

class ClinicAdminApp extends StatelessWidget {
  const ClinicAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    final isInviteRoute = Uri.base.queryParameters['invite'] == 'true'; 

    return BlocProvider<ThemeBloc>(
      create: (_) => ThemeBloc(),
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
            home: StreamBuilder<User?>(
              initialData: FirebaseAuth.instance.currentUser,
              stream: FirebaseAuth.instance.authStateChanges(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting &&
                    snapshot.data == null) {
                  return const Scaffold(
                    body: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );   
                }

                // 1. If user is authenticated, ALWAYS show ClinicDashboardPage
                if (snapshot.hasData && snapshot.data != null) {
                  return const ClinicDashboardPage();
                }

                // 2. If user is NOT authenticated:
                // Check if this is an invite/activation link
                if (isInviteRoute) { 
                  return const ClinicAccountActivationPage();
                }

                // Otherwise show standard staff login page
                return const ClinicStaffLoginPage();
              },
            ),
          );
        },
      ),
    );
  }
}
