import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:queueflow_ui/queueflow_ui.dart';
import 'features/auth/presentation/pages/platform_admin_login_screen.dart';
import 'features/dashboard/presentation/pages/platform_clinics_page.dart';
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
  runApp(const PlatformOwnerApp());
}

class PlatformOwnerApp extends StatelessWidget {
  const PlatformOwnerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ThemeBloc>(
      create: (_) => ThemeBloc(),
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, themeState) {
          return MaterialApp(
            title: 'QueueFlow — Platform Owner Console',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeState.themeMode,
            themeAnimationDuration: Duration.zero,
            builder: (context, child) =>
                ThemeWaveScope(child: child ?? const SizedBox.shrink()),
            home: StreamBuilder<User?>(
              stream: FirebaseAuth.instance.authStateChanges(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Scaffold(
                    body: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
                return snapshot.hasData && snapshot.data != null
                    ? const PlatformClinicsPage()
                    : const PlatformAdminLoginScreen();
              },
            ),
          );
        },
      ),
    );
  }
}
