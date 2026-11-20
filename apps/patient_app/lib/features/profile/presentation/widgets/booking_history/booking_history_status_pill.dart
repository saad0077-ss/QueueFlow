import 'package:flutter/material.dart';

class BookingHistoryStatusPill extends StatelessWidget {
  final bool isUpcoming;
  final bool isCompleted;
  final bool isCancelled;

  const BookingHistoryStatusPill({
    super.key,
    required this.isUpcoming,
    required this.isCompleted,
    required this.isCancelled,
  });

  @override
  Widget build(BuildContext context) {
    if (isUpcoming) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: const Color(0xFFEFF6FF),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: const Color(0xFFBFDBFE)),
        ),
        child: const Text(
          'UPCOMING',
          style: TextStyle(
            fontSize: 9.5,
            fontWeight: FontWeight.w800,
            color: Color(0xFF1D4ED8),
          ),
        ),
      );
    }
    if (isCancelled) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: const Color(0xFFFEF2F2),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: const Color(0xFFFECACA)),
        ),
        child: const Text(
          'CANCELLED',
          style: TextStyle(
            fontSize: 9.5,
            fontWeight: FontWeight.w800,
            color: Color(0xFFB91C1C),
          ),
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFECFDF5),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFA7F3D0)),
      ),
      child: const Text(
        '✓ COMPLETED',
        style: TextStyle(
          fontSize: 9.5,
          fontWeight: FontWeight.w800,
          color: Color(0xFF047857),
        ),
      ),
    );
  }
}
