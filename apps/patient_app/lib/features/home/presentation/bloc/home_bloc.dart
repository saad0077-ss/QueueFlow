import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/clinic_entity.dart';
import '../../domain/usecases/cancel_ticket_usecase.dart';
import '../../domain/usecases/get_active_ticket_usecase.dart';
import '../../domain/usecases/get_featured_clinics_usecase.dart';
import '../../domain/usecases/join_queue_usecase.dart';
import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final GetFeaturedClinicsUseCase getFeaturedClinicsUseCase;
  final GetActiveTicketUseCase getActiveTicketUseCase;
  final JoinQueueUseCase joinQueueUseCase;
  final CancelTicketUseCase cancelTicketUseCase;
  final FirebaseAuth _firebaseAuth;

  HomeBloc({
    required this.getFeaturedClinicsUseCase,
    required this.getActiveTicketUseCase,
    required this.joinQueueUseCase,
    required this.cancelTicketUseCase,
    FirebaseAuth? firebaseAuth,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        super(const HomeState()) {
    on<HomeInitialDataRequested>(_onInitialDataRequested);
    on<HomeCategorySelected>(_onCategorySelected);
    on<HomeSearchQueryChanged>(_onSearchQueryChanged);
    on<HomeNavTabChanged>(_onNavTabChanged);
    on<HomeJoinQueueRequested>(_onJoinQueueRequested);
    on<HomeCancelTicketRequested>(_onCancelTicketRequested);
  }

  Future<void> _onInitialDataRequested(
    HomeInitialDataRequested event,
    Emitter<HomeState> emit,
  ) async {
    final user = _firebaseAuth.currentUser;
    String name = 'Aisha';
    String initials = 'AR';

    if (user?.displayName != null && user!.displayName!.trim().isNotEmpty) {
      final parts = user.displayName!.trim().split(' ');
      name = parts[0];
      if (parts.length >= 2) {
        initials = '${parts[0][0]}${parts[1][0]}'.toUpperCase();
      } else {
        initials = parts[0][0].toUpperCase();
      }
    }

    final clinics = await getFeaturedClinicsUseCase();
    final activeTicket = await getActiveTicketUseCase();

    emit(state.copyWith(
      allClinics: clinics,
      filteredClinics: clinics,
      userName: name,
      userInitials: initials,
      activeTicket: activeTicket,
      currentTabIndex: 0,
      selectedCategory: 'all',
      searchQuery: '',
    ));
  }

  void _onCategorySelected(
    HomeCategorySelected event,
    Emitter<HomeState> emit,
  ) {
    final filtered = _filterClinics(
      state.allClinics,
      event.category,
      state.searchQuery,
    );
    emit(state.copyWith(
      selectedCategory: event.category,
      filteredClinics: filtered,
    ));
  }

  void _onSearchQueryChanged(
    HomeSearchQueryChanged event,
    Emitter<HomeState> emit,
  ) {
    final filtered = _filterClinics(
      state.allClinics,
      state.selectedCategory,
      event.query,
    );
    emit(state.copyWith(
      searchQuery: event.query,
      filteredClinics: filtered,
    ));
  }

  void _onNavTabChanged(
    HomeNavTabChanged event,
    Emitter<HomeState> emit,
  ) {
    emit(state.copyWith(
      currentTabIndex: event.tabIndex,
      clearSuccessMessage: true,
      clearErrorMessage: true,
    ));
  }

  Future<void> _onJoinQueueRequested(
    HomeJoinQueueRequested event,
    Emitter<HomeState> emit,
  ) async {
    try {
      final ticket = await joinQueueUseCase(
        clinicId: event.clinic.id,
        clinicName: event.clinic.name,
        patientName: event.patientName,
        currentWaitingCount: event.clinic.waitingCount,
        currentToken: event.clinic.currentToken,
      );

      emit(state.copyWith(
        activeTicket: ticket,
        currentTabIndex: 1, // Switch to Queue tab
        successMessage: 'Token ${ticket.token} allocated successfully!',
      ));
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Failed to join queue: $e'));
    }
  }

  Future<void> _onCancelTicketRequested(
    HomeCancelTicketRequested event,
    Emitter<HomeState> emit,
  ) async {
    final ticketId = event.ticketId ?? state.activeTicket?.id;
    if (ticketId != null) {
      await cancelTicketUseCase(ticketId);
    }
    emit(state.copyWith(
      clearActiveTicket: true,
      successMessage: 'Left queue. Your ticket has been cancelled.',
    ));
  }

  List<ClinicEntity> _filterClinics(
    List<ClinicEntity> clinics,
    String category,
    String query,
  ) {
    var result = clinics;
    if (category.toLowerCase() != 'all') {
      result = result
          .where((c) =>
              c.category.toLowerCase().contains(category.toLowerCase()))
          .toList();
    }
    if (query.trim().isNotEmpty) {
      final q = query.toLowerCase();
      result = result
          .where((c) =>
              c.name.toLowerCase().contains(q) ||
              c.category.toLowerCase().contains(q) ||
              c.address.toLowerCase().contains(q))
          .toList();
    }
    return result;
  }
}
