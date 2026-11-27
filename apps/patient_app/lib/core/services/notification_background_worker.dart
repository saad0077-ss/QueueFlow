import 'dart:ui' show DartPluginRegistrant;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:workmanager/workmanager.dart';

import '../../features/notifications/data/services/patient_notifications_service.dart';
import '../../firebase_options.dart';
import 'notification_controller.dart';
import 'notification_payload_helper.dart';

const String kQueueFlowBgSyncTask = 'queueflow.notifications.backgroundSync';

@pragma('vm:entry-point')
void queueFlowBackgroundDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    WidgetsFlutterBinding.ensureInitialized();
    DartPluginRegistrant.ensureInitialized();
    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
      }
      await NotificationController.ensureInitialized();
      if (FirebaseAuth.instance.currentUser == null) return true;

      final items = await PatientNotificationsService.instance.fetchAllOnce();
      await NotificationPayloadHelper.dispatchUnreadAlerts(items);
      return true;
    } catch (e) {
      debugPrint('Background notification sync error: $e');
      return false;
    }
  });
}

/// Registers periodic OS background checks so Firestore updates still raise
/// Android system notifications even when the app is closed.
class NotificationBackgroundWorker {
  const NotificationBackgroundWorker._();

  static bool _registered = false;

  static Future<void> register() async {
    if (_registered || kIsWeb) return;
    if (defaultTargetPlatform != TargetPlatform.android &&
        defaultTargetPlatform != TargetPlatform.iOS) {
      return;
    }
    try {
      await Workmanager().initialize(queueFlowBackgroundDispatcher);
      await Workmanager().registerPeriodicTask(
        kQueueFlowBgSyncTask,
        kQueueFlowBgSyncTask,
        frequency: const Duration(minutes: 15),
        existingWorkPolicy: ExistingPeriodicWorkPolicy.update,
        constraints: Constraints(networkType: NetworkType.connected),
      );
      _registered = true;
    } catch (e) {
      debugPrint('Workmanager registration skipped: $e');
    }
  }
}
