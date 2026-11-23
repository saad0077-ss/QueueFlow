import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PlatformTicketsMatrixColumns {
  static List<DataColumn> getColumns() {
    return [
      _colHeader('Ticket ID'),
      _colHeader('Clinic'),
      _colHeader('Patient'),
      _colHeader('Category'),
      _colHeader('Subject & Issue'),
      _colHeader('Priority'),
      _colHeader('SLA Timer'),
      _colHeader('Status'),
      _colHeader('Actions', alignRight: true),
    ];
  }

  static DataColumn _colHeader(String title, {bool alignRight = false}) {
    return DataColumn(
      label: alignRight
          ? Expanded(
              child: Text(
                title,
                textAlign: TextAlign.right,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.3,
                ),
              ),
            )
          : Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.3,
              ),
            ),
    );
  }
}
