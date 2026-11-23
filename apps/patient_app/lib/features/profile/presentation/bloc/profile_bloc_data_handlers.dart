part of 'profile_bloc.dart';

extension _ProfileBlocDataHandlers on ProfileBloc {
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
      final queueHist = getQueueHistoryUseCase != null
          ? await getQueueHistoryUseCase!()
          : await GetQueueHistoryUseCase(getProfileUseCase.repository)();
      final payHist = getPaymentHistoryUseCase != null
          ? await getPaymentHistoryUseCase!()
          : await GetPaymentHistoryUseCase(getProfileUseCase.repository)();

      emit(
        state.copyWith(
          status: ProfileStatus.loaded,
          profile: profile,
          favoriteClinics: favorites,
          userReviews: reviews,
          supportTickets: tickets,
          queueHistory: queueHist,
          paymentHistory: payHist,
          activeTicketId: tickets.isNotEmpty ? tickets.first.id : null,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: ProfileStatus.error,
          errorMessage: 'Failed to load profile data: $e',
        ),
      );
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

      emit(
        state.copyWith(
          status: ProfileStatus.loaded,
          profile: updated,
          successMessage: 'Profile updated successfully!',
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: ProfileStatus.error,
          errorMessage: 'Failed to update profile: $e',
        ),
      );
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

  Future<void> _onLogoutRequested(
    ProfileLogoutRequested event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      await logoutUseCase();
      emit(
        state.copyWith(
          isLoggedOut: true,
          successMessage: 'You have been logged out.',
        ),
      );
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
      emit(
        state.copyWith(
          isLoggedOut: true,
          successMessage: 'Account and all history permanently deleted.',
        ),
      );
    } catch (e) {
      if (e.toString().contains('requires-recent-login')) {
        emit(
          state.copyWith(
            errorMessage: 'For security, please sign in again before deleting your account.',
          ),
        );
      } else {
        emit(state.copyWith(errorMessage: 'Account deletion failed: $e'));
      }
    }
  }
}
