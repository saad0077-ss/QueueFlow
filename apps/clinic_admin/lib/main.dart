import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

import 'app/clinic_admin_app.dart';
import 'firebase_options.dart';

export 'app/clinic_admin_app.dart';

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
