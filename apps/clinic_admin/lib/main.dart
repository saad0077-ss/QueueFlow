import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'features/auth/presentation/pages/clinic_account_activation_page.dart';
import 'features/auth/presentation/pages/clinic_staff_login_page.dart';
import 'features/dashboard/presentation/pages/clinic_dashboard_page.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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

    return MaterialApp(
      title: 'QueueFlow — Clinic Staff Portal',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2563EB)),
        useMaterial3: true,
      ),
      home: isInviteRoute
          ? const ClinicAccountActivationPage()
          : StreamBuilder<User?>(
              stream: FirebaseAuth.instance.authStateChanges(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Scaffold(
                    backgroundColor: Color(0xFF070B14),
                    body: Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF38BDF8),
                      ),
                    ),
                  );
                }

                if (snapshot.hasData && snapshot.data != null) {
                  return const ClinicDashboardPage(); 
                }
                return snapshot.hasData && snapshot.data != null
                    ? const ClinicDashboardPage()
                    : const ClinicStaffLoginPage();
              },
            ),
    );
  }
}
