import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/profile_usecases.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final GetProfileUseCase getProfileUseCase;
  final UpdateProfileUseCase updateProfileUseCase;
  final ToggleDarkModeUseCase toggleDarkModeUseCase;
  final GetFavoriteClinicsUseCase getFavoriteClinicsUseCase;
  final GetUserReviewsUseCase getUserReviewsUseCase;
  final AddReviewUseCase addReviewUseCase;
  final DeleteReviewUseCase deleteReviewUseCase;
  final GetSupportTicketsUseCase getSupportTicketsUseCase;
  final CreateSupportTicketUseCase createSupportTicketUseCase;
  final SendTicketReplyUseCase sendTicketReplyUseCase;
  final LogoutUseCase logoutUseCase;
  final DeleteAccountUseCase deleteAccountUseCase;

  ProfileBloc({
    required this.getProfileUseCase,
    required this.updateProfileUseCase,
    required this.toggleDarkModeUseCase,
    required this.getFavoriteClinicsUseCase,
    required this.getUserReviewsUseCase,
    required this.addReviewUseCase,
    required this.deleteReviewUseCase,
    required this.getSupportTicketsUseCase,
    required this.createSupportTicketUseCase,
    required this.sendTicketReplyUseCase,
    required this.logoutUseCase,
    required this.deleteAccountUseCase,
  }) : super(const ProfileState()) {
    on<ProfileLoadRequested>(_onLoadRequested);
    on<ProfileUpdated>(_onUpdated);
    on<ProfileDarkModeToggled>(_onDarkModeToggled);
    on<ProfileReviewSubmitted>(_onReviewSubmitted);
    on<ProfileReviewDeleted>(_onReviewDeleted);
    on<ProfileSupportTicketCreated>(_onSupportTicketCreated);
    on<ProfileTicketReplySent>(_onTicketReplySent);
    on<ProfileActiveTicketChanged>(_onActiveTicketChanged);
    on<ProfileLogoutRequested>(_onLogoutRequested);
    on<ProfileDeleteAccountRequested>(_onDeleteAccountRequested);
  }

  Future<void> _onLoadRequested(
    ProfileLoadRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(status: ProfileStatus.loading, clearMessages: true));
    try {
      final profile = await getProfileUseCase();
      final favorites = await getFavoriteClinicsUseCase();
      final reviews = await getUserReviewsUseCase();
      final tickets = await getSupportTicketsUseCase();

      emit(state.copyWith(
        status: ProfileStatus.loaded,
        profile: profile,
        favoriteClinics: favorites,
        userReviews: reviews,
        supportTickets: tickets,
        activeTicketId: tickets.isNotEmpty ? tickets.first.id : null,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ProfileStatus.error,
        errorMessage: 'Failed to load profile data: $e',
      ));
    }
  }

  Future<void> _onUpdated(
    ProfileUpdated event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(status: ProfileStatus.updating, clearMessages: true));
    try {
      final updated = await updateProfileUseCase(
        name: event.name,
        email: event.email,
        phone: event.phone,
        initials: event.initials,
        age: event.age,
        gender: event.gender,
        bloodGroup: event.bloodGroup,
        photoBase64: event.photoBase64,
      );

      emit(state.copyWith(
        status: ProfileStatus.loaded,
        profile: updated,
        successMessage: 'Profile updated successfully!',
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ProfileStatus.error,
        errorMessage: 'Failed to update profile: $e',
      ));
    }
  }

  Future<void> _onDarkModeToggled(
    ProfileDarkModeToggled event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      final updated = await toggleDarkModeUseCase(event.enabled);
      emit(state.copyWith(profile: updated));
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Could not change theme: $e'));
    }
  }

  Future<void> _onReviewSubmitted(
    ProfileReviewSubmitted event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      final newRev = await addReviewUseCase(
        clinicId: event.clinicId,
        clinicName: event.clinicName,
        doctorName: event.doctorName,
        rating: event.rating,
        tags: event.tags,
        comment: event.comment,
        isAnonymous: event.isAnonymous,
      );

      final updatedReviews = [newRev, ...state.userReviews];
      final updatedProfile = state.profile?.copyWith(
        reviewsCount: updatedReviews.length,
        loyaltyCredits: (state.profile?.loyaltyCredits ?? 450) + 50,
      );

      emit(state.copyWith(
        profile: updatedProfile,
        userReviews: updatedReviews,
        successMessage: 'Thank you! Your verified review has been published ⭐',
      ));
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Failed to submit review: $e'));
    }
  }

  Future<void> _onReviewDeleted(
    ProfileReviewDeleted event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      await deleteReviewUseCase(event.reviewId);
      final updatedReviews = state.userReviews.where((r) => r.id != event.reviewId).toList();
      final updatedProfile = state.profile?.copyWith(
        reviewsCount: updatedReviews.length,
      );

      emit(state.copyWith(
        profile: updatedProfile,
        userReviews: updatedReviews,
        successMessage: 'Review removed.',
      ));
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Failed to remove review: $e'));
    }
  }

  Future<void> _onSupportTicketCreated(
    ProfileSupportTicketCreated event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      final newTicket = await createSupportTicketUseCase(
        clinicId: event.clinicId,
        clinicName: event.clinicName,
        category: event.category,
        subject: event.subject,
        description: event.description,
      );

      final updatedTickets = [newTicket, ...state.supportTickets];
      emit(state.copyWith(
        supportTickets: updatedTickets,
        activeTicketId: newTicket.id,
        successMessage: 'Support ticket #${newTicket.id} raised successfully!',
      ));
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Failed to raise ticket: $e'));
    }
  }

  Future<void> _onTicketReplySent(
    ProfileTicketReplySent event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      final senderName = state.profile?.name ?? 'Aisha Rahman';
      final updated = await sendTicketReplyUseCase(
        ticketId: event.ticketId,
        text: event.text,
        senderName: senderName,
      );

      final updatedTickets = state.supportTickets.map((t) {
        return t.id == updated.id ? updated : t;
      }).toList();

      emit(state.copyWith(
        supportTickets: updatedTickets,
        activeTicketId: updated.id,
      ));
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Could not send reply: $e'));
    }
  }

  void _onActiveTicketChanged(
    ProfileActiveTicketChanged event,
    Emitter<ProfileState> emit,
  ) {
    emit(state.copyWith(activeTicketId: event.ticketId));
  }

  Future<void> _onLogoutRequested(
    ProfileLogoutRequested event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      await logoutUseCase();
      emit(state.copyWith(
        isLoggedOut: true,
        successMessage: 'You have been logged out.',
      ));
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Logout failed: $e'));
    }
  }

  Future<void> _onDeleteAccountRequested(
    ProfileDeleteAccountRequested event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      await deleteAccountUseCase();
      emit(state.copyWith(
        isLoggedOut: true,
        successMessage: 'Account data reset successfully.',
      ));
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Account deletion failed: $e'));
    }
  }
}
