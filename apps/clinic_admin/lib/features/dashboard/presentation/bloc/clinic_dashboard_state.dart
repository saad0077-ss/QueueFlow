import 'package:equatable/equatable.dart';
import '../../domain/entities/clinic_queue_entity.dart';

enum ClinicDashboardStatus { initial, loading, success, failure }

/// Immutable state for the Clinic Dashboard BLoC.
class ClinicDashboardState extends Equatable {
  final ClinicDashboardStatus status;
  final ClinicQueueEntity queue;
  final String activeNav;
  final String searchQuery;
  final String? toastMessage;
  final bool isErrorToast;

  const ClinicDashboardState({
    this.status = ClinicDashboardStatus.initial,
    this.queue = const ClinicQueueEntity(),
    this.activeNav = 'Dashboard',
    this.searchQuery = '',
    this.toastMessage,
    this.isErrorToast = false,
  });

  ClinicDashboardState copyWith({
    ClinicDashboardStatus? status,
    ClinicQueueEntity? queue,
    String? activeNav,
    String? searchQuery,
    String? toastMessage,
    bool? isErrorToast,
    bool clearToast = false,
  }) {
    return ClinicDashboardState(
      status: status ?? this.status,
      queue: queue ?? this.queue,
      activeNav: activeNav ?? this.activeNav,
      searchQuery: searchQuery ?? this.searchQuery,
      toastMessage: clearToast ? null : (toastMessage ?? this.toastMessage),
      isErrorToast: isErrorToast ?? this.isErrorToast,
    );
  }

  @override
  List<Object?> get props => [
        status,
        queue,
        activeNav,
        searchQuery,
        toastMessage,
        isErrorToast,
      ];
}
