import 'package:equatable/equatable.dart';
import 'platform_invoice_entity.dart';
import 'platform_tenant_subscription_entity.dart';

class PlatformBillingKpis extends Equatable {
  final String totalMrr;
  final String mrrTrend;
  final int activeSubscriptions;
  final String retentionRate;
  final int overdueCount;
  final String overdueAmount;
  final String arpu;
  final String churnRate;
  final String collectionRate;

  const PlatformBillingKpis({
    this.totalMrr = '₹0',
    this.mrrTrend = 'Live MRR',
    this.activeSubscriptions = 0,
    this.retentionRate = '100% Active',
    this.overdueCount = 0,
    this.overdueAmount = '₹0 pending',
    this.arpu = '₹0',
    this.churnRate = '0.0% Churn',
    this.collectionRate = '100% On Time',
  });

  factory PlatformBillingKpis.compute({
    required List<PlatformTenantSubscriptionEntity> subscriptions,
    required List<PlatformInvoiceEntity> invoices,
  }) {
    final activeSubs = subscriptions.where((s) => s.isActive).toList();
    final activeCount = activeSubs.length;
    final totalCount = subscriptions.length;

    // Calculate MRR
    int totalMrrInt = 0;
    for (final s in activeSubs) {
      final pid = s.planId.toLowerCase();
      int rate;
      if (pid == 'unlimited' || pid == 'enterprise') {
        rate = 6999;
      } else if (pid == 'multi') {
        rate = 2999;
      } else {
        rate = 999;
      }
      final digits = s.mrrAmount.replaceAll(RegExp(r'[^0-9]'), '');
      if (digits.isNotEmpty) {
        final parsed = int.tryParse(digits);
        if (parsed != null && parsed > 0) {
          rate = parsed;
        }
      }
      totalMrrInt += rate;
    }

    // Pending / overdue invoices
    final pendingInvoices = invoices.where((i) {
      final st = i.status.toLowerCase();
      return st == 'pending' || st == 'overdue' || st == 'unpaid';
    }).toList();

    int pendingTotal = 0;
    for (final inv in pendingInvoices) {
      final digits = inv.amount.replaceAll(RegExp(r'[^0-9]'), '');
      pendingTotal += int.tryParse(digits) ?? 0;
    }

    final overdueCount = pendingInvoices.length;
    final overdueAmount = '₹${_formatNum(pendingTotal)} pending';

    // ARPU & Churn
    final arpuInt = activeCount > 0 ? (totalMrrInt / activeCount).round() : 0;
    final churn = totalCount > 0 ? (((totalCount - activeCount) / totalCount) * 100) : 0.0;
    final retentionPct = totalCount > 0 ? ((activeCount / totalCount) * 100).round() : 100;

    return PlatformBillingKpis(
      totalMrr: '₹${_formatNum(totalMrrInt)}',
      mrrTrend: totalMrrInt > 0 ? '₹${_formatNum(totalMrrInt * 12)} ARR' : 'Live MRR',
      activeSubscriptions: activeCount,
      retentionRate: '$retentionPct% Active',
      overdueCount: overdueCount,
      overdueAmount: overdueAmount,
      arpu: '₹${_formatNum(arpuInt)}',
      churnRate: '${churn.toStringAsFixed(1)}% Churn',
      collectionRate: '100% On Time',
    );
  }

  static String _formatNum(num n) {
    final str = n.round().toString();
    if (str.length <= 3) return str;
    final lastThree = str.substring(str.length - 3);
    var rest = str.substring(0, str.length - 3);
    final buffer = StringBuffer();
    while (rest.length > 2) {
      buffer.write(',${rest.substring(rest.length - 2)}');
      rest = rest.substring(0, rest.length - 2);
    }
    return '$rest$buffer,$lastThree';
  }

  @override
  List<Object?> get props => [
    totalMrr,
    mrrTrend,
    activeSubscriptions,
    retentionRate,
    overdueCount,
    overdueAmount,
    arpu,
    churnRate,
    collectionRate,
  ];
}
