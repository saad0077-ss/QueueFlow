import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:queueflow_ui/queueflow_ui.dart';
import 'package:patient_app/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:patient_app/features/profile/domain/repositories/profile_repository.dart';
import 'payment_history_cubit.dart';
import 'payment_history_item_tile.dart';
import 'payment_history_summary_banner.dart';

class PaymentHistorySheet extends StatelessWidget {
  final ProfileRepository? repository;

  const PaymentHistorySheet({super.key, this.repository});

  static Future<void> show(BuildContext context, {ProfileRepository? repository}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PaymentHistorySheet(repository: repository),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return BlocProvider(
      create: (_) => PaymentHistoryCubit(repository ?? ProfileRepositoryImpl()),
      child: BlocBuilder<PaymentHistoryCubit, PaymentHistoryState>(
        builder: (context, state) {
          return Container(
            margin: const EdgeInsets.only(top: 48),
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 24),
            decoration: BoxDecoration(
              color: colors.surfaceElevated,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 14),
                      decoration: BoxDecoration(
                        color: colors.border,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Text('💳', style: TextStyle(fontSize: 22)),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Payment History',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: colors.textPrimary),
                              ),
                              Text(
                                'Consultation fees, receipts & refunds',
                                style: TextStyle(fontSize: 11.5, color: colors.textMuted),
                              ),
                            ],
                          ),
                        ],
                      ),
                      IconButton(
                        icon: Icon(Icons.close_rounded, color: colors.textMuted, size: 20),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  PaymentHistorySummaryBanner(
                    totalSpent: state.totalSpent,
                    count: state.payments.length,
                  ),
                  const SizedBox(height: 14),
                  ConstrainedBox(
                    constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.55),
                    child: state.isLoading
                        ? const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator(color: AppColors.primary)))
                        : state.payments.isEmpty
                            ? Padding(
                                padding: const EdgeInsets.all(24),
                                child: Center(
                                  child: Text('No payment records found', style: TextStyle(color: colors.textMuted, fontSize: 13)),
                                ),
                              )
                            : ListView.builder(
                                shrinkWrap: true,
                                itemCount: state.payments.length,
                                itemBuilder: (ctx, idx) => PaymentHistoryItemTile(payment: state.payments[idx]),
                              ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
