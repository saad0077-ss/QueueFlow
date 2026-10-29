import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'features/auth/presentation/pages/platform_admin_login_screen.dart';
import 'features/dashboard/presentation/pages/platform_clinics_page.dart';
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
  runApp(const PlatformOwnerApp());
} 
 class PlatformOwnerApp extends StatelessWidget { 
  const PlatformOwnerApp({super.key});
  
  @override            
  Widget build(BuildContext context) { 
    return MaterialApp(         
      title: 'QueueFlow — Platform Owner Console',
      debugShowCheckedModeBanner: false,  
      theme: ThemeData(  
        colorScheme: ColorScheme.fromSeed( 
          seedColor: const Color(0xFF2563EB),  
          brightness: Brightness.dark,  
        ),
        scaffoldBackgroundColor: const Color(0xFF070B14),
        useMaterial3: true,
      ),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              backgroundColor: Color(0xFF070B14), 
              body: Center( 
                child: CircularProgressIndicator(color: Color(0xFF38BDF8)),
              ),
            ); 
          }
          return snapshot.hasData && snapshot.data != null
              ? const PlatformClinicsPage()
              : const PlatformAdminLoginScreen();
        },
      ),
    );
  }
}
