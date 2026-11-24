import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

import 'app/patient_app.dart';
import 'core/services/notification_service.dart';
import 'firebase_options.dart';

export 'app/patient_app.dart';
export 'features/home/presentation/pages/patient_home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ThemeBloc.initializePrefs();

  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
    await NotificationService.initialize();
  } catch (e) {
    debugPrint('Firebase already initialized: $e');
  }

  runApp(const PatientApp());
}
