import 'package:equatable/equatable.dart';

/// Revenue earned across a payment collection channel (e.g. Online UPI, Cash).
class RevenueChannelStat extends Equatable {
  final String label;
  final double amount;
  final int count;
  final double sharePercent;
  final bool isOnline;

  const RevenueChannelStat({
    required this.label,
    required this.amount,
    required this.count,
    required this.sharePercent,
    required this.isOnline,
  });

  @override
  List<Object?> get props => [label, amount, count, sharePercent, isOnline];
}

/// Revenue and consultation share attributed to a clinical service.
class RevenueServiceStat extends Equatable {
  final String serviceName;
  final String departmentName;
  final int visits;
  final double revenue;
  final double sharePercent;

  const RevenueServiceStat({
    required this.serviceName,
    required this.departmentName,
    required this.visits,
    required this.revenue,
    required this.sharePercent,
  });

  @override
  List<Object?> get props => [
    serviceName,
    departmentName,
    visits,
    revenue,
    sharePercent,
  ];
}

/// Revenue earned by a consulting doctor within the selected period.
class RevenueDoctorStat extends Equatable {
  final String doctorName;
  final String specialty;
  final int consultations;
  final double revenue;

  const RevenueDoctorStat({
    required this.doctorName,
    required this.specialty,
    required this.consultations,
    required this.revenue,
  });

  @override
  List<Object?> get props => [doctorName, specialty, consultations, revenue];
}

/// Time-bucket data point rendered in the revenue trend chart.
class DailyRevenuePoint extends Equatable {
  final String label;
  final double amount;
  final int count;

  const DailyRevenuePoint({
    required this.label,
    required this.amount,
    required this.count,
  });

  @override
  List<Object?> get props => [label, amount, count];
}

/// Single patient payment or settlement record shown in the ledger.
class RevenueLedgerEntry extends Equatable {
  final String id;
  final String bookingId;
  final String receiptNo;
  final String patientName;
  final String serviceName;
  final String doctorName;
  final String dateLabel;
  final String dateRaw;
  final String method;
  final String status; // 'paid', 'pending', 'refunded'
  final double grossAmount;
  final double refundAmount;
  final double netAmount;

  const RevenueLedgerEntry({
    required this.id,
    required this.bookingId,
    required this.receiptNo,
    required this.patientName,
    required this.serviceName,
    required this.doctorName,
    required this.dateLabel,
    required this.dateRaw,
    required this.method,
    required this.status,
    required this.grossAmount,
    required this.refundAmount,
    required this.netAmount,
  });

  @override
  List<Object?> get props => [
    id,
    bookingId,
    receiptNo,
    patientName,
    serviceName,
    doctorName,
    dateLabel,
    dateRaw,
    method,
    status,
    grossAmount,
    refundAmount,
    netAmount,
  ];
}
