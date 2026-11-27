import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../notifications/data/services/patient_notifications_service.dart';
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
  StreamSubscription<int>? _unreadSubscription;
  StreamSubscription<User?>? _authSubscription;
  String? _lastAuthUid;

  HomeBloc({
    required this.getFeaturedClinicsUseCase,
    required this.getActiveTicketUseCase,
    required this.joinQueueUseCase,
    required this.cancelTicketUseCase,
    FirebaseAuth? firebaseAuth,
  }) : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
       super(_initialState(firebaseAuth ?? FirebaseAuth.instance)) {
    _lastAuthUid = _firebaseAuth.currentUser?.uid;
    on<HomeInitialDataRequested>(_onInitialDataRequested);
    on<HomeClinicsUpdated>(_onClinicsUpdated);
    on<HomeRefreshRequested>(_onRefreshRequested);
    on<HomeCategorySelected>(_onCategorySelected);
    on<HomeSearchQueryChanged>(_onSearchQueryChanged);
    on<HomeNavTabChanged>(_onNavTabChanged);
    on<HomeJoinQueueRequested>(_onJoinQueueRequested);
    on<HomeCancelTicketRequested>(_onCancelTicketRequested);
    on<HomeActiveTicketEnded>(_onActiveTicketEnded);
    on<HomeUnreadNotificationsUpdated>((e, emit) {
      emit(state.copyWith(unreadNotificationsCount: e.count));
    });
    on<HomeAuthCleared>(_onAuthCleared);

    if (Firebase.apps.isNotEmpty) {
      _authSubscription = _firebaseAuth.authStateChanges().listen((user) {
        final nextUid = user?.uid;
        if (nextUid == _lastAuthUid) return;
        _lastAuthUid = nextUid;
        if (!isClosed) {
          add(
            nextUid == null
                ? const HomeAuthCleared()
                : const HomeInitialDataRequested(),
          );
        }
      });
    }
  }

  Future<void> _onAuthCleared(
    HomeAuthCleared event,
    Emitter<HomeState> emit,
  ) async {
    await _unreadSubscription?.cancel();
    _unreadSubscription = null;
    emit(
      state.copyWith(
        clearActiveTicket: true,
        unreadNotificationsCount: 0,
        userName: '',
        userInitials: '',
      ),
    );
  }

  void _onActiveTicketEnded(
    HomeActiveTicketEnded event,
    Emitter<HomeState> emit,
  ) {
    // Ignore if the ticket was already cleared or is a different one.
    if (state.activeTicket == null ||
        state.activeTicket!.id != event.ticketId) {
      return;
    }
    emit(
      state.copyWith(
        clearActiveTicket: true,
        successMessage: event.status == 'completed'
            ? 'Consultation completed. Thank you for visiting!'
            : 'Your ticket was cancelled.',
      ),
    );
  }

  static HomeState _initialState(FirebaseAuth auth) {
    final id = _identityFor(auth.currentUser);
    return HomeState(userName: id.name, userInitials: id.initials);
  }

  /// Display name + initials of the signed-in user; empty when unknown (no mock data).
  static ({String name, String initials}) _identityFor(User? user) {
    final display = user?.displayName?.trim() ?? '';
    if (display.isNotEmpty) {
      final parts = display.split(RegExp(r'\s+'));
      final initials = parts.length >= 2 && parts[1].isNotEmpty
          ? '${parts[0][0]}${parts[1][0]}'
          : parts[0].substring(0, parts[0].length >= 2 ? 2 : 1);
      return (name: parts[0], initials: initials.toUpperCase());
    }
    final handle = (user?.email ?? '').split('@').first;
    if (handle.isNotEmpty) {
      return (
        name: handle[0].toUpperCase() + handle.substring(1),
        initials: handle.substring(0, handle.length >= 2 ? 2 : 1).toUpperCase(),
      );
    }
    return (name: '', initials: '');
  }

  Future<void> _onInitialDataRequested(
    HomeInitialDataRequested event,
    Emitter<HomeState> emit,
  ) async {
    final identity = _identityFor(_firebaseAuth.currentUser);
    final name = identity.name;
    final initials = identity.initials;

    // Cancel any previous stream
    await _clinicsSubscription?.cancel();
    _clinicsSubscription = getFeaturedClinicsUseCase.watch().listen((clinics) {
      add(HomeClinicsUpdated(clinics));
    });
    if (Firebase.apps.isNotEmpty) {
      await _unreadSubscription?.cancel();
      _unreadSubscription = PatientNotificationsService.instance
          .watchUnreadCount()
          .listen((count) {
            if (!isClosed) add(HomeUnreadNotificationsUpdated(count));
          }, onError: (_) {});
    }

    final clinics = await getFeaturedClinicsUseCase();
    final activeTicket = await getActiveTicketUseCase();

    emit(
      state.copyWith(
        allClinics: clinics,
        filteredClinics: _filterClinics(
          clinics,
          state.selectedCategory,
          state.searchQuery,
        ),
        userName: name,
        userInitials: initials,
        activeTicket: activeTicket,
        currentTabIndex: 0,
        selectedCategory: 'all',
        searchQuery: '',
      ),
    );
  }

  void _onClinicsUpdated(HomeClinicsUpdated event, Emitter<HomeState> emit) {
    final filtered = _filterClinics(
      event.clinics,
      state.selectedCategory,
      state.searchQuery,
    );
    emit(state.copyWith(allClinics: event.clinics, filteredClinics: filtered));
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
    emit(
      state.copyWith(
        allClinics: clinics,
        filteredClinics: filtered,
        activeTicket: activeTicket,
      ),
    );
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
    emit(
      state.copyWith(
        selectedCategory: event.category,
        filteredClinics: filtered,
      ),
    );
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
    emit(state.copyWith(searchQuery: event.query, filteredClinics: filtered));
  }

  void _onNavTabChanged(HomeNavTabChanged event, Emitter<HomeState> emit) {
    emit(
      state.copyWith(
        currentTabIndex: event.tabIndex,
        clearSuccessMessage: true,
        clearErrorMessage: true,
      ),
    );
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
        serviceName: event.serviceName,
        departmentName: event.departmentName,
      );

      emit(
        state.copyWith(
          activeTicket: ticket,
          currentTabIndex: 1, // Switch to Queue tab
          successMessage: 'Token ${ticket.token} allocated successfully!',
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          errorMessage: e is StateError
              ? e.message
              : 'Failed to join queue: $e',
        ),
      );
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
    emit(
      state.copyWith(
        clearActiveTicket: true,
        successMessage: 'Left queue. Your ticket has been cancelled.',
      ),
    );
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
    _unreadSubscription?.cancel();
    _authSubscription?.cancel();
    return super.close();
  }
}
