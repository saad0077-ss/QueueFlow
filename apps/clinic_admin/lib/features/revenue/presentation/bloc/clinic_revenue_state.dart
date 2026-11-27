import 'package:equatable/equatable.dart';
import '../../domain/entities/clinic_revenue_breakdown.dart';
import '../../domain/entities/clinic_revenue_summary.dart';

/// UI state for the Clinic Revenue analytics and settlements tab.
class ClinicRevenueState extends Equatable {
  final bool isLoading;
  final ClinicRevenuePeriod period;
  final String ledgerStatusFilter;
  final String searchQuery;
  final ClinicRevenueSummary? summary;
  final String? errorMessage;

  const ClinicRevenueState({
    this.isLoading = true,
    this.period = ClinicRevenuePeriod.month,
    this.ledgerStatusFilter = 'all',
    this.searchQuery = '',
    this.summary,
    this.errorMessage,
  });

  /// Returns transactions matching [ledgerStatusFilter] and [searchQuery].
  List<RevenueLedgerEntry> get filteredLedger {
    final txns = summary?.recentTransactions ?? const [];
    final q = searchQuery.trim().toLowerCase();

    return txns.where((entry) {
      if (ledgerStatusFilter != 'all' && entry.status != ledgerStatusFilter) {
        return false;
      }
      if (q.isEmpty) return true;
      return entry.patientName.toLowerCase().contains(q) ||
          entry.receiptNo.toLowerCase().contains(q) ||
          entry.bookingId.toLowerCase().contains(q) ||
          entry.serviceName.toLowerCase().contains(q) ||
          entry.doctorName.toLowerCase().contains(q);
    }).toList();
  }

  ClinicRevenueState copyWith({
    bool? isLoading,
    ClinicRevenuePeriod? period,
    String? ledgerStatusFilter,
    String? searchQuery,
    ClinicRevenueSummary? summary,
    String? errorMessage,
    bool clearError = false,
  }) {
    return ClinicRevenueState(
      isLoading: isLoading ?? this.isLoading,
      period: period ?? this.period,
      ledgerStatusFilter: ledgerStatusFilter ?? this.ledgerStatusFilter,
      searchQuery: searchQuery ?? this.searchQuery,
      summary: summary ?? this.summary,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    period,
    ledgerStatusFilter,
    searchQuery,
    summary,
    errorMessage,
  ];
}
