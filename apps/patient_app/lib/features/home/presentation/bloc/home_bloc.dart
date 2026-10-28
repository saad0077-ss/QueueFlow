import 'dart:async';
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
  StreamSubscription<List<ClinicEntity>>? _clinicsSubscription;

  HomeBloc({
    required this.getFeaturedClinicsUseCase,
    required this.getActiveTicketUseCase,
    required this.joinQueueUseCase,
    required this.cancelTicketUseCase,
    FirebaseAuth? firebaseAuth,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        super(const HomeState()) {
    on<HomeInitialDataRequested>(_onInitialDataRequested);
    on<HomeClinicsUpdated>(_onClinicsUpdated);
    on<HomeRefreshRequested>(_onRefreshRequested);
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
      final parts = user.displayName!.trim().split(RegExp(r'\s+'));
      name = parts[0];
      if (parts.length >= 2 && parts[1].isNotEmpty) {
        initials = '${parts[0][0]}${parts[1][0]}'.toUpperCase();
      } else {
        initials = parts[0].substring(0, parts[0].length >= 2 ? 2 : 1).toUpperCase();
      }
    } else if (user?.email != null && user!.email!.isNotEmpty) {
      final handle = user.email!.split('@')[0];
      name = handle[0].toUpperCase() + handle.substring(1);
      initials = handle.substring(0, handle.length >= 2 ? 2 : 1).toUpperCase();
    }

    // Cancel any previous stream
    await _clinicsSubscription?.cancel();
    _clinicsSubscription = getFeaturedClinicsUseCase.watch().listen((clinics) {
      add(HomeClinicsUpdated(clinics));
    });

    final clinics = await getFeaturedClinicsUseCase();
    final activeTicket = await getActiveTicketUseCase();

    emit(state.copyWith(
      allClinics: clinics,
      filteredClinics: _filterClinics(clinics, state.selectedCategory, state.searchQuery),
      userName: name,
      userInitials: initials,
      activeTicket: activeTicket,
      currentTabIndex: 0,
      selectedCategory: 'all',
      searchQuery: '',
    ));
  }

  void _onClinicsUpdated(
    HomeClinicsUpdated event,
    Emitter<HomeState> emit,
  ) {
    final filtered = _filterClinics(
      event.clinics,
      state.selectedCategory,
      state.searchQuery,
    );
    emit(state.copyWith(
      allClinics: event.clinics,
      filteredClinics: filtered,
    ));
  }

  Future<void> _onRefreshRequested(
    HomeRefreshRequested event,
    Emitter<HomeState> emit,
  ) async {
    final clinics = await getFeaturedClinicsUseCase();
    final activeTicket = await getActiveTicketUseCase();
    final filtered = _filterClinics(
      clinics,
      state.selectedCategory,
      state.searchQuery,
    );
    emit(state.copyWith(
      allClinics: clinics,
      filteredClinics: filtered,
      activeTicket: activeTicket,
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
    final catLower = category.trim().toLowerCase();
    if (catLower.isNotEmpty && catLower != 'all') {
      result = result.where((c) {
        final clinicCat = c.category.toLowerCase();
        return clinicCat.contains(catLower);
      }).toList();
    }
    if (query.trim().isNotEmpty) {
      final q = query.trim().toLowerCase();
      result = result.where((c) {
        return c.name.toLowerCase().contains(q) ||
            c.category.toLowerCase().contains(q) ||
            c.address.toLowerCase().contains(q) ||
            c.city.toLowerCase().contains(q);
      }).toList();
    }
    return result;
  }

  @override
  Future<void> close() {
    _clinicsSubscription?.cancel();
    return super.close();
  }
}
