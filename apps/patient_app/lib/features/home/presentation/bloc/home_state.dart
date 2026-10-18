import 'package:equatable/equatable.dart';
import '../../domain/entities/active_ticket_entity.dart';
import '../../domain/entities/clinic_entity.dart';

class HomeState extends Equatable {
  final int currentTabIndex;
  final String selectedCategory;
  final String searchQuery;
  final List<ClinicEntity> allClinics;
  final List<ClinicEntity> filteredClinics;
  final ActiveTicketEntity? activeTicket;
  final String userName;
  final String userInitials;
  final int unreadNotificationsCount;
  final String? successMessage;
  final String? errorMessage;

  const HomeState({
    this.currentTabIndex = 0,
    this.selectedCategory = 'all',
    this.searchQuery = '',
    this.allClinics = const [],
    this.filteredClinics = const [],
    this.activeTicket,
    this.userName = 'Aisha',
    this.userInitials = 'AR',
    this.unreadNotificationsCount = 1,
    this.successMessage,
    this.errorMessage,
  });

  HomeState copyWith({
    int? currentTabIndex,
    String? selectedCategory,
    String? searchQuery,
    List<ClinicEntity>? allClinics,
    List<ClinicEntity>? filteredClinics,
    ActiveTicketEntity? activeTicket,
    bool clearActiveTicket = false,
    String? userName,
    String? userInitials,
    int? unreadNotificationsCount,
    String? successMessage,
    bool clearSuccessMessage = false,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return HomeState(
      currentTabIndex: currentTabIndex ?? this.currentTabIndex,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      searchQuery: searchQuery ?? this.searchQuery,
      allClinics: allClinics ?? this.allClinics,
      filteredClinics: filteredClinics ?? this.filteredClinics,
      activeTicket: clearActiveTicket ? null : (activeTicket ?? this.activeTicket),
      userName: userName ?? this.userName,
      userInitials: userInitials ?? this.userInitials,
      unreadNotificationsCount:
          unreadNotificationsCount ?? this.unreadNotificationsCount,
      successMessage:
          clearSuccessMessage ? null : (successMessage ?? this.successMessage),
      errorMessage:
          clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
        currentTabIndex,
        selectedCategory,
        searchQuery,
        allClinics,
        filteredClinics,
        activeTicket,
        userName,
        userInitials,
        unreadNotificationsCount,
        successMessage,
        errorMessage,
      ];
}
