import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/clinic_billing_repository.dart';
import 'clinic_billing_event.dart';
import 'clinic_billing_state.dart';

class ClinicBillingBloc extends Bloc<ClinicBillingEvent, ClinicBillingState> {
  final ClinicBillingRepository repository;

  ClinicBillingBloc({required this.repository}) : super(const ClinicBillingState()) {
    on<ClinicBillingStarted>(_onStarted);
    on<ClinicBillingCadenceToggled>(_onCadenceToggled);
    on<ClinicBillingPlanChangeRequested>(_onPlanChangeRequested);
    on<ClinicBillingContactUpdated>(_onContactUpdated);
    on<ClinicBillingInvoicesRefreshed>(_onInvoicesRefreshed);
    on<ClinicBillingFeedbackDismissed>(_onFeedbackDismissed);
  }

  Future<void> _onStarted(ClinicBillingStarted event, Emitter<ClinicBillingState> emit) async {
    emit(state.copyWith(status: ClinicBillingStatus.loading));
    try {
      final sub = await repository.getClinicSubscription();
      final tiers = await repository.getPlanTiers();
      final invoices = await repository.getInvoices();
      emit(state.copyWith(
        status: ClinicBillingStatus.success,
        subscription: sub,
        tiers: tiers,
        invoices: invoices,
        activeCadence: sub.billingCycle,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ClinicBillingStatus.failure,
        feedbackMessage: 'Failed to load billing: $e',
        isError: true,
      ));
    }
  }

  Future<void> _onCadenceToggled(
    ClinicBillingCadenceToggled event,
    Emitter<ClinicBillingState> emit,
  ) async {
    // The toggle only changes which prices are previewed. The clinic's actual
    // billing cycle changes only once a plan change is paid/confirmed.
    emit(state.copyWith(activeCadence: event.newCadence));
  }

  Future<void> _onPlanChangeRequested(
    ClinicBillingPlanChangeRequested event,
    Emitter<ClinicBillingState> emit,
  ) async {
    emit(state.copyWith(isSubmitting: true));
    try {
      await repository.activateSubscription(
        planId: event.targetTier.id,
        billingCycle: event.billingCadence,
        paymentId: event.paymentId,
      );
      final sub = await repository.getClinicSubscription();
      final invoices = await repository.getInvoices();
      emit(state.copyWith(
        isSubmitting: false,
        subscription: sub,
        invoices: invoices,
        feedbackMessage: '${event.targetTier.name} activated. Your receipt is available in Invoice History.',
        isError: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        isSubmitting: false,
        feedbackMessage: e.toString().replaceFirst('Exception: ', ''),
        isError: true,
      ));
    }
  }

  Future<void> _onContactUpdated(
    ClinicBillingContactUpdated event,
    Emitter<ClinicBillingState> emit,
  ) async {
    emit(state.copyWith(isSubmitting: true));
    try {
      await repository.updateBillingContact(event.contact);
      final sub = await repository.getClinicSubscription();
      emit(state.copyWith(
        isSubmitting: false,
        subscription: sub,
        feedbackMessage: 'GST and billing information updated successfully.',
        isError: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        isSubmitting: false,
        feedbackMessage: 'Failed to update billing details: $e',
        isError: true,
      ));
    }
  }

  Future<void> _onInvoicesRefreshed(
    ClinicBillingInvoicesRefreshed event,
    Emitter<ClinicBillingState> emit,
  ) async {
    try {
      final invoices = await repository.getInvoices();
      emit(state.copyWith(
        invoices: invoices,
        feedbackMessage: 'Invoices list refreshed.',
        isError: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        feedbackMessage: 'Failed to refresh invoices: $e',
        isError: true,
      ));
    }
  }

  void _onFeedbackDismissed(
    ClinicBillingFeedbackDismissed event,
    Emitter<ClinicBillingState> emit,
  ) {
    emit(state.copyWith(feedbackMessage: null, isError: false));
  }
}
