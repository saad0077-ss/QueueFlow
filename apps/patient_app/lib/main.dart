import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:queueflow_ui/queueflow_ui.dart';
import 'firebase_options.dart';
import 'features/splash/presentation/pages/splash_screen.dart';

export 'features/home/presentation/pages/patient_home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Theme preference persistence synchronously
  await ThemeBloc.initializePrefs();

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
  final ThemeBloc? themeBloc;

  const PatientApp({
    super.key,
    this.home,
    this.themeBloc,
  });
 
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => themeBloc ?? ThemeBloc(),
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, themeState) {
          return MaterialApp(
            title: 'QueueFlow',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,     
            darkTheme: AppTheme.darkTheme,
            themeMode: themeState.themeMode,
            home: home ?? const SplashScreen(),
          );
        },
      ),
    );
  }
}
