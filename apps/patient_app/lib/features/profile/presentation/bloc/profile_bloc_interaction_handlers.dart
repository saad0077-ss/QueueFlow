part of 'profile_bloc.dart';

extension _ProfileBlocInteractionHandlers on ProfileBloc {
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

      emit(
        state.copyWith(
          profile: updatedProfile,
          userReviews: updatedReviews,
          successMessage:
              'Thank you! Your verified review has been published ⭐',
        ),
      );
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
      final updatedReviews = state.userReviews
          .where((r) => r.id != event.reviewId)
          .toList();
      final updatedProfile = state.profile?.copyWith(
        reviewsCount: updatedReviews.length,
      );

      emit(
        state.copyWith(
          profile: updatedProfile,
          userReviews: updatedReviews,
          successMessage: 'Review removed.',
        ),
      );
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
        priority: event.priority,
        linkedTokenNumber: event.linkedTokenNumber,
        isClinicRelated: event.isClinicRelated,
      );

      final updatedTickets = [newTicket, ...state.supportTickets];
      emit(
        state.copyWith(
          supportTickets: updatedTickets,
          activeTicketId: newTicket.id,
          successMessage:
              'Support ticket #${newTicket.ticketNumber} raised successfully!',
        ),
      );
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Failed to raise ticket: $e'));
    }
  }

  Future<void> _onTicketReplySent(
    ProfileTicketReplySent event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      final senderName = state.profile?.name ?? 'Patient';
      final updated = await sendTicketReplyUseCase(
        ticketId: event.ticketId,
        text: event.text,
        senderName: senderName,
      );

      final updatedTickets = state.supportTickets.map((t) {
        return t.id == updated.id ? updated : t;
      }).toList();

      emit(
        state.copyWith(
          supportTickets: updatedTickets,
          activeTicketId: updated.id,
        ),
      );
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

  Future<void> _onTicketStatusUpdated(
    ProfileTicketStatusUpdated event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      if (updateTicketStatusUseCase != null) {
        await updateTicketStatusUseCase!(event.ticketId, event.status);
      } else {
        await getProfileUseCase.repository.updateTicketStatus(
          event.ticketId,
          event.status,
        );
      }
      final updatedTickets = state.supportTickets.map((t) {
        if (t.id == event.ticketId) {
          return t.copyWith(
            status: event.status,
            resolvedAt: event.status == 'resolved' ? 'Just now' : null,
          );
        }
        return t;
      }).toList();
      emit(
        state.copyWith(
          supportTickets: updatedTickets,
          successMessage: event.status == 'resolved'
              ? 'Concern marked as resolved.'
              : 'Concern reopened.',
        ),
      );
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Could not update concern status: $e'));
    }
  }

  Future<void> _onTicketRated(
    ProfileTicketRated event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      if (rateTicketUseCase != null) {
        await rateTicketUseCase!(event.ticketId, event.rating);
      } else {
        await getProfileUseCase.repository.rateTicket(
          event.ticketId,
          event.rating,
        );
      }
      final updatedTickets = state.supportTickets.map((t) {
        if (t.id == event.ticketId) {
          return t.copyWith(rating: event.rating);
        }
        return t;
      }).toList();
      emit(
        state.copyWith(
          supportTickets: updatedTickets,
          successMessage: 'Thank you for your rating!',
        ),
      );
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Could not submit rating: $e'));
    }
  }
}
