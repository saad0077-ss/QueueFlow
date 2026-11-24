import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

import '../features/billing/data/repositories/platform_billing_repository_impl.dart';
import '../features/billing/presentation/bloc/platform_billing_bloc.dart';
import '../features/billing/presentation/bloc/platform_billing_event.dart';
import '../features/dashboard/presentation/bloc/clinics_directory_bloc.dart';
import '../features/departments/presentation/bloc/departments_bloc.dart';
import '../features/reports/data/repositories/platform_reports_repository_impl.dart';
import '../features/reports/domain/usecases/get_platform_reports_usecase.dart';
import '../features/reports/presentation/bloc/platform_reports_bloc.dart';
import '../features/reports/presentation/bloc/platform_reports_event.dart';
import '../features/revenue/presentation/bloc/platform_revenue_bloc.dart';
import '../features/revenue/presentation/bloc/platform_revenue_event.dart';
import '../features/tickets/presentation/bloc/platform_tickets_bloc.dart';
import '../features/tickets/presentation/bloc/platform_tickets_bloc_factory.dart';
import '../features/tickets/presentation/bloc/platform_tickets_event.dart';

/// Injects all root-level BLoCs for the Platform Owner Console.
class PlatformOwnerProviders extends StatelessWidget {
  final Widget child;

  const PlatformOwnerProviders({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ThemeBloc>(create: (_) => ThemeBloc()),
        BlocProvider<ClinicsDirectoryBloc>(
          create: (_) => ClinicsDirectoryBloc(),
        ),
        BlocProvider<PlatformBillingBloc>(
          create: (_) => PlatformBillingBloc(
            repository: PlatformBillingRepositoryImpl(),
          )..add(const PlatformBillingStarted()),
        ),
        BlocProvider<DepartmentsBloc>(create: (_) => DepartmentsBloc()),
        BlocProvider<PlatformReportsBloc>(
          create: (_) => PlatformReportsBloc(
            getReportsUseCase: GetPlatformReportsUseCase(
              PlatformReportsRepositoryImpl(),
            ),
          )..add(const PlatformReportsStarted()),
        ),
        BlocProvider<PlatformRevenueBloc>(
          create: (_) =>
              PlatformRevenueBloc()..add(const PlatformRevenueStarted()),
        ),
        BlocProvider<PlatformTicketsBloc>(
          create: (_) => PlatformTicketsBlocFactory.create()
            ..add(const WatchPlatformTicketsStarted()),
        ),
      ],
      child: child,
    );
  }
}
