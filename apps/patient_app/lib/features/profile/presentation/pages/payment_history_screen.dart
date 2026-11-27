import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

import '../../data/repositories/profile_repository_impl.dart';
import '../../domain/entities/patient_payment_item_entity.dart';
import '../../domain/repositories/profile_repository.dart';
import '../widgets/payment_history/payment_history_bloc.dart';
import '../widgets/payment_history/payment_history_empty_state.dart';
import '../widgets/payment_history/payment_history_filter_dialog.dart';
import '../widgets/payment_history/payment_history_header.dart';
import '../widgets/payment_history/payment_history_hero_banner.dart';
import '../widgets/payment_history/payment_history_list.dart';
import '../widgets/payment_history/payment_history_search_bar.dart';

class PaymentHistoryScreen extends StatelessWidget {
  final ProfileRepository? repository;
  final List<PatientPaymentItemEntity>? initialPayments;

  const PaymentHistoryScreen({
    super.key,
    this.repository,
    this.initialPayments,
  });

  static Future<void> open(
    BuildContext context, {
    ProfileRepository? repository,
    List<PatientPaymentItemEntity>? initialPayments,
  }) {
    return Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => PaymentHistoryScreen(
        repository: repository,
        initialPayments: initialPayments,
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return BlocProvider(
      create: (_) => PaymentHistoryBloc(
        repository ?? ProfileRepositoryImpl(),
        initialPayments: initialPayments,
      ),
      child: Scaffold(
        backgroundColor: colors.background,
        body: SafeArea(
          bottom: false,
          child: BlocBuilder<PaymentHistoryBloc, PaymentHistoryState>(
            builder: (context, state) {
              final bloc = context.read<PaymentHistoryBloc>();
              final filtered = state.filteredPayments;

              return Column(
                children: [
                  PaymentHistoryHeader(
                    onRefresh: () => bloc.load(),
                    onBack: () => Navigator.of(context).pop(),
                  ),
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final isLaptop = constraints.maxWidth >= 800;
                        return RefreshIndicator(
                          onRefresh: () async => bloc.load(),
                          color: colors.primary,
                          backgroundColor: colors.surfaceElevated,
                          child: SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: EdgeInsets.symmetric(
                              horizontal: isLaptop ? 32 : 16,
                              vertical: 14,
                            ),
                            child: Center(
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                  maxWidth: isLaptop ? 1280 : 640,
                                ),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    PaymentHistoryHeroBanner(
                                      totalPaid: state.totalPaid,
                                      paidCount: state.paidPayments.length,
                                      totalRefunded: state.totalRefunded,
                                      refundCount:
                                          state.refundedPayments.length,
                                      queueTokensCount: state.queueTokensCount,
                                      activeQueueToken: state.activeQueueToken,
                                      activeQueueClinicName:
                                          state.activeQueueClinicName,
                                    ),
                                    const SizedBox(height: 14),
                                    PaymentHistorySearchBar(
                                      query: state.searchQuery,
                                      hasActiveFilter:
                                          state.activeFilter != 'all',
                                      onChanged: bloc.setSearchQuery,
                                      onClear: () => bloc.setSearchQuery(''),
                                      onFilterTap: () =>
                                          PaymentHistoryFilterDialog.showForBloc(
                                        context,
                                        bloc,
                                        state,
                                      ),
                                    ),
                                    const SizedBox(height: 14),
                                    if (state.isLoading) ...[
                                      const SizedBox(height: 60),
                                      Center(
                                        child: CircularProgressIndicator(
                                          color: colors.primary,
                                        ),
                                      ),
                                    ] else if (filtered.isEmpty)
                                      PaymentHistoryEmptyState(
                                        hasFilters:
                                            state.activeFilter != 'all' ||
                                            state.searchQuery.isNotEmpty,
                                        onReset: bloc.resetFilters,
                                      )
                                    else ...[
                                      PaymentHistoryList(payments: filtered),
                                      const SizedBox(height: 24),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
