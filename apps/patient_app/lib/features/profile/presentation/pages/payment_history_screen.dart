import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:queueflow_ui/queueflow_ui.dart';
import '../../../../core/widgets/app_snack_bar.dart';
import '../../data/repositories/profile_repository_impl.dart';
import '../../domain/entities/patient_payment_item_entity.dart';
import '../../domain/repositories/profile_repository.dart';
import '../widgets/payment_history/payment_history_card.dart';
import '../widgets/payment_history/payment_history_cubit.dart';
import '../widgets/payment_history/payment_history_empty_state.dart';
import '../widgets/payment_history/payment_history_filter_tabs.dart';
import '../widgets/payment_history/payment_history_header.dart';
import '../widgets/payment_history/payment_history_hero_banner.dart';
import '../widgets/payment_history/payment_history_search_bar.dart';
import '../widgets/payment_history/payment_receipt_modal.dart';

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
    return Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PaymentHistoryScreen(
          repository: repository,
          initialPayments: initialPayments,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return BlocProvider(
      create: (_) => PaymentHistoryCubit(
        repository ?? ProfileRepositoryImpl(),
        initialPayments: initialPayments,
      ),
      child: Scaffold(
        backgroundColor: colors.background,
        body: SafeArea(
          bottom: false,
          child: BlocBuilder<PaymentHistoryCubit, PaymentHistoryState>(
            builder: (context, state) {
              final cubit = context.read<PaymentHistoryCubit>();
              final filtered = state.filteredPayments;

              return Column(
                children: [
                  PaymentHistoryHeader(
                    onRefresh: () => cubit.load(),
                    onBack: () => Navigator.of(context).pop(),
                  ),
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: () => cubit.load(),
                      color: colors.primary,
                      backgroundColor: colors.surfaceElevated,
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 640),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // 1. Hero KPI Banner
                                PaymentHistoryHeroBanner(
                                  totalPaid: state.totalPaid,
                                  paidCount: state.paidPayments.length,
                                  totalRefunded: state.totalRefunded,
                                  refundCount: state.refundedPayments.length,
                                  queueTokensCount: state.queueTokensCount,
                                  activeQueueToken: state.activeQueueToken,
                                  activeQueueClinicName: state.activeQueueClinicName,
                                ),
                                const SizedBox(height: 14),

                                // 2. Search Bar
                                PaymentHistorySearchBar(
                                  query: state.searchQuery,
                                  onChanged: (q) => cubit.setSearchQuery(q),
                                  onClear: () => cubit.setSearchQuery(''),
                                ),
                                const SizedBox(height: 12),

                                // 3. Filter Tabs
                                PaymentHistoryFilterTabs(
                                  activeFilter: state.activeFilter,
                                  countAll: state.allPayments.length,
                                  countQueue: state.queuePayments.length,
                                  countAppt: state.apptPayments.length,
                                  countRefunded: state.refundedPayments.length,
                                  onFilterSelected: (f) => cubit.setFilter(f),
                                ),
                                const SizedBox(height: 14),

                                // 4. Transaction Cards List
                                if (state.isLoading) ...[
                                  const SizedBox(height: 60),
                                  Center(
                                    child: CircularProgressIndicator(color: colors.primary),
                                  ),
                                ] else if (filtered.isEmpty) ...[
                                  PaymentHistoryEmptyState(
                                    hasFilters: state.activeFilter != 'all' || state.searchQuery.isNotEmpty,
                                    onReset: () => cubit.resetFilters(),
                                  ),
                                ] else ...[
                                  ListView.separated(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    itemCount: filtered.length,
                                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                                    itemBuilder: (context, index) {
                                      final item = filtered[index];
                                      return PaymentHistoryCard(
                                        payment: item,
                                        onViewReceipt: () => PaymentReceiptModal.show(context, item),
                                        onDownloadReceipt: () {
                                          AppSnackBar.showSuccess(
                                            context,
                                            message: 'Receipt ${item.receiptNo} downloaded as PDF',
                                          );
                                        },
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 24),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
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
