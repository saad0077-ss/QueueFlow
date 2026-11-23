import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/widgets/app_snack_bar.dart';
import '../../domain/entities/platform_support_ticket_entity.dart';

class PlatformTicketsExportHelper {
  static void exportCsv(
    BuildContext context,
    List<PlatformSupportTicketEntity> tickets,
  ) {
    if (tickets.isEmpty) {
      AppSnackBar.showWarning(
        context,
        message: 'No tickets available to export.',
      );
      return;
    }

    final buffer = StringBuffer();
    buffer.writeln(
      'Ticket ID,Patient Name,Phone,Email,Clinic,Category,Subject,Priority,Status,Created At',
    );
    for (final t in tickets) {
      final safeSubj = t.subject.replaceAll('"', '""');
      buffer.writeln(
        '"${t.ticketNumber}","${t.patientName}","${t.patientPhone}","${t.patientEmail}","${t.clinicName}","${t.category}","$safeSubj","${t.priority}","${t.status}","${t.createdAt}"',
      );
    }

    Clipboard.setData(ClipboardData(text: buffer.toString()));
    AppSnackBar.showSuccess(
      context,
      message: 'Exported ${tickets.length} tickets! CSV copied to clipboard.',
    );
  }
}
