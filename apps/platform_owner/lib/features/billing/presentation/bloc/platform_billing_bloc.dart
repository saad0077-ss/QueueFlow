import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/platform_invoice_entity.dart';
import '../../domain/repositories/platform_billing_repository.dart';
import 'platform_billing_event.dart';
import 'platform_billing_state.dart';

class PlatformBillingBloc extends Bloc<PlatformBillingEvent, PlatformBillingState> {
  final PlatformBillingRepository repository;
  StreamSubscription? _subscriptionsSub;

  PlatformBillingBloc({required this.repository}) : super(const PlatformBillingState()) {
    on<PlatformBillingStarted>(_onStarted);
    on<PlatformBillingTabChanged>((e, emit) => emit(state.copyWith(activeTab: e.activeTab)));
    on<PlatformBillingSearchChanged>((e, emit) => emit(state.copyWith(searchQuery: e.query)));
    on<PlatformBillingInvoiceFilterChanged>((e, emit) => emit(state.copyWith(invoiceFilter: e.filter)));
    on<PlatformBillingSubscriptionsStreamUpdated>((e, emit) => emit(state.copyWith(subscriptions: e.subscriptions)));
    on<PlatformBillingIssueInvoiceSubmitted>(_onIssueInvoice);
    on<PlatformBillingSubscriptionUpdated>(_onUpdateSubscription);
    on<PlatformBillingPlanTierSaved>(_onSavePlanTier);
    on<PlatformBillingInvoiceMarkedPaid>(_onMarkInvoicePaid);
    on<PlatformBillingFeedbackDismissed>((e, emit) => emit(state.copyWith(feedbackMessage: null, isError: false)));
  }

  Future<void> _onStarted(PlatformBillingStarted event, Emitter<PlatformBillingState> emit) async {
    emit(state.copyWith(status: PlatformBillingStatus.loading));
    try {
      final kpis = await repository.getKpis();
      final tiers = await repository.getPlanTiers();
      final invoices = await repository.getInvoices();

      await _subscriptionsSub?.cancel();
      _subscriptionsSub = repository.watchTenantSubscriptions().listen((subs) {
        add(PlatformBillingSubscriptionsStreamUpdated(subs));
      });

      emit(state.copyWith(
        status: PlatformBillingStatus.success,
        kpis: kpis,
        tiers: tiers,
        invoices: invoices,
      ));
    } catch (e) {
      emit(state.copyWith(status: PlatformBillingStatus.failure, feedbackMessage: 'Failed to load: $e', isError: true));
    }
  }

  Future<void> _onIssueInvoice(
    PlatformBillingIssueInvoiceSubmitted event,
    Emitter<PlatformBillingState> emit,
  ) async {
    emit(state.copyWith(isSubmitting: true));
    try {
      await repository.issueInvoice(
        clinicId: event.clinicId,
        clinicName: event.clinicName,
        plan: event.plan,
        amount: event.amount,
        dueDate: event.dueDate,
      );
      final updatedInvoices = await repository.getInvoices();
      emit(state.copyWith(
        isSubmitting: false,
        invoices: updatedInvoices,
        feedbackMessage: 'Invoice issued successfully to ${event.clinicName}.',
        isError: false,
      ));
    } catch (e) {
      emit(state.copyWith(isSubmitting: false, feedbackMessage: 'Failed to issue invoice: $e', isError: true));
    }
  }

  Future<void> _onUpdateSubscription(
    PlatformBillingSubscriptionUpdated event,
    Emitter<PlatformBillingState> emit,
  ) async {
    emit(state.copyWith(isSubmitting: true));
    try {
      await repository.updateTenantSubscription(
        clinicId: event.clinicId,
        planId: event.planId,
        billingCadence: event.billingCadence,
        status: event.status,
      );
      emit(state.copyWith(
        isSubmitting: false,
        feedbackMessage: 'Clinic subscription updated successfully.',
        isError: false,
      ));
    } catch (e) {
      emit(state.copyWith(isSubmitting: false, feedbackMessage: 'Failed to update: $e', isError: true));
    }
  }

  Future<void> _onSavePlanTier(
    PlatformBillingPlanTierSaved event,
    Emitter<PlatformBillingState> emit,
  ) async {
    emit(state.copyWith(isSubmitting: true));
    try {
      await repository.savePlanTier(event.tier);
      final tiers = await repository.getPlanTiers();
      emit(state.copyWith(
        isSubmitting: false,
        tiers: tiers,
        feedbackMessage: '${event.tier.name} configuration saved successfully.',
        isError: false,
      ));
    } catch (e) {
      emit(state.copyWith(isSubmitting: false, feedbackMessage: 'Failed to save tier: $e', isError: true));
    }
  }

  Future<void> _onMarkInvoicePaid(
    PlatformBillingInvoiceMarkedPaid event,
    Emitter<PlatformBillingState> emit,
  ) async {
    await repository.markInvoicePaid(event.invoice.id);
    final invoices = state.invoices
        .map((i) => i.id == event.invoice.id
            ? PlatformInvoiceEntity(
                id: i.id,
                number: i.number,
                clinicId: i.clinicId,
                clinicName: i.clinicName,
                plan: i.plan,
                amount: i.amount,
                dueDate: i.dueDate,
                date: i.date,
                status: 'completed',
                method: i.method,
              )
            : i)
        .toList();
    emit(state.copyWith(
      invoices: invoices,
      feedbackMessage: 'Invoice ${event.invoice.number} marked as paid.',
      isError: false,
    ));
  }

  @override
  Future<void> close() {
    _subscriptionsSub?.cancel();
    return super.close();
  }
}
