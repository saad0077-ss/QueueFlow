import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

import '../core/services/notification_service.dart';
import '../core/widgets/app_snack_bar.dart';
import '../features/home/presentation/bloc/home_bloc.dart';
import '../features/home/presentation/bloc/home_bloc_factory.dart';
import '../features/profile/presentation/bloc/profile_bloc.dart';
import '../features/profile/presentation/bloc/profile_bloc_factory.dart';
import '../features/splash/presentation/pages/splash_screen.dart';

/// Root Patient Application widget configuring all core BLoCs at the root level.
class PatientApp extends StatelessWidget {
  final Widget? home;
  final ThemeBloc? themeBloc;
  final ProfileBloc? profileBloc;
  final HomeBloc? homeBloc;

  const PatientApp({
    super.key,
    this.home,
    this.themeBloc,
    this.profileBloc,
    this.homeBloc,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => themeBloc ?? ThemeBloc()),
        BlocProvider(create: (_) => profileBloc ?? ProfileBlocFactory.create()),
        BlocProvider(create: (_) => homeBloc ?? HomeBlocFactory.create()),
      ],
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, themeState) {
          return MaterialApp(
            navigatorKey: NotificationService.navigatorKey,
            title: 'QueueFlow',
            scaffoldMessengerKey: AppSnackBar.messengerKey,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeState.themeMode,
            themeAnimationDuration: Duration.zero,
            builder: (context, child) =>
                ThemeWaveScope(child: child ?? const SizedBox.shrink()),
            home: home ?? const SplashScreen(),
          );
        },
      ),
    );
  }
}
