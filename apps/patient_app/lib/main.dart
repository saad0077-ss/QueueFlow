import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'core/theme/app_theme.dart';
import 'features/splash/presentation/pages/splash_screen.dart';

export 'features/home/presentation/pages/patient_home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase safely (guards against Hot Restart & native auto-init)
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
  } catch (e) {
    debugPrint('Firebase already initialized: $e');
  }

  runApp(const PatientApp());
}

class PatientApp extends StatelessWidget {
  final Widget? home;
  const PatientApp({super.key, this.home});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QueueFlow',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: home ?? const SplashScreen(), 
    );
  }
}
