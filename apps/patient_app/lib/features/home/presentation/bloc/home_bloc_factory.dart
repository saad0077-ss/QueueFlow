import '../../data/repositories/home_repository_impl.dart';
import '../../domain/repositories/home_repository.dart';
import '../../domain/usecases/cancel_ticket_usecase.dart';
import '../../domain/usecases/get_active_ticket_usecase.dart';
import '../../domain/usecases/get_featured_clinics_usecase.dart';
import '../../domain/usecases/join_queue_usecase.dart';
import 'home_bloc.dart';
import 'home_event.dart';

/// Factory for building fully-injected [HomeBloc] instances.
class HomeBlocFactory {
  const HomeBlocFactory._();

  static HomeBloc create({HomeRepository? repository}) {
    final repo = repository ?? HomeRepositoryImpl();
    return HomeBloc(
      getFeaturedClinicsUseCase: GetFeaturedClinicsUseCase(repo),
      getActiveTicketUseCase: GetActiveTicketUseCase(repo),
      joinQueueUseCase: JoinQueueUseCase(repo),
      cancelTicketUseCase: CancelTicketUseCase(repo),
    )..add(const HomeInitialDataRequested());
  }
}
