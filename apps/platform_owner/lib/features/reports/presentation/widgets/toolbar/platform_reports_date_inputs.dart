import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PlatformReportsDateInputs extends StatelessWidget {
  final DateTime startDate;
  final DateTime endDate;
  final ValueChanged<DateTime> onStartDateChanged;
  final ValueChanged<DateTime> onEndDateChanged;

  const PlatformReportsDateInputs({
    super.key,
    required this.startDate,
    required this.endDate,
    required this.onStartDateChanged,
    required this.onEndDateChanged,
  });

  @override
  Widget build(BuildContext context) {
    final diff = endDate.difference(startDate).inDays + 1;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: _buildDateCard(
                label: 'START DATE (FROM)',
                date: startDate,
                onTap: () => _pickDate(context, startDate, onStartDateChanged),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Icon(Icons.arrow_forward_rounded, color: Color(0xFF64748B), size: 18),
            ),
            Expanded(
              child: _buildDateCard(
                label: 'END DATE (TO)',
                date: endDate,
                onTap: () => _pickDate(context, endDate, onEndDateChanged),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B).withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFF334155)),
          ),
          child: Row(
            children: [
              const Icon(Icons.info_outline_rounded, color: Color(0xFF06B6D4), size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Range: ${_fmt(startDate)} → ${_fmt(endDate)} ($diff days)',
                  style: GoogleFonts.inter(
                    fontSize: 11.5,
                    color: const Color(0xFF94A3B8),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDateCard({
    required String label,
    required DateTime date,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF0B0F19),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFF1E293B), width: 1.2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF64748B),
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.calendar_month_rounded, size: 15, color: Color(0xFF06B6D4)),
                const SizedBox(width: 8),
                Text(
                  _fmt(date),
                  style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDate(BuildContext context, DateTime current, ValueChanged<DateTime> onPicked) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: DateTime(2023),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (ctx, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFF06B6D4),
            surface: Color(0xFF0F172A),
            onSurface: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) onPicked(picked);
  }

  static String _fmt(DateTime d) {
    const m = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${d.day.toString().padLeft(2, '0')} ${m[d.month - 1]} ${d.year}';
  }
}
