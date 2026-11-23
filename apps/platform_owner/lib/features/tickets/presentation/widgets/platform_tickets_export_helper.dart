import 'package:flutter/material.dart';

import '../../../../core/utils/pdf_exporter.dart';
import '../../../../core/widgets/app_snack_bar.dart';
import '../../domain/entities/platform_support_ticket_entity.dart';

class PlatformTicketsExportHelper {
  static void exportPdf(
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

    PdfExporter.exportTickets(context, tickets);
  }
}
