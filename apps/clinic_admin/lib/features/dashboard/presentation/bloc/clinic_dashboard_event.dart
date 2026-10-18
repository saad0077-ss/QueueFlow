import 'package:equatable/equatable.dart';
import '../../domain/entities/clinic_queue_entity.dart';

/// Base class for all Clinic Dashboard events.
abstract class ClinicDashboardEvent extends Equatable {
  const ClinicDashboardEvent();

  @override
  List<Object?> get props => [];
}

/// Request to subscribe to live queue changes from Firestore.
class DashboardSubscriptionRequested extends ClinicDashboardEvent {
  const DashboardSubscriptionRequested();
}

/// Dispatched when the live queue stream emits an update.
class DashboardQueueUpdated extends ClinicDashboardEvent {
  final ClinicQueueEntity queue;

  const DashboardQueueUpdated(this.queue);

  @override
  List<Object?> get props => [queue];
}

/// Dispatched when staff clicks "Call Next".
class DashboardCallNextPressed extends ClinicDashboardEvent {
  const DashboardCallNextPressed();
}

/// Dispatched when staff clicks "Add Walk-In Patient".
class DashboardIssueWalkInPressed extends ClinicDashboardEvent {
  const DashboardIssueWalkInPressed();
}

/// Dispatched when staff clicks "Pause Live Queue" or "Resume Live Queue".
class DashboardTogglePausePressed extends ClinicDashboardEvent {
  const DashboardTogglePausePressed();
}

/// Dispatched when staff switches tabs on the sidebar.
class DashboardNavTabChanged extends ClinicDashboardEvent {
  final String activeTab;

  const DashboardNavTabChanged(this.activeTab);

  @override
  List<Object?> get props => [activeTab];
}

/// Dispatched when staff types into the search field.
class DashboardSearchQueryChanged extends ClinicDashboardEvent {
  final String query;

  const DashboardSearchQueryChanged(this.query);

  @override
  List<Object?> get props => [query];
}

/// Dispatched to clear feedback or error toast messages.
class DashboardClearFeedback extends ClinicDashboardEvent {
  const DashboardClearFeedback();
}
