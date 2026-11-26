import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NotificationHeroBanner extends StatelessWidget {
  final int totalCount;
  final int unreadCount;
  final int queueAndBookingCount;
  final bool pushEnabled;
  final VoidCallback onEnablePushTap;

  const NotificationHeroBanner({
    super.key,
    required this.totalCount,
    required this.unreadCount,
    required this.queueAndBookingCount,
    required this.pushEnabled,
    required this.onEnablePushTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E3A8A), Color(0xFF2563EB), Color(0xFF0891B2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2563EB).withValues(alpha: 0.28),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.notifications_active_rounded, size: 13, color: Colors.white),
                    const SizedBox(width: 5),
                    Text(
                      'Live Push & Status Alerts',
                      style: GoogleFonts.inter(fontSize: 10.5, fontWeight: FontWeight.w700, color: Colors.white),
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: pushEnabled ? null : onEnablePushTap,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                    color: (pushEnabled ? const Color(0xFF10B981) : const Color(0xFFF59E0B)).withValues(alpha: 0.26),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: (pushEnabled ? const Color(0xFF34D399) : const Color(0xFFFBBF24)).withValues(alpha: 0.65),
                    ),
                  ),
                  child: Text(
                    pushEnabled ? '● Status Bar On' : 'Enable Alerts',
                    style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.22),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            ),
            child: Row(
              children: [
                Expanded(child: _kpi('UNREAD', '$unreadCount', unreadCount == 0 ? 'All caught up' : 'Needs review', const Color(0xFF93C5FD))),
                Container(width: 1, height: 36, color: Colors.white.withValues(alpha: 0.12)),
                Expanded(child: _kpi('VISITS & QUEUE', '$queueAndBookingCount', 'Active updates', const Color(0xFF6EE7B7))),
                Container(width: 1, height: 36, color: Colors.white.withValues(alpha: 0.12)),
                Expanded(child: _kpi('TOTAL FEED', '$totalCount', 'Synced live', const Color(0xFFFDE68A))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _kpi(String label, String value, String sub, Color valueColor) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(label, style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w700, color: Colors.white.withValues(alpha: 0.75), letterSpacing: 0.5)),
      const SizedBox(height: 2),
      Text(value, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w900, color: valueColor)),
      Text(sub, style: GoogleFonts.inter(fontSize: 9.5, fontWeight: FontWeight.w500, color: Colors.white.withValues(alpha: 0.72))),
    ],
  );
}
