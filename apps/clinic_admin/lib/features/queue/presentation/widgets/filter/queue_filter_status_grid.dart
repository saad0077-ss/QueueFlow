import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

class QueueFilterStatusGrid extends StatelessWidget {
  final String selectedStatus;
  final ValueChanged<String> onSelectStatus;

  const QueueFilterStatusGrid({
    super.key,
    required this.selectedStatus,
    required this.onSelectStatus,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final w = (c.maxWidth - 10) / 2;
        return Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            _StatusTile(
              width: w,
              id: 'all',
              title: 'All Queues',
              sub: 'Show all departments & services',
              isSelected: selectedStatus == 'all',
              onTap: () => onSelectStatus('all'),
            ),
            _StatusTile(
              width: w,
              id: 'waiting',
              title: 'Has Patients Waiting',
              sub: 'Only services with waiting line',
              titleColor: const Color(0xFFF59E0B),
              isSelected: selectedStatus == 'waiting',
              onTap: () => onSelectStatus('waiting'),
            ),
            _StatusTile(
              width: w,
              id: 'active',
              title: 'Active Consultations',
              sub: 'Currently serving or waiting',
              titleColor: const Color(0xFF10B981),
              isSelected: selectedStatus == 'active',
              onTap: () => onSelectStatus('active'),
            ),
            _StatusTile(
              width: w,
              id: 'idle',
              title: 'All Clear / Idle',
              sub: 'Zero patients waiting or serving',
              titleColor: const Color(0xFF0284C7),
              isSelected: selectedStatus == 'idle',
              onTap: () => onSelectStatus('idle'),
            ),
          ],
        );
      },
    );
  }
}

class _StatusTile extends StatelessWidget {
  final double width;
  final String id;
  final String title;
  final String sub;
  final Color? titleColor;
  final bool isSelected;
  final VoidCallback onTap;

  const _StatusTile({
    required this.width,
    required this.id,
    required this.title,
    required this.sub,
    this.titleColor,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return SizedBox(
      width: width,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? colors.primaryTint : colors.background,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? colors.primary : colors.border,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w800,
                  color: titleColor ?? colors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                sub,
                style: GoogleFonts.inter(
                  fontSize: 10.5,
                  color: colors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
